From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Don't panic in xfrm_user_init
Date: Thu, 28 Oct 2004 13:16:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028031640.GA14317@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Since xfrm_user can be built as a module it's best not to panic
when something goes wrong in xfrm_user_init.  Call me a wimp for
not fixing netlink_kernel_init's return value :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_user.c 1.48 vs edited =====
--- 1.48/net/xfrm/xfrm_user.c	2004-09-11 07:35:53 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-10-28 13:13:01 +10:00
@@ -1232,8 +1232,7 @@
 
 	xfrm_nl = netlink_kernel_create(NETLINK_XFRM, xfrm_netlink_rcv);
 	if (xfrm_nl == NULL)
-		panic("xfrm_user_init: cannot initialize xfrm_nl\n");
-
+		return -ENOMEM;
 
 	xfrm_register_km(&netlink_mgr);
 

--3V7upXqbjpZ4EhLz--
