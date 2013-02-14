From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 6/9] net: cwdavinci_cpdma: export symbols for cpsw
Date: Thu, 14 Feb 2013 23:47:48 +0100
Message-ID: <1360882071-4072668-7-git-send-email-arnd@arndb.de>
References: <1360882071-4072668-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, arm@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360882071-4072668-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the support for ARM AM33xx in multiplatform kernels
in 3.9, an older bug appears in ARM allmodconfig:
When the cpsw driver is built as a module with cpdma
support enabled, it uses symbols that the cpdma driver
does not export.

Without this patch, building allmodconfig results in:

ERROR: "cpdma_ctlr_int_ctrl" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_control_set" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_ctlr_eoi" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 7d3bffd..8eeb7c9 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -492,11 +492,13 @@ int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_int_ctrl);
 
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr)
 {
 	dma_reg_write(ctlr, CPDMA_MACEOIVECTOR, 0);
 }
+EXPORT_SYMBOL_GPL(cpdma_ctlr_eoi);
 
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan_num,
 				     cpdma_handler_fn handler)
@@ -1028,3 +1030,4 @@ unlock_ret:
 	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cpdma_control_set);
-- 
1.8.1.2
