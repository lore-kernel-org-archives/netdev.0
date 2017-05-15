From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/2] net-next: stmmac: remove struct mac_link
Date: Mon, 15 May 2017 13:41:40 +0200
Message-ID: <20170515114140.1676-2-clabbe.montjoie@gmail.com>
References: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the usage of adjust_link(), the struct mac_link is now useless.
This patch remove it.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h         | 7 -------
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 3 ---
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c  | 3 ---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c    | 3 ---
 4 files changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 451c231006fe..63350b70e10f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -551,12 +551,6 @@ struct stmmac_hwtimestamp {
 extern const struct stmmac_hwtimestamp stmmac_ptp;
 extern const struct stmmac_mode_ops dwmac4_ring_mode_ops;
 
-struct mac_link {
-	int port;
-	int duplex;
-	int speed;
-};
-
 struct mii_regs {
 	unsigned int addr;	/* MII Address */
 	unsigned int data;	/* MII Data */
@@ -587,7 +581,6 @@ struct mac_device_info {
 	const struct stmmac_mode_ops *mode;
 	const struct stmmac_hwtimestamp *ptp;
 	struct mii_regs mii;	/* MII register Addresses */
-	struct mac_link link;
 	void __iomem *pcsr;     /* vpointer to device CSRs */
 	int multicast_filter_bins;
 	int unicast_filter_entries;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 5f3aace46c41..52092ec5f4af 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -585,9 +585,6 @@ struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 	mac->mac = &dwmac1000_ops;
 	mac->dma = &dwmac1000_dma_ops;
 
-	mac->link.port = GMAC_CONTROL_PS;
-	mac->link.duplex = GMAC_CONTROL_DM;
-	mac->link.speed = GMAC_CONTROL_FES;
 	mac->mii.addr = GMAC_MII_ADDR;
 	mac->mii.data = GMAC_MII_DATA;
 	mac->mii.addr_shift = 11;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index ba3d46e65e1a..faddbf3c2916 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -221,9 +221,6 @@ struct mac_device_info *dwmac100_setup(void __iomem *ioaddr, int *synopsys_id)
 	mac->mac = &dwmac100_ops;
 	mac->dma = &dwmac100_dma_ops;
 
-	mac->link.port = MAC_CONTROL_PS;
-	mac->link.duplex = MAC_CONTROL_F;
-	mac->link.speed = 0;
 	mac->mii.addr = MAC_MII_ADDR;
 	mac->mii.data = MAC_MII_DATA;
 	mac->mii.addr_shift = 11;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 133b6bcd7b61..baf32c91122d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -801,9 +801,6 @@ struct mac_device_info *dwmac4_setup(void __iomem *ioaddr, int mcbins,
 	if (mac->multicast_filter_bins)
 		mac->mcast_bits_log2 = ilog2(mac->multicast_filter_bins);
 
-	mac->link.port = GMAC_CONFIG_PS;
-	mac->link.duplex = GMAC_CONFIG_DM;
-	mac->link.speed = GMAC_CONFIG_FES;
 	mac->mii.addr = GMAC_MDIO_ADDR;
 	mac->mii.data = GMAC_MDIO_DATA;
 	mac->mii.addr_shift = 21;
-- 
2.13.0
