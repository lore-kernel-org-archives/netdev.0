From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Missing unlock in policy timer
Date: Fri, 23 Jul 2004 21:06:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723110626.GA31264@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is one of those cases where the cure is worse than the disease :)
I added read locks in the policy timer to close an unlikely race, but
I missed an unlock on the expire path which leads to all sort of weird
things.

I'll stay away from the timers for a while :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_policy.c 1.51 vs edited =====
--- 1.51/net/xfrm/xfrm_policy.c	2004-05-30 05:45:43 +10:00
+++ edited/net/xfrm/xfrm_policy.c	2004-07-23 21:00:52 +10:00
@@ -204,6 +204,7 @@
 	return;
 
 expired:
+	read_unlock(&xp->lock);
 	km_policy_expired(xp, dir, 1);
 	xfrm_policy_delete(xp, dir);
 	xfrm_pol_put(xp);

--EeQfGwPcQSOJBaQU--
