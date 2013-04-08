From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 3/5] stmmac: code tidy-up
Date: Mon,  8 Apr 2013 14:10:01 +0200
Message-ID: <1365423003-23959-4-git-send-email-peppe.cavallaro@st.com>
References: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shiraz.hashim@st.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:56948 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935294Ab3DHMKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:10:31 -0400
In-Reply-To: <1365423003-23959-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tidies up the code. I have run Linden (and verified with checkpatch)
many part of the driver trying to reorganize some sections respecting the
codying-style rules in the points where it was not done.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   12 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   89 ++++----
 drivers/net/ethernet/stmicro/stmmac/descs.h        |    6 +-
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   69 +++---
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   70 +++---
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   23 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   28 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |   26 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |    3 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  273 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    2 +-
 17 files changed, 311 insertions(+), 309 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 37a3f93..d234ab5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -30,7 +30,7 @@
 
 static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *) p;
+	struct stmmac_priv *priv = (struct stmmac_priv *)p;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int entry = priv->cur_tx % txsize;
 	struct dma_desc *desc = priv->dma_tx + entry;
@@ -103,7 +103,7 @@ static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
 	dma_addr_t dma_phy = phy_addr;
 
 	if (extend_desc) {
-		struct dma_extended_desc *p = (struct dma_extended_desc *) des;
+		struct dma_extended_desc *p = (struct dma_extended_desc *)des;
 		for (i = 0; i < (size - 1); i++) {
 			dma_phy += sizeof(struct dma_extended_desc);
 			p->basic.des3 = (unsigned int)dma_phy;
@@ -112,7 +112,7 @@ static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
 		p->basic.des3 = (unsigned int)phy_addr;
 
 	} else {
-		struct dma_desc *p = (struct dma_desc *) des;
+		struct dma_desc *p = (struct dma_desc *)des;
 		for (i = 0; i < (size - 1); i++) {
 			dma_phy += sizeof(struct dma_desc);
 			p->des3 = (unsigned int)dma_phy;
@@ -133,7 +133,7 @@ static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 		 */
 		p->des3 = (unsigned int)(priv->dma_rx_phy +
 					 (((priv->dirty_rx) + 1) %
-					 priv->dma_rx_size) *
+					  priv->dma_rx_size) *
 					 sizeof(struct dma_desc));
 }
 
@@ -148,8 +148,8 @@ static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 		 */
 		p->des3 = (unsigned int)(priv->dma_tx_phy +
 					 (((priv->dirty_tx + 1) %
-					 priv->dma_tx_size) *
-					 sizeof(struct dma_desc)));
+					   priv->dma_tx_size) *
+					  sizeof(struct dma_desc)));
 }
 
 const struct stmmac_chain_mode_ops chain_mode_ops = {
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index ad7e20a..7788fbe 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -174,37 +174,37 @@ struct stmmac_extra_stats {
 #define STMMAC_PCS_TBI		(1 << 2)
 #define STMMAC_PCS_RTBI		(1 << 3)
 
-#define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
+#define SF_DMA_MODE 1		/* DMA STORE-AND-FORWARD Operation Mode */
 
 /* DAM HW feature register fields */
-#define DMA_HW_FEAT_MIISEL	0x00000001 /* 10/100 Mbps Support */
-#define DMA_HW_FEAT_GMIISEL	0x00000002 /* 1000 Mbps Support */
-#define DMA_HW_FEAT_HDSEL	0x00000004 /* Half-Duplex Support */
-#define DMA_HW_FEAT_EXTHASHEN	0x00000008 /* Expanded DA Hash Filter */
-#define DMA_HW_FEAT_HASHSEL	0x00000010 /* HASH Filter */
-#define DMA_HW_FEAT_ADDMACADRSEL	0x00000020 /* Multiple MAC Addr Reg */
-#define DMA_HW_FEAT_PCSSEL	0x00000040 /* PCS registers */
-#define DMA_HW_FEAT_L3L4FLTREN	0x00000080 /* Layer 3 & Layer 4 Feature */
-#define DMA_HW_FEAT_SMASEL	0x00000100 /* SMA(MDIO) Interface */
-#define DMA_HW_FEAT_RWKSEL	0x00000200 /* PMT Remote Wakeup */
-#define DMA_HW_FEAT_MGKSEL	0x00000400 /* PMT Magic Packet */
-#define DMA_HW_FEAT_MMCSEL	0x00000800 /* RMON Module */
-#define DMA_HW_FEAT_TSVER1SEL	0x00001000 /* Only IEEE 1588-2002 Timestamp */
-#define DMA_HW_FEAT_TSVER2SEL	0x00002000 /* IEEE 1588-2008 Adv Timestamp */
-#define DMA_HW_FEAT_EEESEL	0x00004000 /* Energy Efficient Ethernet */
-#define DMA_HW_FEAT_AVSEL	0x00008000 /* AV Feature */
-#define DMA_HW_FEAT_TXCOESEL	0x00010000 /* Checksum Offload in Tx */
-#define DMA_HW_FEAT_RXTYP1COE	0x00020000 /* IP csum Offload(Type 1) in Rx */
-#define DMA_HW_FEAT_RXTYP2COE	0x00040000 /* IP csum Offload(Type 2) in Rx */
-#define DMA_HW_FEAT_RXFIFOSIZE	0x00080000 /* Rx FIFO > 2048 Bytes */
-#define DMA_HW_FEAT_RXCHCNT	0x00300000 /* No. of additional Rx Channels */
-#define DMA_HW_FEAT_TXCHCNT	0x00c00000 /* No. of additional Tx Channels */
-#define DMA_HW_FEAT_ENHDESSEL	0x01000000 /* Alternate (Enhanced Descriptor) */
-#define DMA_HW_FEAT_INTTSEN	0x02000000 /* Timestamping with Internal
-					      System Time */
-#define DMA_HW_FEAT_FLEXIPPSEN	0x04000000 /* Flexible PPS Output */
-#define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
-#define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
+#define DMA_HW_FEAT_MIISEL	0x00000001	/* 10/100 Mbps Support */
+#define DMA_HW_FEAT_GMIISEL	0x00000002	/* 1000 Mbps Support */
+#define DMA_HW_FEAT_HDSEL	0x00000004	/* Half-Duplex Support */
+#define DMA_HW_FEAT_EXTHASHEN	0x00000008	/* Expanded DA Hash Filter */
+#define DMA_HW_FEAT_HASHSEL	0x00000010	/* HASH Filter */
+#define DMA_HW_FEAT_ADDMAC	0x00000020	/* Multiple MAC Addr Reg */
+#define DMA_HW_FEAT_PCSSEL	0x00000040	/* PCS registers */
+#define DMA_HW_FEAT_L3L4FLTREN	0x00000080	/* Layer 3 & Layer 4 Feature */
+#define DMA_HW_FEAT_SMASEL	0x00000100	/* SMA(MDIO) Interface */
+#define DMA_HW_FEAT_RWKSEL	0x00000200	/* PMT Remote Wakeup */
+#define DMA_HW_FEAT_MGKSEL	0x00000400	/* PMT Magic Packet */
+#define DMA_HW_FEAT_MMCSEL	0x00000800	/* RMON Module */
+#define DMA_HW_FEAT_TSVER1SEL	0x00001000	/* Only IEEE 1588-2002 */
+#define DMA_HW_FEAT_TSVER2SEL	0x00002000	/* IEEE 1588-2008 PTPv2 */
+#define DMA_HW_FEAT_EEESEL	0x00004000	/* Energy Efficient Ethernet */
+#define DMA_HW_FEAT_AVSEL	0x00008000	/* AV Feature */
+#define DMA_HW_FEAT_TXCOESEL	0x00010000	/* Checksum Offload in Tx */
+#define DMA_HW_FEAT_RXTYP1COE	0x00020000	/* IP COE (Type 1) in Rx */
+#define DMA_HW_FEAT_RXTYP2COE	0x00040000	/* IP COE (Type 2) in Rx */
+#define DMA_HW_FEAT_RXFIFOSIZE	0x00080000	/* Rx FIFO > 2048 Bytes */
+#define DMA_HW_FEAT_RXCHCNT	0x00300000	/* No. additional Rx Channels */
+#define DMA_HW_FEAT_TXCHCNT	0x00c00000	/* No. additional Tx Channels */
+#define DMA_HW_FEAT_ENHDESSEL	0x01000000	/* Alternate Descriptor */
+/* Timestamping with Internal System Time */
+#define DMA_HW_FEAT_INTTSEN	0x02000000
+#define DMA_HW_FEAT_FLEXIPPSEN	0x04000000	/* Flexible PPS Output */
+#define DMA_HW_FEAT_SAVLANINS	0x08000000	/* Source Addr or VLAN */
+#define DMA_HW_FEAT_ACTPHYIF	0x70000000	/* Active/selected PHY iface */
 #define DEFAULT_DMA_PBL		8
 
 /* Max/Min RI Watchdog Timer count value */
@@ -216,7 +216,8 @@ struct stmmac_extra_stats {
 #define STMMAC_TX_MAX_FRAMES	256
 #define STMMAC_TX_FRAMES	64
 
-enum rx_frame_status { /* IPC status */
+/* Rx IPC status */
+enum rx_frame_status {
 	good_frame = 0,
 	discard_frame = 1,
 	csum_none = 2,
@@ -261,9 +262,9 @@ struct dma_features {
 	unsigned int pmt_remote_wake_up;
 	unsigned int pmt_magic_frame;
 	unsigned int rmon;
-	/* IEEE 1588-2002*/
+	/* IEEE 1588-2002 */
 	unsigned int time_stamp;
-	/* IEEE 1588-2008*/
+	/* IEEE 1588-2008 */
 	unsigned int atime_stamp;
 	/* 802.3az - Energy-Efficient Ethernet (EEE) */
 	unsigned int eee;
@@ -276,7 +277,7 @@ struct dma_features {
 	/* TX and RX number of channels */
 	unsigned int number_rx_channel;
 	unsigned int number_tx_channel;
-	/* Alternate (enhanced) DESC mode*/
+	/* Alternate (enhanced) DESC mode */
 	unsigned int enh_desc;
 };
 
@@ -344,7 +345,7 @@ struct stmmac_desc_ops {
 	/* get tx timestamp status */
 	int (*get_tx_timestamp_status) (struct dma_desc *p);
 	/* get timestamp value */
-	u64 (*get_timestamp) (void *desc, u32 ats);
+	 u64(*get_timestamp) (void *desc, u32 ats);
 	/* get rx timestamp status */
 	int (*get_rx_timestamp_status) (void *desc, u32 ats);
 };
@@ -378,7 +379,7 @@ struct stmmac_dma_ops {
 
 struct stmmac_ops {
 	/* MAC core initialization */
-	void (*core_init) (void __iomem *ioaddr) ____cacheline_aligned;
+	void (*core_init) (void __iomem *ioaddr);
 	/* Enable and verify that the IPC module is supported */
 	int (*rx_ipc) (void __iomem *ioaddr);
 	/* Dump MAC registers */
@@ -410,10 +411,10 @@ struct stmmac_hwtimestamp {
 	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
 	void (*config_sub_second_increment) (void __iomem *ioaddr);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
-	int (*config_addend)(void __iomem *ioaddr, u32 addend);
-	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
-			      int add_sub);
-	u64 (*get_systime)(void __iomem *ioaddr);
+	int (*config_addend) (void __iomem *ioaddr, u32 addend);
+	int (*adjust_systime) (void __iomem *ioaddr, u32 sec, u32 nsec,
+			       int add_sub);
+	 u64(*get_systime) (void __iomem *ioaddr);
 };
 
 struct mac_link {
@@ -446,11 +447,11 @@ struct stmmac_chain_mode_ops {
 };
 
 struct mac_device_info {
-	const struct stmmac_ops		*mac;
-	const struct stmmac_desc_ops	*desc;
-	const struct stmmac_dma_ops	*dma;
-	const struct stmmac_ring_mode_ops	*ring;
-	const struct stmmac_chain_mode_ops	*chain;
+	const struct stmmac_ops *mac;
+	const struct stmmac_desc_ops *desc;
+	const struct stmmac_dma_ops *dma;
+	const struct stmmac_ring_mode_ops *ring;
+	const struct stmmac_chain_mode_ops *chain;
 	const struct stmmac_hwtimestamp *ptp;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 2eca0c0..ad39960 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -192,9 +192,9 @@ struct dma_extended_desc {
 			u32 reserved;
 		} etx;
 	} des4;
-	unsigned int des5; /* Reserved */
-	unsigned int des6; /* Tx/Rx Timestamp Low */
-	unsigned int des7; /* Tx/Rx Timestamp High */
+	unsigned int des5;	/* Reserved */
+	unsigned int des6;	/* Tx/Rx Timestamp Low */
+	unsigned int des7;	/* Tx/Rx Timestamp High */
 };
 
 /* Transmit checksum insertion control */
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
index 20f83fc..6f2cc78 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs_com.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs_com.h
@@ -117,8 +117,7 @@ static inline void ndesc_rx_set_on_chain(struct dma_desc *p, int end)
 	p->des01.rx.second_address_chained = 1;
 }
 
-static inline void ndesc_tx_set_on_chain(struct dma_desc *p, int
-						 ring_size)
+static inline void ndesc_tx_set_on_chain(struct dma_desc *p, int ring_size)
 {
 	p->des01.tx.second_address_chained = 1;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 57f4e8f..c12aabb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -99,18 +99,18 @@ enum power_event {
 #define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
 
 /* AN Configuration defines */
-#define GMAC_AN_CTRL_RAN	0x00000200 /* Restart Auto-Negotiation */
-#define GMAC_AN_CTRL_ANE	0x00001000 /* Auto-Negotiation Enable */
-#define GMAC_AN_CTRL_ELE	0x00004000 /* External Loopback Enable */
-#define GMAC_AN_CTRL_ECD	0x00010000 /* Enable Comma Detect */
-#define GMAC_AN_CTRL_LR	0x00020000 /* Lock to Reference */
-#define GMAC_AN_CTRL_SGMRAL	0x00040000 /* SGMII RAL Control */
+#define GMAC_AN_CTRL_RAN	0x00000200	/* Restart Auto-Negotiation */
+#define GMAC_AN_CTRL_ANE	0x00001000	/* Auto-Negotiation Enable */
+#define GMAC_AN_CTRL_ELE	0x00004000	/* External Loopback Enable */
+#define GMAC_AN_CTRL_ECD	0x00010000	/* Enable Comma Detect */
+#define GMAC_AN_CTRL_LR		0x00020000	/* Lock to Reference */
+#define GMAC_AN_CTRL_SGMRAL	0x00040000	/* SGMII RAL Control */
 
 /* AN Status defines */
-#define GMAC_AN_STATUS_LS	0x00000004 /* Link Status 0:down 1:up */
-#define GMAC_AN_STATUS_ANA	0x00000008 /* Auto-Negotiation Ability */
-#define GMAC_AN_STATUS_ANC	0x00000020 /* Auto-Negotiation Complete */
-#define GMAC_AN_STATUS_ES	0x00000100 /* Extended Status */
+#define GMAC_AN_STATUS_LS	0x00000004	/* Link Status 0:down 1:up */
+#define GMAC_AN_STATUS_ANA	0x00000008	/* Auto-Negotiation Ability */
+#define GMAC_AN_STATUS_ANC	0x00000020	/* Auto-Negotiation Complete */
+#define GMAC_AN_STATUS_ES	0x00000100	/* Extended Status */
 
 /* Register 54 (SGMII/RGMII status register) */
 #define GMAC_S_R_GMII_LINK		0x8
@@ -127,8 +127,8 @@ enum power_event {
 #define GMAC_ANE_PSE_SHIFT	7
 
  /* GMAC Configuration defines */
-#define GMAC_CONTROL_TC	0x01000000 /* Transmit Conf. in RGMII/SGMII */
-#define GMAC_CONTROL_WD	0x00800000 /* Disable Watchdog on receive */
+#define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
+#define GMAC_CONTROL_WD	0x00800000	/* Disable Watchdog on receive */
 
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
@@ -141,19 +141,19 @@ enum inter_frame_gap {
 	GMAC_CONTROL_IFG_80 = 0x00020000,
 	GMAC_CONTROL_IFG_40 = 0x000e0000,
 };
-#define GMAC_CONTROL_DCRS	0x00010000 /* Disable carrier sense during tx */
-#define GMAC_CONTROL_PS		0x00008000 /* Port Select 0:GMI 1:MII */
-#define GMAC_CONTROL_FES	0x00004000 /* Speed 0:10 1:100 */
-#define GMAC_CONTROL_DO		0x00002000 /* Disable Rx Own */
-#define GMAC_CONTROL_LM		0x00001000 /* Loop-back mode */
-#define GMAC_CONTROL_DM		0x00000800 /* Duplex Mode */
-#define GMAC_CONTROL_IPC	0x00000400 /* Checksum Offload */
-#define GMAC_CONTROL_DR		0x00000200 /* Disable Retry */
-#define GMAC_CONTROL_LUD	0x00000100 /* Link up/down */
-#define GMAC_CONTROL_ACS	0x00000080 /* Automatic Pad/FCS Stripping */
-#define GMAC_CONTROL_DC		0x00000010 /* Deferral Check */
-#define GMAC_CONTROL_TE		0x00000008 /* Transmitter Enable */
-#define GMAC_CONTROL_RE		0x00000004 /* Receiver Enable */
+#define GMAC_CONTROL_DCRS	0x00010000	/* Disable carrier sense */
+#define GMAC_CONTROL_PS		0x00008000	/* Port Select 0:GMI 1:MII */
+#define GMAC_CONTROL_FES	0x00004000	/* Speed 0:10 1:100 */
+#define GMAC_CONTROL_DO		0x00002000	/* Disable Rx Own */
+#define GMAC_CONTROL_LM		0x00001000	/* Loop-back mode */
+#define GMAC_CONTROL_DM		0x00000800	/* Duplex Mode */
+#define GMAC_CONTROL_IPC	0x00000400	/* Checksum Offload */
+#define GMAC_CONTROL_DR		0x00000200	/* Disable Retry */
+#define GMAC_CONTROL_LUD	0x00000100	/* Link up/down */
+#define GMAC_CONTROL_ACS	0x00000080	/* Auto Pad/FCS Stripping */
+#define GMAC_CONTROL_DC		0x00000010	/* Deferral Check */
+#define GMAC_CONTROL_TE		0x00000008	/* Transmitter Enable */
+#define GMAC_CONTROL_RE		0x00000004	/* Receiver Enable */
 
 #define GMAC_CORE_INIT (GMAC_CONTROL_JD | GMAC_CONTROL_PS | GMAC_CONTROL_ACS | \
 			GMAC_CONTROL_JE | GMAC_CONTROL_BE)
@@ -184,16 +184,16 @@ enum inter_frame_gap {
 #define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
 #define DMA_BUS_MODE_DA		0x00000002	/* Arbitration scheme */
 #define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
-#define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
+#define DMA_BUS_MODE_DSL_SHIFT	2		/*   (in DWORDS)      */
 /* Programmable burst length (passed thorugh platform)*/
 #define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
 #define DMA_BUS_MODE_PBL_SHIFT	8
 #define DMA_BUS_MODE_ATDS	0x00000080	/* Alternate Descriptor Size */
 
 enum rx_tx_priority_ratio {
-	double_ratio = 0x00004000,	/*2:1 */
-	triple_ratio = 0x00008000,	/*3:1 */
-	quadruple_ratio = 0x0000c000,	/*4:1 */
+	double_ratio = 0x00004000,	/* 2:1 */
+	triple_ratio = 0x00008000,	/* 3:1 */
+	quadruple_ratio = 0x0000c000,	/* 4:1 */
 };
 
 #define DMA_BUS_MODE_FB		0x00010000	/* Fixed burst */
@@ -213,9 +213,10 @@ enum rx_tx_priority_ratio {
 #define DMA_BUS_FB	  	  0x00010000	/* Fixed Burst */
 
 /* DMA operation mode defines (start/stop tx/rx are placed in common header)*/
-#define DMA_CONTROL_DT		0x04000000 /* Disable Drop TCP/IP csum error */
-#define DMA_CONTROL_RSF		0x02000000 /* Receive Store and Forward */
-#define DMA_CONTROL_DFF		0x01000000 /* Disaable flushing */
+/* Disable Drop TCP/IP csum error */
+#define DMA_CONTROL_DT		0x04000000
+#define DMA_CONTROL_RSF		0x02000000	/* Receive Store and Forward */
+#define DMA_CONTROL_DFF		0x01000000	/* Disaable flushing */
 /* Threshold for Activating the FC */
 enum rfa {
 	act_full_minus_1 = 0x00800000,
@@ -230,7 +231,7 @@ enum rfd {
 	deac_full_minus_3 = 0x00401000,
 	deac_full_minus_4 = 0x00401800,
 };
-#define DMA_CONTROL_TSF		0x00200000 /* Transmit  Store and Forward */
+#define DMA_CONTROL_TSF	0x00200000	/* Transmit  Store and Forward */
 
 enum ttc_control {
 	DMA_CONTROL_TTC_64 = 0x00000000,
@@ -264,7 +265,5 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
-
-
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
 #endif /* __DWMAC1000_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 29138da..7e05e8d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -72,22 +72,22 @@ static void dwmac1000_dump_regs(void __iomem *ioaddr)
 }
 
 static void dwmac1000_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
-				unsigned int reg_n)
+				    unsigned int reg_n)
 {
 	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
-				GMAC_ADDR_LOW(reg_n));
+			    GMAC_ADDR_LOW(reg_n));
 }
 
 static void dwmac1000_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
-				unsigned int reg_n)
+				    unsigned int reg_n)
 {
 	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
-				GMAC_ADDR_LOW(reg_n));
+			    GMAC_ADDR_LOW(reg_n));
 }
 
 static void dwmac1000_set_filter(struct net_device *dev, int id)
 {
-	void __iomem *ioaddr = (void __iomem *) dev->base_addr;
+	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
 	unsigned int value = 0;
 	unsigned int perfect_addr_number;
 
@@ -97,7 +97,7 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
 	else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
-		   || (dev->flags & IFF_ALLMULTI)) {
+		 || (dev->flags & IFF_ALLMULTI)) {
 		value = GMAC_FRAME_FILTER_PM;	/* pass all multi */
 		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
 		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
@@ -111,12 +111,13 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 		memset(mc_filter, 0, sizeof(mc_filter));
 		netdev_for_each_mc_addr(ha, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
-			   index the contens of the hash table */
-			int bit_nr =
-			    bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
+			 * index the contens of the hash table
+			 */
+			int bit_nr = bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
 			/* The most significant bit determines the register to
 			 * use (H/L) while the other 5 bits determine the bit
-			 * within the register. */
+			 * within the register.
+			 */
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
 		writel(mc_filter[0], ioaddr + GMAC_HASH_LOW);
@@ -129,10 +130,11 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 	else
 		perfect_addr_number = GMAC_MAX_PERFECT_ADDRESSES / 2;
 
-	/* Handle multiple unicast addresses (perfect filtering)*/
+	/* Handle multiple unicast addresses (perfect filtering) */
 	if (netdev_uc_count(dev) > perfect_addr_number)
-		/* Switch to promiscuous mode is more than 16 addrs
-		   are required */
+		/* Switch to promiscuous mode if more than 16 addrs
+		 * are required
+		 */
 		value |= GMAC_FRAME_FILTER_PR;
 	else {
 		int reg = 1;
@@ -150,13 +152,13 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 #endif
 	writel(value, ioaddr + GMAC_FRAME_FILTER);
 
-	CHIP_DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
-	    "HI 0x%08x, LO 0x%08x\n", readl(ioaddr + GMAC_FRAME_FILTER),
-	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
+	CHIP_DBG(KERN_INFO "\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+		 readl(ioaddr + GMAC_FRAME_FILTER),
+		 readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
 }
 
 static void dwmac1000_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
-			   unsigned int fc, unsigned int pause_time)
+				unsigned int fc, unsigned int pause_time)
 {
 	unsigned int flow = 0;
 
@@ -203,23 +205,22 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 	/* Not used events (e.g. MMC interrupts) are not handled. */
 	if ((intr_status & mmc_tx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC tx interrupt: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_TX_INTR));
+			 readl(ioaddr + GMAC_MMC_TX_INTR));
 		x->mmc_tx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx interrupt: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_RX_INTR));
+			 readl(ioaddr + GMAC_MMC_RX_INTR));
 		x->mmc_rx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_csum_offload_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx csum offload: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
+			 readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
 		x->mmc_rx_csum_offload_irq_n++;
 	}
 	if (unlikely(intr_status & pmt_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: received Magic frame\n");
-		/* clear the PMT bits 5 and 6 by reading the PMT
-		 * status register. */
+		/* clear the PMT bits 5 and 6 by reading the PMT status reg */
 		readl(ioaddr + GMAC_PMT);
 		x->irq_receive_pmt_irq_n++;
 	}
@@ -252,14 +253,14 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 		x->irq_pcs_ane_n++;
 	}
 	if (intr_status & rgmii_irq) {
-		u32 status  = readl(ioaddr + GMAC_S_R_GMII);
+		u32 status = readl(ioaddr + GMAC_S_R_GMII);
 		CHIP_DBG(KERN_INFO "GMAC RGMII/SGMII interrupt\n");
 		x->irq_rgmii_n++;
 
 		/* Save and dump the link status. */
 		if (status & GMAC_S_R_GMII_LINK) {
 			int speed_value = (status & GMAC_S_R_GMII_SPEED) >>
-					  GMAC_S_R_GMII_SPEED_SHIFT;
+			    GMAC_S_R_GMII_SPEED_SHIFT;
 			x->pcs_duplex = (status & GMAC_S_R_GMII_MODE);
 
 			if (speed_value == GMAC_S_R_GMII_SPEED_125)
@@ -270,7 +271,7 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 				x->pcs_speed = SPEED_10;
 
 			x->pcs_link = 1;
-			pr_debug("Link is Up - %d/%s\n", (int) x->pcs_speed,
+			pr_debug("Link is Up - %d/%s\n", (int)x->pcs_speed,
 				 x->pcs_duplex ? "Full" : "Half");
 		} else {
 			x->pcs_link = 0;
@@ -281,19 +282,20 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 	return ret;
 }
 
-static void  dwmac1000_set_eee_mode(void __iomem *ioaddr)
+static void dwmac1000_set_eee_mode(void __iomem *ioaddr)
 {
 	u32 value;
 
 	/* Enable the link status receive on RGMII, SGMII ore SMII
 	 * receive path and instruct the transmit to enter in LPI
-	 * state. */
+	 * state.
+	 */
 	value = readl(ioaddr + LPI_CTRL_STATUS);
 	value |= LPI_CTRL_STATUS_LPIEN | LPI_CTRL_STATUS_LPITXA;
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void  dwmac1000_reset_eee_mode(void __iomem *ioaddr)
+static void dwmac1000_reset_eee_mode(void __iomem *ioaddr)
 {
 	u32 value;
 
@@ -302,7 +304,7 @@ static void  dwmac1000_reset_eee_mode(void __iomem *ioaddr)
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void  dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
+static void dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
 {
 	u32 value;
 
@@ -316,7 +318,7 @@ static void  dwmac1000_set_eee_pls(void __iomem *ioaddr, int link)
 	writel(value, ioaddr + LPI_CTRL_STATUS);
 }
 
-static void  dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
+static void dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
 {
 	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
 
@@ -375,10 +377,10 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.pmt = dwmac1000_pmt,
 	.set_umac_addr = dwmac1000_set_umac_addr,
 	.get_umac_addr = dwmac1000_get_umac_addr,
-	.set_eee_mode =  dwmac1000_set_eee_mode,
-	.reset_eee_mode =  dwmac1000_reset_eee_mode,
-	.set_eee_timer =  dwmac1000_set_eee_timer,
-	.set_eee_pls =  dwmac1000_set_eee_pls,
+	.set_eee_mode = dwmac1000_set_eee_mode,
+	.reset_eee_mode = dwmac1000_reset_eee_mode,
+	.set_eee_timer = dwmac1000_set_eee_timer,
+	.set_eee_pls = dwmac1000_set_eee_pls,
 	.ctrl_ane = dwmac1000_ctrl_ane,
 	.get_adv = dwmac1000_get_adv,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index f1c4b2c..2c431b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -60,7 +60,7 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	 * depending on pbl value.
 	 */
 	value = DMA_BUS_MODE_PBL | ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
-		(pbl << DMA_BUS_MODE_RPBL_SHIFT));
+				    (pbl << DMA_BUS_MODE_RPBL_SHIFT));
 
 	/* Set the Fixed burst mode */
 	if (fb)
@@ -94,14 +94,16 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	 *
 	 *  For Non Fixed Burst Mode: provide the maximum value of the
 	 *  burst length. Any burst equal or below the provided burst
-	 *  length would be allowed to perform. */
+	 *  length would be allowed to perform.
+	 */
 	writel(burst_len, ioaddr + DMA_AXI_BUS_MODE);
 
 	/* Mask interrupts by writing to CSR7 */
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
 
-	/* The base address of the RX/TX descriptor lists must be written into
-	 * DMA CSR3 and CSR4, respectively. */
+	/* RX/TX descriptor base address lists must be written into
+	 * DMA CSR3 and CSR4, respectively
+	 */
 	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
 	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
 
@@ -109,7 +111,7 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 }
 
 static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
-				    int rxmode)
+					 int rxmode)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
@@ -118,11 +120,12 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 		/* Transmit COE type 2 cannot be done in cut-through mode. */
 		csr6 |= DMA_CONTROL_TSF;
 		/* Operating on second frame increase the performance
-		 * especially when transmit store-and-forward is used.*/
+		 * especially when transmit store-and-forward is used.
+		 */
 		csr6 |= DMA_CONTROL_OSF;
 	} else {
-		CHIP_DBG(KERN_DEBUG "GMAC: disabling TX store and forward mode"
-			      " (threshold = %d)\n", txmode);
+		CHIP_DBG(KERN_DEBUG "GMAC: disabling TX SF (threshold %d)\n",
+			 txmode);
 		csr6 &= ~DMA_CONTROL_TSF;
 		csr6 &= DMA_CONTROL_TC_TX_MASK;
 		/* Set the transmit threshold */
@@ -142,8 +145,8 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 		CHIP_DBG(KERN_DEBUG "GMAC: enable RX store and forward mode\n");
 		csr6 |= DMA_CONTROL_RSF;
 	} else {
-		CHIP_DBG(KERN_DEBUG "GMAC: disabling RX store and forward mode"
-			      " (threshold = %d)\n", rxmode);
+		CHIP_DBG(KERN_DEBUG "GMAC: disable RX SF mode (threshold %d)\n",
+			 rxmode);
 		csr6 &= ~DMA_CONTROL_RSF;
 		csr6 &= DMA_CONTROL_TC_RX_MASK;
 		if (rxmode <= 32)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index cb86a58..007bb2b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -47,8 +47,7 @@ static void dwmac100_dump_mac_regs(void __iomem *ioaddr)
 {
 	pr_info("\t----------------------------------------------\n"
 		"\t  DWMAC 100 CSR (base addr = 0x%p)\n"
-		"\t----------------------------------------------\n",
-		ioaddr);
+		"\t----------------------------------------------\n", ioaddr);
 	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
 		readl(ioaddr + MAC_CONTROL));
 	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
