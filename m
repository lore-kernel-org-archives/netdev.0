From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [7/*] [IPSEC] Get metrics for xfrm_dst from top dst
Date: Wed, 16 Feb 2005 22:38:36 +1100
Message-ID: <20050216113836.GA1652@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050216103744.GA476@gondor.apana.org.au> <20050216110842.GA1024@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050216110842.GA1024@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

For the metrics other than MTU, we should also be getting it from
the top dst as opposed to the bottom dst.  With this change, the
user is able to manipulate values such as advmss for individual
hosts behind a remote IPsec gateway.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-7

===== net/ipv4/xfrm4_policy.c 1.17 vs edited =====
--- 1.17/net/ipv4/xfrm4_policy.c	2005-02-16 22:09:18 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-02-16 22:35:09 +11:00
@@ -133,7 +133,7 @@
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
 		dst_prev->trailer_len	= trailer_len;
-		memcpy(&dst_prev->metrics, &rt->u.dst.metrics, sizeof(dst_prev->metrics));
+		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
===== net/ipv6/xfrm6_policy.c 1.28 vs edited =====
--- 1.28/net/ipv6/xfrm6_policy.c	2005-02-16 22:09:18 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-02-16 22:35:15 +11:00
@@ -149,7 +149,7 @@
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
 		dst_prev->trailer_len	= trailer_len;
-		memcpy(&dst_prev->metrics, &rt->u.dst.metrics, sizeof(dst_prev->metrics));
+		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);

--pf9I7BMVVzbSWLtt--
