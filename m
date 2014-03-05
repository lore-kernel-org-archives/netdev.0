From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] samsung: xgmac: Mostly whitespace neatening
Date: Wed,  5 Mar 2014 11:20:19 -0800
Message-ID: <2f8a1b8c2b1d4f8078e952aed329f1eed3b0474d.1394046997.git.joe@perches.com>
References: <cover.1394046997.git.joe@perches.com>
Cc: linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com,
	netdev@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0132.hostedemail.com ([216.40.44.132]:48606 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756728AbaCETUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:20:39 -0500
In-Reply-To: <cover.1394046997.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alignment to parenthesis and adding parenthesis where appropriate.
Added a conversion of if (foo < x) bar ; else return baz to
	if (foo >= x) return baz; and unindented.

git diff -w shows trivial changes.
Added a few > 80 column lines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/samsung/xgmac_common.h   |  32 ++---
 drivers/net/ethernet/samsung/xgmac_core.c     |  19 ++-
 drivers/net/ethernet/samsung/xgmac_desc.c     |  10 +-
 drivers/net/ethernet/samsung/xgmac_desc.h     |  14 +-
 drivers/net/ethernet/samsung/xgmac_dma.c      |  14 +-
 drivers/net/ethernet/samsung/xgmac_dma.h      |  10 +-
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |  23 ++--
 drivers/net/ethernet/samsung/xgmac_main.c     |  95 +++++++-------
 drivers/net/ethernet/samsung/xgmac_mdio.c     |  33 +++--
 drivers/net/ethernet/samsung/xgmac_mtl.c      |   4 +-
 drivers/net/ethernet/samsung/xgmac_mtl.h      |  14 +-
 drivers/net/ethernet/samsung/xgmac_platform.c |  28 ++--
 drivers/net/ethernet/samsung/xgmac_reg.h      | 182 +++++++++++++-------------
 13 files changed, 240 insertions(+), 238 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
index 4c46504..47721b6 100644
--- a/drivers/net/ethernet/samsung/xgmac_common.h
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -8,7 +8,7 @@
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
-*/
+ */
 
 #ifndef __XGMAC_COMMON_H__
 #define __XGMAC_COMMON_H__
@@ -167,21 +167,21 @@ enum dma_irq_status {
 	handle_rx = BIT(5),
 };
 
-#define NETIF_F_HW_VLAN_ALL     (NETIF_F_HW_VLAN_CTAG_RX |\
-				NETIF_F_HW_VLAN_STAG_RX |\
-				NETIF_F_HW_VLAN_CTAG_TX |\
-				NETIF_F_HW_VLAN_STAG_TX |\
-				NETIF_F_HW_VLAN_CTAG_FILTER |\
-				NETIF_F_HW_VLAN_STAG_FILTER)
+#define NETIF_F_HW_VLAN_ALL     (NETIF_F_HW_VLAN_CTAG_RX |	\
+				 NETIF_F_HW_VLAN_STAG_RX |	\
+				 NETIF_F_HW_VLAN_CTAG_TX |	\
+				 NETIF_F_HW_VLAN_STAG_TX |	\
+				 NETIF_F_HW_VLAN_CTAG_FILTER |	\
+				 NETIF_F_HW_VLAN_STAG_FILTER)
 
 /* MMC control defines */
 #define XGMAC_MMC_CTRL_CNT_FRZ  0x00000008
 
 /* XGMAC HW ADDR regs */
 #define XGMAC_ADDR_HIGH(reg)    (((reg > 15) ? 0x00000800 : 0x00000040) + \
-				(reg * 8))
+				 (reg * 8))
 #define XGMAC_ADDR_LOW(reg)     (((reg > 15) ? 0x00000804 : 0x00000044) + \
-				(reg * 8))
+				 (reg * 8))
 #define XGMAC_MAX_PERFECT_ADDRESSES 32 /* Maximum unicast perfect filtering */
 #define XGMAC_FRAME_FILTER       0x00000004      /* Frame Filter */
 
@@ -207,7 +207,7 @@ enum dma_irq_status {
 #define MIN_MTU         68
 #define MAX_MTU         9000
 
-#define XGMAC_FOR_EACH_QUEUE(max_queues, queue_num) \
+#define XGMAC_FOR_EACH_QUEUE(max_queues, queue_num)			\
 	for (queue_num = 0; queue_num < max_queues; queue_num++)
 
 #define DRV_VERSION "1.0.0"
@@ -331,7 +331,7 @@ struct xgmac_hwtimestamp {
 	int (*init_systime)(void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend)(void __iomem *ioaddr, u32 addend);
 	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
-			       int add_sub);
+			      int add_sub);
 	u64 (*get_systime)(void __iomem *ioaddr);
 };
 
@@ -353,14 +353,14 @@ struct xgmac_core_ops {
 	void (*dump_regs)(void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
 	int (*host_irq_status)(void __iomem *ioaddr,
-				struct xgmac_extra_stats *x);
+			       struct xgmac_extra_stats *x);
 	/* Set power management mode (e.g. magic frame) */
 	void (*pmt)(void __iomem *ioaddr, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
 	void (*set_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n);
+			      unsigned int reg_n);
 	void (*get_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n);
+			      unsigned int reg_n);
 	void (*enable_rx)(void __iomem *ioaddr, bool enable);
 	void (*enable_tx)(void __iomem *ioaddr, bool enable);
 
@@ -369,7 +369,7 @@ struct xgmac_core_ops {
 
 	/* If supported then get the optional core features */
 	unsigned int (*get_hw_feature)(void __iomem *ioaddr,
-						unsigned char feature_index);
+				       unsigned char feature_index);
 	/* adjust XGMAC speed */
 	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
 
@@ -377,7 +377,7 @@ struct xgmac_core_ops {
 	void (*set_eee_mode)(void __iomem *ioaddr);
 	void (*reset_eee_mode)(void __iomem *ioaddr);
 	void (*set_eee_timer)(void __iomem *ioaddr, const int ls,
-			const int tw);
+			      const int tw);
 	void (*set_eee_pls)(void __iomem *ioaddr, const int link);
 
 	/* Enable disable checksum offload operations */
diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index 40b1946..2a239d1 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -69,7 +69,7 @@ static int xgmac_get_lpi_status(void __iomem *ioaddr, const u32 irq_status)
 
 /* Handle extra events on specific interrupts hw dependent */
 static int xgmac_core_host_irq_status(void __iomem *ioaddr,
-				struct xgmac_extra_stats *x)
+				      struct xgmac_extra_stats *x)
 {
 	int irq_status, status = 0;
 
@@ -110,26 +110,26 @@ static void xgmac_core_pmt(void __iomem *ioaddr, unsigned long mode)
 	/* Enable power down bit if any of the requested mode is enabled */
 	if (pmt) {
 		writel(XGMAC_RX_ENABLE, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
-		 pmt |= PMT_PWRDWN;
+		pmt |= PMT_PWRDWN;
 		writel(pmt, ioaddr + XGMAC_CORE_PMT_CTL_STATUS_REG);
 	}
 }
 
 /* Set/Get Unicast MAC addresses */
 static void xgmac_core_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n)
