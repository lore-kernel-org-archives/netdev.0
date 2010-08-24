From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/3] stmmac: make ioaddr 'void __iomem *' rather than unsigned long
Date: Tue, 24 Aug 2010 08:40:42 +0200
Message-ID: <1282632042-752-3-git-send-email-peppe.cavallaro@st.com>
References: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
 <1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:39442 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755184Ab0HXNjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 09:39:16 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E4A25FB
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:12 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4A6A726AC
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:12 +0000 (GMT)
In-Reply-To: <1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids unnecessary casting and adds the ioaddr in the
private structure.
This patch also removes many warning when compile the driver.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h         |   50 +++++++-------
 drivers/net/stmmac/dwmac1000_core.c |   18 +++---
 drivers/net/stmmac/dwmac1000_dma.c  |    8 +-
 drivers/net/stmmac/dwmac100_core.c  |   20 +++---
 drivers/net/stmmac/dwmac100_dma.c   |    8 +-
 drivers/net/stmmac/dwmac_dma.h      |   16 ++--
 drivers/net/stmmac/dwmac_lib.c      |   22 +++---
 drivers/net/stmmac/enh_desc.c       |    2 +-
 drivers/net/stmmac/norm_desc.c      |    2 +-
 drivers/net/stmmac/stmmac.h         |    3 +-
 drivers/net/stmmac/stmmac_ethtool.c |   21 +++----
 drivers/net/stmmac/stmmac_main.c    |  124 +++++++++++++++++------------------
 drivers/net/stmmac/stmmac_mdio.c    |   21 +++----
 include/linux/stmmac.h              |    2 +-
 14 files changed, 153 insertions(+), 164 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 66b9da0..e8cbcb5 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -167,7 +167,7 @@ struct stmmac_desc_ops {
 	int (*get_tx_ls) (struct dma_desc *p);
 	/* Return the transmit status looking at the TDES1 */
 	int (*tx_status) (void *data, struct stmmac_extra_stats *x,
-			  struct dma_desc *p, unsigned long ioaddr);
+			  struct dma_desc *p, void __iomem *ioaddr);
 	/* Get the buffer size from the descriptor */
 	int (*get_tx_len) (struct dma_desc *p);
 	/* Handle extra events on specific interrupts hw dependent */
@@ -182,44 +182,44 @@ struct stmmac_desc_ops {
 
 struct stmmac_dma_ops {
 	/* DMA core initialization */
-	int (*init) (unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
+	int (*init) (void __iomem *ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
 	/* Dump DMA registers */
-	void (*dump_regs) (unsigned long ioaddr);
+	void (*dump_regs) (void __iomem *ioaddr);
 	/* Set tx/rx threshold in the csr6 register
 	 * An invalid value enables the store-and-forward mode */
-	void (*dma_mode) (unsigned long ioaddr, int txmode, int rxmode);
+	void (*dma_mode) (void __iomem *ioaddr, int txmode, int rxmode);
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
-				   unsigned long ioaddr);
-	void (*enable_dma_transmission) (unsigned long ioaddr);
-	void (*enable_dma_irq) (unsigned long ioaddr);
-	void (*disable_dma_irq) (unsigned long ioaddr);
-	void (*start_tx) (unsigned long ioaddr);
-	void (*stop_tx) (unsigned long ioaddr);
-	void (*start_rx) (unsigned long ioaddr);
-	void (*stop_rx) (unsigned long ioaddr);
-	int (*dma_interrupt) (unsigned long ioaddr,
+				   void __iomem *ioaddr);
+	void (*enable_dma_transmission) (void __iomem *ioaddr);
+	void (*enable_dma_irq) (void __iomem *ioaddr);
+	void (*disable_dma_irq) (void __iomem *ioaddr);
+	void (*start_tx) (void __iomem *ioaddr);
+	void (*stop_tx) (void __iomem *ioaddr);
+	void (*start_rx) (void __iomem *ioaddr);
+	void (*stop_rx) (void __iomem *ioaddr);
+	int (*dma_interrupt) (void __iomem *ioaddr,
 			      struct stmmac_extra_stats *x);
 };
 
 struct stmmac_ops {
 	/* MAC core initialization */
-	void (*core_init) (unsigned long ioaddr) ____cacheline_aligned;
+	void (*core_init) (void __iomem *ioaddr) ____cacheline_aligned;
 	/* Dump MAC registers */
-	void (*dump_regs) (unsigned long ioaddr);
+	void (*dump_regs) (void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
-	void (*host_irq_status) (unsigned long ioaddr);
+	void (*host_irq_status) (void __iomem *ioaddr);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev);
 	/* Flow control setting */
-	void (*flow_ctrl) (unsigned long ioaddr, unsigned int duplex,
+	void (*flow_ctrl) (void __iomem *ioaddr, unsigned int duplex,
 			   unsigned int fc, unsigned int pause_time);
 	/* Set power management mode (e.g. magic frame) */
-	void (*pmt) (unsigned long ioaddr, unsigned long mode);
+	void (*pmt) (void __iomem *ioaddr, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
-	void (*set_umac_addr) (unsigned long ioaddr, unsigned char *addr,
+	void (*set_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
 			       unsigned int reg_n);
-	void (*get_umac_addr) (unsigned long ioaddr, unsigned char *addr,
+	void (*get_umac_addr) (void __iomem *ioaddr, unsigned char *addr,
 			       unsigned int reg_n);
 };
 
@@ -243,11 +243,11 @@ struct mac_device_info {
 	struct mac_link link;
 };
 
-struct mac_device_info *dwmac1000_setup(unsigned long addr);
-struct mac_device_info *dwmac100_setup(unsigned long addr);
+struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr);
+struct mac_device_info *dwmac100_setup(void __iomem *ioaddr);
 
-extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
+extern void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low);
-extern void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
+extern void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int high, unsigned int low);
-extern void dwmac_dma_flush_tx_fifo(unsigned long ioaddr);
+extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 2b2f5c8..8bbfc0f 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -30,7 +30,7 @@
 #include <linux/slab.h>
 #include "dwmac1000.h"
 
-static void dwmac1000_core_init(unsigned long ioaddr)
+static void dwmac1000_core_init(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + GMAC_CONTROL);
 	value |= GMAC_CORE_INIT;
@@ -50,7 +50,7 @@ static void dwmac1000_core_init(unsigned long ioaddr)
 #endif
 }
 
-static void dwmac1000_dump_regs(unsigned long ioaddr)
+static void dwmac1000_dump_regs(void __iomem *ioaddr)
 {
 	int i;
 	pr_info("\tDWMAC1000 regs (base addr = 0x%8x)\n", (unsigned int)ioaddr);
@@ -62,14 +62,14 @@ static void dwmac1000_dump_regs(unsigned long ioaddr)
 	}
 }
 
-static void dwmac1000_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+static void dwmac1000_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int reg_n)
 {
 	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
 				GMAC_ADDR_LOW(reg_n));
 }
 