@@ -92,7 +91,7 @@ static void dwmac100_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
 
 static void dwmac100_set_filter(struct net_device *dev, int id)
 {
-	void __iomem *ioaddr = (void __iomem *) dev->base_addr;
+	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
 	u32 value = readl(ioaddr + MAC_CONTROL);
 
 	if (dev->flags & IFF_PROMISC) {
@@ -113,7 +112,8 @@ static void dwmac100_set_filter(struct net_device *dev, int id)
 		struct netdev_hw_addr *ha;
 
 		/* Perfect filter mode for physical address and Hash
-		   filter for multicast */
+		 * filter for multicast
+		 */
 		value |= MAC_CONTROL_HP;
 		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR |
 			   MAC_CONTROL_IF | MAC_CONTROL_HO);
@@ -121,12 +121,13 @@ static void dwmac100_set_filter(struct net_device *dev, int id)
 		memset(mc_filter, 0, sizeof(mc_filter));
 		netdev_for_each_mc_addr(ha, dev) {
 			/* The upper 6 bits of the calculated CRC are used to
-			 * index the contens of the hash table */
-			int bit_nr =
-			    ether_crc(ETH_ALEN, ha->addr) >> 26;
+			 * index the contens of the hash table
+			 */
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			/* The most significant bit determines the register to
 			 * use (H/L) while the other 5 bits determine the bit
-			 * within the register. */
+			 * within the register.
+			 */
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 		}
 		writel(mc_filter[0], ioaddr + MAC_HASH_LOW);
@@ -135,10 +136,9 @@ static void dwmac100_set_filter(struct net_device *dev, int id)
 
 	writel(value, ioaddr + MAC_CONTROL);
 
-	CHIP_DBG(KERN_INFO "%s: CTRL reg: 0x%08x Hash regs: "
-	    "HI 0x%08x, LO 0x%08x\n",
-	    __func__, readl(ioaddr + MAC_CONTROL),
-	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
+	CHIP_DBG(KERN_INFO "%s: Filter: 0x%08x Hash: HI 0x%08x, LO 0x%08x\n",
+		 __func__, readl(ioaddr + MAC_CONTROL),
+		 readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
 }
 
 static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
@@ -151,9 +151,7 @@ static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 	writel(flow, ioaddr + MAC_FLOW_CTRL);
 }
 
-/* No PMT module supported for this Ethernet Controller.
- * Tested on ST platforms only.
- */
+/* No PMT module supported on ST boards with this Eth chip. */
 static void dwmac100_pmt(void __iomem *ioaddr, unsigned long mode)
 {
 	return;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index e979a8b..67551c1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -52,22 +52,25 @@ static int dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 
 	/* Enable Application Access by writing to DMA CSR0 */
 	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
-			ioaddr + DMA_BUS_MODE);
+	       ioaddr + DMA_BUS_MODE);
 
 	/* Mask interrupts by writing to CSR7 */
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
 
