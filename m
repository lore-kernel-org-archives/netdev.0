From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: fixed dma lib build when turn-on the debug option
Date: Fri, 18 Feb 2011 11:21:29 +0100
Message-ID: <1298024489-20041-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:42660 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752519Ab1BRKVt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 05:21:49 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 425CF1E4
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 10:21:39 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas1.st.com [10.75.90.14])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 160C92C7E
	for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 10:21:39 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a compilation error when build the
dwmac_lib with the DEBUG option enabled.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/dwmac_lib.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/stmmac/dwmac_lib.c
index d65fab1..e250935 100644
--- a/drivers/net/stmmac/dwmac_lib.c
+++ b/drivers/net/stmmac/dwmac_lib.c
@@ -26,9 +26,9 @@
 
 #undef DWMAC_DMA_DEBUG
 #ifdef DWMAC_DMA_DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
+#define DWMAC_LIB_DBG(fmt, args...)  printk(fmt, ## args)
 #else
-#define DBG(fmt, args...)  do { } while (0)
+#define DWMAC_LIB_DBG(fmt, args...)  do { } while (0)
 #endif
 
 /* CSR1 enables the transmit DMA to check for new descriptor */
@@ -152,7 +152,7 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* read the status register (CSR5) */
 	u32 intr_status = readl(ioaddr + DMA_STATUS);
 
-	DBG(INFO, "%s: [CSR5: 0x%08x]\n", __func__, intr_status);
+	DWMAC_LIB_DBG(KERN_INFO "%s: [CSR5: 0x%08x]\n", __func__, intr_status);
 #ifdef DWMAC_DMA_DEBUG
 	/* It displays the DMA process states (CSR5 register) */
 	show_tx_process_state(intr_status);
@@ -160,43 +160,43 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 #endif
 	/* ABNORMAL interrupts */
 	if (unlikely(intr_status & DMA_STATUS_AIS)) {
-		DBG(INFO, "CSR5[15] DMA ABNORMAL IRQ: ");
+		DWMAC_LIB_DBG(KERN_INFO "CSR5[15] DMA ABNORMAL IRQ: ");
 		if (unlikely(intr_status & DMA_STATUS_UNF)) {
-			DBG(INFO, "transmit underflow\n");
+			DWMAC_LIB_DBG(KERN_INFO "transmit underflow\n");
 			ret = tx_hard_error_bump_tc;
 			x->tx_undeflow_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_TJT)) {
-			DBG(INFO, "transmit jabber\n");
+			DWMAC_LIB_DBG(KERN_INFO "transmit jabber\n");
 			x->tx_jabber_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_OVF)) {
-			DBG(INFO, "recv overflow\n");
+			DWMAC_LIB_DBG(KERN_INFO "recv overflow\n");
 			x->rx_overflow_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_RU)) {
-			DBG(INFO, "receive buffer unavailable\n");
+			DWMAC_LIB_DBG(KERN_INFO "receive buffer unavailable\n");
 			x->rx_buf_unav_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_RPS)) {
-			DBG(INFO, "receive process stopped\n");
+			DWMAC_LIB_DBG(KERN_INFO "receive process stopped\n");
 			x->rx_process_stopped_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_RWT)) {
-			DBG(INFO, "receive watchdog\n");
+			DWMAC_LIB_DBG(KERN_INFO "receive watchdog\n");
 			x->rx_watchdog_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_ETI)) {
-			DBG(INFO, "transmit early interrupt\n");
+			DWMAC_LIB_DBG(KERN_INFO "transmit early interrupt\n");
 			x->tx_early_irq++;
 		}
 		if (unlikely(intr_status & DMA_STATUS_TPS)) {
-			DBG(INFO, "transmit process stopped\n");
+			DWMAC_LIB_DBG(KERN_INFO "transmit process stopped\n");
 			x->tx_process_stopped_irq++;
 			ret = tx_hard_error;
 		}
 		if (unlikely(intr_status & DMA_STATUS_FBI)) {
-			DBG(INFO, "fatal bus error\n");
+			DWMAC_LIB_DBG(KERN_INFO "fatal bus error\n");
 			x->fatal_bus_error_irq++;
 			ret = tx_hard_error;
 		}
@@ -215,7 +215,7 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* Clear the interrupt by writing a logic 1 to the CSR5[15-0] */
 	writel((intr_status & 0x1ffff), ioaddr + DMA_STATUS);
 
-	DBG(INFO, "\n\n");
+	DWMAC_LIB_DBG(KERN_INFO "\n\n");
 	return ret;
 }
 
-- 
1.7.4
