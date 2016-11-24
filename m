From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] cxgb4: leak on error path in setup_sge_txq_uld()
Date: Thu, 24 Nov 2016 14:26:49 +0300
Message-ID: <20161124112649.GM17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Freeing "txq_info->uldtxq" is a no-op.  We intended to free "txq_info".

Fixes: ab677ff4ad15 ("cxgb4: Allocate Tx queues dynamically")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

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
 
