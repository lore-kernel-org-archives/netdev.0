From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/7] [IPSEC]: Move linux/crypto.h inclusion out of net/xfrm.h
Date: Fri, 4 Aug 2006 23:31:57 +1000
Message-ID: <20060804133157.GA12787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35077 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161124AbWHDNcE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 09:32:04 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Here is a collection of patches before I introduce the new block cipher
type.

The first patch is because I got tired of recompiling net/ipv4/route.o
whenever I change crypto.h :)

[IPSEC]: Move linux/crypto.h inclusion out of net/xfrm.h

The header file linux/crypto.h is only needed by a few files so including
it in net/xfrm.h (which is included by half of the networking stack) is a
waste.  This patch moves it out of net/xfrm.h and into the specific header
files that actually need it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ah.h b/include/net/ah.h
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -1,6 +1,7 @@
 #ifndef _NET_AH_H
 #define _NET_AH_H
 
+#include <linux/crypto.h>
 #include <net/xfrm.h>
 
 /* This is the maximum truncated ICV length that we know of. */
diff --git a/include/net/esp.h b/include/net/esp.h
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -1,6 +1,7 @@
 #ifndef _NET_ESP_H
 #define _NET_ESP_H
 
+#include <linux/crypto.h>
 #include <net/xfrm.h>
 #include <asm/scatterlist.h>
 
diff --git a/include/net/ipcomp.h b/include/net/ipcomp.h
--- a/include/net/ipcomp.h
+++ b/include/net/ipcomp.h
@@ -1,8 +1,12 @@
 #ifndef _NET_IPCOMP_H
 #define _NET_IPCOMP_H
 
+#include <linux/types.h>
+
 #define IPCOMP_SCRATCH_SIZE     65400
 
+struct crypto_tfm;
+
 struct ipcomp_data {
 	u16 threshold;
 	struct crypto_tfm **tfms;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -8,7 +8,6 @@
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
-#include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
 #include <linux/in6.h>
 #include <linux/mutex.h>
@@ -986,6 +985,7 @@ extern struct xfrm_algo_desc *xfrm_ealg_
 extern struct xfrm_algo_desc *xfrm_calg_get_byname(char *name, int probe);
 
 struct crypto_tfm;
+struct scatterlist;
 typedef void (icv_update_fn_t)(struct crypto_tfm *, struct scatterlist *, unsigned int);
 
 extern void skb_icv_walk(const struct sk_buff *skb, struct crypto_tfm *tfm,
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -10,6 +10,7 @@
  *
  */
 
+#include <linux/crypto.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
