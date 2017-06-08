From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH net-next] net: ethernet: ti: cpdma: do not enable host error misc irq
Date: Thu, 8 Jun 2017 13:51:52 -0500
Message-ID: <20170608185152.32710-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPSW driver does not handle this interrupt, so there are no reasons to enable
it in hardware.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
no changes, just resubmitting with proper subj line.

 drivers/net/ethernet/ti/davinci_cpdma.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 7ecc6b7..e4d6edf 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -645,7 +645,7 @@ EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 {
 	unsigned long flags;
-	int i, reg;
+	int i;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->state != CPDMA_STATE_ACTIVE) {
@@ -653,9 +653,6 @@ int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 		return -EINVAL;
 	}
 
-	reg = enable ? CPDMA_DMAINTMASKSET : CPDMA_DMAINTMASKCLEAR;
-	dma_reg_write(ctlr, reg, CPDMA_DMAINT_HOSTERR);
-
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
 		if (ctlr->channels[i])
 			cpdma_chan_int_ctrl(ctlr->channels[i], enable);
-- 
2.10.1
