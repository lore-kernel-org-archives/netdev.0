From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 8/8] crypto:chcr-Fix Smatch Complaint
Date: Fri, 27 Jan 2017 16:09:12 +0530
Message-ID: <282aaa4d9d726ecfde639ad24e2bb8479a94e1dd.1485501429.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        hariprasad@chelsio.com, netdev@vger.kernel.org, arjun@chelsio.com,
        atul.gupta@chelsio.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
References: <cover.1485501428.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialise variable after null check.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
 mode change 100644 => 100755 drivers/crypto/chelsio/chcr_algo.c

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
old mode 100644
new mode 100755
index 21fc04c..41bc7f4
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -2456,13 +2456,14 @@ static int chcr_aead_op(struct aead_request *req,
 {
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
 	struct chcr_context *ctx = crypto_aead_ctx(tfm);
-	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct uld_ctx *u_ctx;
 	struct sk_buff *skb;
 
-	if (ctx && !ctx->dev) {
+	if (!ctx->dev) {
 		pr_err("chcr : %s : No crypto device.\n", __func__);
 		return -ENXIO;
 	}
+	u_ctx = ULD_CTX(ctx);
 	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0],
 				   ctx->tx_channel_id)) {
 		if (!(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
-- 
1.8.2.3
