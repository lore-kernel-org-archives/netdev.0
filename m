From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET] Get rid of unused glbl counter in neighbour
Date: Thu, 4 Nov 2004 18:25:11 +1100
Message-ID: <20041104072511.GA29842@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch gets rid of an unused global counter in neighbour.c.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/core/neighbour.c 1.55 vs edited =====
--- 1.55/net/core/neighbour.c	2004-11-04 10:41:49 +11:00
+++ edited/net/core/neighbour.c	2004-11-04 14:47:14 +11:00
@@ -59,7 +59,6 @@
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
-static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
 static struct file_operations neigh_stat_seq_fops;
 
@@ -282,7 +281,6 @@
 	n->timer.data	  = (unsigned long)n;
 
 	NEIGH_CACHE_STAT_INC(tbl, allocs);
-	neigh_glbl_allocs++;
 	n->tbl		  = tbl;
 	atomic_set(&n->refcnt, 1);
 	n->dead		  = 1;
@@ -612,7 +610,6 @@
 
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
-	neigh_glbl_allocs--;
 	atomic_dec(&neigh->tbl->entries);
 	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
 }

--TB36FDmn/VVEgNH/--