+				     unsigned int reg_n)
 {
 	u32 high_word, low_word;
 
 	high_word = (addr[5] << 8) || (addr[4]);
-	low_word = (addr[3] << 24) || (addr[2] << 16) ||
-		   (addr[1] << 8) || (addr[0]);
+	low_word = ((addr[3] << 24) || (addr[2] << 16) ||
+		    (addr[1] << 8) || (addr[0]));
 	writel(high_word, ioaddr + XGMAC_CORE_ADD_HIGHOFFSET(reg_n));
 	writel(low_word, ioaddr + XGMAC_CORE_ADD_LOWOFFSET(reg_n));
 }
 
 static void xgmac_core_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
-			       unsigned int reg_n)
+				     unsigned int reg_n)
 {
 	u32 high_word, low_word;
 
@@ -176,13 +176,12 @@ static int xgmac_get_controller_version(void __iomem *ioaddr)
 
 /* If supported then get the optional core features */
 static unsigned int xgmac_get_hw_feature(void __iomem *ioaddr,
-						unsigned char feature_index)
+					 unsigned char feature_index)
 {
 	return readl(ioaddr + (XGMAC_CORE_HW_FEA_REG(feature_index)));
 }
 
-static void xgmac_core_set_speed(void __iomem *ioaddr,
-					unsigned char speed)
+static void xgmac_core_set_speed(void __iomem *ioaddr, unsigned char speed)
 {
 	u32 tx_cfg = readl(ioaddr + XGMAC_CORE_TX_CONFIG_REG);
 
@@ -233,7 +232,7 @@ static void  xgmac_set_eee_pls(void __iomem *ioaddr, const int link)
 }
 
 static void  xgmac_set_eee_timer(void __iomem *ioaddr,
-					const int ls, const int tw)
+				 const int ls, const int tw)
 {
 	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
 
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index 2a7fd21..45e6676 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -29,8 +29,8 @@ static void xgmac_init_tx_desc(struct xgmac_tx_norm_desc *p)
 }
 
 static void xgmac_tx_desc_enable_tse(struct xgmac_tx_norm_desc *p, u8 is_tse,
-			      u32 total_hdr_len, u32 tcp_hdr_len,
-			      u32 tcp_payload_len)
+				     u32 total_hdr_len, u32 tcp_hdr_len,
+				     u32 tcp_payload_len)
 {
 	p->tdes23.tx_rd_des23.tse_bit = is_tse;
 	p->tdes23.tx_rd_des23.buf1_size = total_hdr_len;
@@ -40,7 +40,7 @@ static void xgmac_tx_desc_enable_tse(struct xgmac_tx_norm_desc *p, u8 is_tse,
 
 /* Assign buffer lengths for descriptor */
 static void xgmac_prepare_tx_desc(struct xgmac_tx_norm_desc *p, u8 is_fd,
-			int buf1_len, int pkt_len, int cksum)
+				  int buf1_len, int pkt_len, int cksum)
 {
 	p->tdes23.tx_rd_des23.first_desc = is_fd;
 	p->tdes23.tx_rd_des23.buf1_size = buf1_len;
@@ -49,7 +49,7 @@ static void xgmac_prepare_tx_desc(struct xgmac_tx_norm_desc *p, u8 is_fd,
 
 	if (cksum)
 		p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.cksum_ctl =
-								cic_full;
+			cic_full;
 }
 
 /* Set VLAN control information */
@@ -192,7 +192,7 @@ static int xgmac_tx_ctxt_desc_get_vlantag(struct xgmac_tx_ctxt_desc *p)
 
 /* Set Time stamp */
 static void xgmac_tx_ctxt_desc_set_tstamp(struct xgmac_tx_ctxt_desc *p,
-					 u8 ostc_enable, u64 tstamp)
+					  u8 ostc_enable, u64 tstamp)
 {
 	if (ostc_enable) {
 		p->ostc = ostc_enable;
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.h b/drivers/net/ethernet/samsung/xgmac_desc.h
index 8433030..adf5a0f 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.h
+++ b/drivers/net/ethernet/samsung/xgmac_desc.h
@@ -125,7 +125,7 @@ struct xgmac_rx_norm_desc {
 			u32 recv_context_desc:1;
 			u32 own_bit:1;
 		} rx_wb_des23;
-	 } rdes23;
+	} rdes23;
 };
 
 /* Context descriptor structure */
@@ -173,7 +173,7 @@ struct xgmac_desc_ops {
 
 	/* Assign buffer lengths for descriptor */
 	void (*prepare_tx_desc)(struct xgmac_tx_norm_desc *p, u8 is_fd,
-				 int buf1_len, int pkt_len, int cksum);
+				int buf1_len, int pkt_len, int cksum);
 
 	/* Set VLAN control information */
 	void (*tx_vlanctl_desc)(struct xgmac_tx_norm_desc *p, int vlan_ctl);
@@ -230,22 +230,22 @@ struct xgmac_desc_ops {
 
 	/* Set IVLAN information */
 	void (*tx_ctxt_desc_set_ivlantag)(struct xgmac_tx_ctxt_desc *p,
-					int is_ivlanvalid, int ivlan_tag,
-					int ivlan_ctl);
+					  int is_ivlanvalid, int ivlan_tag,
+					  int ivlan_ctl);
 
 	/* Return IVLAN Tag */
 	int (*tx_ctxt_desc_get_ivlantag)(struct xgmac_tx_ctxt_desc *p);
 
 	/* Set VLAN Tag */
 	void (*tx_ctxt_desc_set_vlantag)(struct xgmac_tx_ctxt_desc *p,
-					int is_vlanvalid, int vlan_tag);
+					 int is_vlanvalid, int vlan_tag);
 
 	/* Return VLAN Tag */
 	int (*tx_ctxt_desc_get_vlantag)(struct xgmac_tx_ctxt_desc *p);
 
 	/* Set Time stamp */
 	void (*tx_ctxt_set_tstamp)(struct xgmac_tx_ctxt_desc *p,
-					u8 ostc_enable, u64 tstamp);
+				   u8 ostc_enable, u64 tstamp);
 
 	/* Close TX context descriptor */
 	void (*close_tx_ctxt_desc)(struct xgmac_tx_ctxt_desc *p);
@@ -255,7 +255,7 @@ struct xgmac_desc_ops {
 
 	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc)(struct xgmac_rx_norm_desc *p, int disable_rx_ic,
-				int mode, int end);
+			     int mode, int end);
 
 	/* Get own bit */
 	int (*get_rx_owner)(struct xgmac_rx_norm_desc *p);
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.c b/drivers/net/ethernet/samsung/xgmac_dma.c
index 9a22990a..e606ea7 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.c
+++ b/drivers/net/ethernet/samsung/xgmac_dma.c
@@ -32,7 +32,7 @@ static int xgmac_dma_init(void __iomem *ioaddr, int fix_burst,
 	writel(XGMAC_DMA_SOFT_RESET, ioaddr + XGMAC_DMA_MODE_REG);
 	while (retry_count--) {
 		if (!(readl(ioaddr + XGMAC_DMA_MODE_REG) &
-			XGMAC_DMA_SOFT_RESET))
+		      XGMAC_DMA_SOFT_RESET))
 			break;
 		mdelay(10);
 	}