-	/* The base address of the RX/TX descriptor lists must be written into
-	 * DMA CSR3 and CSR4, respectively. */
+	/* RX/TX descriptor base addr lists must be written into
+	 * DMA CSR3 and CSR4, respectively
+	 */
 	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
 	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
 
 	return 0;
 }
 
-/* Store and Forward capability is not used at all..
- * The transmit threshold can be programmed by
- * setting the TTC bits in the DMA control register.*/
+/* Store and Forward capability is not used at all.
+ *
+ * The transmit threshold can be programmed by setting the TTC bits in the DMA
+ * control register.
+ */
 static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
 					int rxmode)
 {
@@ -90,16 +93,15 @@ static void dwmac100_dump_dma_regs(void __iomem *ioaddr)
 	CHIP_DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
 	for (i = 0; i < 9; i++)
 		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
-		       (DMA_BUS_MODE + i * 4),
-		       readl(ioaddr + DMA_BUS_MODE + i * 4));
+			 (DMA_BUS_MODE + i * 4),
+			 readl(ioaddr + DMA_BUS_MODE + i * 4));
 	CHIP_DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
-	    DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
+		 DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
 	CHIP_DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
-	    DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
+		 DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
 }
 
-/* DMA controller has two counters to track the number of
- * the receive missed frames. */
+/* DMA controller has two counters to track the number of the missed frames. */
 static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
 				       void __iomem *ioaddr)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index ab4896e..8e5662c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -102,7 +102,7 @@
 #define DMA_STATUS_TU	0x00000004	/* Transmit Buffer Unavailable */
 #define DMA_STATUS_TPS	0x00000002	/* Transmit Process Stopped */
 #define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
