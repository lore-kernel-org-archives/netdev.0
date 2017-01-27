From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 2/8] crypto:chcr- Fix key length for RFC4106
Date: Fri, 27 Jan 2017 16:09:06 +0530
Message-ID: <b3ab5708d9ac06a5bf45d8014713dfb5957524b7.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:35087 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932533AbdA0Klf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 05:41:35 -0500
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check keylen before copying salt to avoid wrap around of Integer.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index deec7c0..6c2dea3 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -2194,8 +2194,8 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
 	unsigned int ck_size;
 	int ret = 0, key_ctx_size = 0;
 
-	if (get_aead_subtype(aead) ==
-	    CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106) {
+	if (get_aead_subtype(aead) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106 &&
+	    keylen > 3) {
 		keylen -= 4;  /* nonce/salt is present in the last 4 bytes */
 		memcpy(aeadctx->salt, key + keylen, 4);
 	}
-- 
1.8.2.3
