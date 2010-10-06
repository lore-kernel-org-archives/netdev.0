From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 17/19] bnx2x: code beautify
Date: Wed, 6 Oct 2010 15:34:21 +0200
Message-ID: <1286372061.30552.61.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932351Ab0JFNkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:40:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch does not include any functional changes.
The changes are: empty lines, indentation and comments.  

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |   54 ++++----
 drivers/net/bnx2x/bnx2x_cmn.c     |   60 +++++----
 drivers/net/bnx2x/bnx2x_cmn.h     |  145 ++++++++++++++-----
 drivers/net/bnx2x/bnx2x_ethtool.c |    5 +-
 drivers/net/bnx2x/bnx2x_main.c    |  275 +++++++++++++++++++------------------
 drivers/net/bnx2x/bnx2x_stats.c   |    4 +-
 drivers/net/bnx2x/bnx2x_stats.h   |    8 +-
 7 files changed, 318 insertions(+), 233 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index d80809f..6fc77a4 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -180,13 +180,14 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 #define SHMEM2_WR(bp, field, val)	REG_WR(bp, SHMEM2_ADDR(bp, field), val)
 #define MF_CFG_ADDR(bp, field)		(bp->common.mf_cfg_base + \
 					 offsetof(struct mf_cfg, field))
-#define MF2_CFG_ADDR(bp, field)	(bp->common.mf2_cfg_base + \
+#define MF2_CFG_ADDR(bp, field)		(bp->common.mf2_cfg_base + \
 					 offsetof(struct mf2_cfg, field))
 
 #define MF_CFG_RD(bp, field)		REG_RD(bp, MF_CFG_ADDR(bp, field))
 #define MF_CFG_WR(bp, field, val)	REG_WR(bp,\
 					       MF_CFG_ADDR(bp, field), (val))
 #define MF2_CFG_RD(bp, field)		REG_RD(bp, MF2_CFG_ADDR(bp, field))
+
 #define SHMEM2_HAS(bp, field)		((bp)->common.shmem2_base &&	\
 					 (SHMEM2_RD((bp), size) >	\
 					 offsetof(struct shmem2_region, field)))
@@ -310,7 +311,7 @@ struct bnx2x_fastpath {
 
 #define BNX2X_NAPI_WEIGHT       128
 	struct napi_struct	napi;
-	union host_hc_status_block status_blk;
+	union host_hc_status_block	status_blk;
 	/* chip independed shortcuts into sb structure */
 	__le16			*sb_index_values;
 	__le16			*sb_running_index;
@@ -349,8 +350,8 @@ struct bnx2x_fastpath {
 #define BNX2X_FP_STATE_TERMINATING	0xd0000
 #define BNX2X_FP_STATE_TERMINATED	0xe0000
 
-	u8			index;	/* number in fp array */
-	u8			cl_id;	/* eth client id */
+	u8			index;		/* number in fp array */
+	u8			cl_id;		/* eth client id */
 	u8			cl_qzone_id;
 	u8			fw_sb_id;	/* status block number in FW */
 	u8			igu_sb_id;	/* status block number in HW */
@@ -375,8 +376,6 @@ struct bnx2x_fastpath {
 	u16			last_max_sge;
 	__le16			*rx_cons_sb;
 
-
-
 	unsigned long		tx_pkt,
 				rx_pkt,
 				rx_calls;
@@ -977,7 +976,7 @@ struct bnx2x {
 	u32			mf2_config[E2_FUNC_MAX];
 	u16			mf_ov;
 	u8			mf_mode;
-#define IS_MF(bp)			(bp->mf_mode != 0)
+#define IS_MF(bp)		(bp->mf_mode != 0)
 
 	u8			wol;
 
@@ -1302,21 +1301,35 @@ struct bnx2x_func_init_params {
 			for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++)
 
 
+#define WAIT_RAMROD_POLL	0x01
+#define WAIT_RAMROD_COMMON	0x02
+int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
+			     int *state_p, int flags);
+
+/* dmae */
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
+void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
+			       u32 addr, u32 len);
+void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx);
+u32 bnx2x_dmae_opcode_add_comp(u32 opcode, u8 comp_type);
+u32 bnx2x_dmae_opcode_clr_src_reset(u32 opcode);
+u32 bnx2x_dmae_opcode(struct bnx2x *bp, u8 src_type, u8 dst_type,
+		      bool with_comp, u8 comp_type);
+
 int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param);
 void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
-void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
-			       u32 addr, u32 len);
+
 void bnx2x_calc_fc_adv(struct bnx2x *bp);
 int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		  u32 data_hi, u32 data_lo, int common);
 void bnx2x_update_coalesce(struct bnx2x *bp);
 int bnx2x_get_link_cfg_idx(struct bnx2x *bp);
+
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
 {
@@ -1333,6 +1346,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 	return val;
 }
