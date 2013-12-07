From: Srikanth Thokala <sthokal@xilinx.com>
Subject: [PATCH v2 1/2] net: emaclite: Remove unnecessary code that enables/disables interrupts on PONG buffers
Date: Sat,  7 Dec 2013 13:40:48 +0530
Message-ID: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
Cc: davem@davemloft.net, michal.simek@xilinx.com,
	Srikanth Thokala <sthokal@xilinx.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:41914 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab3LGILH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 03:11:07 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so2268777pdj.17
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 00:11:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no specific interrupts for the PONG buffer on both
transmit and receive side, same interrupt is valid for both
buffers. So, this patch removes this code.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Reviewed-by: Michal Simek <monstr@monstr.eu>
---
Changes in v2:
	rebased on v3.13.0-rc3.

 drivers/net/ethernet/xilinx/xilinx_emaclite.c |   38 -------------------------
 1 file changed, 38 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 74234a5..b2850fd 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -163,26 +163,9 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
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
@@ -206,31 +189,10 @@ static void xemaclite_disable_interrupts(struct net_local *drvdata)
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
1.7.9.5
