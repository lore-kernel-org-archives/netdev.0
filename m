From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: [PATCH] net: macb: Add better comment for RXUBR handling
Date: Wed, 13 May 2015 17:01:36 -0500
Message-ID: <1431554496-11716-1-git-send-email-nathan.sullivan@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nathan Sullivan <nathan.sullivan@ni.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:32784 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965113AbbEMWBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 18:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Describe the handler for RXUBR better with a new comment.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Reviewied-by: Josh Cartwright <joshc@ni.com>
Reviewied-by: Ben Shelton <ben.shelton@ni.com>
---
 drivers/net/ethernet/cadence/macb.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 61aa570..5f10dfc 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1037,6 +1037,12 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		 * add that if/when we get our hands on a full-blown MII PHY.
 		 */
 
+		/* There is a hardware issue under heavy load where DMA can
+		 * stop, this causes endless "used buffer descriptor read"
+		 * interrupts but it can be cleared by re-enabling RX. See
+		 * the at91 manual, section 41.3.1 or the Zynq manual
+		 * section 16.7.4 for details.
+		 */
 		if (status & MACB_BIT(RXUBR)) {
 			ctrl = macb_readl(bp, NCR);
 			macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
-- 
1.7.10.4