@@ -63,8 +63,8 @@ static int xgmac_dma_init(void __iomem *ioaddr, int fix_burst,
 }
 
 static void xgmac_dma_channel_init(void __iomem *ioaddr, int cha_num,
-				int fix_burst, int pbl, dma_addr_t dma_tx,
-				dma_addr_t dma_rx, int t_rsize, int r_rsize)
+				   int fix_burst, int pbl, dma_addr_t dma_tx,
+				   dma_addr_t dma_rx, int t_rsize, int r_rsize)
 {
 	u32 reg_val;
 	dma_addr_t dma_addr;
@@ -205,7 +205,7 @@ static void xgmac_dma_stop_rx(void __iomem *ioaddr, int rchannels)
 }
 
 static int xgmac_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
-			      struct xgmac_extra_stats *x)
+				   struct xgmac_extra_stats *x)
 {
 	u32 int_status = readl(ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
 	u32 clear_val = 0;
@@ -254,7 +254,7 @@ static int xgmac_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
 				x->tx_desc_access_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_TEB1;
 			} else {
-				 x->tx_buffer_access_err++;
+				x->tx_buffer_access_err++;
 			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_TEB2) {
@@ -277,7 +277,7 @@ static int xgmac_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
 }
 
 static int xgmac_rx_dma_int_status(void __iomem *ioaddr, int channel_no,
-			      struct xgmac_extra_stats *x)
+				   struct xgmac_extra_stats *x)
 {
 	u32 int_status = readl(ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
 	u32 clear_val = 0;
@@ -326,7 +326,7 @@ static int xgmac_rx_dma_int_status(void __iomem *ioaddr, int channel_no,
 				x->rx_desc_access_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_REB1;
 			} else {
-				 x->rx_buffer_access_err++;
+				x->rx_buffer_access_err++;
 			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_REB2) {
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.h b/drivers/net/ethernet/samsung/xgmac_dma.h
index 022fd2b..64ccd91 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.h
+++ b/drivers/net/ethernet/samsung/xgmac_dma.h
@@ -23,10 +23,10 @@ struct xgmac_extra_stats;
 struct xgmac_dma_ops {
 	/* DMA core initialization */
 	int (*init)(void __iomem *ioaddr, int fix_burst,
-		     int burst_map, int enhance_amode);
+		    int burst_map, int enhance_amode);
 	void (*cha_init)(void __iomem *ioaddr, int cha_num, int fix_burst,
-			int pbl, dma_addr_t dma_tx, dma_addr_t dma_rx,
-			int t_rzie, int r_rsize);
+			 int pbl, dma_addr_t dma_tx, dma_addr_t dma_rx,
+			 int t_rzie, int r_rsize);
 	void (*enable_dma_transmission)(void __iomem *ioaddr, int dma_cnum);
 	void (*enable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
 	void (*disable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
@@ -37,9 +37,9 @@ struct xgmac_dma_ops {
 	void (*start_rx)(void __iomem *ioaddr, int rchannels);
 	void (*stop_rx)(void __iomem *ioaddr, int rchannels);
 	int (*tx_dma_int_status)(void __iomem *ioaddr, int channel_no,
-			      struct xgmac_extra_stats *x);
+				 struct xgmac_extra_stats *x);
 	int (*rx_dma_int_status)(void __iomem *ioaddr, int channel_no,
-			      struct xgmac_extra_stats *x);
+				 struct xgmac_extra_stats *x);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
 	/* Enable TSO for each DMA channel */
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 378f6f1..46198bf 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -30,9 +30,12 @@ struct xgmac_stats {
 	int stat_offset;
 };
 
-#define XGMAC_STAT(m)	\
-	{ #m, FIELD_SIZEOF(struct xgmac_extra_stats, m),	\
-	offsetof(struct xgmac_priv_data, xstats.m)}
+#define XGMAC_STAT(m)						\
+{								\
+	#m,							\
+	FIELD_SIZEOF(struct xgmac_extra_stats, m),		\
+	offsetof(struct xgmac_priv_data, xstats.m)		\
+}
 
 static const struct xgmac_stats xgmac_gstrings_stats[] = {
 	/* TX/RX IRQ events */
@@ -134,7 +137,7 @@ static const struct xgmac_stats xgmac_gstrings_stats[] = {
 #define XGMAC_STATS_LEN ARRAY_SIZE(xgmac_gstrings_stats)
 
 static int xgmac_get_eee(struct net_device *dev,
-				     struct ethtool_eee *edata)
+			 struct ethtool_eee *edata)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
@@ -149,7 +152,7 @@ static int xgmac_get_eee(struct net_device *dev,
 }
 
 static int xgmac_set_eee(struct net_device *dev,
-				     struct ethtool_eee *edata)
+			 struct ethtool_eee *edata)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
@@ -217,14 +220,14 @@ static int xgmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 }
 
 static void xgmac_getdrvinfo(struct net_device *dev,
-				     struct ethtool_drvinfo *info)
+			     struct ethtool_drvinfo *info)
 {
 	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
 static int xgmac_getsettings(struct net_device *dev,
-				     struct ethtool_cmd *cmd)
+			     struct ethtool_cmd *cmd)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
@@ -257,7 +260,7 @@ static void xgmac_setmsglevel(struct net_device *dev, u32 level)
 }
 
 static int xgmac_get_ts_info(struct net_device *dev,
-				     struct ethtool_ts_info *info)
+			     struct ethtool_ts_info *info)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
@@ -370,12 +373,12 @@ static void xgmac_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < XGMAC_STATS_LEN; i++) {
 		p = (char *)priv + xgmac_gstrings_stats[i].stat_offset;
 		data[j++] = (xgmac_gstrings_stats[i].sizeof_stat == sizeof(u64))
-				? (*(u64 *)p) : (*(u32 *)p);
+			? (*(u64 *)p) : (*(u32 *)p);
 	}
 }
 
 static void xgmac_get_channels(struct net_device *dev,
-		struct ethtool_channels *channel)
+			       struct ethtool_channels *channel)
 {
 	channel->max_rx = XGMAC_MAX_RX_CHANNELS;
 	channel->max_tx = XGMAC_MAX_TX_CHANNELS;
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index e0e339e..4a2a55d 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -394,7 +394,7 @@ static int xgmac_init_rx_buffers(struct net_device *dev,
 
 	rx_ring->rx_skbuff[i] = skb;
 	rx_ring->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
-						dma_buf_sz, DMA_FROM_DEVICE);
+						   dma_buf_sz, DMA_FROM_DEVICE);
 
 	if (dma_mapping_error(priv->device, rx_ring->rx_skbuff_dma[i])) {
 		netdev_err(dev, "%s: DMA mapping error\n", __func__);
@@ -424,8 +424,8 @@ static int init_tx_ring(struct device *dev, u8 queue_no,
 
 	/* allocate memory for TX descriptors */
 	tx_ring->dma_tx = dma_zalloc_coherent(dev,
-			tx_rsize * sizeof(struct xgmac_tx_norm_desc),
-			&tx_ring->dma_tx_phy, GFP_KERNEL);
+					      tx_rsize * sizeof(struct xgmac_tx_norm_desc),
+					      &tx_ring->dma_tx_phy, GFP_KERNEL);
 	if (!tx_ring->dma_tx) {
 		dev_err(dev, "No memory for TX desc of XGMAC\n");
 		return -ENOMEM;
@@ -433,14 +433,14 @@ static int init_tx_ring(struct device *dev, u8 queue_no,
 
 	/* allocate memory for TX skbuff array */
 	tx_ring->tx_skbuff_dma = devm_kcalloc(dev, tx_rsize,
-					sizeof(dma_addr_t), GFP_KERNEL);
+					      sizeof(dma_addr_t), GFP_KERNEL);
 	if (!tx_ring->tx_skbuff_dma) {
 		dev_err(dev, "No memory for TX skbuffs DMA of XGMAC\n");
 		goto dmamem_err;
 	}
 
 	tx_ring->tx_skbuff = devm_kcalloc(dev, tx_rsize,
-				sizeof(struct sk_buff *), GFP_KERNEL);
+					  sizeof(struct sk_buff *), GFP_KERNEL);
 
 	if (!tx_ring->tx_skbuff) {
 		dev_err(dev, "No memory for TX skbuffs of XGMAC\n");
@@ -473,7 +473,7 @@ dmamem_err:
  * Description:  this function initializes the DMA RX descriptor
  */
 void free_rx_ring(struct device *dev, struct xgmac_rx_queue *rx_ring,
-			int rx_rsize)
+		  int rx_rsize)
 {
 	dma_free_coherent(dev, rx_rsize * sizeof(struct xgmac_rx_norm_desc),
 			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
@@ -567,7 +567,7 @@ error:
  * Description:  this function initializes the DMA TX descriptor
  */
 void free_tx_ring(struct device *dev, struct xgmac_tx_queue *tx_ring,
-			int tx_rsize)
+		  int tx_rsize)
 {
 	dma_free_coherent(dev, tx_rsize * sizeof(struct xgmac_tx_norm_desc),
 			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
@@ -690,7 +690,7 @@ static int txring_mem_alloc(struct xgmac_priv_data *priv)
 
 	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
 		priv->txq[queue_num] = devm_kmalloc(priv->device,
-				sizeof(struct xgmac_tx_queue), GFP_KERNEL);
+						    sizeof(struct xgmac_tx_queue), GFP_KERNEL);
 		if (!priv->txq[queue_num]) {
 			dev_err(priv->device,
 				"No memory for TX queue of XGMAC\n");
@@ -707,7 +707,7 @@ static int rxring_mem_alloc(struct xgmac_priv_data *priv)
 
 	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
 		priv->rxq[queue_num] = devm_kmalloc(priv->device,
-				sizeof(struct xgmac_rx_queue), GFP_KERNEL);
+						    sizeof(struct xgmac_rx_queue), GFP_KERNEL);
 		if (!priv->rxq[queue_num])
 			return -ENOMEM;
 	}
@@ -848,7 +848,7 @@ static void xgmac_restart_tx_queue(struct xgmac_priv_data *priv, int queue_num)
 {
 	struct xgmac_tx_queue *tx_ring = priv->txq[queue_num];
 	struct netdev_queue *dev_txq = netdev_get_tx_queue(priv->dev,
-							queue_num);
+							   queue_num);
 
 	/* stop the queue */
 	netif_tx_stop_queue(dev_txq);
@@ -910,15 +910,15 @@ static int xgmac_get_hw_features(struct xgmac_priv_data * const priv)
 		features->vlan_hfilter = XGMAC_HW_FEAT_VLAN_HASH_FILTER(rval);
 		features->sma_mdio = XGMAC_HW_FEAT_SMA(rval);
 		features->pmt_remote_wake_up =
-				XGMAC_HW_FEAT_PMT_TEMOTE_WOP(rval);
+			XGMAC_HW_FEAT_PMT_TEMOTE_WOP(rval);
 		features->pmt_magic_frame = XGMAC_HW_FEAT_PMT_MAGIC_PKT(rval);
 		features->rmon = XGMAC_HW_FEAT_RMON(rval);
 		features->arp_offload = XGMAC_HW_FEAT_ARP_OFFLOAD(rval);
 		features->atime_stamp = XGMAC_HW_FEAT_IEEE1500_2008(rval);
 		features->tx_csum_offload =
-					XGMAC_HW_FEAT_TX_CSUM_OFFLOAD(rval);
+			XGMAC_HW_FEAT_TX_CSUM_OFFLOAD(rval);
 		features->rx_csum_offload =
-					XGMAC_HW_FEAT_RX_CSUM_OFFLOAD(rval);
+			XGMAC_HW_FEAT_RX_CSUM_OFFLOAD(rval);
 		features->multi_macaddr = XGMAC_HW_FEAT_MACADDR_COUNT(rval);
 		features->tstamp_srcselect = XGMAC_HW_FEAT_TSTMAP_SRC(rval);
 		features->sa_vlan_insert = XGMAC_HW_FEAT_SRCADDR_VLAN(rval);
@@ -1002,7 +1002,7 @@ static int xgmac_init_dma_engine(struct xgmac_priv_data *priv)
 					priv->dma_tx_size, priv->dma_rx_size);
 
 	return priv->hw->dma->init(priv->ioaddr, fixed_burst,
-				burst_map, adv_addr_mode);
+				   burst_map, adv_addr_mode);
 }
 
 /**
@@ -1017,7 +1017,7 @@ static void xgmac_init_mtl_engine(struct xgmac_priv_data *priv)
 
 	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
 		priv->hw->mtl->mtl_set_txfifosize(priv->ioaddr, queue_num,
-				priv->hw_cap.tx_mtl_qsize);
+						  priv->hw_cap.tx_mtl_qsize);
 		priv->hw->mtl->mtl_enable_txqueue(priv->ioaddr, queue_num);
 	}
 }
@@ -1133,7 +1133,7 @@ static int xgmac_open(struct net_device *dev)
 
 	/* Request the IRQ lines */
 	ret = devm_request_irq(priv->device, dev->irq, xgmac_common_interrupt,
-			  IRQF_SHARED, dev->name, dev);
+			       IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
 		netdev_err(dev, "%s: ERROR: allocating the IRQ %d (error: %d)\n",
 			   __func__, dev->irq, ret);
