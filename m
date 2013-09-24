From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/10] stmicro: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:10:00 -0700
Message-ID: <d6cc64ef73f74edfc485fefb5e6dc2ba625bd675.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h    | 12 ++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h | 17 ++++++++---------
 drivers/net/ethernet/stmicro/stmmac/mmc.h       |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h    | 10 +++++-----
 4 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7eb8bab..fc94f20 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -451,14 +451,14 @@ struct mac_device_info {
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr);
 struct mac_device_info *dwmac100_setup(void __iomem *ioaddr);
 
-extern void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
-				unsigned int high, unsigned int low);
-extern void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
-				unsigned int high, unsigned int low);
+void stmmac_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
+			 unsigned int high, unsigned int low);
+void stmmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
+			 unsigned int high, unsigned int low);
 
-extern void stmmac_set_mac(void __iomem *ioaddr, bool enable);
+void stmmac_set_mac(void __iomem *ioaddr, bool enable);
 
-extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
+void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_ring_mode_ops ring_mode_ops;
 extern const struct stmmac_chain_mode_ops chain_mode_ops;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 8e5662c..def266d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -104,14 +104,13 @@
 #define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
 #define DMA_CONTROL_FTF		0x00100000	/* Flush transmit FIFO */
 
-extern void dwmac_enable_dma_transmission(void __iomem *ioaddr);
-extern void dwmac_enable_dma_irq(void __iomem *ioaddr);
-extern void dwmac_disable_dma_irq(void __iomem *ioaddr);
-extern void dwmac_dma_start_tx(void __iomem *ioaddr);
-extern void dwmac_dma_stop_tx(void __iomem *ioaddr);
-extern void dwmac_dma_start_rx(void __iomem *ioaddr);
-extern void dwmac_dma_stop_rx(void __iomem *ioaddr);
-extern int dwmac_dma_interrupt(void __iomem *ioaddr,
-			       struct stmmac_extra_stats *x);
+void dwmac_enable_dma_transmission(void __iomem *ioaddr);
+void dwmac_enable_dma_irq(void __iomem *ioaddr);
+void dwmac_disable_dma_irq(void __iomem *ioaddr);
+void dwmac_dma_start_tx(void __iomem *ioaddr);
+void dwmac_dma_stop_tx(void __iomem *ioaddr);
+void dwmac_dma_start_rx(void __iomem *ioaddr);
+void dwmac_dma_stop_rx(void __iomem *ioaddr);
+int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
 
 #endif /* __DWMAC_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 48ec001..8607488 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -128,8 +128,8 @@ struct stmmac_counters {
 	unsigned int mmc_rx_icmp_err_octets;
 };
 
-extern void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode);
-extern void dwmac_mmc_intr_all_mask(void __iomem *ioaddr);
-extern void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc);
+void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode);
+void dwmac_mmc_intr_all_mask(void __iomem *ioaddr);
+void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc);
 
 #endif /* __MMC_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index f16a9bd..22f89ff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -110,14 +110,14 @@ struct stmmac_priv {
 
 extern int phyaddr;
 
-extern int stmmac_mdio_unregister(struct net_device *ndev);
-extern int stmmac_mdio_register(struct net_device *ndev);
-extern void stmmac_set_ethtool_ops(struct net_device *netdev);
+int stmmac_mdio_unregister(struct net_device *ndev);
+int stmmac_mdio_register(struct net_device *ndev);
+void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
 extern const struct stmmac_hwtimestamp stmmac_ptp;
-extern int stmmac_ptp_register(struct stmmac_priv *priv);
-extern void stmmac_ptp_unregister(struct stmmac_priv *priv);
+int stmmac_ptp_register(struct stmmac_priv *priv);
+void stmmac_ptp_unregister(struct stmmac_priv *priv);
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
-- 
1.8.1.2.459.gbcd45b4.dirty