-#define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
+#define DMA_CONTROL_FTF		0x00100000	/* Flush transmit FIFO */
 
 extern void dwmac_enable_dma_transmission(void __iomem *ioaddr);
 extern void dwmac_enable_dma_irq(void __iomem *ioaddr);
@@ -112,6 +112,6 @@ extern void dwmac_dma_stop_tx(void __iomem *ioaddr);
 extern void dwmac_dma_start_rx(void __iomem *ioaddr);
 extern void dwmac_dma_stop_rx(void __iomem *ioaddr);
 extern int dwmac_dma_interrupt(void __iomem *ioaddr,
-				struct stmmac_extra_stats *x);
+			       struct stmmac_extra_stats *x);
 
 #endif /* __DWMAC_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 67995ef..48ec001 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -28,8 +28,7 @@
 /* MMC control register */
 /* When set, all counter are reset */
 #define MMC_CNTRL_COUNTER_RESET		0x1
-/* When set, do not roll over zero
- * after reaching the max value*/
+/* When set, do not roll over zero after reaching the max value*/
 #define MMC_CNTRL_COUNTER_STOP_ROLLOVER	0x2
 #define MMC_CNTRL_RESET_ON_READ		0x4	/* Reset after reading */
 #define MMC_CNTRL_COUNTER_FREEZER	0x8	/* Freeze counter values to the
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 7cbcea3..11775b9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -79,8 +79,8 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
 	if (unlikely(p->des01.rx.last_descriptor == 0)) {
-		pr_warning("ndesc Error: Oversized Ethernet "
-			   "frame spanned multiple buffers\n");
+		pr_warn("%s: Oversized frame spanned multiple buffers\n",
+			__func__);
 		stats->rx_length_errors++;
 		return discard_frame;
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index d0265a7..c9d942a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -30,7 +30,7 @@
 
 static unsigned int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *) p;