@@ -1143,8 +1143,8 @@ static int xgmac_open(struct net_device *dev)
 	/* Request the Wake IRQ in case of another line is used for WoL */
 	if (priv->wol_irq != dev->irq) {
 		ret = devm_request_irq(priv->device, priv->wol_irq,
-				xgmac_common_interrupt, IRQF_SHARED,
-				dev->name, dev);
+				       xgmac_common_interrupt, IRQF_SHARED,
+				       dev->name, dev);
 		if (unlikely(ret < 0)) {
 			netdev_err(dev, "%s: ERROR: allocating the WoL IRQ %d (%d)\n",
 				   __func__, priv->wol_irq, ret);
@@ -1169,9 +1169,9 @@ static int xgmac_open(struct net_device *dev)
 	/* Request TX DMA irq lines */
 	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
 		ret = devm_request_irq(priv->device,
-					(priv->txq[queue_num])->irq_no,
-					xgmac_tx_interrupt, 0,
-					dev->name, priv->txq[queue_num]);
+				       (priv->txq[queue_num])->irq_no,
+				       xgmac_tx_interrupt, 0,
+				       dev->name, priv->txq[queue_num]);
 		if (unlikely(ret < 0)) {
 			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
 				   __func__, dev->irq, ret);
@@ -1182,9 +1182,9 @@ static int xgmac_open(struct net_device *dev)
 	/* Request RX DMA irq lines */
 	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
 		ret = devm_request_irq(priv->device,
-					(priv->rxq[queue_num])->irq_no,
-					xgmac_rx_interrupt, 0,
-					dev->name, priv->rxq[queue_num]);
+				       (priv->rxq[queue_num])->irq_no,
+				       xgmac_rx_interrupt, 0,
+				       dev->name, priv->rxq[queue_num]);
 		if (unlikely(ret < 0)) {
 			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
 				   __func__, dev->irq, ret);
