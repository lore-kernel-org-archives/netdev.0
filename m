From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 2/7] crypto:chelsio: Check error code with IS_ERR macro
Date: Tue,  3 Oct 2017 12:16:25 +0530
Message-ID: <5bcbee612af4f7413a8785c3aa52e5febc130df5.1507010612.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
In-Reply-To: <cover.1507010612.git.harsh@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check and return proper error code.

Signed-off-by: Harsh Jain <harsh@chelsio.com>
---
 drivers/crypto/chelsio/chcr_algo.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index bdb1014..e4bf32d 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -1455,8 +1455,8 @@ static int chcr_ahash_update(struct ahash_request *req)
 	req_ctx->result = 0;
 	req_ctx->data_len += params.sg_len + params.bfr_len;
 	skb = create_hash_wr(req, &params);
-	if (!skb)
-		return -ENOMEM;
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 
 	if (remainder) {
 		u8 *temp;
@@ -1519,8 +1519,8 @@ static int chcr_ahash_final(struct ahash_request *req)
 		params.more = 0;
 	}
 	skb = create_hash_wr(req, &params);
-	if (!skb)
-		return -ENOMEM;
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 
 	skb->dev = u_ctx->lldi.ports[0];
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
@@ -1570,8 +1570,8 @@ static int chcr_ahash_finup(struct ahash_request *req)
 	}
 
 	skb = create_hash_wr(req, &params);
-	if (!skb)
-		return -ENOMEM;
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 
 	skb->dev = u_ctx->lldi.ports[0];
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
@@ -1621,8 +1621,8 @@ static int chcr_ahash_digest(struct ahash_request *req)
 	}
 
 	skb = create_hash_wr(req, &params);
-	if (!skb)
-		return -ENOMEM;
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
 
 	skb->dev = u_ctx->lldi.ports[0];
 	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_qidx);
-- 
2.1.4
