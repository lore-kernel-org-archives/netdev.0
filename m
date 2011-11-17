From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/5] stmmac: use mdelay on timeout of sw reset
Date: Thu, 17 Nov 2011 08:57:58 +0100
Message-ID: <1321516682-32208-1-git-send-email-peppe.cavallaro@st.com>
Cc: francesco.virlinzi@st.com, srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:43931 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1KQH6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:58:11 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 183622DA
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:08 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AB79618F5
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 07:58:08 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

This patch uses an mdelay to manage the timeout on
sw reset to be independant of cpu_clk.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index da66ac5..4d5402a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -39,10 +39,11 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 15000;
+	limit = 10;
 	while (limit--) {
 		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
 			break;
+		mdelay(10);
 	}
 	if (limit < 0)
 		return -EBUSY;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 627f656..bc17fd0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -41,10 +41,11 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 	/* DMA SW reset */
 	value |= DMA_BUS_MODE_SFT_RESET;
 	writel(value, ioaddr + DMA_BUS_MODE);
-	limit = 15000;
+	limit = 10;
 	while (limit--) {
 		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
 			break;
+		mdelay(10);
 	}
 	if (limit < 0)
 		return -EBUSY;
-- 
1.7.4.4