@@ -1386,13 +1386,13 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			xgmac_tso_prepare(priv, first_desc, skb);
 		} else {
 			tx_desc->tdes01 = dma_map_single(priv->device,
-					skb->data, no_pagedlen, DMA_TO_DEVICE);
+							 skb->data, no_pagedlen, DMA_TO_DEVICE);
 			if (dma_mapping_error(priv->device, tx_desc->tdes01))
 				netdev_err(dev, "%s: TX dma mapping failed!!\n",
 					   __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
-					no_pagedlen, cksum_flag);
+							no_pagedlen, cksum_flag);
 		}
 	}
 
@@ -1506,11 +1506,11 @@ static void xgmac_rx_refill(struct xgmac_priv_data *priv)
 
 			priv->rxq[qnum]->rx_skbuff[entry] = skb;
 			priv->rxq[qnum]->rx_skbuff_dma[entry] =
-			    dma_map_single(priv->device, skb->data, bfsize,
-					   DMA_FROM_DEVICE);
+				dma_map_single(priv->device, skb->data, bfsize,
+					       DMA_FROM_DEVICE);
 
 			p->rdes23.rx_rd_des23.buf2_addr =
-					priv->rxq[qnum]->rx_skbuff_dma[entry];
+				priv->rxq[qnum]->rx_skbuff_dma[entry];
 		}
 
 		/* Added memory barrier for RX descriptor modification */
@@ -1603,7 +1603,7 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 static int xgmac_poll(struct napi_struct *napi, int budget)
 {
 	struct xgmac_priv_data *priv = container_of(napi,
-					struct xgmac_priv_data, napi);
+						    struct xgmac_priv_data, napi);
 	int work_done = 0;
 	u8 qnum = priv->cur_rx_qnum;
 
@@ -1680,7 +1680,7 @@ static irqreturn_t xgmac_tx_interrupt(int irq, void *dev_id)
 
 	/* get the channel status */
 	status = priv->hw->dma->tx_dma_int_status(priv->ioaddr, txq->queue_no,
-						&priv->xstats);
+						  &priv->xstats);
 	/* check for normal path */
 	if (likely((status & handle_tx)))
 		napi_schedule(&priv->napi);
@@ -1716,7 +1716,7 @@ static irqreturn_t xgmac_rx_interrupt(int irq, void *dev_id)
 
 	/* get the channel status */
 	status = priv->hw->dma->rx_dma_int_status(priv->ioaddr, rxq->queue_no,
-						&priv->xstats);
+						  &priv->xstats);
 
 	if (likely((status & handle_rx) && (napi_schedule_prep(&priv->napi)))) {
 		priv->hw->dma->disable_dma_irq(priv->ioaddr, rxq->queue_no);
@@ -1747,7 +1747,7 @@ static irqreturn_t xgmac_rx_interrupt(int irq, void *dev_id)
  *  This function returns various statistical information of device.
  */
 static struct rtnl_link_stats64 *xgmac_get_stats64(struct net_device *dev,
-						struct rtnl_link_stats64 *stats)
+						   struct rtnl_link_stats64 *stats)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->ioaddr;
@@ -1761,23 +1761,23 @@ static struct rtnl_link_stats64 *xgmac_get_stats64(struct net_device *dev,
 
 	stats->rx_bytes = readl(ioaddr + XGMAC_MMC_RXOCTETLO_GCNT_REG);
 	stats->rx_bytes |= (u64)(readl(ioaddr + XGMAC_MMC_RXOCTETHI_GCNT_REG))
-				<< 32;
+		<< 32;
 	stats->rx_packets = readl(ioaddr + XGMAC_MMC_RXFRAMELO_GBCNT_REG);
 	stats->rx_packets |=
 		(u64)(readl(ioaddr + XGMAC_MMC_RXFRAMEHI_GBCNT_REG)) << 32;
 	stats->multicast = readl(ioaddr + XGMAC_MMC_RXMULTILO_GCNT_REG);
 	stats->multicast |= (u64)(readl(ioaddr + XGMAC_MMC_RXMULTIHI_GCNT_REG))
-				<< 32;
+		<< 32;
 	stats->rx_crc_errors = readl(ioaddr + XGMAC_MMC_RXCRCERRLO_REG);
 	stats->rx_crc_errors |= (u64)(readl(ioaddr + XGMAC_MMC_RXCRCERRHI_REG))
-				<< 32;
+		<< 32;
 	stats->rx_length_errors = readl(ioaddr + XGMAC_MMC_RXLENERRLO_REG);
 	stats->rx_length_errors |=
-			(u64)(readl(ioaddr + XGMAC_MMC_RXLENERRHI_REG))	<< 32;
+		(u64)(readl(ioaddr + XGMAC_MMC_RXLENERRHI_REG))	<< 32;
 	stats->rx_missed_errors = readl(ioaddr +
-				 XGMAC_MMC_RXFIFOOVERFLOWLO_GBCNT_REG);
+					XGMAC_MMC_RXFIFOOVERFLOWLO_GBCNT_REG);
 	stats->rx_missed_errors |= (u64)(readl(ioaddr +
-				 XGMAC_MMC_RXFIFOOVERFLOWHI_GBCNT_REG));
+					       XGMAC_MMC_RXFIFOOVERFLOWHI_GBCNT_REG));
 
 	stats->tx_bytes = readl(ioaddr + XGMAC_MMC_TXOCTETLO_GCNT_REG);
 	stats->tx_bytes |=
@@ -1787,12 +1787,12 @@ static struct rtnl_link_stats64 *xgmac_get_stats64(struct net_device *dev,
 	count |= (u64)(readl(ioaddr + XGMAC_MMC_TXFRAMEHI_GBCNT_REG)) << 32;
 	stats->tx_errors = readl(ioaddr + XGMAC_MMC_TXFRAMELO_GCNT_REG);
 	stats->tx_errors |= (u64)(readl(ioaddr + XGMAC_MMC_TXFRAMEHI_GCNT_REG))
-				<< 32;
+		<< 32;
 	stats->tx_errors = count - stats->tx_errors;
 	stats->tx_packets = count;
 	stats->tx_fifo_errors = readl(ioaddr + XGMAC_MMC_TXUFLWLO_GBCNT_REG);
 	stats->tx_fifo_errors |= (u64)(readl(ioaddr +
-				 XGMAC_MMC_TXUFLWHI_GBCNT_REG));
+					     XGMAC_MMC_TXUFLWHI_GBCNT_REG));
 
 	writel(0, ioaddr + XGMAC_MMC_CTL_REG);
 	spin_unlock(&priv->stats_lock);
@@ -1950,7 +1950,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 
 	netdev_dbg(dev, "Filter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
 		   readl(ioaddr + XGMAC_FRAME_FILTER),
-	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
+		   readl(ioaddr + XGMAC_HASH_HIGH),
+		   readl(ioaddr + XGMAC_HASH_LOW));
 }
 
 /**
@@ -2135,8 +2136,8 @@ static void xgmac_set_pmt_capabilities(struct xgmac_priv_data *priv)
  * call the alloc_etherdev, allocate the priv structure.
  */
 struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