+
 #define BNX2X_ILT_ZALLOC(x, y, size) \
 	do { \
 		x = pci_alloc_consistent(bp->pdev, size, y); \
@@ -1353,6 +1367,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 #define ILT_NUM_PAGE_ENTRIES	(3072)
 /* In 57710/11 we use whole table since we have 8 func
+ * In 57712 we have only 4 func, but use same size per func, then only half of
+ * the table in use
  */
 #define ILT_PER_FUNC		(ILT_NUM_PAGE_ENTRIES/8)
 
@@ -1366,14 +1382,13 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define ONCHIP_ADDR1(x)		((u32)(((u64)x >> 12) & 0xFFFFFFFF))
 #define ONCHIP_ADDR2(x)		((u32)((1 << 20) | ((u64)x >> 44)))
 
-
 /* load/unload mode */
 #define LOAD_NORMAL			0
 #define LOAD_OPEN			1
 #define LOAD_DIAG			2
 #define UNLOAD_NORMAL			0
 #define UNLOAD_CLOSE			1
-#define UNLOAD_RECOVERY                 2
+#define UNLOAD_RECOVERY			2
 
 
 /* DMAE command defines */
@@ -1447,7 +1462,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PMF_DMAE_C(bp)			(BP_PORT(bp) * MAX_DMAE_C_PER_PORT + \
 					 E1HVN_MAX)
 
-
 /* PCIE link and speed */
 #define PCICFG_LINK_WIDTH		0x1f00000
 #define PCICFG_LINK_WIDTH_SHIFT		20
@@ -1596,6 +1610,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_SP_DSB_INDEX \
 		(&bp->def_status_blk->sp_sb.\
 					index_values[HC_SP_INDEX_ETH_DEF_CONS])
+
 #define SET_FLAG(value, mask, flag) \
 	do {\
 		(value) &= ~(mask);\
@@ -1630,6 +1645,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #ifndef ETH_MAX_RX_CLIENTS_E2
 #define ETH_MAX_RX_CLIENTS_E2		ETH_MAX_RX_CLIENTS_E1H
 #endif
+
 #define BNX2X_VPD_LEN			128
 #define VENDOR_ID_LEN			4
 
@@ -1649,20 +1665,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 BNX2X_EXTERN int load_count[2][3]; /* per path: 0-common, 1-port0, 2-port1 */
 
-/* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
-
 extern void bnx2x_set_ethtool_ops(struct net_device *netdev);
 
-void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx);
-u32 bnx2x_dmae_opcode_add_comp(u32 opcode, u8 comp_type);
-u32 bnx2x_dmae_opcode_clr_src_reset(u32 opcode);
-u32 bnx2x_dmae_opcode(struct bnx2x *bp, u8 src_type, u8 dst_type,
-		      bool with_comp, u8 comp_type);
-
-
-#define WAIT_RAMROD_POLL	0x01
-#define WAIT_RAMROD_COMMON	0x02
-
-int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
-			     int *state_p, int flags);
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index a43cbc4..b5e15cf 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -15,7 +15,6 @@
  *
  */
 
-
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
 #include <net/ipv6.h>
@@ -136,7 +135,6 @@ int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	 */
 	smp_mb();
 
-	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
 		/* Taking tx_lock() is needed to prevent reenabling the queue
 		 * while it's empty. This could have happen if rx_action() gets
@@ -623,6 +621,7 @@ reuse_rx:
 			bnx2x_set_skb_rxhash(bp, cqe, skb);
 
 			skb_checksum_none_assert(skb);
+
 			if (bp->rx_csum) {
 				if (likely(BNX2X_RX_CSUM_OK(cqe)))
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -704,7 +703,6 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	return IRQ_HANDLED;
 }
 
-
 /* HW Lock for shared dual port PHYs */
 void bnx2x_acquire_phy_lock(struct bnx2x *bp)
 {
@@ -916,6 +914,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		}
 	}
 }
+
 static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
 	int i;
@@ -1185,6 +1184,7 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 	case ETH_RSS_MODE_REGULAR:
 		bp->num_queues = bnx2x_calc_num_queues(bp);
 		break;
+
 	default:
 		bp->num_queues = 1;
 		break;
@@ -1347,6 +1347,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Enable Timer scan */
 	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
 #endif
+
 	for_each_nondefault_queue(bp, i) {
 		rc = bnx2x_setup_client(bp, &bp->fp[i], 0);
 		if (rc)
@@ -1465,11 +1466,13 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);
+
 	del_timer_sync(&bp->timer);
+
 	SHMEM_WR(bp, func_mb[BP_FW_MB_IDX(bp)].drv_pulse_mb,
 		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
-	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
+	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
 	/* Cleanup the chip if needed */
 	if (unload_mode != UNLOAD_RECOVERY)
@@ -1506,6 +1509,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	return 0;
 }
+
 int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 {
 	u16 pmcsr;
@@ -1552,12 +1556,9 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 	return 0;
 }
 
-
-
 /*
  * net_device service functions
  */
-
 int bnx2x_poll(struct napi_struct *napi, int budget)
 {
 	int work_done = 0;
@@ -1587,19 +1588,19 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 		/* Fall out from the NAPI loop if needed */
 		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
 			bnx2x_update_fpsb_idx(fp);
-		/* bnx2x_has_rx_work() reads the status block,
-		 * thus we need to ensure that status block indices
-		 * have been actually read (bnx2x_update_fpsb_idx)
-		 * prior to this check (bnx2x_has_rx_work) so that
-		 * we won't write the "newer" value of the status block
-		 * to IGU (if there was a DMA right after
-		 * bnx2x_has_rx_work and if there is no rmb, the memory
-		 * reading (bnx2x_update_fpsb_idx) may be postponed
-		 * to right before bnx2x_ack_sb). In this case there
-		 * will never be another interrupt until there is
-		 * another update of the status block, while there
-		 * is still unhandled work.
-		 */
+			/* bnx2x_has_rx_work() reads the status block,
+			 * thus we need to ensure that status block indices
+			 * have been actually read (bnx2x_update_fpsb_idx)
+			 * prior to this check (bnx2x_has_rx_work) so that
+			 * we won't write the "newer" value of the status block
+			 * to IGU (if there was a DMA right after
+			 * bnx2x_has_rx_work and if there is no rmb, the memory
+			 * reading (bnx2x_update_fpsb_idx) may be postponed
+			 * to right before bnx2x_ack_sb). In this case there
+			 * will never be another interrupt until there is
+			 * another update of the status block, while there
+			 * is still unhandled work.
+			 */
 			rmb();
 
 			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
@@ -1618,7 +1619,6 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-
 /* we split the first BD into headers and data BDs
  * to ease the pain of our fellow microcode engineers
  * we use one mapping for both BDs
@@ -1834,6 +1834,7 @@ static inline void bnx2x_set_pbd_gso(struct sk_buff *skb,
 
 	pbd->global_data |= ETH_TX_PARSE_BD_E1X_PSEUDO_CS_WITHOUT_LEN;
 }
+
 /**
  *
  * @param skb
@@ -1906,6 +1907,7 @@ static inline u8 bnx2x_set_pbd_csum(struct bnx2x *bp, struct sk_buff *skb,
 
 	return hlen;
 }
+
 /* called with netif_tx_lock
  * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
  * netif_wake_queue()
@@ -1995,13 +1997,11 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
 
 	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	SET_FLAG(tx_start_bd->general_data,
-		  ETH_TX_START_BD_ETH_ADDR_TYPE,
-		  mac_type);
+	SET_FLAG(tx_start_bd->general_data, ETH_TX_START_BD_ETH_ADDR_TYPE,
+		 mac_type);
+
 	/* header nbd */
-	SET_FLAG(tx_start_bd->general_data,
-		  ETH_TX_START_BD_HDR_NBDS,
-		  1);
+	SET_FLAG(tx_start_bd->general_data, ETH_TX_START_BD_HDR_NBDS, 1);
 
 	/* remember the first BD of the packet */
 	tx_buf->first_bd = fp->tx_bd_prod;
@@ -2057,9 +2057,11 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	}
 
