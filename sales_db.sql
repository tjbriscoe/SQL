
insert into customers(name, email, signup_date)
values('TJ briscoe', 'tjbriscoe@gmail.com', '2026-01-01'),
	('Kayla Cobain', 'kayla01@gmail.com', '2026-09-08'),
	('Lily James', 'tylily111@gmail.com', '2026-03-02'),
	('Marcus Allen', 'marcusallen@gmail.com','2026-02-14'),
	('Sofia Rivera', 'sofiarivera@gmail.com', '2026-04-22'),
	('Ethan Cole', 'ethancole@gmail.com', '2026-05-10'),
	('Ava Johnson', 'avajohnson@gmail.com', '2026-06-18'),
	('Noah Williams', 'noahwilliams@gmail.com', '2026-07-03'),
	('Mia Thompson', 'miathompson@gmail.com', '2026-08-27'),
	('Liam Brown', 'liambrown@gmail.com', '2026-09-12'),
	('Isabella Moore', 'isabellamoore@gmail.com', '2026-10-05'),
	('James Taylor', 'jamestaylor@gmail.com', '2026-11-19'),
	('Olivia Anderson', 'oliviaanderson@gmail.com', '2026-12-01'),
	('William Thomas', 'williamthomas@gmail.com', '2026-03-15'),
	('Emma Jackson', 'emmaj@gmail.com', '2026-04-09'),
	('Benjamin White', 'benwhite@gmail.com', '2026-05-25'),
	('Charlotte Harris', 'charlotteh@gmail.com', '2026-06-30'),
	('Henry Martin', 'henrymartin@gmail.com', '2026-07-21'),
	('Amelia Clark', 'ameliac@gmail.com', '2026-08-14'),
	('Lucas Lewis', 'lucaslewis@gmail.com', '2026-09-29');

insert into purchased(purchase_id,item_price, purchase_date,item_purchased,customer_rating)
values(1,19992, '2026-08-11', 'Honda Civic', 7),
	  (2,15996, '2024-02-14', 'Acura Integra', 8),
	  (3,7893, '2017-09-26', 'Nissan Altima', 6),
	  (4,8997, '2015-06-17', 'Subaru Outback', 7.5),
	  (5,7932, '2012-05-28', 'Hyundai Elantra', 6.5),
	  (6,6674, '2017-06-12', 'Nissan Sentra', 8.1),
	  (7,38542, '2016-06-28', 'Mercedes-Benz CLS',10),
	  (8,57342, '2016-09-07', 'Mercedes-Benz GLE', 8),
 	  (9,12450, '2018-03-15', 'Toyota Corolla', 7.2),
	  (10,21500, '2020-11-09', 'Mazda CX-5', 8.4),
	  (11,18475, '2019-07-21', 'Ford Fusion', 7.8),
	  (12,9450, '2014-01-30', 'Chevrolet Malibu', 6.9),
	  (13,31200, '2021-05-18', 'BMW X3', 9.1),
	  (14,8700, '2013-10-12', 'Kia Optima', 6.7),
	  (15,14600, '2018-08-03', 'Volkswagen Jetta', 7.4),
	  (16,22890, '2022-04-27', 'Toyota RAV4', 8.8),
	  (17,13420, '2016-12-14', 'Honda Accord', 7.6),
	  (18,7650, '2011-09-05', 'Ford Focus', 6.3),
	  (19,45200, '2023-06-22', 'Audi Q7', 9.5),
	  (20,19800, '2019-02-11', 'Jeep Cherokee', 7.9),
	  (21,15875, '2017-11-29', 'Hyundai Sonata', 7.1),
	  (22,27450, '2021-08-16', 'Lexus RX 350', 9.0);


alter table public.purchased 
add column credit_score INT;
add column customer_id references customers(purchase_id);

create table financing(
financing_id serial primary key,
purchase_id int,
loan_amount numeric,
interest_rate int,
term_months int,
remaining_balance int,
status varchar(20)
);

alter table financing
add column credit_score int;


update purchased 
set credit_score  =  floor(random()  * (850-300+1) + 300)
where credit_score is null;



select email, count(*)
from customers c
group by email
having count(*) > 1;

create table customers_clean as 
select distinct on(email, name) *
from customers c
order by email, name;

TRUNCATE customers restart identity;

select * from customers_clean;

insert into customers(name, email, signup_date)
select name, email, signup_date from customers_clean;


---Logic to update customers with a unique 5-digit identification number---
update customers c
set customer_id = s.new_id
from(
select ctid ,
		(10000 + (row_number() over (order by random()))) :: int as new_id 
		from customers
		) as s 
where c.ctid = s.ctid;

select * from customers;


alter table purchased 
add column customer_id int,
add constraint not null;

update purchased p
set customer_id = c.customer_id
from(
select customer_id,
row_number() over (order by customer_id) as rn
from customers
)c
where p.purchase_id = c.rn;

select p.purchase_id, p.customer_id, c.name, c.email,
from purchased p
join customers c on p.customer_id = c.customer_id;


delete from purchased 
where purchase_id not in(
select purchase_id
from purchased
order by purchase_id 
limit 20
);


select c.name,
c.email,
p.item_purchased,
p.credit_score
from customers c 
join purchased p on p.customer_id = c.customer_id;

update financing f 
set credit_score = p.credit_score
from purchased p
where f.purchase_id = p.purchase_id;
-- Logic to calculate monthly payment---
--MONTH = loan amount + interest
--		------------------------
---			  term_months

alter table financing 
add column credit_score int;

--Update financing table's credit_score column to equal to purchased credit_score--
update financing f 
set credit_score = p.credit_score
from purchased p
where f.purchase_id = p.purchase_id ;


select f.purchase_id, p.purchase_id 
from financing f
full join purchased p on f.purchase_id = p.purchase_id;

UPDATE financing f
SET credit_score = p.credit_score
FROM (
  SELECT credit_score,
         ROW_NUMBER() OVER (ORDER BY purchase_id) AS rn
  FROM purchased
) p
WHERE f.financing_id = p.rn;

SELECT 
f.financing_id,
f.remaining_balance,
f.term_months,
f.credit_score,
p.credit_score,


CASE
	    WHEN f.credit_score >= 750 THEN 0.03
        WHEN f.credit_score >= 650 THEN 0.06
        WHEN f.credit_score >= 600 THEN 0.10
        ELSE 0.15
end as interest_rate,

ROUND(
f.remaining_balance * (CASE
		WHEN f.credit_score >= 750 THEN 0.03
        WHEN f.credit_score >= 650 THEN 0.06
        WHEN f.credit_score >= 600 THEN 0.10
        ELSE 0.15
		end/12
		)
	/
	(1- POWER(1 + (CASE
		
		WHEN f.credit_score >= 750 THEN 0.03
        WHEN f.credit_score >= 650 THEN 0.06
        WHEN f.credit_score >= 600 THEN 0.10
        ELSE 0.15
		
	end/ 12), -f.term_months))
	
	, 2) AS monthly_payment
from financing f
join purchased p on f.purchase_id = p.purchase_id;

select * from financing;


