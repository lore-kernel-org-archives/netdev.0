From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Use add_timer instead of mod_timer in find_acq
Date: Mon, 24 May 2004 21:53:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524115357.GA28827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a tiny optimisation to use add_timer instead of mod_timer
on the create path in find_acq.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== xfrm4_state.c 1.7 vs edited =====
--- 1.7/net/ipv4/xfrm4_state.c	2004-05-24 21:49:33 +10:00
+++ edited/xfrm4_state.c	2004-05-24 21:41:13 +10:00
@@ -98,7 +98,8 @@
 		x0->props.family = AF_INET;
 		x0->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
 		xfrm_state_hold(x0);
-		mod_timer(&x0->timer, jiffies + XFRM_ACQ_EXPIRES*HZ);
+		x0->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm4_state_afinfo.state_bydst+h);
 		wake_up(&km_waitq);
===== xfrm6_state.c 1.9 vs edited =====
--- 1.9/net/ipv6/xfrm6_state.c	2004-05-24 21:49:33 +10:00
+++ edited/xfrm6_state.c	2004-05-24 21:51:19 +10:00
@@ -108,7 +108,8 @@
 		x0->props.reqid = reqid;
 		x0->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
 		xfrm_state_hold(x0);
-		mod_timer(&x0->timer, jiffies + XFRM_ACQ_EXPIRES*HZ);
+		x0->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+		add_timer(&x0->timer);
 		xfrm_state_hold(x0);
 		list_add_tail(&x0->bydst, xfrm6_state_afinfo.state_bydst+h);
 		wake_up(&km_waitq);

--Nq2Wo0NMKNjxTN9z--