-				     struct xgmac_plat_data *plat_dat,
-				     void __iomem *addr)
+					struct xgmac_plat_data *plat_dat,
+					void __iomem *addr)
 {
 	int ret = 0;
 	struct net_device *ndev = NULL;
@@ -2144,7 +2145,7 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	u8 queue_num;
 
 	ndev = alloc_etherdev_mqs(sizeof(struct xgmac_priv_data),
-				 XGMAC_TX_QUEUES, XGMAC_RX_QUEUES);
+				  XGMAC_TX_QUEUES, XGMAC_RX_QUEUES);
 	if (!ndev)
 		return NULL;
 
@@ -2187,8 +2188,8 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	ndev->netdev_ops = &xgmac_netdev_ops;
 
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			    NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
-			    NETIF_F_GRO;
+		NETIF_F_RXCSUM | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_GRO;
 	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 
diff --git a/drivers/net/ethernet/samsung/xgmac_mdio.c b/drivers/net/ethernet/samsung/xgmac_mdio.c
index 5e1e40e..6d85b65 100644
--- a/drivers/net/ethernet/samsung/xgmac_mdio.c
+++ b/drivers/net/ethernet/samsung/xgmac_mdio.c
@@ -67,30 +67,28 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	if (phyreg & MII_ADDR_C45) {
 		devaddr = (phyreg >> 16) & 0x1F;
 		/* set mdio address register */
-		reg_val = (phyaddr << 16) | (devaddr << 21) |
-			  (phyreg & 0xFFFF);
+		reg_val = (phyaddr << 16) | (devaddr << 21) | (phyreg & 0xFFFF);
 		writel(reg_val, priv->ioaddr + mii_addr);
 
 		/* set mdio control/data register */
-		reg_val = (XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
-			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val = ((XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			   ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY);
 		writel(reg_val, priv->ioaddr + mii_data);
 	} else {
 		/* configure the port for C22
 		 * ports 0-3 only supports C22
 		 */
-		if (phyaddr < 4)
-			writel((1 << phyaddr),
-			       priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
-		else
+		if (phyaddr >= 4)
 			return -ENODEV;
+		writel((1 << phyaddr),
+		       priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
 		/* set mdio address register */
 		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
 		writel(reg_val, priv->ioaddr + mii_addr);
 
 		/* set mdio control/data register */
-		reg_val = (XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
-			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val = ((XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			   ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY);
 		writel(reg_val, priv->ioaddr + mii_data);
 	}
 
@@ -111,7 +109,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
  * Description: this function is used for C45 and C22 MDIO write
  */
 static int xgmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
-			     u16 phydata)
+			    u16 phydata)
 {
 	struct net_device *ndev = bus->priv;
 	struct xgmac_priv_data *priv = netdev_priv(ndev);
@@ -126,13 +124,13 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	if (phyreg & MII_ADDR_C45) {
 		devaddr = (phyreg >> 16) & 0x1F;
 		/* set mdio address register */
-		reg_val = (phyaddr << 16) | (devaddr << 21) |
-			  (phyreg & 0xFFFF);
+		reg_val = (phyaddr << 16) | (devaddr << 21) | (phyreg & 0xFFFF);
 		writel(reg_val, priv->ioaddr + mii_addr);
 
 		/* set mdio control/data register */
-		reg_val = (XGMAC_SMA_WRITE_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
-			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val = ((XGMAC_SMA_WRITE_CMD << 16) |
+			   XGMAC_SMA_SKIP_ADDRFRM |
+			   ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY);
 		reg_val |= phydata;
 
 		writel(reg_val, priv->ioaddr + mii_data);
@@ -151,8 +149,9 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 		writel(reg_val, priv->ioaddr + mii_addr);
 
 		/* set mdio control/data register */
-		reg_val = (XGMAC_SMA_WRITE_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
-			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val = ((XGMAC_SMA_WRITE_CMD << 16) |
+			   XGMAC_SMA_SKIP_ADDRFRM |
+			   ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY);
 		reg_val |= phydata;
 		writel(reg_val, priv->ioaddr + mii_data);
 	}
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.c b/drivers/net/ethernet/samsung/xgmac_mtl.c
index 2edad0f..0c1e100 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.c
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.c
@@ -61,7 +61,7 @@ static void xgmac_mtl_dma_dm_rxqueue(void __iomem *ioaddr)
 }
 
 static void xgmac_mtl_set_txfifosize(void __iomem *ioaddr, int queue_num,
-				int queue_fifo)
+				     int queue_fifo)
 {
 	u32 fifo_bits, reg_val;
 	/* 0 means 256 bytes */
@@ -72,7 +72,7 @@ static void xgmac_mtl_set_txfifosize(void __iomem *ioaddr, int queue_num,
 }
 
 static void xgmac_mtl_set_rxfifosize(void __iomem *ioaddr, int queue_num,
-				int queue_fifo)
+				     int queue_fifo)
 {
 	u32 fifo_bits, reg_val;
 	/* 0 means 256 bytes */
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.h b/drivers/net/ethernet/samsung/xgmac_mtl.h
index bacd5e3..2c80753 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.h
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.h
@@ -62,31 +62,31 @@ enum flow_control_th {
 
 struct xgmac_mtl_ops {
 	void (*mtl_init)(void __iomem *ioaddr, unsigned int etsalg,
-			unsigned int raa);
+			 unsigned int raa);
 
 	void (*mtl_set_txfifosize)(void __iomem *ioaddr, int queue_num,
-				    int mtl_fifo);
+				   int mtl_fifo);
 
 	void (*mtl_set_rxfifosize)(void __iomem *ioaddr, int queue_num,
-					  int queue_fifo);
+				   int queue_fifo);
 
 	void (*mtl_enable_txqueue)(void __iomem *ioaddr, int queue_num);
 
 	void (*mtl_disable_txqueue)(void __iomem *ioaddr, int queue_num);
 
 	void (*set_tx_mtl_mode)(void __iomem *ioaddr, int queue_num,
-				 int tx_mode);
+				int tx_mode);
 
 	void (*set_rx_mtl_mode)(void __iomem *ioaddr, int queue_num,
-				 int rx_mode);
+				int rx_mode);
 
 	void (*mtl_dynamic_dma_rxqueue)(void __iomem *ioaddr);
 
 	void (*mtl_fc_active)(void __iomem *ioaddr, int queue_num,
-			       int threshold);
+			      int threshold);
 
 	void (*mtl_fc_deactive)(void __iomem *ioaddr, int queue_num,
-				 int threshold);
+				int threshold);
 
 	void (*mtl_fc_enable)(void __iomem *ioaddr, int queue_num);
 
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
index fb80c2c..d56602c 100644
--- a/drivers/net/ethernet/samsung/xgmac_platform.c
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -28,8 +28,8 @@
 
 #ifdef CONFIG_OF
 static int xgmac_probe_config_dt(struct platform_device *pdev,
-				  struct xgmac_plat_data *plat,
-				  const char **mac)
+				 struct xgmac_plat_data *plat,
+				 const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct xgmac_dma_cfg *dma_cfg;
@@ -55,7 +55,7 @@ static int xgmac_probe_config_dt(struct platform_device *pdev,
 		plat->pmt = 1;
 
 	plat->force_sf_dma_mode = of_property_read_bool(np,
-					"samsung,force_sf_dma_mode");
+							"samsung,force_sf_dma_mode");
 
 	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
 	if (!dma_cfg)
@@ -66,10 +66,10 @@ static int xgmac_probe_config_dt(struct platform_device *pdev,
 	of_property_read_u32(np, "samsung,burst-map", &dma_cfg->burst_map);
 	dma_cfg->fixed_burst = of_property_read_bool(np, "samsung,fixed-burst");
 	dma_cfg->adv_addr_mode = of_property_read_bool(np,
-							"samsung,adv-addr-mode");
+						       "samsung,adv-addr-mode");
 
 	plat->force_thresh_dma_mode = of_property_read_bool(np,
-					"samsung,force_thresh_dma_mode");
+							    "samsung,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
 		plat->force_sf_dma_mode = 0;
 		pr_warn("force_sf_dma_mode is ignored as force_thresh_dma_mode is set\n");
@@ -79,8 +79,8 @@ static int xgmac_probe_config_dt(struct platform_device *pdev,
 }
 #else
 static int xgmac_probe_config_dt(struct platform_device *pdev,
-				  struct xgmac_plat_data *plat,
-				  const char **mac)
+				 struct xgmac_plat_data *plat,
+				 const char **mac)
 {
 	return -ENOSYS;
 }