+	struct stmmac_priv *priv = (struct stmmac_priv *)p;
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int entry = priv->cur_tx % txsize;
 	struct dma_desc *desc = priv->dma_tx + entry;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 75f997b..77d534a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -142,6 +142,7 @@ static inline int stmmac_register_platform(void)
 
 	return err;
 }
+
 static inline void stmmac_unregister_platform(void)
 {
 	platform_driver_unregister(&stmmac_pltfr_driver);
@@ -153,6 +154,7 @@ static inline int stmmac_register_platform(void)
 
 	return 0;
 }
+
 static inline void stmmac_unregister_platform(void)
 {
 }
@@ -170,6 +172,7 @@ static inline int stmmac_register_pci(void)
 
 	return err;
 }
+
 static inline void stmmac_unregister_pci(void)
 {
 	pci_unregister_driver(&stmmac_pci_driver);
@@ -181,6 +184,7 @@ static inline int stmmac_register_pci(void)
 
 	return 0;
 }
+
 static inline void stmmac_unregister_pci(void)
 {
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index caee7fd..5d336e7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -46,7 +46,7 @@
 #ifdef CONFIG_STMMAC_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
-#endif
+#endif /* CONFIG_STMMAC_DEBUG_FS */
 #include <linux/net_tstamp.h>
 #include "stmmac_ptp.h"
 #include "stmmac.h"
@@ -192,7 +192,12 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 	clk_rate = clk_get_rate(priv->stmmac_clk);
 
 	/* Platform provided default clk_csr would be assumed valid
-	 * for all other cases except for the below mentioned ones. */
+	 * for all other cases except for the below mentioned ones.
+	 * For values higher than the IEEE 802.3 specified frequency
+	 * we can not estimate the proper divider as it is not known
+	 * the frequency of clk_csr_i. So we do not change the default
+	 * divider.
+	 */
 	if (!(priv->clk_csr & MAC_CSR_H_FRQ_MASK)) {
 		if (clk_rate < CSR_F_35M)
 			priv->clk_csr = STMMAC_CSR_20_35M;
@@ -206,10 +211,7 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 			priv->clk_csr = STMMAC_CSR_150_250M;
 		else if ((clk_rate >= CSR_F_250M) && (clk_rate < CSR_F_300M))
 			priv->clk_csr = STMMAC_CSR_250_300M;
-	} /* For values higher than the IEEE 802.3 specified frequency
-	   * we can not estimate the proper divider as it is not known
-	   * the frequency of clk_csr_i. So we do not change the default
-	   * divider. */
+	}
 }
 
 #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
@@ -245,8 +247,7 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 	struct phy_device *phydev = priv->phydev;
 
 	if (likely(priv->plat->fix_mac_speed))
-		priv->plat->fix_mac_speed(priv->plat->bsp_priv,
-					  phydev->speed);
+		priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
 }
 
 /**
@@ -351,8 +352,7 @@ static void stmmac_eee_adjust(struct stmmac_priv *priv)
  * and also perform some sanity checks.
  */
 static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
-				   unsigned int entry,
-				   struct sk_buff *skb)
+				   unsigned int entry, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps shhwtstamp;
 	u64 ns;
@@ -361,7 +361,7 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 	if (!priv->hwts_tx_en)
 		return;
 
-	/* if skb doesn't support hw tstamp */
+	/* exit if skb doesn't support hw tstamp */
 	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
 		return;
 
@@ -394,8 +394,7 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
  * and pass it to stack. It also perform some sanity checks.
  */
 static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv,
-				   unsigned int entry,
-				   struct sk_buff *skb)
+				   unsigned int entry, struct sk_buff *skb)
 {
 	struct skb_shared_hwtstamps *shhwtstamp = NULL;
 	u64 ns;
@@ -409,7 +408,7 @@ static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv,
 	else
 		desc = (priv->dma_rx + entry);
 
-	/* if rx tstamp is not valid */
+	/* exit if rx tstamp is not valid */
 	if (!priv->hw->desc->get_rx_timestamp_status(desc, priv->adv_ts))
 		return;
 
@@ -456,7 +455,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	}
 
 	if (copy_from_user(&config, ifr->ifr_data,
-		sizeof(struct hwtstamp_config)))
+			   sizeof(struct hwtstamp_config)))
 		return -EFAULT;
 
 	pr_debug("%s config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
@@ -479,13 +478,13 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 
 	if (priv->adv_ts) {
 		switch (config.rx_filter) {
-		/* time stamp no incoming packet at all */
 		case HWTSTAMP_FILTER_NONE:
+			/* time stamp no incoming packet at all */
 			config.rx_filter = HWTSTAMP_FILTER_NONE;
 			break;
 
-		/* PTP v1, UDP, any kind of event packet */
 		case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+			/* PTP v1, UDP, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
 			/* take time stamp for all event messages */
 			snap_type_sel = PTP_TCR_SNAPTYPSEL_1;
@@ -494,8 +493,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v1, UDP, Sync packet */
 		case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+			/* PTP v1, UDP, Sync packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_SYNC;
 			/* take time stamp for SYNC messages only */
 			ts_event_en = PTP_TCR_TSEVNTENA;
@@ -504,8 +503,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v1, UDP, Delay_req packet */
 		case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+			/* PTP v1, UDP, Delay_req packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ;
 			/* take time stamp for Delay_Req messages only */
 			ts_master_en = PTP_TCR_TSMSTRENA;
@@ -515,8 +514,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v2, UDP, any kind of event packet */
 		case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+			/* PTP v2, UDP, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
@@ -526,8 +525,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v2, UDP, Sync packet */
 		case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+			/* PTP v2, UDP, Sync packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_SYNC;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for SYNC messages only */
@@ -537,8 +536,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v2, UDP, Delay_req packet */
 		case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+			/* PTP v2, UDP, Delay_req packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for Delay_Req messages only */
@@ -549,8 +548,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ipv6_udp = PTP_TCR_TSIPV6ENA;
 			break;
 
-		/* PTP v2/802.AS1, any layer, any kind of event packet */
 		case HWTSTAMP_FILTER_PTP_V2_EVENT:
+			/* PTP v2/802.AS1 any layer, any kind of event packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for all event messages */
@@ -561,8 +560,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ethernet = PTP_TCR_TSIPENA;
 			break;
 
-		/* PTP v2/802.AS1, any layer, Sync packet */
 		case HWTSTAMP_FILTER_PTP_V2_SYNC:
+			/* PTP v2/802.AS1, any layer, Sync packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_SYNC;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for SYNC messages only */
@@ -573,8 +572,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ethernet = PTP_TCR_TSIPENA;
 			break;
 
-		/* PTP v2/802.AS1, any layer, Delay_req packet */
 		case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+			/* PTP v2/802.AS1, any layer, Delay_req packet */
 			config.rx_filter = HWTSTAMP_FILTER_PTP_V2_DELAY_REQ;
 			ptp_v2 = PTP_TCR_TSVER2ENA;
 			/* take time stamp for Delay_Req messages only */
@@ -586,8 +585,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			ptp_over_ethernet = PTP_TCR_TSIPENA;
 			break;
 
-		/* time stamp any incoming packet */
 		case HWTSTAMP_FILTER_ALL:
+			/* time stamp any incoming packet */
 			config.rx_filter = HWTSTAMP_FILTER_ALL;
 			tstamp_all = PTP_TCR_TSENALL;
 			break;
@@ -612,9 +611,9 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
 	else {
 		value = (PTP_TCR_TSENA | PTP_TCR_TSCFUPDT | PTP_TCR_TSCTRLSSR |
-			tstamp_all | ptp_v2 | ptp_over_ethernet |
-			ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
-			ts_master_en | snap_type_sel);
+			 tstamp_all | ptp_v2 | ptp_over_ethernet |
+			 ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
+			 ts_master_en | snap_type_sel);
 
 		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
 
@@ -632,7 +631,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 * 2^x * y == (y << x), hence
 		 * 2^32 * 50000000 ==> (50000000 << 32)
 		 */
-		temp = (u64)(50000000ULL << 32);
+		temp = (u64) (50000000ULL << 32);
 		priv->default_addend = div_u64(temp, STMMAC_SYSCLOCK);
 		priv->hw->ptp->config_addend(priv->ioaddr,
 					     priv->default_addend);
@@ -665,7 +664,8 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 			priv->adv_ts = 0;
 		}
 		if (priv->dma_cap.atime_stamp && priv->extend_desc) {
-			pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+			pr_debug
+			    ("IEEE 1588-2008 Advanced Time Stamp supported\n");
 			priv->adv_ts = 1;
 		}
 	}
@@ -727,7 +727,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			case 1000:
 				if (likely(priv->plat->has_gmac))
 					ctrl &= ~priv->hw->link.port;
-					stmmac_hw_fix_mac_speed(priv);
+				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
@@ -745,8 +745,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 				break;
 			default:
 				if (netif_msg_link(priv))
-					pr_warning("%s: Speed (%d) is not 10"
-				       " or 100!\n", dev->name, phydev->speed);
+					pr_warn("%s: Speed (%d) not 10/100\n",
+						dev->name, phydev->speed);
 				break;
 			}
 
