From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v2 7/7] crypto:chelsio: Fix memory leak
Date: Sun,  8 Oct 2017 13:37:24 +0530
Message-ID: <3854cc62059923e5f10b64418d16f47886056249.1507449374.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52910 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdJHIHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 04:07:55 -0400
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
In-Reply-To: <cover.1507449374.git.harsh@chelsio.com>
References: <cover.1507449374.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory leak when device does not support crypto.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_core.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index b6dd9cb..4f677b3 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -154,15 +154,15 @@ static void *chcr_uld_add(const struct cxgb4_lld_info *lld)
 	struct uld_ctx *u_ctx;
 
 	/* Create the device and add it in the device list */
+	if (!(lld->ulp_crypto & ULP_CRYPTO_LOOKASIDE))
+		return ERR_PTR(-EOPNOTSUPP);
+
+	/* Create the device and add it in the device list */
 	u_ctx = kzalloc(sizeof(*u_ctx), GFP_KERNEL);
 	if (!u_ctx) {
 		u_ctx = ERR_PTR(-ENOMEM);
 		goto out;
 	}
-	if (!(lld->ulp_crypto & ULP_CRYPTO_LOOKASIDE)) {
-		u_ctx = ERR_PTR(-ENOMEM);
-		goto out;
-	}
 	u_ctx->lldi = *lld;
 out:
 	return u_ctx;
-- 
2.1.4