-static void dwmac1000_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+static void dwmac1000_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 				unsigned int reg_n)
 {
 	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
@@ -78,7 +78,7 @@ static void dwmac1000_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
 
 static void dwmac1000_set_filter(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = (void __iomem *) dev->base_addr;
 	unsigned int value = 0;
 
 	CHIP_DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
@@ -139,7 +139,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
 }
 
-static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
+static void dwmac1000_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 			   unsigned int fc, unsigned int pause_time)
 {
 	unsigned int flow = 0;
@@ -162,7 +162,7 @@ static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
 	writel(flow, ioaddr + GMAC_FLOW_CTRL);
 }
 
-static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
+static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 {
 	unsigned int pmt = 0;
 
@@ -178,7 +178,7 @@ static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
 }
 
 
-static void dwmac1000_irq_status(unsigned long ioaddr)
+static void dwmac1000_irq_status(void __iomem *ioaddr)
 {
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
 
@@ -211,7 +211,7 @@ struct stmmac_ops dwmac1000_ops = {
 	.get_umac_addr = dwmac1000_get_umac_addr,
 };
 
-struct mac_device_info *dwmac1000_setup(unsigned long ioaddr)
+struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
 {
 	struct mac_device_info *mac;
 	u32 uid = readl(ioaddr + GMAC_VERSION);
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 4158050..2ef5a56 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -29,7 +29,7 @@
 #include "dwmac1000.h"
 #include "dwmac_dma.h"
 
-static int dwmac1000_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
+static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 			      u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
@@ -58,7 +58,7 @@ static int dwmac1000_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
 	return 0;
 }
 
-static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
+static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 				    int rxmode)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
@@ -111,12 +111,12 @@ static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
 
 /* Not yet implemented --- no RMON module */
 static void dwmac1000_dma_diagnostic_fr(void *data,
-		  struct stmmac_extra_stats *x, unsigned long ioaddr)
+		  struct stmmac_extra_stats *x, void __iomem *ioaddr)
 {
 	return;
 }
 
-static void dwmac1000_dump_dma_regs(unsigned long ioaddr)
+static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
 {
 	int i;
 	pr_info(" DMA registers\n");
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index 2fb165f..135a808 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -31,7 +31,7 @@
 #include <linux/crc32.h>
 #include "dwmac100.h"
 
-static void dwmac100_core_init(unsigned long ioaddr)
+static void dwmac100_core_init(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CONTROL);
 
@@ -42,12 +42,12 @@ static void dwmac100_core_init(unsigned long ioaddr)
 #endif
 }
 