@@ -822,10 +822,10 @@ static int stmmac_init_phy(struct net_device *dev)
 
 	if (priv->plat->phy_bus_name)
 		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
-				priv->plat->phy_bus_name, priv->plat->bus_id);
+			 priv->plat->phy_bus_name, priv->plat->bus_id);
 	else
 		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
-				priv->plat->bus_id);
+			 priv->plat->bus_id);
 
 	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
@@ -873,23 +873,23 @@ static int stmmac_init_phy(struct net_device *dev)
 static void stmmac_display_ring(void *head, int size, int extend_desc)
 {
 	int i;
-	struct dma_extended_desc *ep = (struct dma_extended_desc *) head;
-	struct dma_desc *p = (struct dma_desc *) head;
+	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
+	struct dma_desc *p = (struct dma_desc *)head;
 
 	for (i = 0; i < size; i++) {
 		u64 x;
 		if (extend_desc) {
 			x = *(u64 *) ep;
 			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				i, (unsigned int) virt_to_phys(ep),
-				(unsigned int) x, (unsigned int) (x >> 32),
+				i, (unsigned int)virt_to_phys(ep),
+				(unsigned int)x, (unsigned int)(x >> 32),
 				ep->basic.des2, ep->basic.des3);
 			ep++;
 		} else {
 			x = *(u64 *) p;
 			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x",
-				i, (unsigned int) virt_to_phys(p),
-				(unsigned int) x, (unsigned int) (x >> 32),
+				i, (unsigned int)virt_to_phys(p),
+				(unsigned int)x, (unsigned int)(x >> 32),
 				p->des2, p->des3);
 			p++;
 		}
