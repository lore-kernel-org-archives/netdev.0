From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Kill redundan dst_release check in xfrm_dst_destroy
Date: Mon, 7 Mar 2005 21:16:57 +1100
Message-ID: <20050307101657.GA7486@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050214221433.GB18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here's a trivial patch to get rid of a redundant check that I added
in patch 3/4.  dst_release already checks for dst == NULL.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-8

===== net/xfrm/xfrm_policy.c 1.69 vs edited =====
--- 1.69/net/xfrm/xfrm_policy.c	2005-03-07 16:31:30 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-03-07 21:12:23 +11:00
@@ -1028,8 +1028,7 @@
 {
 	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 
-	if (xdst->route)
-		dst_release(xdst->route);
+	dst_release(xdst->route);
 
 	if (!dst->xfrm)
 		return;

--oyUTqETQ0mS9luUI--
