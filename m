From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/7] [CRYPTO] api: Added asynchronous flag
Date: Fri, 4 Aug 2006 23:36:33 +1000
Message-ID: <20060804133633.GD12832@gondor.apana.org.au>
References: <20060804133157.GA12787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44805 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161152AbWHDNgg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 09:36:36 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060804133157.GA12787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[CRYPTO] api: Added asynchronous flag

This patch adds the asynchronous flag and changes all existing users to
only look up algorithms that are synchronous.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/crypto/api.c b/crypto/api.c
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -354,7 +354,7 @@ struct crypto_tfm *crypto_alloc_tfm(cons
 	do {
 		struct crypto_alg *alg;
 
-		alg = crypto_alg_mod_lookup(name, 0, 0);
+		alg = crypto_alg_mod_lookup(name, 0, CRYPTO_ALG_ASYNC);
 		err = PTR_ERR(alg);
 		if (IS_ERR(alg))
 			continue;
@@ -393,7 +393,8 @@ void crypto_free_tfm(struct crypto_tfm *
 int crypto_alg_available(const char *name, u32 flags)
 {
 	int ret = 0;
-	struct crypto_alg *alg = crypto_alg_mod_lookup(name, 0, 0);
+	struct crypto_alg *alg = crypto_alg_mod_lookup(name, 0,
+						       CRYPTO_ALG_ASYNC);
 	
 	if (!IS_ERR(alg)) {
 		crypto_mod_put(alg);
diff --git a/crypto/hmac.c b/crypto/hmac.c
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -135,7 +135,7 @@ static struct crypto_instance *crypto_hm
 	struct crypto_alg *alg;
 
 	alg = crypto_get_attr_alg(param, len, CRYPTO_ALG_TYPE_DIGEST,
-				  CRYPTO_ALG_TYPE_MASK);
+				  CRYPTO_ALG_TYPE_MASK | CRYPTO_ALG_ASYNC);
 	if (IS_ERR(alg))
 		return ERR_PTR(PTR_ERR(alg));
 
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -36,6 +36,7 @@
 #define CRYPTO_ALG_LARVAL		0x00000010
 #define CRYPTO_ALG_DEAD			0x00000020
 #define CRYPTO_ALG_DYING		0x00000040
+#define CRYPTO_ALG_ASYNC		0x00000080
 
 /*
  * Transform masks and values (for crt_flags).