@@ -904,9 +904,9 @@ static void stmmac_display_rings(struct stmmac_priv *priv)
 
 	if (priv->extend_desc) {
 		pr_info("Extended RX descriptor ring:\n");
-		stmmac_display_ring((void *) priv->dma_erx, rxsize, 1);
+		stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
 		pr_info("Extended TX descriptor ring:\n");
-		stmmac_display_ring((void *) priv->dma_etx, txsize, 1);
+		stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
 	} else {
 		pr_info("RX descriptor ring:\n");
 		stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
@@ -1006,7 +1006,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	unsigned int bfsize = 0;
 
 	/* Set the max buffer size according to the DESC mode
-	 * and the MTU. Note that RING mode allows 16KiB bsize. */
+	 * and the MTU. Note that RING mode allows 16KiB bsize.
+	 */
 	if (priv->mode == STMMAC_RING_MODE)
 		bfsize = priv->hw->ring->set_16kib_bfsize(dev->mtu);
 
@@ -1047,7 +1048,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->rx_skbuff = kmalloc_array(rxsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	priv->tx_skbuff_dma = kmalloc_array(txsize, sizeof(dma_addr_t),
-					GFP_KERNEL);
+					    GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
 	if (netif_msg_drv(priv))
@@ -1067,7 +1068,7 @@ static void init_dma_desc_rings(struct net_device *dev)
 			break;
 
 		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
-			priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
+		    priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
 	}
 	priv->cur_rx = 0;
 	priv->dirty_rx = (unsigned int)(i - rxsize);
@@ -1154,8 +1155,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 	dma_free_rx_skbufs(priv);
 	dma_free_tx_skbufs(priv);
 
-	/* Free the region of consistent memory previously allocated for
-	 * the DMA */
+	/* Free DMA regions of consistent memory previously allocated */
 	if (!priv->extend_desc) {
 		dma_free_coherent(priv->device,
 				  priv->dma_tx_size * sizeof(struct dma_desc),
@@ -1186,7 +1186,7 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
 	if (likely(priv->plat->force_sf_dma_mode ||
-		((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
+		   ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
 		/*
 		 * In case of GMAC, SF mode can be enabled
 		 * to perform the TX COE in HW. This depends on:
@@ -1194,8 +1194,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 		 * 2) There is no bugged Jumbo frame support
 		 *    that needs to not insert csum in the TDES.
 		 */
-		priv->hw->dma->dma_mode(priv->ioaddr,
-					SF_DMA_MODE, SF_DMA_MODE);
+		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE);
 		tc = SF_DMA_MODE;
 	} else
 		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE);
@@ -1221,7 +1220,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *) (priv->dma_etx + entry);
+			p = (struct dma_desc *)(priv->dma_etx + entry);
 		else
 			p = priv->dma_tx + entry;
 
@@ -1233,9 +1232,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		last = priv->hw->desc->get_tx_ls(p);
 		if (likely(last)) {
 			int tx_error =
-				priv->hw->desc->tx_status(&priv->dev->stats,
-							  &priv->xstats, p,
-							  priv->ioaddr);
+			    priv->hw->desc->tx_status(&priv->dev->stats,
+						      &priv->xstats, p,
+						      priv->ioaddr);
 			if (likely(tx_error == 0)) {
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
@@ -1245,7 +1244,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
 		TX_DBG("%s: curr %d, dirty %d\n", __func__,
-			priv->cur_tx, priv->dirty_tx);
+		       priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry])) {
 			dma_unmap_single(priv->device,
@@ -1269,7 +1268,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
-		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
+		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
 			TX_DBG("%s: restart transmit\n", __func__);
 			netif_wake_queue(priv->dev);
 		}
@@ -1293,7 +1292,6 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
 	priv->hw->dma->disable_dma_irq(priv->ioaddr);
 }
 
-
 /**
  * stmmac_tx_err: irq tx error mng function
  * @priv: driver private structure
@@ -1363,7 +1361,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 static void stmmac_mmc_setup(struct stmmac_priv *priv)
 {
 	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
-			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
+	    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
 
 	dwmac_mmc_intr_all_mask(priv->ioaddr);
 
@@ -1378,8 +1376,7 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 {
 	u32 hwid = priv->hw->synopsys_uid;
 
-	/* Only check valid Synopsys Id because old MAC chips
-	 * have no HW registers where get the ID */
+	/* Check Synopsys Id (not available on old chips) */
 	if (likely(hwid)) {
 		u32 uid = ((hwid & 0x0000ff00) >> 8);
 		u32 synid = (hwid & 0x000000ff);
@@ -1438,41 +1435,39 @@ static int stmmac_get_hw_features(struct stmmac_priv *priv)
 		priv->dma_cap.mbps_1000 = (hw_cap & DMA_HW_FEAT_GMIISEL) >> 1;
 		priv->dma_cap.half_duplex = (hw_cap & DMA_HW_FEAT_HDSEL) >> 2;
 		priv->dma_cap.hash_filter = (hw_cap & DMA_HW_FEAT_HASHSEL) >> 4;
-		priv->dma_cap.multi_addr =
-			(hw_cap & DMA_HW_FEAT_ADDMACADRSEL) >> 5;
+		priv->dma_cap.multi_addr = (hw_cap & DMA_HW_FEAT_ADDMAC) >> 5;
 		priv->dma_cap.pcs = (hw_cap & DMA_HW_FEAT_PCSSEL) >> 6;
 		priv->dma_cap.sma_mdio = (hw_cap & DMA_HW_FEAT_SMASEL) >> 8;
 		priv->dma_cap.pmt_remote_wake_up =
-			(hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
+		    (hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
 		priv->dma_cap.pmt_magic_frame =
-			(hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
+		    (hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
 		/* MMC */
 		priv->dma_cap.rmon = (hw_cap & DMA_HW_FEAT_MMCSEL) >> 11;
-		/* IEEE 1588-2002*/
+		/* IEEE 1588-2002 */
 		priv->dma_cap.time_stamp =
-			(hw_cap & DMA_HW_FEAT_TSVER1SEL) >> 12;
-		/* IEEE 1588-2008*/
+		    (hw_cap & DMA_HW_FEAT_TSVER1SEL) >> 12;
+		/* IEEE 1588-2008 */
 		priv->dma_cap.atime_stamp =
-			(hw_cap & DMA_HW_FEAT_TSVER2SEL) >> 13;
+		    (hw_cap & DMA_HW_FEAT_TSVER2SEL) >> 13;
 		/* 802.3az - Energy-Efficient Ethernet (EEE) */
 		priv->dma_cap.eee = (hw_cap & DMA_HW_FEAT_EEESEL) >> 14;
 		priv->dma_cap.av = (hw_cap & DMA_HW_FEAT_AVSEL) >> 15;
 		/* TX and RX csum */
 		priv->dma_cap.tx_coe = (hw_cap & DMA_HW_FEAT_TXCOESEL) >> 16;
 		priv->dma_cap.rx_coe_type1 =
-			(hw_cap & DMA_HW_FEAT_RXTYP1COE) >> 17;
+		    (hw_cap & DMA_HW_FEAT_RXTYP1COE) >> 17;
 		priv->dma_cap.rx_coe_type2 =
-			(hw_cap & DMA_HW_FEAT_RXTYP2COE) >> 18;
+		    (hw_cap & DMA_HW_FEAT_RXTYP2COE) >> 18;
 		priv->dma_cap.rxfifo_over_2048 =
-			(hw_cap & DMA_HW_FEAT_RXFIFOSIZE) >> 19;
+		    (hw_cap & DMA_HW_FEAT_RXFIFOSIZE) >> 19;
 		/* TX and RX number of channels */
 		priv->dma_cap.number_rx_channel =
-			(hw_cap & DMA_HW_FEAT_RXCHCNT) >> 20;
+		    (hw_cap & DMA_HW_FEAT_RXCHCNT) >> 20;
 		priv->dma_cap.number_tx_channel =
-			(hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
-		/* Alternate (enhanced) DESC mode*/
-		priv->dma_cap.enh_desc =
-			(hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
+		    (hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
+		/* Alternate (enhanced) DESC mode */
+		priv->dma_cap.enh_desc = (hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
 	}
 
 	return hw_cap;
@@ -1491,11 +1486,11 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 		priv->hw->mac->get_umac_addr((void __iomem *)
 					     priv->dev->base_addr,
 					     priv->dev->dev_addr, 0);
-		if  (!is_valid_ether_addr(priv->dev->dev_addr))
+		if (!is_valid_ether_addr(priv->dev->dev_addr))
 			eth_hw_addr_random(priv->dev);
 	}
-	pr_warning("%s: device MAC address %pM\n", priv->dev->name,
-						   priv->dev->dev_addr);
+	pr_warn("%s: device MAC address %pM\n", priv->dev->name,
+		priv->dev->dev_addr);
 }
 
 /**
@@ -1611,7 +1606,7 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
-			 IRQF_SHARED, dev->name, dev);
+			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
 		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
 		       __func__, dev->irq, ret);
@@ -1623,8 +1618,8 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->wol_irq, stmmac_interrupt,
 				  IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating the ext WoL IRQ %d "
-			       "(error: %d)\n",	__func__, priv->wol_irq, ret);
+			pr_err("%s: ERROR: allocating the WoL IRQ %d (%d)\n",
+			       __func__, priv->wol_irq, ret);
 			goto open_error_wolirq;
 		}
 	}
@@ -1659,7 +1654,7 @@ static int stmmac_open(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
-		pr_warning("%s: failed debugFS registration\n", __func__);
+		pr_warn("%s: failed debugFS registration\n", __func__);
 #endif
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
@@ -1791,8 +1786,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
-			pr_err("%s: BUG! Tx Ring full when queue awake\n",
-				__func__);
+			pr_err("%s: Tx Ring full when queue awake\n", __func__);
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -1806,10 +1800,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef STMMAC_XMIT_DEBUG
 	if ((skb->len > ETH_FRAME_LEN) || nfrags)
-		pr_debug("stmmac xmit: [entry %d]\n"
-			 "\tskb addr %p - len: %d - nopaged_len: %d\n"
+		pr_debug("%s: [entry %d]: skb addr %p len: %d nopagedlen: %d\n"
 			 "\tn_frags: %d - ip_summed: %d - %s gso\n"
-			 "\ttx_count_frames %d\n", entry,
+			 "\ttx_count_frames %d\n", __func__, entry,
 			 skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
 			 !skb_is_gso(skb) ? "isn't" : "is",
 			 priv->tx_count_frames);
@@ -1818,7 +1811,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
 	if (priv->extend_desc)
-		desc = (struct dma_desc *) (priv->dma_etx + entry);
+		desc = (struct dma_desc *)(priv->dma_etx + entry);
 	else
 		desc = priv->dma_tx + entry;
 
@@ -1841,14 +1834,14 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 							  csum_insertion);
 	} else {
 		is_jumbo = priv->hw->chain->is_jumbo_frm(skb->len,
-							priv->plat->enh_desc);
+							 priv->plat->enh_desc);
 		if (unlikely(is_jumbo))
 			entry = priv->hw->chain->jumbo_frm(priv, skb,
 							   csum_insertion);
 	}
 	if (likely(!is_jumbo)) {
 		desc->des2 = dma_map_single(priv->device, skb->data,
-					nopaged_len, DMA_TO_DEVICE);
+					    nopaged_len, DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						csum_insertion, priv->mode);
@@ -1861,7 +1854,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		entry = (++priv->cur_tx) % txsize;
 		if (priv->extend_desc)
-			desc = (struct dma_desc *) (priv->dma_etx + entry);
+			desc = (struct dma_desc *)(priv->dma_etx + entry);
 		else
 			desc = priv->dma_tx + entry;
 
@@ -1904,10 +1897,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 #ifdef STMMAC_XMIT_DEBUG
 	if (netif_msg_pktdata(priv)) {
-		pr_info("stmmac xmit: current=%d, dirty=%d, entry=%d, "
-		       "first=%p, nfrags=%d\n",
-		       (priv->cur_tx % txsize), (priv->dirty_tx % txsize),
-		       entry, first, nfrags);
+		pr_info("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d"
+			__func__, (priv->cur_tx % txsize),
+			(priv->dirty_tx % txsize), entry, first, nfrags);
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
 		else
@@ -1957,7 +1949,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *) (priv->dma_erx + entry);
+			p = (struct dma_desc *)(priv->dma_erx + entry);
 		else
 			p = priv->dma_rx + entry;
 
@@ -1999,12 +1991,13 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	unsigned int entry = priv->cur_rx % rxsize;
 	unsigned int next_entry;
 	unsigned int count = 0;
+	int coe = priv->plat->rx_coe;
 
 #ifdef STMMAC_RX_DEBUG
 	if (netif_msg_hw(priv)) {
 		pr_debug(">>> stmmac_rx: descriptor ring:\n");
 		if (priv->extend_desc)
-			stmmac_display_ring((void *) priv->dma_erx, rxsize, 1);
+			stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
 		else
 			stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
 	}
@@ -2014,9 +2007,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		struct dma_desc *p, *p_next;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *) (priv->dma_erx + entry);
+			p = (struct dma_desc *)(priv->dma_erx + entry);
 		else
-			p = priv->dma_rx + entry ;
+			p = priv->dma_rx + entry;
 
 		if (priv->hw->desc->get_rx_owner(p))
 			break;
@@ -2025,8 +2018,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		next_entry = (++priv->cur_rx) % rxsize;
 		if (priv->extend_desc)
-			p_next = (struct dma_desc *) (priv->dma_erx +
-						      next_entry);
+			p_next = (struct dma_desc *)(priv->dma_erx +
+						     next_entry);
 		else
 			p_next = priv->dma_rx + next_entry;
 
@@ -2050,32 +2043,34 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				 */
 				priv->rx_skbuff[entry] = NULL;
 				dma_unmap_single(priv->device,
-					priv->rx_skbuff_dma[entry],
-					priv->dma_buf_sz, DMA_FROM_DEVICE);
+						 priv->rx_skbuff_dma[entry],
+						 priv->dma_buf_sz,
+						 DMA_FROM_DEVICE);
 			}
 		} else {
 			struct sk_buff *skb;
 			int frame_len;
 
-			frame_len = priv->hw->desc->get_rx_frame_len(p,
-					priv->plat->rx_coe);
+			frame_len = priv->hw->desc->get_rx_frame_len(p, coe);
+
 			/* ACS is set; GMAC core strips PAD/FCS for IEEE 802.3
-			 * Type frames (LLC/LLC-SNAP) */
+			 * Type frames (LLC/LLC-SNAP)
+			 */
 			if (unlikely(status != llc_snap))
 				frame_len -= ETH_FCS_LEN;
 #ifdef STMMAC_RX_DEBUG
 			if (frame_len > ETH_FRAME_LEN)
 				pr_debug("\tRX frame size %d, COE status: %d\n",
-					frame_len, status);
+					 frame_len, status);
 
 			if (netif_msg_hw(priv))
 				pr_debug("\tdesc: %p [entry %d] buff=0x%x\n",
-					p, entry, p->des2);
+					 p, entry, p->des2);
 #endif
 			skb = priv->rx_skbuff[entry];
 			if (unlikely(!skb)) {
 				pr_err("%s: Inconsistent Rx descriptor chain\n",
-					priv->dev->name);
+				       priv->dev->name);
 				priv->dev->stats.rx_dropped++;
 				break;
 			}
@@ -2096,7 +2091,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
-			if (unlikely(!priv->plat->rx_coe))
+			if (unlikely(!coe))
 				skb_checksum_none_assert(skb);
 			else
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -2164,18 +2159,16 @@ static int stmmac_config(struct net_device *dev, struct ifmap *map)
 
 	/* Don't allow changing the I/O address */
 	if (map->base_addr != dev->base_addr) {
-		pr_warning("%s: can't change I/O address\n", dev->name);
+		pr_warn("%s: can't change I/O address\n", dev->name);
 		return -EOPNOTSUPP;
 	}
 
 	/* Don't allow changing the IRQ */
 	if (map->irq != dev->irq) {
-		pr_warning("%s: can't change IRQ number %d\n",
-		       dev->name, dev->irq);
+		pr_warn("%s: not change IRQ number %d\n", dev->name, dev->irq);
 		return -EOPNOTSUPP;
 	}
 
-	/* ignore other fields */
 	return 0;
 }
 
@@ -2235,7 +2228,7 @@ static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static netdev_features_t stmmac_fix_features(struct net_device *dev,
-	netdev_features_t features)
+					     netdev_features_t features)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
@@ -2249,7 +2242,8 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 	/* Some GMAC devices have a bugged Jumbo frame support that
 	 * needs to have the Tx COE disabled for oversized frames
 	 * (due to limited buffer sizes). In this case we disable
-	 * the TX csum insertionin the TDES and not use SF. */
+	 * the TX csum insertionin the TDES and not use SF.
+	 */
 	if (priv->plat->bugged_jumbo && (dev->mtu > ETH_DATA_LEN))
 		features &= ~NETIF_F_ALL_CSUM;
 
@@ -2296,7 +2290,8 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* Polling receive - used by NETCONSOLE and other diagnostic tools
- * to allow network I/O with interrupts disabled. */
+ * to allow network I/O with interrupts disabled.
+ */
 static void stmmac_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
@@ -2346,26 +2341,26 @@ static struct dentry *stmmac_rings_status;
 static struct dentry *stmmac_dma_cap;
 
 static void sysfs_display_ring(void *head, int size, int extend_desc,
-				struct seq_file *seq)
+			       struct seq_file *seq)
 {
 	int i;
-	struct dma_extended_desc *ep = (struct dma_extended_desc *) head;
-	struct dma_desc *p = (struct dma_desc *) head;
+	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
+	struct dma_desc *p = (struct dma_desc *)head;
 
 	for (i = 0; i < size; i++) {
 		u64 x;
 		if (extend_desc) {
 			x = *(u64 *) ep;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				   i, (unsigned int) virt_to_phys(ep),
-				   (unsigned int) x, (unsigned int) (x >> 32),
+				   i, (unsigned int)virt_to_phys(ep),
+				   (unsigned int)x, (unsigned int)(x >> 32),
 				   ep->basic.des2, ep->basic.des3);
 			ep++;
 		} else {
 			x = *(u64 *) p;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				   i, (unsigned int) virt_to_phys(ep),
-				   (unsigned int) x, (unsigned int) (x >> 32),
+				   i, (unsigned int)virt_to_phys(ep),
+				   (unsigned int)x, (unsigned int)(x >> 32),
 				   p->des2, p->des3);
 			p++;
 		}
