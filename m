From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Move xfrm4_rcv export to its site
Date: Fri, 29 Oct 2004 12:13:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029021352.GA22550@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Here is a trivial patch that moves xfrm4_rcv's export to the
site of its definition.  Currently it lives in net/xfrm which
is miles away.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/xfrm4_input.c 1.12 vs edited =====
--- 1.12/net/ipv4/xfrm4_input.c	2004-09-17 06:11:46 +10:00
+++ edited/net/ipv4/xfrm4_input.c	2004-10-29 11:56:27 +10:00
@@ -9,6 +9,7 @@
  * 	
  */
 
+#include <linux/module.h>
 #include <linux/string.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
@@ -18,6 +19,8 @@
 {
 	return xfrm4_rcv_encap(skb, 0);
 }
+
+EXPORT_SYMBOL(xfrm4_rcv);
 
 static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
 {
===== net/xfrm/xfrm_export.c 1.5 vs edited =====
--- 1.5/net/xfrm/xfrm_export.c	2004-10-26 13:23:46 +10:00
+++ edited/net/xfrm/xfrm_export.c	2004-10-29 11:55:44 +10:00
@@ -27,7 +27,6 @@
 EXPORT_SYMBOL(secpath_dup);
 EXPORT_SYMBOL(xfrm_get_acqseq);
 EXPORT_SYMBOL(xfrm_parse_spi);
-EXPORT_SYMBOL(xfrm4_rcv);
 EXPORT_SYMBOL(xfrm_register_type);
 EXPORT_SYMBOL(xfrm_unregister_type);
 EXPORT_SYMBOL(xfrm_get_type);

--k1lZvvs/B4yU6o8G--
