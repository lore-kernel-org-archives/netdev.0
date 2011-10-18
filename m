From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 5/7] stmmac: use predefined macros for HW cap register fields (V3)
Date: Tue, 18 Oct 2011 10:42:09 +0200
Message-ID: <1318927331-20855-6-git-send-email-peppe.cavallaro@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Rayagond Kokatanur <rayagond@vayavyalabs.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:52521 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864Ab1JRIt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:49:26 -0400
In-Reply-To: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |   30 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   54 +++++++++++++--------
 2 files changed, 63 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 22c61b2..ffba014 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -103,6 +103,36 @@ struct stmmac_extra_stats {
 
 #define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
 
+/* DAM HW feature register fields */
+#define DMA_HW_FEAT_MIISEL	0x00000001 /* 10/100 Mbps Support */
+#define DMA_HW_FEAT_GMIISEL	0x00000002 /* 1000 Mbps Support */
+#define DMA_HW_FEAT_HDSEL	0x00000004 /* Half-Duplex Support */
+#define DMA_HW_FEAT_EXTHASHEN	0x00000008 /* Expanded DA Hash Filter */
+#define DMA_HW_FEAT_HASHSEL	0x00000010 /* HASH Filter */
+#define DMA_HW_FEAT_ADDMACADRSEL	0x00000020 /* Multiple MAC Addr Reg */
+#define DMA_HW_FEAT_PCSSEL	0x00000040 /* PCS registers */
+#define DMA_HW_FEAT_L3L4FLTREN	0x00000080 /* Layer 3 & Layer 4 Feature */
+#define DMA_HW_FEAT_SMASEL	0x00000100 /* SMA(MDIO) Interface */
+#define DMA_HW_FEAT_RWKSEL	0x00000200 /* PMT Remote Wakeup */
+#define DMA_HW_FEAT_MGKSEL	0x00000400 /* PMT Magic Packet */
+#define DMA_HW_FEAT_MMCSEL	0x00000800 /* RMON Module */
+#define DMA_HW_FEAT_TSVER1SEL	0x00001000 /* Only IEEE 1588-2002 Timestamp */
+#define DMA_HW_FEAT_TSVER2SEL	0x00002000 /* IEEE 1588-2008 Adv Timestamp */
+#define DMA_HW_FEAT_EEESEL	0x00004000 /* Energy Efficient Ethernet */
+#define DMA_HW_FEAT_AVSEL	0x00008000 /* AV Feature */
+#define DMA_HW_FEAT_TXCOESEL	0x00010000 /* Checksum Offload in Tx */
+#define DMA_HW_FEAT_RXTYP1COE	0x00020000 /* IP csum Offload(Type 1) in Rx */
+#define DMA_HW_FEAT_RXTYP2COE	0x00040000 /* IP csum Offload(Type 2) in Rx */
+#define DMA_HW_FEAT_RXFIFOSIZE	0x00080000 /* Rx FIFO > 2048 Bytes */
+#define DMA_HW_FEAT_RXCHCNT	0x00300000 /* No. of additional Rx Channels */
+#define DMA_HW_FEAT_TXCHCNT	0x00c00000 /* No. of additional Tx Channels */
+#define DMA_HW_FEAT_ENHDESSEL	0x01000000 /* Alternate (Enhanced Descriptor) */
+#define DMA_HW_FEAT_INTTSEN	0x02000000 /* Timestamping with Internal
+					      System Time */
+#define DMA_HW_FEAT_FLEXIPPSEN	0x04000000 /* Flexible PPS Output */
+#define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
+#define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
+
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
 	discard_frame = 1,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 622b7ac..125a177 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -799,33 +799,45 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 	u32 hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
 
 	if (likely(hw_cap)) {
-		priv->dma_cap.mbps_10_100 = (hw_cap & 0x1);
-		priv->dma_cap.mbps_1000 = (hw_cap & 0x2) >> 1;
-		priv->dma_cap.half_duplex = (hw_cap & 0x4) >> 2;
-		priv->dma_cap.hash_filter = (hw_cap & 0x10) >> 4;
-		priv->dma_cap.multi_addr = (hw_cap & 0x20) >> 5;
-		priv->dma_cap.pcs = (hw_cap & 0x40) >> 6;
-		priv->dma_cap.sma_mdio = (hw_cap & 0x100) >> 8;
-		priv->dma_cap.pmt_remote_wake_up = (hw_cap & 0x200) >> 9;
-		priv->dma_cap.pmt_magic_frame = (hw_cap & 0x400) >> 10;
-		priv->dma_cap.rmon = (hw_cap & 0x800) >> 11; /* MMC */
+		priv->dma_cap.mbps_10_100 = (hw_cap & DMA_HW_FEAT_MIISEL);
+		priv->dma_cap.mbps_1000 = (hw_cap & DMA_HW_FEAT_GMIISEL) >> 1;
+		priv->dma_cap.half_duplex = (hw_cap & DMA_HW_FEAT_HDSEL) >> 2;
+		priv->dma_cap.hash_filter = (hw_cap & DMA_HW_FEAT_HASHSEL) >> 4;
+		priv->dma_cap.multi_addr =
+			(hw_cap & DMA_HW_FEAT_ADDMACADRSEL) >> 5;
+		priv->dma_cap.pcs = (hw_cap & DMA_HW_FEAT_PCSSEL) >> 6;
+		priv->dma_cap.sma_mdio = (hw_cap & DMA_HW_FEAT_SMASEL) >> 8;
+		priv->dma_cap.pmt_remote_wake_up =
+			(hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
+		priv->dma_cap.pmt_magic_frame =
+			(hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
+		/*MMC*/
+		priv->dma_cap.rmon = (hw_cap & DMA_HW_FEAT_MMCSEL) >> 11;
 		/* IEEE 1588-2002*/
-		priv->dma_cap.time_stamp = (hw_cap & 0x1000) >> 12;
+		priv->dma_cap.time_stamp =
+			(hw_cap & DMA_HW_FEAT_TSVER1SEL) >> 12;
 		/* IEEE 1588-2008*/
-		priv->dma_cap.atime_stamp = (hw_cap & 0x2000) >> 13;
+		priv->dma_cap.atime_stamp =
+			(hw_cap & DMA_HW_FEAT_TSVER2SEL) >> 13;
 		/* 802.3az - Energy-Efficient Ethernet (EEE) */
-		priv->dma_cap.eee = (hw_cap & 0x4000) >> 14;
-		priv->dma_cap.av = (hw_cap & 0x8000) >> 15;
+		priv->dma_cap.eee = (hw_cap & DMA_HW_FEAT_EEESEL) >> 14;
+		priv->dma_cap.av = (hw_cap & DMA_HW_FEAT_AVSEL) >> 15;
 		/* TX and RX csum */
-		priv->dma_cap.tx_coe = (hw_cap & 0x10000) >> 16;
-		priv->dma_cap.rx_coe_type1 = (hw_cap & 0x20000) >> 17;
-		priv->dma_cap.rx_coe_type2 = (hw_cap & 0x40000) >> 18;
-		priv->dma_cap.rxfifo_over_2048 = (hw_cap & 0x80000) >> 19;
+		priv->dma_cap.tx_coe = (hw_cap & DMA_HW_FEAT_TXCOESEL) >> 16;
+		priv->dma_cap.rx_coe_type1 =
+			(hw_cap & DMA_HW_FEAT_RXTYP1COE) >> 17;
+		priv->dma_cap.rx_coe_type2 =
+			(hw_cap & DMA_HW_FEAT_RXTYP2COE) >> 18;
+		priv->dma_cap.rxfifo_over_2048 =
+			(hw_cap & DMA_HW_FEAT_RXFIFOSIZE) >> 19;
 		/* TX and RX number of channels */
-		priv->dma_cap.number_rx_channel = (hw_cap & 0x300000) >> 20;
-		priv->dma_cap.number_tx_channel = (hw_cap & 0xc00000) >> 22;
+		priv->dma_cap.number_rx_channel =
+			(hw_cap & DMA_HW_FEAT_RXCHCNT) >> 20;
+		priv->dma_cap.number_tx_channel =
+			(hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
 		/* Alternate (enhanced) DESC mode*/
-		priv->dma_cap.enh_desc = (hw_cap & 0x1000000) >> 24;
+		priv->dma_cap.enh_desc =
+			(hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
 
 	} else
 		pr_debug("\tNo HW DMA feature register supported");
-- 
1.7.4.4
