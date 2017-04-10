From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 1/4] chcr: Increase priority of AEAD algos.
Date: Mon, 10 Apr 2017 18:23:58 +0530
Message-ID: <98a557c2312d78636f2050702f3f2ee8daaa3e00.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, atul.gupta@chelsio.com,
        ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:53016 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753622AbdDJMxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:53:25 -0400
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
References: <cover.1491807106.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

templates(gcm,ccm etc) inherit priority value of driver to
calculate its priority. In some cases template priority becomes
 more than driver priority for same algo.
Without this patch we will not be able to use driver authenc algos. It will
be good if it pushed in stable kernel.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c   |   12 ++++++++++--
 drivers/crypto/chelsio/chcr_crypto.h |    4 ++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 41bc7f4..7d59591 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -2673,6 +2673,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_name = "gcm(aes)",
 				.cra_driver_name = "gcm-aes-chcr",
 				.cra_blocksize	= 1,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_gcm_ctx),
@@ -2691,6 +2692,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_name = "rfc4106(gcm(aes))",
 				.cra_driver_name = "rfc4106-gcm-aes-chcr",
 				.cra_blocksize	 = 1,
+				.cra_priority = CHCR_AEAD_PRIORITY + 1,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_gcm_ctx),
@@ -2710,6 +2712,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_name = "ccm(aes)",
 				.cra_driver_name = "ccm-aes-chcr",
 				.cra_blocksize	 = 1,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx),
 
@@ -2728,6 +2731,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_name = "rfc4309(ccm(aes))",
 				.cra_driver_name = "rfc4309-ccm-aes-chcr",
 				.cra_blocksize	 = 1,
+				.cra_priority = CHCR_AEAD_PRIORITY + 1,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx),
 
@@ -2747,6 +2751,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-hmac-sha1-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2768,6 +2773,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-hmac-sha256-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2788,6 +2794,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-hmac-sha224-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2807,6 +2814,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-hmac-sha384-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2827,6 +2835,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-hmac-sha512-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2847,6 +2856,7 @@ static int chcr_aead_op(struct aead_request *req,
 				.cra_driver_name =
 					"authenc-digest_null-cbc-aes-chcr",
 				.cra_blocksize	 = AES_BLOCK_SIZE,
+				.cra_priority = CHCR_AEAD_PRIORITY,
 				.cra_ctxsize =	sizeof(struct chcr_context) +
 						sizeof(struct chcr_aead_ctx) +
 						sizeof(struct chcr_authenc_ctx),
@@ -2915,8 +2925,6 @@ static int chcr_register_alg(void)
 			name = driver_algs[i].alg.crypto.cra_driver_name;
 			break;
 		case CRYPTO_ALG_TYPE_AEAD:
-			driver_algs[i].alg.aead.base.cra_priority =
-				CHCR_CRA_PRIORITY;
 			driver_algs[i].alg.aead.base.cra_flags =
 				CRYPTO_ALG_TYPE_AEAD | CRYPTO_ALG_ASYNC;
 			driver_algs[i].alg.aead.encrypt = chcr_aead_encrypt;
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index 81cfd0b..4469fea 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -48,8 +48,8 @@
  * giving the processed data
  */
 
-#define CHCR_CRA_PRIORITY 3000
-
+#define CHCR_CRA_PRIORITY 500
+#define CHCR_AEAD_PRIORITY 6000
 #define CHCR_AES_MAX_KEY_LEN  (2 * (AES_MAX_KEY_SIZE)) /* consider xts */
 #define CHCR_MAX_CRYPTO_IV_LEN 16 /* AES IV len */
 
-- 
1.7.1
