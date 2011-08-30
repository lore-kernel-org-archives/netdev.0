From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/9] stmmac: remove the mmc code (v2)
Date: Tue, 30 Aug 2011 16:20:57 +0200
Message-ID: <1314714064-29101-3-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:42922 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753257Ab1H3OV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:26 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C0165BA
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:23 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7F12E2261
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:23 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DWMAC Management Counters (MMC) are not fully support.
The minimal support added in the past allowed to
only disable counters (if present) and mask their
interrupts.
This patch prepares the driver to support the MMC
removing obsolete code.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |   11 -----------
 drivers/net/stmmac/dwmac1000_core.c |    2 --
 drivers/net/stmmac/dwmac100_core.c  |   11 -----------
 drivers/net/stmmac/stmmac_main.c    |    4 ----
 4 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 375ea19..290b97a 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -130,17 +130,6 @@ enum tx_dma_irq_status {
 #define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
 #define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
 
-/* MAC Management Counters register */
-#define MMC_CONTROL		0x00000100	/* MMC Control */
-#define MMC_HIGH_INTR		0x00000104	/* MMC High Interrupt */
-#define MMC_LOW_INTR		0x00000108	/* MMC Low Interrupt */
-#define MMC_HIGH_INTR_MASK	0x0000010c	/* MMC High Interrupt Mask */
-#define MMC_LOW_INTR_MASK	0x00000110	/* MMC Low Interrupt Mask */
-
-#define MMC_CONTROL_MAX_FRM_MASK	0x0003ff8	/* Maximum Frame Size */
-#define MMC_CONTROL_MAX_FRM_SHIFT	3
-#define MMC_CONTROL_MAX_FRAME		0x7FF
-
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index eea184a..9ba9cae 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -37,8 +37,6 @@ static void dwmac1000_core_init(void __iomem *ioaddr)
 	value |= GMAC_CORE_INIT;
 	writel(value, ioaddr + GMAC_CONTROL);
 
-	/* Freeze MMC counters */
-	writel(0x8, ioaddr + GMAC_MMC_CTRL);
 	/* Mask GMAC interrupts */
 	writel(0x207, ioaddr + GMAC_INT_MASK);
 
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index 743a580..aacfc6e 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -70,17 +70,6 @@ static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 		readl(ioaddr + MAC_VLAN1));
 	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
 		readl(ioaddr + MAC_VLAN2));
-	pr_info("\n\tMAC management counter registers\n");
-	pr_info("\t MMC crtl (offset 0x%x): 0x%08x\n",
-		MMC_CONTROL, readl(ioaddr + MMC_CONTROL));
-	pr_info("\t MMC High Interrupt (offset 0x%x): 0x%08x\n",
-		MMC_HIGH_INTR, readl(ioaddr + MMC_HIGH_INTR));
-	pr_info("\t MMC Low Interrupt (offset 0x%x): 0x%08x\n",
-		MMC_LOW_INTR, readl(ioaddr + MMC_LOW_INTR));
-	pr_info("\t MMC High Interrupt Mask (offset 0x%x): 0x%08x\n",
-		MMC_HIGH_INTR_MASK, readl(ioaddr + MMC_HIGH_INTR_MASK));
-	pr_info("\t MMC Low Interrupt Mask (offset 0x%x): 0x%08x\n",
-		MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
 }
 
 static void dwmac100_irq_status(void __iomem *ioaddr)
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c6e567e..da11405 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -826,10 +826,6 @@ static int stmmac_open(struct net_device *dev)
 		pr_info("\tTX Checksum insertion supported\n");
 	netdev_update_features(dev);
 
-	/* Initialise the MMC (if present) to disable all interrupts. */
-	writel(0xffffffff, priv->ioaddr + MMC_HIGH_INTR_MASK);
-	writel(0xffffffff, priv->ioaddr + MMC_LOW_INTR_MASK);
-
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			 IRQF_SHARED, dev->name, dev);
-- 
1.7.4.4
