From: Colin King <colin.king@canonical.com>
Subject: [PATCH] cxgb4: fix memory leak on txq_info
Date: Wed, 23 Nov 2016 11:02:44 +0000
Message-ID: <20161123110244.16111-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently if txq_info->uldtxq cannot be allocated then
txq_info->txq is being kfree'd (which is redundant because it
is NULL) instead of txq_info. Fix this by instead kfree'ing
txq_info.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index 565a6c6..8098902 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -532,7 +532,7 @@ setup_sge_txq_uld(struct adapter *adap, unsigned int uld_type,
 	txq_info->uldtxq = kcalloc(txq_info->ntxq, sizeof(struct sge_uld_txq),
 				   GFP_KERNEL);
 	if (!txq_info->uldtxq) {
-		kfree(txq_info->uldtxq);
+		kfree(txq_info);
 		return -ENOMEM;
 	}
 
-- 
2.10.2