+	/* Map skb linear data for DMA */
 	mapping = dma_map_single(&bp->pdev->dev, skb->data,
 				 skb_headlen(skb), DMA_TO_DEVICE);
 
+	/* Setup the data pointer of the first BD of the packet */
 	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
 	nbd = skb_shinfo(skb)->nr_frags + 2; /* start_bd + pbd + frags */
@@ -2093,6 +2095,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
 
+	/* Handle fragmented skb */
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
@@ -2157,6 +2160,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	fp->tx_db.data.prod += nbd;
 	barrier();
+
 	DOORBELL(bp, fp->cid, fp->tx_db.raw);
 
 	mmiowb();
@@ -2179,6 +2183,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	return NETDEV_TX_OK;
 }
+
 /* called with rtnl_lock */
 int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 {
@@ -2311,6 +2316,7 @@ void bnx2x_vlan_rx_register(struct net_device *dev,
 }
 
 #endif
+
 int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 1d9686e..7f52cec 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -64,6 +64,15 @@ u8 bnx2x_link_test(struct bnx2x *bp, u8 is_serdes);
 void bnx2x__link_status_update(struct bnx2x *bp);
 
 /**
+ * Report link status to upper layer
+ *
+ * @param bp
+ *
+ * @return int
+ */
+void bnx2x_link_report(struct bnx2x *bp);
+
+/**
  * MSI-X slowpath interrupt handler
  *
  * @param irq
@@ -234,7 +243,7 @@ int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource);
 
 /**
  * Configure eth MAC address in the HW according to the value in
- * netdev->dev_addr for 57711
+ * netdev->dev_addr.
  *
  * @param bp driver handle
  * @param set
@@ -270,10 +279,11 @@ void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 			  u8 vf_valid, int fw_sb_id, int igu_sb_id);
 
 /**
- * Reconfigure FW/HW according to dev->flags rx mode
+ * Set MAC filtering configurations.
  *
- * @param dev net_device
+ * @remarks called with netif_tx_lock from dev_mcast.c
  *
+ * @param dev net_device
  */
 void bnx2x_set_rx_mode(struct net_device *dev);
 
@@ -295,17 +305,17 @@ void bnx2x_disable_close_the_gate(struct bnx2x *bp);
  * Perform statistics handling according to event
  *
  * @param bp driver handle
- * @param even tbnx2x_stats_event
+ * @param event bnx2x_stats_event
  */
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
 /**
- * Handle sp events
+ * Handle ramrods completion
  *
  * @param fp fastpath handle for the event
  * @param rr_cqe eth_rx_cqe
  */
-void bnx2x_sp_event(struct bnx2x_fastpath *fp,  union eth_rx_cqe *rr_cqe);
+void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe);
 
 /**
  * Init/halt function before/after sending
@@ -327,6 +337,46 @@ int bnx2x_func_stop(struct bnx2x *bp);
 void bnx2x_ilt_set_info(struct bnx2x *bp);
 
 /**
+ * Set power state to the requested value. Currently only D0 and
+ * D3hot are supported.
+ *
+ * @param bp
+ * @param state D0 or D3hot
+ *
+ * @return int
+ */
+int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
+
+/* dev_close main block */
+int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
+
+/* dev_open main block */
+int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
+
+/* hard_xmit callback */
+netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
+
+int bnx2x_change_mac_addr(struct net_device *dev, void *p);
+
+/* NAPI poll Rx part */
+int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget);
+
+/* NAPI poll Tx part */
+int bnx2x_tx_int(struct bnx2x_fastpath *fp);
+
+/* suspend/resume callbacks */
+int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state);
+int bnx2x_resume(struct pci_dev *pdev);
+
+/* Release IRQ vectors */
+void bnx2x_free_irq(struct bnx2x *bp);
+
+void bnx2x_init_rx_rings(struct bnx2x *bp);
+void bnx2x_free_skbs(struct bnx2x *bp);
+void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
+void bnx2x_netif_start(struct bnx2x *bp);
+
+/**
  * Fill msix_table, request vectors, update num_queues according
  * to number of available vectors
  *
@@ -362,6 +412,51 @@ int bnx2x_setup_irqs(struct bnx2x *bp);
  * @return int
  */
 int bnx2x_poll(struct napi_struct *napi, int budget);