-static void dwmac100_dump_mac_regs(unsigned long ioaddr)
+static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 {
 	pr_info("\t----------------------------------------------\n"
 		"\t  DWMAC 100 CSR (base addr = 0x%8x)\n"
 		"\t----------------------------------------------\n",
-		(unsigned int)ioaddr);
+		(unsigned int) ioaddr);
 	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
 		readl(ioaddr + MAC_CONTROL));
 	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
@@ -77,18 +77,18 @@ static void dwmac100_dump_mac_regs(unsigned long ioaddr)
 		MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
 }
 
-static void dwmac100_irq_status(unsigned long ioaddr)
+static void dwmac100_irq_status(void __iomem *ioaddr)
 {
 	return;
 }
 
-static void dwmac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+static void dwmac100_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 				   unsigned int reg_n)
 {
 	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
 }
 
-static void dwmac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+static void dwmac100_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 				   unsigned int reg_n)
 {
 	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
@@ -96,7 +96,7 @@ static void dwmac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
 
 static void dwmac100_set_filter(struct net_device *dev)
 {
-	unsigned long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = (void __iomem *) dev->base_addr;
 	u32 value = readl(ioaddr + MAC_CONTROL);
 
 	if (dev->flags & IFF_PROMISC) {
@@ -145,7 +145,7 @@ static void dwmac100_set_filter(struct net_device *dev)
 	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
 }
 
-static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
+static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 			       unsigned int fc, unsigned int pause_time)
 {
 	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
@@ -158,7 +158,7 @@ static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
 /* No PMT module supported for this Ethernet Controller.
  * Tested on ST platforms only.
  */
-static void dwmac100_pmt(unsigned long ioaddr, unsigned long mode)
+static void dwmac100_pmt(void __iomem *ioaddr, unsigned long mode)
 {
 	return;
 }
@@ -174,7 +174,7 @@ struct stmmac_ops dwmac100_ops = {
 	.get_umac_addr = dwmac100_get_umac_addr,
 };
 
-struct mac_device_info *dwmac100_setup(unsigned long ioaddr)
+struct mac_device_info *dwmac100_setup(void __iomem *ioaddr)
 {
 	struct mac_device_info *mac;
 
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/stmmac/dwmac100_dma.c
index 2fece7b..c7279d2 100644
--- a/drivers/net/stmmac/dwmac100_dma.c
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -31,7 +31,7 @@
 #include "dwmac100.h"
 #include "dwmac_dma.h"
 
-static int dwmac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
+static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, u32 dma_tx,
 			     u32 dma_rx)
 {
 	u32 value = readl(ioaddr + DMA_BUS_MODE);
@@ -58,7 +58,7 @@ static int dwmac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
 /* Store and Forward capability is not used at all..
  * The transmit threshold can be programmed by
  * setting the TTC bits in the DMA control register.*/
-static void dwmac100_dma_operation_mode(unsigned long ioaddr, int txmode,
+static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
 					int rxmode)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
@@ -73,7 +73,7 @@ static void dwmac100_dma_operation_mode(unsigned long ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-static void dwmac100_dump_dma_regs(unsigned long ioaddr)
+static void dwmac100_dump_dma_regs(void __iomem *ioaddr)
 {
 	int i;
 
@@ -91,7 +91,7 @@ static void dwmac100_dump_dma_regs(unsigned long ioaddr)
 /* DMA controller has two counters to track the number of
  * the receive missed frames. */
 static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
-				       unsigned long ioaddr)
+				       void __iomem *ioaddr)
 {
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 	u32 csr8 = readl(ioaddr + DMA_MISSED_FRAME_CTR);
diff --git a/drivers/net/stmmac/dwmac_dma.h b/drivers/net/stmmac/dwmac_dma.h
index 7b815a1..da3f5cc 100644
--- a/drivers/net/stmmac/dwmac_dma.h
+++ b/drivers/net/stmmac/dwmac_dma.h
@@ -97,12 +97,12 @@
 #define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
 #define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
 
-extern void dwmac_enable_dma_transmission(unsigned long ioaddr);
-extern void dwmac_enable_dma_irq(unsigned long ioaddr);
-extern void dwmac_disable_dma_irq(unsigned long ioaddr);
-extern void dwmac_dma_start_tx(unsigned long ioaddr);
-extern void dwmac_dma_stop_tx(unsigned long ioaddr);
-extern void dwmac_dma_start_rx(unsigned long ioaddr);
-extern void dwmac_dma_stop_rx(unsigned long ioaddr);
-extern int dwmac_dma_interrupt(unsigned long ioaddr,
+extern void dwmac_enable_dma_transmission(void __iomem *ioaddr);
+extern void dwmac_enable_dma_irq(void __iomem *ioaddr);
+extern void dwmac_disable_dma_irq(void __iomem *ioaddr);
+extern void dwmac_dma_start_tx(void __iomem *ioaddr);
+extern void dwmac_dma_stop_tx(void __iomem *ioaddr);
+extern void dwmac_dma_start_rx(void __iomem *ioaddr);
+extern void dwmac_dma_stop_rx(void __iomem *ioaddr);
+extern int dwmac_dma_interrupt(void __iomem *ioaddr,
 				struct stmmac_extra_stats *x);
diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/stmmac/dwmac_lib.c
index a854152..d65fab1 100644
--- a/drivers/net/stmmac/dwmac_lib.c
+++ b/drivers/net/stmmac/dwmac_lib.c
@@ -32,43 +32,43 @@
 #endif
 
 /* CSR1 enables the transmit DMA to check for new descriptor */
-void dwmac_enable_dma_transmission(unsigned long ioaddr)
+void dwmac_enable_dma_transmission(void __iomem *ioaddr)
 {
 	writel(1, ioaddr + DMA_XMT_POLL_DEMAND);
 }
 
-void dwmac_enable_dma_irq(unsigned long ioaddr)
+void dwmac_enable_dma_irq(void __iomem *ioaddr)
 {
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_disable_dma_irq(unsigned long ioaddr)
+void dwmac_disable_dma_irq(void __iomem *ioaddr)
 {
 	writel(0, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_dma_start_tx(unsigned long ioaddr)
+void dwmac_dma_start_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_tx(unsigned long ioaddr)
+void dwmac_dma_stop_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_start_rx(unsigned long ioaddr)
+void dwmac_dma_start_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_SR;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_rx(unsigned long ioaddr)
+void dwmac_dma_stop_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_SR;
@@ -145,7 +145,7 @@ static void show_rx_process_state(unsigned int status)
 }
 #endif
 
-int dwmac_dma_interrupt(unsigned long ioaddr,
+int dwmac_dma_interrupt(void __iomem *ioaddr,
 			struct stmmac_extra_stats *x)
 {
 	int ret = 0;
@@ -219,7 +219,7 @@ int dwmac_dma_interrupt(unsigned long ioaddr,
 	return ret;
 }
 
-void dwmac_dma_flush_tx_fifo(unsigned long ioaddr)
+void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
@@ -227,7 +227,7 @@ void dwmac_dma_flush_tx_fifo(unsigned long ioaddr)
 	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
 }
 
-void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
+void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 			 unsigned int high, unsigned int low)
 {
 	unsigned long data;
@@ -238,7 +238,7 @@ void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
 	writel(data, ioaddr + low);
 }
 
-void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
+void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 			 unsigned int high, unsigned int low)
 {
 	unsigned int hi_addr, lo_addr;
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
index f612f98..77ff88c 100644
--- a/drivers/net/stmmac/enh_desc.c
+++ b/drivers/net/stmmac/enh_desc.c
@@ -25,7 +25,7 @@
 #include "common.h"
 
 static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
-				  struct dma_desc *p, unsigned long ioaddr)
+				  struct dma_desc *p, void __iomem *ioaddr)
 {
 	int ret = 0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/stmmac/norm_desc.c
index 31ad536..51f4440 100644
--- a/drivers/net/stmmac/norm_desc.c
+++ b/drivers/net/stmmac/norm_desc.c
@@ -25,7 +25,7 @@
 #include "common.h"
 
 static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
-			       struct dma_desc *p, unsigned long ioaddr)
+			       struct dma_desc *p, void __iomem *ioaddr)
 {
 	int ret = 0;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index ebebc64..cca53db 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -54,6 +54,7 @@ struct stmmac_priv {
 	unsigned int dma_buf_sz;
 	struct device *device;
 	struct mac_device_info *hw;
+	void __iomem *ioaddr;
 
 	struct stmmac_extra_stats xstats;
 	struct napi_struct napi;
@@ -65,7 +66,7 @@ struct stmmac_priv {
 	int phy_mask;
 	int (*phy_reset) (void *priv);
 	void (*fix_mac_speed) (void *priv, unsigned int speed);
-	void (*bus_setup)(unsigned long ioaddr);
+	void (*bus_setup)(void __iomem *ioaddr);
 	void *bsp_priv;
 
 	int phy_irq;
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index f080509..63b68e6 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -177,21 +177,21 @@ void stmmac_ethtool_gregs(struct net_device *dev,
 	if (!priv->is_gmac) {
 		/* MAC registers */
 		for (i = 0; i < 12; i++)
-			reg_space[i] = readl(dev->base_addr + (i * 4));
+			reg_space[i] = readl(priv->ioaddr + (i * 4));
 		/* DMA registers */
 		for (i = 0; i < 9; i++)
 			reg_space[i + 12] =
-			    readl(dev->base_addr + (DMA_BUS_MODE + (i * 4)));
-		reg_space[22] = readl(dev->base_addr + DMA_CUR_TX_BUF_ADDR);
-		reg_space[23] = readl(dev->base_addr + DMA_CUR_RX_BUF_ADDR);
+			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
+		reg_space[22] = readl(priv->ioaddr + DMA_CUR_TX_BUF_ADDR);
+		reg_space[23] = readl(priv->ioaddr + DMA_CUR_RX_BUF_ADDR);
 	} else {
 		/* MAC registers */
 		for (i = 0; i < 55; i++)
-			reg_space[i] = readl(dev->base_addr + (i * 4));
+			reg_space[i] = readl(priv->ioaddr + (i * 4));
 		/* DMA registers */
 		for (i = 0; i < 22; i++)
 			reg_space[i + 55] =
-			    readl(dev->base_addr + (DMA_BUS_MODE + (i * 4)));
+			    readl(priv->ioaddr + (DMA_BUS_MODE + (i * 4)));
 	}
 }
 
@@ -263,11 +263,9 @@ stmmac_set_pauseparam(struct net_device *netdev,
 			cmd.phy_address = phy->addr;
 			ret = phy_ethtool_sset(phy, &cmd);
 		}
-	} else {
-		unsigned long ioaddr = netdev->base_addr;
-		priv->hw->mac->flow_ctrl(ioaddr, phy->duplex,
+	} else
+		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
-	}
 	spin_unlock(&priv->lock);
 	return ret;
 }
@@ -276,12 +274,11 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 				 struct ethtool_stats *dummy, u64 *data)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int i;
 
 	/* Update HW stats if supported */
 	priv->hw->dma->dma_diagnostic_fr(&dev->stats, (void *) &priv->xstats,
-					 ioaddr);
+					 priv->ioaddr);
 
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 86b6c69..c59c106 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -202,7 +202,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
-	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 	int new_state = 0;
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
@@ -215,7 +214,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 
 	spin_lock_irqsave(&priv->lock, flags);
 	if (phydev->link) {
-		u32 ctrl = readl(ioaddr + MAC_CTRL_REG);
+		u32 ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
 
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
@@ -229,7 +228,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->hw->mac->flow_ctrl(ioaddr, phydev->duplex,
+			priv->hw->mac->flow_ctrl(priv->ioaddr, phydev->duplex,
 						 fc, pause_time);
 
 		if (phydev->speed != priv->speed) {
@@ -268,7 +267,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			priv->speed = phydev->speed;
 		}
 
-		writel(ctrl, ioaddr + MAC_CTRL_REG);
+		writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
 
 		if (!priv->oldlink) {
 			new_state = 1;
@@ -345,7 +344,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	return 0;
 }
 
-static inline void stmmac_mac_enable_rx(unsigned long ioaddr)
+static inline void stmmac_mac_enable_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
 	value |= MAC_RNABLE_RX;
@@ -353,7 +352,7 @@ static inline void stmmac_mac_enable_rx(unsigned long ioaddr)
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
 
-static inline void stmmac_mac_enable_tx(unsigned long ioaddr)
+static inline void stmmac_mac_enable_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
 	value |= MAC_ENABLE_TX;
@@ -361,14 +360,14 @@ static inline void stmmac_mac_enable_tx(unsigned long ioaddr)
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
 
-static inline void stmmac_mac_disable_rx(unsigned long ioaddr)
+static inline void stmmac_mac_disable_rx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
 	value &= ~MAC_RNABLE_RX;
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
 
-static inline void stmmac_mac_disable_tx(unsigned long ioaddr)
+static inline void stmmac_mac_disable_tx(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
 	value &= ~MAC_ENABLE_TX;
@@ -577,17 +576,17 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
 	if (!priv->is_gmac) {
 		/* MAC 10/100 */
-		priv->hw->dma->dma_mode(priv->dev->base_addr, tc, 0);
+		priv->hw->dma->dma_mode(priv->ioaddr, tc, 0);
 		priv->tx_coe = NO_HW_CSUM;
 	} else {
 		if ((priv->dev->mtu <= ETH_DATA_LEN) && (tx_coe)) {
-			priv->hw->dma->dma_mode(priv->dev->base_addr,
+			priv->hw->dma->dma_mode(priv->ioaddr,
 						SF_DMA_MODE, SF_DMA_MODE);
 			tc = SF_DMA_MODE;
 			priv->tx_coe = HW_CSUM;
 		} else {
 			/* Checksum computation is performed in software. */
-			priv->hw->dma->dma_mode(priv->dev->base_addr, tc,
+			priv->hw->dma->dma_mode(priv->ioaddr, tc,
 						SF_DMA_MODE);
 			priv->tx_coe = NO_HW_CSUM;
 		}
@@ -603,7 +602,6 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 static void stmmac_tx(struct stmmac_priv *priv)
 {
 	unsigned int txsize = priv->dma_tx_size;
-	unsigned long ioaddr = priv->dev->base_addr;
 
 	while (priv->dirty_tx != priv->cur_tx) {
 		int last;
@@ -621,7 +619,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			int tx_error =
 				priv->hw->desc->tx_status(&priv->dev->stats,
 							  &priv->xstats, p,
-							  ioaddr);
+							  priv->ioaddr);
 			if (likely(tx_error == 0)) {
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
@@ -677,7 +675,7 @@ static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_start(tmrate);
 	else
 #endif
-		priv->hw->dma->enable_dma_irq(priv->dev->base_addr);
+		priv->hw->dma->enable_dma_irq(priv->ioaddr);
 }
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
@@ -687,7 +685,7 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_stop();
 	else
 #endif
-		priv->hw->dma->disable_dma_irq(priv->dev->base_addr);
+		priv->hw->dma->disable_dma_irq(priv->ioaddr);
 }
 
 static int stmmac_has_work(struct stmmac_priv *priv)
@@ -742,14 +740,15 @@ static void stmmac_no_timer_stopped(void)
  */
 static void stmmac_tx_err(struct stmmac_priv *priv)
 {
+
 	netif_stop_queue(priv->dev);
 
-	priv->hw->dma->stop_tx(priv->dev->base_addr);
+	priv->hw->dma->stop_tx(priv->ioaddr);
 	dma_free_tx_skbufs(priv);
 	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
-	priv->hw->dma->start_tx(priv->dev->base_addr);
+	priv->hw->dma->start_tx(priv->ioaddr);
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
@@ -758,11 +757,9 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
-	unsigned long ioaddr = priv->dev->base_addr;
 	int status;
 
-	status = priv->hw->dma->dma_interrupt(priv->dev->base_addr,
-					      &priv->xstats);
+	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely(status == handle_tx_rx))
 		_stmmac_schedule(priv);
 
@@ -770,7 +767,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		/* Try to bump up the dma threshold on this failure */
 		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
 			tc += 64;
-			priv->hw->dma->dma_mode(ioaddr, tc, SF_DMA_MODE);
+			priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
 			priv->xstats.threshold = tc;
 		}
 		stmmac_tx_err(priv);
@@ -790,7 +787,6 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 static int stmmac_open(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 	int ret;
 
 	/* Check that the MAC address is valid.  If its not, refuse
@@ -846,7 +842,8 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	if (unlikely(priv->hw->dma->init(ioaddr, priv->pbl, priv->dma_tx_phy,
+	if (unlikely(priv->hw->dma->init(priv->ioaddr, priv->pbl,
+					 priv->dma_tx_phy,
 					 priv->dma_rx_phy) < 0)) {
 
 		pr_err("%s: DMA initialization failed\n", __func__);
@@ -854,22 +851,22 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 	/* Copy the MAC addr into the HW  */
-	priv->hw->mac->set_umac_addr(ioaddr, dev->dev_addr, 0);
+	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
 	/* If required, perform hw setup of the bus. */
 	if (priv->bus_setup)
-		priv->bus_setup(ioaddr);
+		priv->bus_setup(priv->ioaddr);
 	/* Initialize the MAC Core */
-	priv->hw->mac->core_init(ioaddr);
+	priv->hw->mac->core_init(priv->ioaddr);
 
 	priv->shutdown = 0;
 
 	/* Initialise the MMC (if present) to disable all interrupts. */
-	writel(0xffffffff, ioaddr + MMC_HIGH_INTR_MASK);
-	writel(0xffffffff, ioaddr + MMC_LOW_INTR_MASK);
+	writel(0xffffffff, priv->ioaddr + MMC_HIGH_INTR_MASK);
+	writel(0xffffffff, priv->ioaddr + MMC_LOW_INTR_MASK);
 
 	/* Enable the MAC Rx/Tx */
-	stmmac_mac_enable_rx(ioaddr);
-	stmmac_mac_enable_tx(ioaddr);
+	stmmac_mac_enable_rx(priv->ioaddr);
+	stmmac_mac_enable_tx(priv->ioaddr);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
@@ -880,16 +877,16 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
-	priv->hw->dma->start_tx(ioaddr);
-	priv->hw->dma->start_rx(ioaddr);
+	priv->hw->dma->start_tx(priv->ioaddr);
+	priv->hw->dma->start_rx(priv->ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
 #endif
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
-		priv->hw->mac->dump_regs(ioaddr);
-		priv->hw->dma->dump_regs(ioaddr);
+		priv->hw->mac->dump_regs(priv->ioaddr);
+		priv->hw->dma->dump_regs(priv->ioaddr);
 	}
 
 	if (priv->phydev)
@@ -933,15 +930,15 @@ static int stmmac_release(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
-	priv->hw->dma->stop_tx(dev->base_addr);
-	priv->hw->dma->stop_rx(dev->base_addr);
+	priv->hw->dma->stop_tx(priv->ioaddr);
+	priv->hw->dma->stop_rx(priv->ioaddr);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
 
 	/* Disable the MAC core */
-	stmmac_mac_disable_tx(dev->base_addr);
-	stmmac_mac_disable_rx(dev->base_addr);
+	stmmac_mac_disable_tx(priv->ioaddr);
+	stmmac_mac_disable_rx(priv->ioaddr);
 
 	netif_carrier_off(dev);
 
@@ -1143,7 +1140,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += skb->len;
 
-	priv->hw->dma->enable_dma_transmission(dev->base_addr);
+	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 
 	return NETDEV_TX_OK;
 }
@@ -1408,11 +1405,9 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
 
-	if (priv->is_gmac) {
-		unsigned long ioaddr = dev->base_addr;
+	if (priv->is_gmac)
 		/* To handle GMAC own interrupts */
-		priv->hw->mac->host_irq_status(ioaddr);
-	}
+		priv->hw->mac->host_irq_status((void __iomem *) dev->base_addr);
 
 	stmmac_dma_interrupt(priv);
 
@@ -1525,7 +1520,8 @@ static int stmmac_probe(struct net_device *dev)
 	netif_napi_add(dev, &priv->napi, stmmac_poll, 64);
 
 	/* Get the MAC address */
-	priv->hw->mac->get_umac_addr(dev->base_addr, dev->dev_addr, 0);
+	priv->hw->mac->get_umac_addr((void __iomem *) dev->base_addr,
+				     dev->dev_addr, 0);
 
 	if (!is_valid_ether_addr(dev->dev_addr))
 		pr_warning("\tno valid MAC address;"
@@ -1555,14 +1551,13 @@ static int stmmac_probe(struct net_device *dev)
 static int stmmac_mac_device_setup(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 
 	struct mac_device_info *device;
 
 	if (priv->is_gmac)
-		device = dwmac1000_setup(ioaddr);
+		device = dwmac1000_setup(priv->ioaddr);
 	else
-		device = dwmac100_setup(ioaddr);
+		device = dwmac100_setup(priv->ioaddr);
 
 	if (!device)
 		return -ENOMEM;
@@ -1656,7 +1651,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
-	unsigned int *addr = NULL;
+	void __iomem *addr = NULL;
 	struct net_device *ndev = NULL;
 	struct stmmac_priv *priv;
 	struct plat_stmmacenet_data *plat_dat;
@@ -1711,6 +1706,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv->pbl = plat_dat->pbl;	/* TLI */
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
 	priv->enh_desc = plat_dat->enh_desc;
+	priv->ioaddr = addr;
 
 	platform_set_drvdata(pdev, ndev);
 
@@ -1782,11 +1778,11 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 
 	pr_info("%s:\n\tremoving driver", __func__);
 
-	priv->hw->dma->stop_rx(ndev->base_addr);
-	priv->hw->dma->stop_tx(ndev->base_addr);
+	priv->hw->dma->stop_rx(priv->ioaddr);
+	priv->hw->dma->stop_tx(priv->ioaddr);
 
-	stmmac_mac_disable_rx(ndev->base_addr);
-	stmmac_mac_disable_tx(ndev->base_addr);
+	stmmac_mac_disable_rx(priv->ioaddr);
+	stmmac_mac_disable_tx(priv->ioaddr);
 
 	netif_carrier_off(ndev);
 
@@ -1795,7 +1791,7 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 
-	iounmap((void *)ndev->base_addr);
+	iounmap((void *)priv->ioaddr);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
@@ -1830,22 +1826,21 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 		napi_disable(&priv->napi);
 
 		/* Stop TX/RX DMA */
-		priv->hw->dma->stop_tx(dev->base_addr);
-		priv->hw->dma->stop_rx(dev->base_addr);
+		priv->hw->dma->stop_tx(priv->ioaddr);
+		priv->hw->dma->stop_rx(priv->ioaddr);
 		/* Clear the Rx/Tx descriptors */
 		priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
 					     dis_ic);
 		priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 
-		stmmac_mac_disable_tx(dev->base_addr);
+		stmmac_mac_disable_tx(priv->ioaddr);
 
 		if (device_may_wakeup(&(pdev->dev))) {
 			/* Enable Power down mode by programming the PMT regs */
 			if (priv->wolenabled == PMT_SUPPORTED)
-				priv->hw->mac->pmt(dev->base_addr,
-						   priv->wolopts);
+				priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
 		} else {
-			stmmac_mac_disable_rx(dev->base_addr);
+			stmmac_mac_disable_rx(priv->ioaddr);
 		}
 	} else {
 		priv->shutdown = 1;
@@ -1863,7 +1858,6 @@ static int stmmac_resume(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(dev);
-	unsigned long ioaddr = dev->base_addr;
 
 	if (!netif_running(dev))
 		return 0;
@@ -1884,15 +1878,15 @@ static int stmmac_resume(struct platform_device *pdev)
 	 * from another devices (e.g. serial console). */
 	if (device_may_wakeup(&(pdev->dev)))
 		if (priv->wolenabled == PMT_SUPPORTED)
-			priv->hw->mac->pmt(dev->base_addr, 0);
+			priv->hw->mac->pmt(priv->ioaddr, 0);
 
 	netif_device_attach(dev);
 
 	/* Enable the MAC and DMA */
-	stmmac_mac_enable_rx(ioaddr);
-	stmmac_mac_enable_tx(ioaddr);
-	priv->hw->dma->start_tx(ioaddr);
-	priv->hw->dma->start_rx(ioaddr);
+	stmmac_mac_enable_rx(priv->ioaddr);
+	stmmac_mac_enable_tx(priv->ioaddr);
+	priv->hw->dma->start_tx(priv->ioaddr);
+	priv->hw->dma->start_rx(priv->ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 40b2c79..03dea14 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -47,7 +47,6 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 {
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	unsigned long ioaddr = ndev->base_addr;
 	unsigned int mii_address = priv->hw->mii.addr;
 	unsigned int mii_data = priv->hw->mii.data;
 
@@ -56,12 +55,12 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 			((phyreg << 6) & (0x000007C0)));
 	regValue |= MII_BUSY;	/* in case of GMAC */
 
-	do {} while (((readl(ioaddr + mii_address)) & MII_BUSY) == 1);
-	writel(regValue, ioaddr + mii_address);
-	do {} while (((readl(ioaddr + mii_address)) & MII_BUSY) == 1);
+	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
+	writel(regValue, priv->ioaddr + mii_address);
+	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
 
 	/* Read the data from the MII data register */
-	data = (int)readl(ioaddr + mii_data);
+	data = (int)readl(priv->ioaddr + mii_data);
 
 	return data;
 }
@@ -79,7 +78,6 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 {
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	unsigned long ioaddr = ndev->base_addr;
 	unsigned int mii_address = priv->hw->mii.addr;
 	unsigned int mii_data = priv->hw->mii.data;
 
@@ -90,14 +88,14 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	value |= MII_BUSY;
 
 	/* Wait until any existing MII operation is complete */
-	do {} while (((readl(ioaddr + mii_address)) & MII_BUSY) == 1);
+	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
 
 	/* Set the MII address register to write */
-	writel(phydata, ioaddr + mii_data);
-	writel(value, ioaddr + mii_address);
+	writel(phydata, priv->ioaddr + mii_data);
+	writel(value, priv->ioaddr + mii_address);
 
 	/* Wait until any existing MII operation is complete */
-	do {} while (((readl(ioaddr + mii_address)) & MII_BUSY) == 1);
+	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
 
 	return 0;
 }
@@ -111,7 +109,6 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 {
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	unsigned long ioaddr = ndev->base_addr;
 	unsigned int mii_address = priv->hw->mii.addr;
 
 	if (priv->phy_reset) {
@@ -123,7 +120,7 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	 * It doesn't complete its reset until at least one clock cycle
 	 * on MDC, so perform a dummy mdio read.
 	 */
-	writel(0, ioaddr + mii_address);
+	writel(0, priv->ioaddr + mii_address);
 
 	return 0;
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 632ff7c..a4adf0d 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -35,7 +35,7 @@ struct plat_stmmacenet_data {
 	int has_gmac;
 	int enh_desc;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	void (*bus_setup)(unsigned long ioaddr);
+	void (*bus_setup)(void __iomem *ioaddr);
 #ifdef CONFIG_STM_DRIVERS
 	struct stm_pad_config *pad_config;
 #endif
-- 
1.5.5.6

