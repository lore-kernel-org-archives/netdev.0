From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ah: use crypto_memneq to check the ICV
Date: Wed,  3 May 2017 16:57:57 +0200
Message-ID: <c53afb48648b2727f6272053f6100c8db3ec6486.1493741168.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753547AbdECO6E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 10:58:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/ipv4/ah4.c | 5 +++--
 net/ipv6/ah6.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 22377c8ff14b..207350b30f88 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -1,5 +1,6 @@
 #define pr_fmt(fmt) "IPsec: " fmt
 
+#include <crypto/algapi.h>
 #include <crypto/hash.h>
 #include <linux/err.h>
 #include <linux/module.h>
@@ -277,7 +278,7 @@ static void ah_input_done(struct crypto_async_request *base, int err)
 	auth_data = ah_tmp_auth(work_iph, ihl);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = crypto_memneq(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out;
 
@@ -413,7 +414,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_free;
 	}
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = crypto_memneq(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out_free;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index dda6035e3b84..ac747b13a8dc 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -25,6 +25,7 @@
 
 #define pr_fmt(fmt) "IPv6: " fmt
 
+#include <crypto/algapi.h>
 #include <crypto/hash.h>
 #include <linux/module.h>
 #include <linux/slab.h>
@@ -481,7 +482,7 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	auth_data = ah_tmp_auth(work_iph, hdr_len);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
+	err = crypto_memneq(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out;
 
@@ -627,7 +628,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_free;
 	}
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
+	err = crypto_memneq(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out_free;
 
-- 
2.12.2
