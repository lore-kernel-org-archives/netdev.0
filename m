From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH 1/3] net/macb: clear tx/rx completion flags in ISR
Date: Fri, 22 Mar 2013 18:33:33 +0100
Message-ID: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Steffen Trumtrar <s.trumtrar@pengutronix.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37966 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161064Ab3CVRdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 13:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least in the cadence IP core on the Xilinx Zynq SoC the TCOMP/RCOMP flags
are not auto-cleaned. As these flags are evaluated, they need to be cleaned.

Signed-off-by: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7903943..817835e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -485,6 +485,8 @@ static void macb_tx_interrupt(struct macb *bp)
 	status = macb_readl(bp, TSR);
 	macb_writel(bp, TSR, status);
 
+	macb_writel(bp, ISR, MACB_BIT(TCOMP));
+
 	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
 		(unsigned long)status);
 
@@ -736,6 +738,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			 * now.
 			 */
 			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+			macb_writel(bp, ISR, MACB_BIT(RCOMP));
 
 			if (napi_schedule_prep(&bp->napi)) {
 				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
-- 
1.8.2.rc2