@@ -119,8 +119,8 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 	if (pdev->dev.of_node) {
 		if (!plat_dat)
 			plat_dat = devm_kzalloc(&pdev->dev,
-					sizeof(struct xgmac_plat_data),
-					GFP_KERNEL);
+						sizeof(struct xgmac_plat_data),
+						GFP_KERNEL);
 		if (!plat_dat)
 			return  -ENOMEM;
 
@@ -249,11 +249,11 @@ struct platform_driver xgmac_platform_driver = {
 	.probe = xgmac_platform_probe,
 	.remove = xgmac_platform_remove,
 	.driver = {
-		   .name = XGMAC_RESOURCE_NAME,
-		   .owner = THIS_MODULE,
-		   .pm = &xgmac_platform_pm_ops,
-		   .of_match_table = of_match_ptr(xgmac_dt_ids),
-		   },
+		.name = XGMAC_RESOURCE_NAME,
+		.owner = THIS_MODULE,
+		.pm = &xgmac_platform_pm_ops,
+		.of_match_table = of_match_ptr(xgmac_dt_ids),
+	},
 };
 
 int xgmac_register_platform(void)
diff --git a/drivers/net/ethernet/samsung/xgmac_reg.h b/drivers/net/ethernet/samsung/xgmac_reg.h
index b26d99b..5ed738e 100644
--- a/drivers/net/ethernet/samsung/xgmac_reg.h
+++ b/drivers/net/ethernet/samsung/xgmac_reg.h
@@ -75,12 +75,12 @@
 
 /* port specific, addr = 0-3 */
 #define XGMAC_MDIO_DEV_BASE_REG		0x0230
-#define	XGMAC_MDIO_PORT_DEV_REG(addr) \
-		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x0)
-#define	XGMAC_MDIO_PORT_LSTATUS_REG(addr) \
-		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x4)
-#define	XGMAC_MDIO_PORT_ALIVE_REG(addr)	\
-		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x8)
+#define XGMAC_MDIO_PORT_DEV_REG(addr)			\
+	(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x0)
+#define XGMAC_MDIO_PORT_LSTATUS_REG(addr)		\
+	(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x4)
+#define XGMAC_MDIO_PORT_ALIVE_REG(addr)			\
+	(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x8)
 
 #define XGMAC_CORE_GPIO_CTL_REG		0x0278
 #define XGMAC_CORE_GPIO_STATUS_REG	0x027C
@@ -89,10 +89,10 @@
 #define XGMAC_CORE_ADD_BASE_REG		0x0300
 
 /* addr = 0-31 */
-#define XGMAC_CORE_ADD_HIGHOFFSET(addr) \
-			(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x0)
-#define XGMAC_CORE_ADD_LOWOFFSET(addr)	\
-			(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x4)
+#define XGMAC_CORE_ADD_HIGHOFFSET(addr)			\
+	(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x0)
+#define XGMAC_CORE_ADD_LOWOFFSET(addr)			\
+	(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x4)
 
 /* XGMAC MMC registers */
 #define XGMAC_MMC_CTL_REG		0x0800
@@ -229,14 +229,14 @@
 #define XGMAC_CORE_PPS_BASE			0x0D80
 
 /* addr = 0 - 3 */
-#define XGMAC_CORE_PPS_TTIME_SEC_REG(addr) \
-		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x0)
-#define	XGMAC_CORE_PPS_TTIME_NSEC_REG(addr) \
-		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x4)
-#define	XGMAC_CORE_PPS_INTERVAL_REG(addr) \
-		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x8)
-#define	XGMAC_CORE_PPS_WIDTH_REG(addr) \
-		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0xC)
+#define XGMAC_CORE_PPS_TTIME_SEC_REG(addr)		\
+	(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x0)
+#define XGMAC_CORE_PPS_TTIME_NSEC_REG(addr)		\
+	(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x4)
+#define XGMAC_CORE_PPS_INTERVAL_REG(addr)		\
+	(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x8)
+#define XGMAC_CORE_PPS_WIDTH_REG(addr)			\
+	(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0xC)
 #define XGMAC_CORE_PTO_CTL_REG		0x0DC0
 #define XGMAC_CORE_SRCPORT_ITY0_REG	0x0DC4
 #define XGMAC_CORE_SRCPORT_ITY1_REG	0x0DC8
@@ -258,39 +258,39 @@
 
 /* TC/Queue registers, qnum=0-15 */
 #define XGMAC_MTL_TC_TXBASE_REG		(XGMAC_MTL_BASE_REG + 0x0100)
-#define XGMAC_MTL_TXQ_OPMODE_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x00)
+#define XGMAC_MTL_TXQ_OPMODE_REG(qnum)				\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x00)
 #define XGMAC_MTL_SFMODE		BIT(1)
 #define XGMAC_MTL_FIFO_LSHIFT		16
 #define XGMAC_MTL_ENABLE_QUEUE		0x00000008
 #define XGMAC_MTL_TXQ_EMPTY_STAT	BIT(4)
 #define XGMAC_MTL_TXQ_WRITE_STAT	BIT(3)
 
-#define XGMAC_MTL_TXQ_UNDERFLOW_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
-#define XGMAC_MTL_TXQ_DEBUG_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x08)
-#define XGMAC_MTL_TXQ_ETSCTL_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x10)
-#define XGMAC_MTL_TXQ_ETSSTATUS_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x14)
-#define XGMAC_MTL_TXQ_QUANTWEIGHT_REG(qnum) \
-		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x18)
+#define XGMAC_MTL_TXQ_UNDERFLOW_REG(qnum)			\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
+#define XGMAC_MTL_TXQ_DEBUG_REG(qnum)				\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x08)
+#define XGMAC_MTL_TXQ_ETSCTL_REG(qnum)				\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x10)
+#define XGMAC_MTL_TXQ_ETSSTATUS_REG(qnum)			\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x14)
+#define XGMAC_MTL_TXQ_QUANTWEIGHT_REG(qnum)			\
+	(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x18)
 
 #define XGMAC_MTL_TC_RXBASE_REG		0x1140
 #define XGMAC_RX_MTL_SFMODE		BIT(5)
