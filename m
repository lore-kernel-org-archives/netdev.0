From: Cyril Roelandt <tipecaml@gmail.com>
Subject: [PATCH] net: ethernet: ti: remove redundant NULL check.
Date: Tue, 12 Feb 2013 23:52:30 +0100
Message-ID: <1360709550-821-1-git-send-email-tipecaml@gmail.com>
References: <20130212.170650.89534546100043269.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	mugunthanvnm@ti.com, zonque@gmail.com, hotforest@gmail.com,
	Julia.Lawall@lip6.fr, netdev@vger.kernel.org,
	Cyril Roelandt <tipecaml@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130212.170650.89534546100043269.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cpdma_chan_destroy() on a NULL pointer is a no-op, so the NULL check in
cpdma_ctlr_destroy() can safely be removed.

Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index f862918..1c4b0aa 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -449,10 +449,8 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 	if (ctlr->state != CPDMA_STATE_IDLE)
 		cpdma_ctlr_stop(ctlr);
 
-	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
-		if (ctlr->channels[i])
-			cpdma_chan_destroy(ctlr->channels[i]);
-	}
+	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++)
+		cpdma_chan_destroy(ctlr->channels[i]);
 
 	cpdma_desc_pool_destroy(ctlr->pool);
 	spin_unlock_irqrestore(&ctlr->lock, flags);
-- 
1.7.10.4