+
+/**
+ * Allocate/release memories outsize main driver structure
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp);
+void bnx2x_free_mem_bp(struct bnx2x *bp);
+
+/**
+ * Change mtu netdev callback
+ *
+ * @param dev
+ * @param new_mtu
+ *
+ * @return int
+ */
+int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
+
+/**
+ * tx timeout netdev callback
+ *
+ * @param dev
+ * @param new_mtu
+ *
+ * @return int
+ */
+void bnx2x_tx_timeout(struct net_device *dev);
+
+#ifdef BCM_VLAN
+/**
+ * vlan rx register netdev callback
+ *
+ * @param dev
+ * @param new_mtu
+ *
+ * @return int
+ */
+void bnx2x_vlan_rx_register(struct net_device *dev,
+				   struct vlan_group *vlgrp);
+
+#endif
+
 static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 {
 	barrier(); /* status block is written to by the chip */
@@ -558,9 +653,6 @@ static inline u16 bnx2x_ack_int(struct bnx2x *bp)
 		return bnx2x_igu_ack_int(bp);
 }
 
-/*
- * fast path service functions
- */
 static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
 {
 	/* Tell compiler that consumer and producer can change */
@@ -611,6 +703,7 @@ static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 		rx_cons_sb++;
 	return (fp->rx_comp_cons != rx_cons_sb);
 }
+
 /**
  * disables tx from stack point of view
  *
@@ -731,6 +824,7 @@ static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
 
 	return 0;
 }
+
 static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 				     struct bnx2x_fastpath *fp, u16 index)
 {
@@ -782,6 +876,7 @@ static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 			   dma_unmap_addr(cons_rx_buf, mapping));
 	*prod_bd = *cons_bd;
 }
+
 static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 					   struct bnx2x_fastpath *fp, int last)
 {
@@ -846,6 +941,7 @@ static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
 		fp->tx_pkt = 0;
 	}
 }
+
 static inline void bnx2x_set_next_page_rx_bd(struct bnx2x_fastpath *fp)
 {
 	int i;
@@ -931,40 +1027,11 @@ static inline void storm_memset_cmng(struct bnx2x *bp,
 
 	__storm_memset_struct(bp, addr, size, (u32 *)cmng);
 }
+
 /* HW Lock for shared dual port PHYs */
 void bnx2x_acquire_phy_lock(struct bnx2x *bp);
 void bnx2x_release_phy_lock(struct bnx2x *bp);
 
-void bnx2x_link_report(struct bnx2x *bp);
-int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget);
-int bnx2x_tx_int(struct bnx2x_fastpath *fp);
-void bnx2x_init_rx_rings(struct bnx2x *bp);
-netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
-
-int bnx2x_change_mac_addr(struct net_device *dev, void *p);
-void bnx2x_tx_timeout(struct net_device *dev);
-void bnx2x_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp);
-void bnx2x_netif_start(struct bnx2x *bp);
-void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
-void bnx2x_free_irq(struct bnx2x *bp);
-int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state);
-int bnx2x_resume(struct pci_dev *pdev);
-void bnx2x_free_skbs(struct bnx2x *bp);
-int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
-int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
-int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
-int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
-
-/**
- * Allocate/release memories outsize main driver structure
- *
- * @param bp
- *
- * @return int
- */
-int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp);
-void bnx2x_free_mem_bp(struct bnx2x *bp);
-
 #define BNX2X_FW_IP_HDR_ALIGN_PAD	2 /* FW places hdr with this padding */
 
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 8fb0027..54fe061 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -25,7 +25,6 @@
 #include "bnx2x_cmn.h"
 #include "bnx2x_dump.h"
 
-
 static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -963,6 +962,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 
 	return rc;
 }
+
 static int bnx2x_get_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
@@ -1288,6 +1288,7 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 			save_val = REG_RD(bp, offset);
 
 			REG_WR(bp, offset, (wr_val & mask));
+
 			val = REG_RD(bp, offset);
 
 			/* Restore the original register's value */
@@ -1471,6 +1472,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	/* turn on parsing and get a BD */
 	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+
 	pbd_e1x = &fp_tx->tx_desc_ring[bd_prod].parse_bd_e1x;
 	pbd_e2 = &fp_tx->tx_desc_ring[bd_prod].parse_bd_e2;
 
@@ -1714,6 +1716,7 @@ static void bnx2x_self_test(struct net_device *dev,
 			buf[1] = 1;
 			etest->flags |= ETH_TEST_FL_FAILED;
 		}
+
 		buf[2] = bnx2x_test_loopback(bp, link_up);
 		if (buf[2] != 0)
 			etest->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index dcc4900..46210ed 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -56,7 +56,6 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_cmn.h"
 
-
 #include <linux/firmware.h>
 #include "bnx2x_fw_file_hdr.h"
 /* FW files */
@@ -1325,7 +1324,6 @@ static bool bnx2x_trylock_hw_lock(struct bnx2x *bp, u32 resource)
 	return false;
 }
 
-
 #ifdef BCM_CNIC
 static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid);
 #endif
@@ -1754,12 +1752,12 @@ void bnx2x_calc_fc_adv(struct bnx2x *bp)
 		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
 		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
-					  ADVERTISED_Pause);
+						   ADVERTISED_Pause);
 		break;
 
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
 		bp->port.advertising[cfg_idx] |= (ADVERTISED_Asym_Pause |
-					 ADVERTISED_Pause);
+						  ADVERTISED_Pause);
 		break;
 
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
@@ -1768,12 +1766,11 @@ void bnx2x_calc_fc_adv(struct bnx2x *bp)
 
 	default:
 		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
-					  ADVERTISED_Pause);
+						   ADVERTISED_Pause);
 		break;
 	}
 }
 
-
 u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 {
 	if (!BP_NOMCP(bp)) {
@@ -1952,6 +1949,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
 				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
 	}
+
 	DP(NETIF_MSG_IFUP,
 	   "func %d: vn_min_rate %d  vn_max_rate %d  vn_weight_sum %d\n",
 	   func, vn_min_rate, vn_max_rate, bp->vn_weight_sum);
@@ -1991,6 +1989,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 		       XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(func) + i * 4,
 		       ((u32 *)(&m_fair_vn))[i]);
 }
