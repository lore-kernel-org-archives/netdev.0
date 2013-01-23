From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/8] crypto: aesni-intel - remove rfc3686(ctr(aes)), utilize rfc3686 from ctr-module instead
Date: Wed, 23 Jan 2013 09:19:00 +0100
Message-ID: <1358929144-17806-5-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50731 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754127Ab3AWITb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:31 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

rfc3686 in CTR module is now able of using asynchronous ctr(aes) from
aesni-intel, so rfc3686(ctr(aes)) in aesni-intel is no longer needed.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 arch/x86/crypto/aesni-intel_glue.c |   37 ------------------------------------
 1 file changed, 37 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_glue.c b/arch/x86/crypto/aesni-intel_glue.c
index 1b9c22b..a0795da 100644
--- a/arch/x86/crypto/aesni-intel_glue.c
+++ b/arch/x86/crypto/aesni-intel_glue.c
@@ -40,10 +40,6 @@
 #include <linux/workqueue.h>
 #include <linux/spinlock.h>
 
-#if defined(CONFIG_CRYPTO_CTR) || defined(CONFIG_CRYPTO_CTR_MODULE)
-#define HAS_CTR
-#endif
-
 #if defined(CONFIG_CRYPTO_PCBC) || defined(CONFIG_CRYPTO_PCBC_MODULE)
 #define HAS_PCBC
 #endif
@@ -395,12 +391,6 @@ static int ablk_ctr_init(struct crypto_tfm *tfm)
 	return ablk_init_common(tfm, "__driver-ctr-aes-aesni");
 }
 
-#ifdef HAS_CTR
-static int ablk_rfc3686_ctr_init(struct crypto_tfm *tfm)
-{
-	return ablk_init_common(tfm, "rfc3686(__driver-ctr-aes-aesni)");
-}
-#endif
 #endif
 
 #ifdef HAS_PCBC
@@ -1158,33 +1148,6 @@ static struct crypto_alg aesni_algs[] = { {
 			.maxauthsize	= 16,
 		},
 	},
-#ifdef HAS_CTR
-}, {
-	.cra_name		= "rfc3686(ctr(aes))",
-	.cra_driver_name	= "rfc3686-ctr-aes-aesni",
-	.cra_priority		= 400,
-	.cra_flags		= CRYPTO_ALG_TYPE_ABLKCIPHER | CRYPTO_ALG_ASYNC,
-	.cra_blocksize		= 1,
-	.cra_ctxsize		= sizeof(struct async_helper_ctx),
-	.cra_alignmask		= 0,
-	.cra_type		= &crypto_ablkcipher_type,
-	.cra_module		= THIS_MODULE,
-	.cra_init		= ablk_rfc3686_ctr_init,
-	.cra_exit		= ablk_exit,
-	.cra_u = {
-		.ablkcipher = {
-			.min_keysize = AES_MIN_KEY_SIZE +
-				       CTR_RFC3686_NONCE_SIZE,
-			.max_keysize = AES_MAX_KEY_SIZE +
-				       CTR_RFC3686_NONCE_SIZE,
-			.ivsize	     = CTR_RFC3686_IV_SIZE,
-			.setkey	     = ablk_set_key,
-			.encrypt     = ablk_encrypt,
-			.decrypt     = ablk_decrypt,
-			.geniv	     = "seqiv",
-		},
-	},
-#endif
 #endif
 #ifdef HAS_PCBC
 }, {
-- 
1.7.9.5