-#define XGMAC_MTL_RXQ_OPMODE_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x00)
-#define XGMAC_MTL_RXQ_MISPKTOVERFLOW_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x04)
-#define XGMAC_MTL_RXQ_DEBUG_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x08)
-#define XGMAC_MTL_RXQ_CTL_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x0C)
-#define XGMAC_MTL_RXQ_INTENABLE_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x30)
-#define XGMAC_MTL_RXQ_INTSTATUS_REG(qnum) \
-		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x34)
+#define XGMAC_MTL_RXQ_OPMODE_REG(qnum)				\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x00)
+#define XGMAC_MTL_RXQ_MISPKTOVERFLOW_REG(qnum)			\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x04)
+#define XGMAC_MTL_RXQ_DEBUG_REG(qnum)				\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x08)
+#define XGMAC_MTL_RXQ_CTL_REG(qnum)				\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x0C)
+#define XGMAC_MTL_RXQ_INTENABLE_REG(qnum)			\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x30)
+#define XGMAC_MTL_RXQ_INTSTATUS_REG(qnum)			\
+	(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x34)
 
 /* XGMAC DMA Registers */
 #define XGMAC_DMA_BASE_REG		0x3000
@@ -310,50 +310,50 @@
 #define XGMAC_DMA_DEBUG_STATUS5_REG	(XGMAC_DMA_BASE_REG + 0x0034)
 
 /* Channel Registers, cha_num = 0-15 */
-#define XGMAC_DMA_CHA_BASE_REG \
-		(XGMAC_DMA_BASE_REG + 0x0100)
-#define XGMAC_DMA_CHA_CTL_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x00)
+#define XGMAC_DMA_CHA_BASE_REG			\
+	(XGMAC_DMA_BASE_REG + 0x0100)
+#define XGMAC_DMA_CHA_CTL_REG(cha_num)				\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x00)
 #define XGMAC_DMA_PBL_X8MODE			BIT(16)
 #define XGMAC_DMA_CHA_TXCTL_TSE_ENABLE		BIT(12)
-#define XGMAC_DMA_CHA_TXCTL_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x04)
-#define XGMAC_DMA_CHA_RXCTL_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x08)
-#define XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x10)
-#define XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x14)
-#define XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x18)
-#define XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x1C)
-#define XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x24)
-#define XGMAC_DMA_CHA_RXDESC_TAILPTR_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x2C)
-#define XGMAC_DMA_CHA_TXDESC_RINGLEN_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x30)
-#define XGMAC_DMA_CHA_RXDESC_RINGLEN_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x34)
-#define XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x38)
-#define XGMAC_DMA_CHA_INT_RXWATCHTMR_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x3C)
-#define XGMAC_DMA_CHA_TXDESC_CURADDLO_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x44)
-#define XGMAC_DMA_CHA_RXDESC_CURADDLO_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x4C)
-#define XGMAC_DMA_CHA_CURTXBUF_ADDHI_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x50)
-#define XGMAC_DMA_CHA_CURTXBUF_ADDLO_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x54)
-#define XGMAC_DMA_CHA_CURRXBUF_ADDHI_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x58)
-#define XGMAC_DMA_CHA_CURRXBUF_ADDLO_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x5C)
-#define XGMAC_DMA_CHA_STATUS_REG(cha_num) \
-		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x60)
+#define XGMAC_DMA_CHA_TXCTL_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x04)
+#define XGMAC_DMA_CHA_RXCTL_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x08)
+#define XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x10)
+#define XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x14)
+#define XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x18)
+#define XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x1C)
+#define XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x24)
+#define XGMAC_DMA_CHA_RXDESC_TAILPTR_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x2C)
+#define XGMAC_DMA_CHA_TXDESC_RINGLEN_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x30)
+#define XGMAC_DMA_CHA_RXDESC_RINGLEN_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x34)
+#define XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x38)
+#define XGMAC_DMA_CHA_INT_RXWATCHTMR_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x3C)
+#define XGMAC_DMA_CHA_TXDESC_CURADDLO_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x44)
+#define XGMAC_DMA_CHA_RXDESC_CURADDLO_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x4C)
+#define XGMAC_DMA_CHA_CURTXBUF_ADDHI_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x50)
+#define XGMAC_DMA_CHA_CURTXBUF_ADDLO_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x54)
+#define XGMAC_DMA_CHA_CURRXBUF_ADDHI_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x58)
+#define XGMAC_DMA_CHA_CURRXBUF_ADDLO_REG(cha_num)		\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x5C)
+#define XGMAC_DMA_CHA_STATUS_REG(cha_num)			\
+	(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x60)
 
 /* TX DMA control register specific */
 #define XGMAC_TX_START_DMA	BIT(0)
@@ -451,9 +451,9 @@ enum vlan_tag_ctl_tx {
 #define XGMAC_DMA_INT_ENA_TUE	BIT(2)	/* Transmit Buffer Unavailable */
 #define XGMAC_DMA_INT_ENA_RIE	BIT(6)	/* Receive Interrupt */
 
-#define XGMAC_DMA_INT_NORMAL \
-		(XGMAC_DMA_INT_ENA_NIE | XGMAC_DMA_INT_ENA_RIE | \
-		XGMAC_DMA_INT_ENA_TIE | XGMAC_DMA_INT_ENA_TUE)
+#define XGMAC_DMA_INT_NORMAL					\
+	(XGMAC_DMA_INT_ENA_NIE | XGMAC_DMA_INT_ENA_RIE |	\
+	 XGMAC_DMA_INT_ENA_TIE | XGMAC_DMA_INT_ENA_TUE)
 
 /* DMA Abnormal interrupt */
 #define XGMAC_DMA_INT_ENA_AIE	BIT(15)	/* Abnormal Summary */
@@ -463,10 +463,10 @@ enum vlan_tag_ctl_tx {
 #define XGMAC_DMA_INT_ENA_FBE	BIT(12)	/* Fatal Bus Error */
 #define XGMAC_DMA_INT_ENA_CDEE	BIT(13)	/* Context Descriptor Error */
 
-#define XGMAC_DMA_INT_ABNORMAL \
-		(XGMAC_DMA_INT_ENA_AIE | XGMAC_DMA_INT_ENA_TSE | \
-		XGMAC_DMA_INT_ENA_RUE | XGMAC_DMA_INT_ENA_RSE | \
-		XGMAC_DMA_INT_ENA_FBE | XGMAC_DMA_INT_ENA_CDEE)
+#define XGMAC_DMA_INT_ABNORMAL					\
+	(XGMAC_DMA_INT_ENA_AIE | XGMAC_DMA_INT_ENA_TSE |	\
+	 XGMAC_DMA_INT_ENA_RUE | XGMAC_DMA_INT_ENA_RSE |	\
+	 XGMAC_DMA_INT_ENA_FBE | XGMAC_DMA_INT_ENA_CDEE)
 
 #define XGMAC_DMA_ENA_INT	(XGMAC_DMA_INT_NORMAL | XGMAC_DMA_INT_ABNORMAL)
 
-- 
1.8.1.2.459.gbcd45b4.dirty