+
 static int bnx2x_get_cmng_fns_mode(struct bnx2x *bp)
 {
 	if (CHIP_REV_IS_SLOW(bp))
@@ -2625,13 +2624,13 @@ static inline void bnx2x_sp_prod_update(struct bnx2x *bp)
 	wmb();
 
 	REG_WR16(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
-	       bp->spq_prod_idx);
+		 bp->spq_prod_idx);
 	mmiowb();
 }
 
 /* the slow path queue is odd since completions arrive on the fastpath ring */
 int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
-			 u32 data_hi, u32 data_lo, int common)
+		  u32 data_hi, u32 data_lo, int common)
 {
 	struct eth_spe *spe;
 	u16 type;
@@ -3055,6 +3054,7 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 #define RESET_DONE_FLAG_MASK	(~LOAD_COUNTER_MASK)
 #define RESET_DONE_FLAG_SHIFT	LOAD_COUNTER_BITS
 #define CHIP_PARITY_SUPPORTED(bp)   (CHIP_IS_E1(bp) || CHIP_IS_E1H(bp))
+
 /*
  * should be run under rtnl lock
  */
@@ -4376,7 +4376,6 @@ gunzip_nomem1:
 static void bnx2x_gunzip_end(struct bnx2x *bp)
 {
 	kfree(bp->strm->workspace);
-
 	kfree(bp->strm);
 	bp->strm = NULL;
 
@@ -4641,6 +4640,7 @@ static void enable_blocks_attention(struct bnx2x *bp)
 	REG_WR(bp, CCM_REG_CCM_INT_MASK, 0);
 /*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_0, 0); */
 /*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_1, 0); */
+
 	if (CHIP_REV_IS_FPGA(bp))
 		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x580000);
 	else if (CHIP_IS_E2(bp))
@@ -4672,29 +4672,29 @@ static const struct {
 	{PXP2_REG_PXP2_PRTY_MASK_1,	0x7f},
 	{HC_REG_HC_PRTY_MASK,		0x7},
 	{MISC_REG_MISC_PRTY_MASK,	0x1},
-	{QM_REG_QM_PRTY_MASK, 0x0},
-	{DORQ_REG_DORQ_PRTY_MASK, 0x0},
+	{QM_REG_QM_PRTY_MASK,		0x0},
+	{DORQ_REG_DORQ_PRTY_MASK,	0x0},
 	{GRCBASE_UPB + PB_REG_PB_PRTY_MASK, 0x0},
 	{GRCBASE_XPB + PB_REG_PB_PRTY_MASK, 0x0},
-	{SRC_REG_SRC_PRTY_MASK, 0x4}, /* bit 2 */
-	{CDU_REG_CDU_PRTY_MASK, 0x0},
-	{CFC_REG_CFC_PRTY_MASK, 0x0},
-	{DBG_REG_DBG_PRTY_MASK, 0x0},
-	{DMAE_REG_DMAE_PRTY_MASK, 0x0},
-	{BRB1_REG_BRB1_PRTY_MASK, 0x0},
-	{PRS_REG_PRS_PRTY_MASK, (1<<6)},/* bit 6 */
-	{TSDM_REG_TSDM_PRTY_MASK, 0x18},/* bit 3,4 */
-	{CSDM_REG_CSDM_PRTY_MASK, 0x8},	/* bit 3 */
-	{USDM_REG_USDM_PRTY_MASK, 0x38},/* bit 3,4,5 */
-	{XSDM_REG_XSDM_PRTY_MASK, 0x8},	/* bit 3 */
-	{TSEM_REG_TSEM_PRTY_MASK_0, 0x0},
-	{TSEM_REG_TSEM_PRTY_MASK_1, 0x0},
-	{USEM_REG_USEM_PRTY_MASK_0, 0x0},
-	{USEM_REG_USEM_PRTY_MASK_1, 0x0},
-	{CSEM_REG_CSEM_PRTY_MASK_0, 0x0},
-	{CSEM_REG_CSEM_PRTY_MASK_1, 0x0},
-	{XSEM_REG_XSEM_PRTY_MASK_0, 0x0},
-	{XSEM_REG_XSEM_PRTY_MASK_1, 0x0}
+	{SRC_REG_SRC_PRTY_MASK,		0x4}, /* bit 2 */
+	{CDU_REG_CDU_PRTY_MASK,		0x0},
+	{CFC_REG_CFC_PRTY_MASK,		0x0},
+	{DBG_REG_DBG_PRTY_MASK,		0x0},
+	{DMAE_REG_DMAE_PRTY_MASK,	0x0},
+	{BRB1_REG_BRB1_PRTY_MASK,	0x0},
+	{PRS_REG_PRS_PRTY_MASK,		(1<<6)},/* bit 6 */
+	{TSDM_REG_TSDM_PRTY_MASK,	0x18},	/* bit 3,4 */
+	{CSDM_REG_CSDM_PRTY_MASK,	0x8},	/* bit 3 */
+	{USDM_REG_USDM_PRTY_MASK,	0x38},  /* bit 3,4,5 */
+	{XSDM_REG_XSDM_PRTY_MASK,	0x8},	/* bit 3 */
+	{TSEM_REG_TSEM_PRTY_MASK_0,	0x0},
+	{TSEM_REG_TSEM_PRTY_MASK_1,	0x0},
+	{USEM_REG_USEM_PRTY_MASK_0,	0x0},
+	{USEM_REG_USEM_PRTY_MASK_1,	0x0},
+	{CSEM_REG_CSEM_PRTY_MASK_0,	0x0},
+	{CSEM_REG_CSEM_PRTY_MASK_1,	0x0},
+	{XSEM_REG_XSEM_PRTY_MASK_0,	0x0},
+	{XSEM_REG_XSEM_PRTY_MASK_1,	0x0}
 };
 
 static void enable_blocks_parity(struct bnx2x *bp)
@@ -4906,7 +4906,6 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 
 	bnx2x_ilt_init_page_size(bp, INITOP_SET);
 
-
 	if (CHIP_REV_IS_FPGA(bp) && CHIP_IS_E1H(bp))
 		REG_WR(bp, PXP2_REG_PGL_TAGS_LIMIT, 0x1);
 
@@ -5003,6 +5002,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 
 	if (CHIP_MODE_IS_4_PORT(bp))
 		bnx2x_init_block(bp, QM_4PORT_BLOCK, COMMON_STAGE);
+
 	/* QM queues pointers table */
 	bnx2x_qm_init_ptr_table(bp, bp->qm_cid_count, INITOP_SET);
 
@@ -5036,6 +5036,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 #endif
 	if (!CHIP_IS_E1(bp))
 		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_MF(bp));
