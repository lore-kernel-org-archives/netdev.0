From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 15/16] [CRYPTO] drivers: Remove obsolete block cipher operations
Date: Sun, 13 Aug 2006 22:20:26 +1000
Message-ID: <E1GCEx8-0004gY-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:25865 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751130AbWHMMWm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:22:42 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] drivers: Remove obsolete block cipher operations

This patch removes obsolete block operations of the simple cipher type
from drivers.  These were preserved so that existing users can make a
smooth transition.  Now that the transition is complete, they are no
longer needed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/s390/crypto/aes_s390.c  |  112 -----------------------
 arch/s390/crypto/des_s390.c  |  203 -------------------------------------------
 drivers/crypto/padlock-aes.c |   44 ---------
 3 files changed, 359 deletions(-)

diff --git a/arch/s390/crypto/aes_s390.c b/arch/s390/crypto/aes_s390.c
--- a/arch/s390/crypto/aes_s390.c
+++ b/arch/s390/crypto/aes_s390.c
@@ -113,114 +113,6 @@ static void aes_decrypt(struct crypto_tf
 	}
 }
 
-static unsigned int aes_encrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct s390_aes_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(AES_BLOCK_SIZE - 1);
-
-	switch (sctx->key_len) {
-	case 16:
-		ret = crypt_s390_km(KM_AES_128_ENCRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 24:
-		ret = crypt_s390_km(KM_AES_192_ENCRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 32:
-		ret = crypt_s390_km(KM_AES_256_ENCRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	}
-	return nbytes;
-}
-
-static unsigned int aes_decrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct s390_aes_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(AES_BLOCK_SIZE - 1);
-
-	switch (sctx->key_len) {
-	case 16:
-		ret = crypt_s390_km(KM_AES_128_DECRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 24:
-		ret = crypt_s390_km(KM_AES_192_DECRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 32:
-		ret = crypt_s390_km(KM_AES_256_DECRYPT, &sctx->key, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	}
-	return nbytes;
-}
-
-static unsigned int aes_encrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct s390_aes_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(AES_BLOCK_SIZE - 1);
-
-	memcpy(&sctx->iv, desc->info, AES_BLOCK_SIZE);
-	switch (sctx->key_len) {
-	case 16:
-		ret = crypt_s390_kmc(KMC_AES_128_ENCRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 24:
-		ret = crypt_s390_kmc(KMC_AES_192_ENCRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 32:
-		ret = crypt_s390_kmc(KMC_AES_256_ENCRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	}
-	memcpy(desc->info, &sctx->iv, AES_BLOCK_SIZE);
-
-	return nbytes;
-}
-
-static unsigned int aes_decrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct s390_aes_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(AES_BLOCK_SIZE - 1);
-
-	memcpy(&sctx->iv, desc->info, AES_BLOCK_SIZE);
-	switch (sctx->key_len) {
-	case 16:
-		ret = crypt_s390_kmc(KMC_AES_128_DECRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 24:
-		ret = crypt_s390_kmc(KMC_AES_192_DECRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	case 32:
-		ret = crypt_s390_kmc(KMC_AES_256_DECRYPT, &sctx->iv, out, in, nbytes);
-		BUG_ON((ret < 0) || (ret != nbytes));
-		break;
-	}
-	return nbytes;
-}
-
 
 static struct crypto_alg aes_alg = {
 	.cra_name		=	"aes",
@@ -238,10 +130,6 @@ static struct crypto_alg aes_alg = {
 			.cia_setkey		=	aes_set_key,
 			.cia_encrypt		=	aes_encrypt,
 			.cia_decrypt		=	aes_decrypt,
-			.cia_encrypt_ecb	=	aes_encrypt_ecb,
-			.cia_decrypt_ecb	=	aes_decrypt_ecb,
-			.cia_encrypt_cbc	=	aes_encrypt_cbc,
-			.cia_decrypt_cbc	=	aes_decrypt_cbc,
 		}
 	}
 };
diff --git a/arch/s390/crypto/des_s390.c b/arch/s390/crypto/des_s390.c
--- a/arch/s390/crypto/des_s390.c
+++ b/arch/s390/crypto/des_s390.c
@@ -73,67 +73,6 @@ static void des_decrypt(struct crypto_tf
 	crypt_s390_km(KM_DEA_DECRYPT, dctx->key, out, in, DES_BLOCK_SIZE);
 }
 
-static unsigned int des_encrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct crypt_s390_des_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_DEA_ENCRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des_decrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct crypt_s390_des_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_DEA_DECRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des_encrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct crypt_s390_des_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES_BLOCK_SIZE - 1);
-
-	memcpy(sctx->iv, desc->info, DES_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_DEA_ENCRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	memcpy(desc->info, sctx->iv, DES_BLOCK_SIZE);
-	return nbytes;
-}
-
-static unsigned int des_decrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct crypt_s390_des_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES_BLOCK_SIZE - 1);
-
-	memcpy(&sctx->iv, desc->info, DES_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_DEA_DECRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
 static struct crypto_alg des_alg = {
 	.cra_name		=	"des",
 	.cra_driver_name	=	"des-s390",
@@ -150,10 +89,6 @@ static struct crypto_alg des_alg = {
 			.cia_setkey		=	des_setkey,
 			.cia_encrypt		=	des_encrypt,
 			.cia_decrypt		=	des_decrypt,
-			.cia_encrypt_ecb	=	des_encrypt_ecb,
-			.cia_decrypt_ecb	=	des_decrypt_ecb,
-			.cia_encrypt_cbc	=	des_encrypt_cbc,
-			.cia_decrypt_cbc	=	des_decrypt_cbc,
 		}
 	}
 };
@@ -344,71 +279,6 @@ static void des3_128_decrypt(struct cryp
 		      DES3_128_BLOCK_SIZE);
 }
 
-static unsigned int des3_128_encrypt_ecb(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_128_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_128_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_TDEA_128_ENCRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des3_128_decrypt_ecb(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_128_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_128_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_TDEA_128_DECRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des3_128_encrypt_cbc(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_128_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_128_BLOCK_SIZE - 1);
-
-	memcpy(sctx->iv, desc->info, DES3_128_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_TDEA_128_ENCRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	memcpy(desc->info, sctx->iv, DES3_128_BLOCK_SIZE);
-	return nbytes;
-}
-
-static unsigned int des3_128_decrypt_cbc(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_128_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_128_BLOCK_SIZE - 1);
-
-	memcpy(&sctx->iv, desc->info, DES3_128_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_TDEA_128_DECRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
 static struct crypto_alg des3_128_alg = {
 	.cra_name		=	"des3_ede128",
 	.cra_driver_name	=	"des3_ede128-s390",
@@ -425,10 +295,6 @@ static struct crypto_alg des3_128_alg = 
 			.cia_setkey		=	des3_128_setkey,
 			.cia_encrypt		=	des3_128_encrypt,
 			.cia_decrypt		=	des3_128_decrypt,
-			.cia_encrypt_ecb	=	des3_128_encrypt_ecb,
-			.cia_decrypt_ecb	=	des3_128_decrypt_ecb,
-			.cia_encrypt_cbc	=	des3_128_encrypt_cbc,
-			.cia_decrypt_cbc	=	des3_128_decrypt_cbc,
 		}
 	}
 };
@@ -575,71 +441,6 @@ static void des3_192_decrypt(struct cryp
 		      DES3_192_BLOCK_SIZE);
 }
 
-static unsigned int des3_192_encrypt_ecb(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_192_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_192_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_TDEA_192_ENCRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des3_192_decrypt_ecb(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_192_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_192_BLOCK_SIZE - 1);
-	ret = crypt_s390_km(KM_TDEA_192_DECRYPT, sctx->key, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
-static unsigned int des3_192_encrypt_cbc(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_192_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_192_BLOCK_SIZE - 1);
-
-	memcpy(sctx->iv, desc->info, DES3_192_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_TDEA_192_ENCRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	memcpy(desc->info, sctx->iv, DES3_192_BLOCK_SIZE);
-	return nbytes;
-}
-
-static unsigned int des3_192_decrypt_cbc(const struct cipher_desc *desc,
-					 u8 *out, const u8 *in,
-					 unsigned int nbytes)
-{
-	struct crypt_s390_des3_192_ctx *sctx = crypto_tfm_ctx(desc->tfm);
-	int ret;
-
-	/* only use complete blocks */
-	nbytes &= ~(DES3_192_BLOCK_SIZE - 1);
-
-	memcpy(&sctx->iv, desc->info, DES3_192_BLOCK_SIZE);
-	ret = crypt_s390_kmc(KMC_TDEA_192_DECRYPT, &sctx->iv, out, in, nbytes);
-	BUG_ON((ret < 0) || (ret != nbytes));
-
-	return nbytes;
-}
-
 static struct crypto_alg des3_192_alg = {
 	.cra_name		=	"des3_ede",
 	.cra_driver_name	=	"des3_ede-s390",
@@ -656,10 +457,6 @@ static struct crypto_alg des3_192_alg = 
 			.cia_setkey		=	des3_192_setkey,
 			.cia_encrypt		=	des3_192_encrypt,
 			.cia_decrypt		=	des3_192_decrypt,
-			.cia_encrypt_ecb	=	des3_192_encrypt_ecb,
-			.cia_decrypt_ecb	=	des3_192_decrypt_ecb,
-			.cia_encrypt_cbc	=	des3_192_encrypt_cbc,
-			.cia_decrypt_cbc	=	des3_192_decrypt_cbc,
 		}
 	}
 };
diff --git a/drivers/crypto/padlock-aes.c b/drivers/crypto/padlock-aes.c
--- a/drivers/crypto/padlock-aes.c
+++ b/drivers/crypto/padlock-aes.c
@@ -452,46 +452,6 @@ static void aes_decrypt(struct crypto_tf
 	padlock_xcrypt_ecb(in, out, ctx->D, &ctx->cword.decrypt, 1);
 }
 
-static unsigned int aes_encrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct aes_ctx *ctx = aes_ctx(desc->tfm);
-	padlock_xcrypt_ecb(in, out, ctx->E, &ctx->cword.encrypt,
-			   nbytes / AES_BLOCK_SIZE);
-	return nbytes & ~(AES_BLOCK_SIZE - 1);
-}
-
-static unsigned int aes_decrypt_ecb(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct aes_ctx *ctx = aes_ctx(desc->tfm);
-	padlock_xcrypt_ecb(in, out, ctx->D, &ctx->cword.decrypt,
-			   nbytes / AES_BLOCK_SIZE);
-	return nbytes & ~(AES_BLOCK_SIZE - 1);
-}
-
-static unsigned int aes_encrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct aes_ctx *ctx = aes_ctx(desc->tfm);
-	u8 *iv;
-
-	iv = padlock_xcrypt_cbc(in, out, ctx->E, desc->info,
-				&ctx->cword.encrypt, nbytes / AES_BLOCK_SIZE);
-	memcpy(desc->info, iv, AES_BLOCK_SIZE);
-
-	return nbytes & ~(AES_BLOCK_SIZE - 1);
-}
-
-static unsigned int aes_decrypt_cbc(const struct cipher_desc *desc, u8 *out,
-				    const u8 *in, unsigned int nbytes)
-{
-	struct aes_ctx *ctx = aes_ctx(desc->tfm);
-	padlock_xcrypt_cbc(in, out, ctx->D, desc->info, &ctx->cword.decrypt,
-			   nbytes / AES_BLOCK_SIZE);
-	return nbytes & ~(AES_BLOCK_SIZE - 1);
-}
-
 static struct crypto_alg aes_alg = {
 	.cra_name		=	"aes",
 	.cra_driver_name	=	"aes-padlock",
@@ -509,10 +469,6 @@ static struct crypto_alg aes_alg = {
 			.cia_setkey	   	= 	aes_set_key,
 			.cia_encrypt	 	=	aes_encrypt,
 			.cia_decrypt	  	=	aes_decrypt,
-			.cia_encrypt_ecb 	=	aes_encrypt_ecb,
-			.cia_decrypt_ecb  	=	aes_decrypt_ecb,
-			.cia_encrypt_cbc 	=	aes_encrypt_cbc,
-			.cia_decrypt_cbc  	=	aes_decrypt_cbc,
 		}
 	}
 };