@@ -2382,9 +2377,9 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 
 	if (priv->extend_desc) {
 		seq_printf(seq, "Extended RX descriptor ring:\n");
-		sysfs_display_ring((void *) priv->dma_erx, rxsize, 1, seq);
+		sysfs_display_ring((void *)priv->dma_erx, rxsize, 1, seq);
 		seq_printf(seq, "Extended TX descriptor ring:\n");
-		sysfs_display_ring((void *) priv->dma_etx, txsize, 1, seq);
+		sysfs_display_ring((void *)priv->dma_etx, txsize, 1, seq);
 	} else {
 		seq_printf(seq, "RX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_rx, rxsize, 0, seq);
@@ -2494,8 +2489,8 @@ static int stmmac_init_fs(struct net_device *dev)
 
 	/* Entry to report DMA RX/TX rings */
 	stmmac_rings_status = debugfs_create_file("descriptors_status",
-					   S_IRUGO, stmmac_fs_dir, dev,
-					   &stmmac_rings_status_fops);
+						  S_IRUGO, stmmac_fs_dir, dev,
+						  &stmmac_rings_status_fops);
 
 	if (!stmmac_rings_status || IS_ERR(stmmac_rings_status)) {
 		pr_info("ERROR creating stmmac ring debugfs file\n");
@@ -2576,7 +2571,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	stmmac_selec_desc_mode(priv);
 
 	/* To use the chained or ring mode */
-	if (chain_mode)	{
+	if (chain_mode) {
 		priv->hw->chain = &chain_mode_ops;
 		pr_info(" Chain mode enabled\n");
 		priv->mode = STMMAC_CHAIN_MODE;
@@ -2609,11 +2604,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
 
-	/* Enable the IPC (Checksum Offload) and check if the feature has been
-	 * enabled during the core configuration. */
 	ret = priv->hw->mac->rx_ipc(priv->ioaddr);
 	if (!ret) {
-		pr_warning(" RX IPC Checksum Offload not configured.\n");
+		pr_warn(" RX IPC Checksum Offload not configured.\n");
 		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
 	}
 
@@ -2669,7 +2662,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	stmmac_verify_args();
 
 	/* Override with kernel parameters if supplied XXX CRS XXX
-	 * this needs to have multiple instances */
+	 * this needs to have multiple instances
+	 */
 	if ((phyaddr >= 0) && (phyaddr <= 31))
 		priv->plat->phy_addr = phyaddr;
 
@@ -2716,7 +2710,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->stmmac_clk)) {
-		pr_warning("%s: warning: cannot get CSR clock\n", __func__);
+		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
 		goto error_clk_get;
 	}
 
@@ -2833,7 +2827,8 @@ int stmmac_resume(struct net_device *ndev)
 	 * automatically as soon as a magic packet or a Wake-up frame
 	 * is received. Anyway, it's better to manually clear
 	 * this bit because it can generate problems while resuming
-	 * from another devices (e.g. serial console). */
+	 * from another devices (e.g. serial console).
+	 */
 	if (device_may_wakeup(priv->device))
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 	else
@@ -2957,7 +2952,7 @@ err:
 }
 
 __setup("stmmaceth=", stmmac_cmdline_opt);
-#endif
+#endif /* MODULE */
 
 MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
 MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 0b9829f..cc15039 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -177,7 +177,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		new_bus->name, priv->plat->bus_id);
+		 new_bus->name, priv->plat->bus_id);
 	new_bus->priv = ndev;
 	new_bus->irq = irqlist;
 	new_bus->phy_mask = mdio_bus_data->phy_mask;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 19b3a25..023b7c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -88,7 +88,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 			continue;
 		addr = pci_iomap(pdev, i, 0);
 		if (addr == NULL) {
-			pr_err("%s: ERROR: cannot map register memory, aborting",
+			pr_err("%s: ERROR: cannot map register memory aborting",
 			       __func__);
 			ret = -EIO;
 			goto err_out_map_failed;
-- 
1.7.4.4