+
 	if (CHIP_IS_E2(bp)) {
 		/* Bit-map indicating which L2 hdrs may appear after the
 		   basic Ethernet header */
@@ -5081,6 +5082,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	REG_WR(bp, SRC_REG_SOFT_RST, 1);
 	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4)
 		REG_WR(bp, i, random32());
+
 	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
 #ifdef BCM_CNIC
 	REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
@@ -5467,6 +5469,7 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 		set the size */
 	}
 	bnx2x_ilt_init_op(bp, INITOP_SET);
+
 #ifdef BCM_CNIC
 	bnx2x_src_init_t2(bp, bp->t2, bp->t2_mapping, SRC_CONN_NUM);
 
@@ -5692,6 +5695,7 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	bnx2x_init_block(bp, DMAE_BLOCK, FUNC0_STAGE + func);
 
 	bnx2x_phy_probe(&bp->link_params);
+
 	return 0;
 }
 
@@ -5826,6 +5830,7 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	bnx2x_ilt_mem_op(bp, ILT_MEMOP_FREE);
 
 	BNX2X_FREE(bp->ilt->lines);
+
 #ifdef BCM_CNIC
 	if (CHIP_IS_E2(bp))
 		BNX2X_PCI_FREE(bp->cnic_sb.e2_sb, bp->cnic_sb_mapping,
@@ -5833,8 +5838,10 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	else
 		BNX2X_PCI_FREE(bp->cnic_sb.e1x_sb, bp->cnic_sb_mapping,
 			       sizeof(struct host_hc_status_block_e1x));
+
 	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
 #endif
+
 	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, BCM_PAGE_SIZE);
 
 	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
@@ -5862,7 +5869,6 @@ static inline void set_sb_shortcuts(struct bnx2x *bp, int index)
 
 int bnx2x_alloc_mem(struct bnx2x *bp)
 {
-
 #define BNX2X_PCI_ALLOC(x, y, size) \
 	do { \
 		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
@@ -5951,6 +5957,7 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 			sizeof(struct bnx2x_slowpath));
 
 	bp->context.size = sizeof(union cdu_context) * bp->l2_cid_count;
+
 	BNX2X_PCI_ALLOC(bp->context.vcxt, &bp->context.cxt_mapping,
 			bp->context.size);
 
@@ -5997,7 +6004,7 @@ int bnx2x_func_stop(struct bnx2x *bp)
 }
 
 /**
- * Sets a MAC in a CAM for a few L2 Clients for E1x chip
+ * Sets a MAC in a CAM for a few L2 Clients for E1x chips
  *
  * @param bp driver descriptor
  * @param set set or clear an entry (1 or 0)
@@ -6007,8 +6014,8 @@ int bnx2x_func_stop(struct bnx2x *bp)
  * @param is_bcast is the set MAC a broadcast address (for E1 only)
  */
 static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, u8 *mac,
-				      u32 cl_bit_vec, u8 cam_offset,
-				      u8 is_bcast)
+				   u32 cl_bit_vec, u8 cam_offset,
+				   u8 is_bcast)
 {
 	struct mac_configuration_cmd *config =
 		(struct mac_configuration_cmd *)bnx2x_sp(bp, mac_config);
@@ -6060,9 +6067,8 @@ static void bnx2x_set_mac_addr_gen(struct bnx2x *bp, int set, u8 *mac,
 	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, ramrod_flags);
 }
 
-
 int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
-			     int *state_p, int flags)
+		      int *state_p, int flags)
 {
 	/* can take a while if any port is running */
 	int cnt = 5000;
@@ -6220,7 +6226,6 @@ static void bnx2x_invlidate_e1_mc_list(struct bnx2x *bp)
 
 }
 
