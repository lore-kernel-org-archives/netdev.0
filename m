From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH v2 1/3] net/macb: clear tx/rx completion flags in ISR
Date: Thu, 28 Mar 2013 10:07:05 +0100
Message-ID: <1364461627-26521-2-git-send-email-s.trumtrar@pengutronix.de>
References: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Steffen Trumtrar <s.trumtrar@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37634 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab3C1JHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:07:22 -0400
In-Reply-To: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
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
