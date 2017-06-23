From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/6] ah: use crypto_memneq to check the ICV
Date: Fri, 23 Jun 2017 10:38:27 +0200
Message-ID: <1498207110-22520-4-git-send-email-steffen.klassert@secunet.com>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51136 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753609AbdFWIii (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:38 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ah4.c | 5 +++--
 net/ipv6/ah6.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 22377c8..207350b 100644
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
index dda6035..ac747b1 100644
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
2.7.4
