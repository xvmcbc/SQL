USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT upper(concat(first_name," ",last_name)) as "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
-- only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM actor WHERE first_name LIKE "%Joe%";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
-- in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name like "%LI%" ORDER BY last_name, first_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, 
-- and China:
SELECT country_id, country FROM country WHERE country IN ("Afghanistan","Bangladesh","China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB 
ALTER TABLE actor
ADD description blob;

-- 3b. Very quickly you realize that entering descriptions 
-- for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS "No. of actors with this last name" FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS count_ln FROM actor GROUP BY last_name
HAVING count_ln >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address FROM staff 
INNER JOIN address 
ON staff.address_id = address.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT p.staff_id, first_name, last_name, sum(amount) as Total_amount FROM payment p 
INNER JOIN staff s ON p.staff_id = s.staff_id
WHERE MONTH(payment_date) = 08 AND
YEAR(payment_date) = 2005
GROUP BY p.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use INNER JOIN.
SELECT title AS Film, count(actor_id) AS Number_actors FROM film_actor fa
INNER JOIN film f
ON fa.film_id = f.film_id
GROUP BY title;
 
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.film_id,f.title,COUNT(inventory_id) AS Number_copies FROM film f
INNER JOIN inventory i ON
f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible"
GROUP BY film_id;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.customer_id, c.last_name, c.first_name, SUM(p.amount) AS Total_paid FROM customer c
JOIN payment p ON
c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND film_id IN
(SELECT film_id FROM film f
JOIN language l ON f.language_id = l.language_id
WHERE f.language_id = 1)

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_id, first_name, last_name FROM actor WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id IN
(SELECT film_id FROM film WHERE title = 'Alone Trip'))

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.
SELECT cu.first_name, cu.last_name, cu.email 
FROM city ci
JOIN country co ON ci.country_id = co.country_id
JOIN address ad ON ad.city_id = ci.city_id
JOIN customer cu ON ad.address_id = cu.address_id
WHERE
co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film_id,title,description FROM film WHERE film_id IN
(SELECT film_id FROM film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.
SELECT title,COUNT(re.rental_id) AS Number_rentals FROM rental re
JOIN inventory inv ON 
re.inventory_id = inv.inventory_id
JOIN film f ON
inv.film_id = f.film_id
GROUP BY title
ORDER BY Number_rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT inv.store_id AS Store, SUM(p.amount) AS Business_amt FROM rental re
JOIN inventory inv ON 
re.inventory_id = inv.inventory_id
JOIN payment p ON
re.rental_id = p.rental_id
GROUP BY inv.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id,ci.city,co.country FROM store st
JOIN address ad ON
st.address_id = ad.address_id
JOIN city ci ON
ad.city_id = ci.city_id 
JOIN country co ON
ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT cat.name AS Genre,SUM(pa.amount) AS Gross_revenue FROM payment pa
JOIN rental re ON
pa.rental_id = re.rental_id
JOIN inventory inv ON
re.inventory_id = inv.inventory_id
JOIN film_category fc ON
inv.film_id = fc.film_id
JOIN category cat ON
fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY Gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by 
-- gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT cat.name AS Genre,SUM(pa.amount) AS Gross_revenue FROM payment pa
JOIN rental re ON
pa.rental_id = re.rental_id
JOIN inventory inv ON
re.inventory_id = inv.inventory_id
JOIN film_category fc ON
inv.film_id = fc.film_id
JOIN category cat ON
fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY Gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
