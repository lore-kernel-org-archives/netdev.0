From: Srikanth Thokala <srikanth.thokala@xilinx.com>
Subject: [PATCH 1/2] net: emaclite: Remove unnecessary code that enables/disables interrupts on PONG buffers
Date: Thu, 28 Nov 2013 12:59:56 +0530
Message-ID: <f9b49a0c-0627-432d-b6c9-faeaa7c412b8@CH1EHSMHS011.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Michal Simek <michal.simek@xilinx.com>,
	Srikanth Thokala <sthokal@xilinx.com>
To: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:18878
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750741Ab3K1Hd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 02:33:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no specific interrupts for the PONG buffer on both
transmit and receive side, same interrupt is valid for both
buffers. So, this patch removes this code.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 38 ---------------------------
 1 file changed, 38 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index a7c02f4..3a693a1 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -164,26 +164,9 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
 	__raw_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
 		     drvdata->base_addr + XEL_TSR_OFFSET);
 
-	/* Enable the Tx interrupts for the second Buffer if
-	 * configured in HW */
-	if (drvdata->tx_ping_pong != 0) {
-		reg_data = __raw_readl(drvdata->base_addr +
-				   XEL_BUFFER_OFFSET + XEL_TSR_OFFSET);
-		__raw_writel(reg_data | XEL_TSR_XMIT_IE_MASK,
-			     drvdata->base_addr + XEL_BUFFER_OFFSET +
-			     XEL_TSR_OFFSET);
-	}
-
 	/* Enable the Rx interrupts for the first buffer */
 	__raw_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr + XEL_RSR_OFFSET);
 
-	/* Enable the Rx interrupts for the second Buffer if
-	 * configured in HW */
-	if (drvdata->rx_ping_pong != 0) {
-		__raw_writel(XEL_RSR_RECV_IE_MASK, drvdata->base_addr +
-			     XEL_BUFFER_OFFSET + XEL_RSR_OFFSET);
-	}
-
 	/* Enable the Global Interrupt Enable */
 	__raw_writel(XEL_GIER_GIE_MASK, drvdata->base_addr + XEL_GIER_OFFSET);
 }
@@ -207,31 +190,10 @@ static void xemaclite_disable_interrupts(struct net_local *drvdata)
 	__raw_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
 		     drvdata->base_addr + XEL_TSR_OFFSET);
 
-	/* Disable the Tx interrupts for the second Buffer
-	 * if configured in HW */
-	if (drvdata->tx_ping_pong != 0) {
-		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
-				   XEL_TSR_OFFSET);
-		__raw_writel(reg_data & (~XEL_TSR_XMIT_IE_MASK),
-			     drvdata->base_addr + XEL_BUFFER_OFFSET +
-			     XEL_TSR_OFFSET);
-	}
-
 	/* Disable the Rx interrupts for the first buffer */
 	reg_data = __raw_readl(drvdata->base_addr + XEL_RSR_OFFSET);
 	__raw_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
 		     drvdata->base_addr + XEL_RSR_OFFSET);
-
-	/* Disable the Rx interrupts for the second buffer
-	 * if configured in HW */
-	if (drvdata->rx_ping_pong != 0) {
-
-		reg_data = __raw_readl(drvdata->base_addr + XEL_BUFFER_OFFSET +
-				   XEL_RSR_OFFSET);
-		__raw_writel(reg_data & (~XEL_RSR_RECV_IE_MASK),
-			     drvdata->base_addr + XEL_BUFFER_OFFSET +
-			     XEL_RSR_OFFSET);
-	}
 }
 
 /**
-- 
1.8.2.GIT