-
 #ifdef BCM_CNIC
 /**
  * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
@@ -6567,6 +6572,7 @@ void bnx2x_ilt_set_info(struct bnx2x *bp)
 	ilt_client->flags = (ILT_CLIENT_SKIP_INIT | ILT_CLIENT_SKIP_MEM);
 #endif
 }
+
 int bnx2x_setup_client(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		       int is_leading)
 {
@@ -6952,7 +6958,6 @@ void bnx2x_disable_close_the_gate(struct bnx2x *bp)
 	}
 }
 
-
 /* Close gates #2, #3 and #4: */
 static void bnx2x_set_234_gates(struct bnx2x *bp, bool close)
 {
@@ -6998,15 +7003,13 @@ static void bnx2x_clp_reset_prep(struct bnx2x *bp, u32 *magic_val)
 static void bnx2x_clp_reset_done(struct bnx2x *bp, u32 magic_val)
 {
 	/* Restore the `magic' bit value... */
-	/* u32 val = SHMEM_RD(bp, mf_cfg.shared_mf_config.clp_mb);
-	SHMEM_WR(bp, mf_cfg.shared_mf_config.clp_mb,
-		(val & (~SHARED_MF_CLP_MAGIC)) | magic_val); */
 	u32 val = MF_CFG_RD(bp, shared_mf_config.clp_mb);
 	MF_CFG_WR(bp, shared_mf_config.clp_mb,
 		(val & (~SHARED_MF_CLP_MAGIC)) | magic_val);
 }
 
-/* Prepares for MCP reset: takes care of CLP configurations.
+/**
+ * Prepares for MCP reset: takes care of CLP configurations.
  *
  * @param bp
  * @param magic_val Old value of 'magic' bit.
@@ -7535,7 +7538,6 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			bp->fw_seq =
 			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
-
 		} else
 			bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 	}
@@ -7654,7 +7656,8 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	}
 	bp->link_params.feature_config_flags |=
 				(val >= REQ_BC_VER_4_VRFY_FIRST_PHY_OPT_MDL) ?
-		FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY : 0;
+				FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY : 0;
+
 	bp->link_params.feature_config_flags |=
 		(val >= REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL) ?
 		FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY : 0;
@@ -7771,7 +7774,7 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 			   SHMEM_RD(bp,
 			   dev_info.port_hw_config[port].external_phy_config2));
 			return;
-		}
+	}
 
 	switch (switch_cfg) {
 	case SWITCH_CFG_1G:
@@ -7784,7 +7787,6 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 		bp->port.phy_addr = REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
 					   port*0x18);
 		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
-
 		break;
 
 	default:
@@ -7813,7 +7815,7 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
 			bp->port.supported[idx] &= ~(SUPPORTED_1000baseT_Half |
-					SUPPORTED_1000baseT_Full);
+						     SUPPORTED_1000baseT_Full);
 
 		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
@@ -7847,41 +7849,41 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 		bp->link_params.req_duplex[idx] = DUPLEX_FULL;
 		link_config = bp->port.link_config[idx];
 		switch (link_config & PORT_FEATURE_LINK_SPEED_MASK) {
-	case PORT_FEATURE_LINK_SPEED_AUTO:
+		case PORT_FEATURE_LINK_SPEED_AUTO:
 			if (bp->port.supported[idx] & SUPPORTED_Autoneg) {
 				bp->link_params.req_line_speed[idx] =
 					SPEED_AUTO_NEG;
 				bp->port.advertising[idx] |=
 					bp->port.supported[idx];
-		} else {
-			/* force 10G, no AN */
+			} else {
+				/* force 10G, no AN */
 				bp->link_params.req_line_speed[idx] =
 					SPEED_10000;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_10000baseT_Full |
-						 ADVERTISED_FIBRE);
+					 ADVERTISED_FIBRE);
 				continue;
-		}
-		break;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_10M_FULL:
+		case PORT_FEATURE_LINK_SPEED_10M_FULL:
 			if (bp->port.supported[idx] & SUPPORTED_10baseT_Full) {
 				bp->link_params.req_line_speed[idx] =
 					SPEED_10;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_10baseT_Full |
-						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
-				    "Invalid link_config 0x%x"
-				    "  speed_cap_mask 0x%x\n",
-				    link_config,
+					 ADVERTISED_TP);
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
+					    "Invalid link_config 0x%x"
+					    "  speed_cap_mask 0x%x\n",
+					    link_config,
 				    bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_10M_HALF:
+		case PORT_FEATURE_LINK_SPEED_10M_HALF:
 			if (bp->port.supported[idx] & SUPPORTED_10baseT_Half) {
 				bp->link_params.req_line_speed[idx] =
 					SPEED_10;
@@ -7889,70 +7891,74 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 					DUPLEX_HALF;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_10baseT_Half |
-						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
-				    "Invalid link_config 0x%x"
-				    "  speed_cap_mask 0x%x\n",
-				    link_config,
-				    bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+					 ADVERTISED_TP);
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
+					    "Invalid link_config 0x%x"
+					    "  speed_cap_mask 0x%x\n",
+					    link_config,
+					  bp->link_params.speed_cap_mask[idx]);
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-			if (bp->port.supported[idx] & SUPPORTED_100baseT_Full) {
+		case PORT_FEATURE_LINK_SPEED_100M_FULL:
+			if (bp->port.supported[idx] &
+			    SUPPORTED_100baseT_Full) {
 				bp->link_params.req_line_speed[idx] =
 					SPEED_100;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_100baseT_Full |
-						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
-				    "Invalid link_config 0x%x"
-				    "  speed_cap_mask 0x%x\n",
-				    link_config,
-				    bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+					 ADVERTISED_TP);
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
+					    "Invalid link_config 0x%x"
+					    "  speed_cap_mask 0x%x\n",
+					    link_config,
+					  bp->link_params.speed_cap_mask[idx]);
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-			if (bp->port.supported[idx] & SUPPORTED_100baseT_Half) {
-				bp->link_params.req_line_speed[idx] = SPEED_100;
-				bp->link_params.req_duplex[idx] = DUPLEX_HALF;
+		case PORT_FEATURE_LINK_SPEED_100M_HALF:
+			if (bp->port.supported[idx] &
+			    SUPPORTED_100baseT_Half) {
+				bp->link_params.req_line_speed[idx] =
+								SPEED_100;
+				bp->link_params.req_duplex[idx] =
+								DUPLEX_HALF;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_100baseT_Half |
-						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
+					 ADVERTISED_TP);
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
 				    bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_1G:
+		case PORT_FEATURE_LINK_SPEED_1G:
 			if (bp->port.supported[idx] &
 			    SUPPORTED_1000baseT_Full) {
 				bp->link_params.req_line_speed[idx] =
 					SPEED_1000;
 				bp->port.advertising[idx] |=
 					(ADVERTISED_1000baseT_Full |
-						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
+					 ADVERTISED_TP);
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
 				    bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_2_5G:
+		case PORT_FEATURE_LINK_SPEED_2_5G:
 			if (bp->port.supported[idx] &
 			    SUPPORTED_2500baseX_Full) {
 				bp->link_params.req_line_speed[idx] =
@@ -7960,19 +7966,19 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 				bp->port.advertising[idx] |=
 					(ADVERTISED_2500baseX_Full |
 						ADVERTISED_TP);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
-				     bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+				    bp->link_params.speed_cap_mask[idx]);
+				return;
+			}
+			break;
 
-	case PORT_FEATURE_LINK_SPEED_10G_CX4:
-	case PORT_FEATURE_LINK_SPEED_10G_KX4:
-	case PORT_FEATURE_LINK_SPEED_10G_KR:
+		case PORT_FEATURE_LINK_SPEED_10G_CX4:
+		case PORT_FEATURE_LINK_SPEED_10G_KX4:
+		case PORT_FEATURE_LINK_SPEED_10G_KR:
 			if (bp->port.supported[idx] &
 			    SUPPORTED_10000baseT_Full) {
 				bp->link_params.req_line_speed[idx] =
@@ -7980,24 +7986,26 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 				bp->port.advertising[idx] |=
 					(ADVERTISED_10000baseT_Full |
 						ADVERTISED_FIBRE);
-		} else {
-			BNX2X_ERROR("NVRAM config error. "
+			} else {
+				BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
 				    link_config,
-				     bp->link_params.speed_cap_mask[idx]);
-			return;
-		}
-		break;
+				    bp->link_params.speed_cap_mask[idx]);
+				return;
+			}
+			break;
 
-	default:
-		BNX2X_ERROR("NVRAM config error. "
-			    "BAD link speed link_config 0x%x\n",
-				  link_config);
-			bp->link_params.req_line_speed[idx] = SPEED_AUTO_NEG;
-			bp->port.advertising[idx] = bp->port.supported[idx];
-		break;
-	}
+		default:
+			BNX2X_ERROR("NVRAM config error. "
+				    "BAD link speed link_config 0x%x\n",
+					  link_config);
+				bp->link_params.req_line_speed[idx] =
+							SPEED_AUTO_NEG;
+				bp->port.advertising[idx] =
+						bp->port.supported[idx];
+			break;
+		}
 
 		bp->link_params.req_flow_ctrl[idx] = (link_config &
 					 PORT_FEATURE_FLOW_CONTROL_MASK);
@@ -8059,14 +8067,14 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->wol = (!(bp->flags & NO_WOL_FLAG) &&
 		   (config & PORT_FEATURE_WOL_ENABLED));
 
-	BNX2X_DEV_INFO("lane_config 0x%08x"
+	BNX2X_DEV_INFO("lane_config 0x%08x  "
 		       "speed_cap_mask0 0x%08x  link_config0 0x%08x\n",
 		       bp->link_params.lane_config,
 		       bp->link_params.speed_cap_mask[0],
 		       bp->port.link_config[0]);
 
 	bp->link_params.switch_cfg = (bp->port.link_config[0] &
-				       PORT_FEATURE_CONNECTED_SWITCH_MASK);
+				      PORT_FEATURE_CONNECTED_SWITCH_MASK);
 	bnx2x_phy_probe(&bp->link_params);
 	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
 
@@ -8461,12 +8469,10 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC)
 		rx_mode = BNX2X_RX_MODE_PROMISC;
-
 	else if ((dev->flags & IFF_ALLMULTI) ||
 		 ((netdev_mc_count(dev) > BNX2X_MAX_MULTICAST) &&
 		  CHIP_IS_E1(bp)))
 		rx_mode = BNX2X_RX_MODE_ALLMULTI;
-
 	else { /* some multicasts */
 		if (CHIP_IS_E1(bp)) {
 			/*
@@ -8506,12 +8512,10 @@ void bnx2x_set_rx_mode(struct net_device *dev)
 		}
 	}
 
-
 	bp->rx_mode = rx_mode;
 	bnx2x_set_storm_rx_mode(bp);
 }
 
-
 /* called with rtnl_lock */
 static int bnx2x_mdio_read(struct net_device *netdev, int prtad,
 			   int devad, u16 addr)
@@ -9002,6 +9006,7 @@ static inline int bnx2x_set_qm_cid_count(struct bnx2x *bp, int l2_cid_count)
 #endif
 	return roundup(cid_count, QM_CID_ROUND);
 }
+
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
@@ -9029,6 +9034,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	}
 
 	cid_count += CNIC_CONTEXT_USE;
+
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), cid_count);
 	if (!dev) {
@@ -9120,6 +9126,7 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 
 	/* Disable MSI/MSI-X */
 	bnx2x_disable_msi(bp);
+
 	/* Make sure RESET task is not scheduled before continuing */
 	cancel_delayed_work_sync(&bp->reset_task);
 
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index ad7aa55..5644bdd 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -14,8 +14,8 @@
  * Statistics and Link management by Yitchak Gertner
  *
  */
- #include "bnx2x_cmn.h"
- #include "bnx2x_stats.h"
+#include "bnx2x_cmn.h"
+#include "bnx2x_stats.h"
 
 /* Statistics */
 
diff --git a/drivers/net/bnx2x/bnx2x_stats.h b/drivers/net/bnx2x/bnx2x_stats.h
index 38a4e90..afd15ef 100644
--- a/drivers/net/bnx2x/bnx2x_stats.h
+++ b/drivers/net/bnx2x/bnx2x_stats.h
@@ -9,6 +9,10 @@
  * Maintained by: Eilon Greenstein <eilong@broadcom.com>
  * Written by: Eliezer Tamir
  * Based on code from Michael Chan's bnx2 driver
+ * UDP CSUM errata workaround by Arik Gendelman
+ * Slowpath and fastpath rework by Vladislav Zolotarov
+ * Statistics and Link management by Yitchak Gertner
+ *
  */
 
 #ifndef BNX2X_STATS_H
@@ -228,12 +232,8 @@ struct bnx2x_eth_stats {
 /* Forward declaration */
 struct bnx2x;
 
-
 void bnx2x_stats_init(struct bnx2x *bp);
 
 extern const u32 dmae_reg_go_c[];
-extern int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
-			 u32 data_hi, u32 data_lo, int common);
-
 
 #endif /* BNX2X_STATS_H */
-- 
1.7.1




