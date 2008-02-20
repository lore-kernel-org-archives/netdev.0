From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 1/8][BNX2X]: fix spelling, some fashion
 policework, report PCI link
Date: Wed, 20 Feb 2008 19:33:55 +0200
Message-ID: <1203528835.8232.89.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2614 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbYBTRld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:41:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: fix spelling, some fashion policework, report PCI link


Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  272 ++++++++++++++++++++++-----------------------------
 drivers/net/bnx2x.h |    7 +-
 2 files changed, 121 insertions(+), 158 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index afc7f34..b137f53 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -10,13 +10,13 @@
  * Based on code from Michael Chan's bnx2 driver
  * UDP CSUM errata workaround by Arik Gendelman
  * Slowpath rework by Vladislav Zolotarov
- * Statistics and Link managment by Yitchak Gertner
+ * Statistics and Link management by Yitchak Gertner
  *
  */
 
 /* define this to make the driver freeze on error
  * to allow getting debug info
- * (you will need to reboot afterwords)
+ * (you will need to reboot afterwards)
  */
 /*#define BNX2X_STOP_ON_ERROR*/
 
@@ -71,14 +71,14 @@
 #define TX_TIMEOUT      	(5*HZ)
 
 static char version[] __devinitdata =
-	"Broadcom NetXtreme II 577xx 10Gigabit Ethernet Driver "
+	"Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
-MODULE_INFO(cvs_version, "$Revision: #356 $");
+MODULE_INFO(cvs_version, "$Revision: #362 $");
 
 static int use_inta;
 static int poll;
@@ -94,8 +94,8 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(use_inta, "use INT#A instead of MSI-X");
 MODULE_PARM_DESC(poll, "use polling (for debug)");
 MODULE_PARM_DESC(onefunc, "enable only first function");
-MODULE_PARM_DESC(nomcp, "ignore managment CPU (Implies onefunc)");
-MODULE_PARM_DESC(debug, "defualt debug msglevel");
+MODULE_PARM_DESC(nomcp, "ignore management CPU (Implies onefunc)");
+MODULE_PARM_DESC(debug, "default debug msglevel");
 
 #ifdef BNX2X_MULTI
 module_param(use_multi, int, 0);
@@ -107,12 +107,14 @@ enum bnx2x_board_type {
 };
 
 /* indexed by board_t, above */
-static struct {
-	char *name;
-} board_info[] __devinitdata = {
-	{ "Broadcom NetXtreme II BCM57710 XGb" }
+static char *board_info[] = {
+	"Broadcom NetXtreme II BCM57710 XGb",
 };
 
+#ifndef PCI_DEVICE_ID_NX2_57710
+#define PCI_DEVICE_ID_NX2_57710 	0x164e
+#endif
+
 static const struct pci_device_id bnx2x_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
@@ -341,6 +343,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 	}
 	return rc;
 }
+
 static void bnx2x_fw_dump(struct bnx2x *bp)
 {
 	u32 mark, offset;
@@ -491,7 +494,7 @@ static void bnx2x_disable_int_sync(struct bnx2x *bp)
 	int i;
 
 	atomic_inc(&bp->intr_sem);
-	/* prevent the HW from sending interrupts*/
+	/* prevent the HW from sending interrupts */
 	bnx2x_disable_int(bp);
 
 	/* make sure all ISRs are done */
@@ -775,6 +778,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		mb(); /* force bnx2x_wait_ramrod to see the change */
 		return;
 	}
+
 	switch (command | bp->state) {
 	case (RAMROD_CMD_ID_ETH_PORT_SETUP | BNX2X_STATE_OPENING_WAIT4_PORT):
 		DP(NETIF_MSG_IFUP, "got setup ramrod\n");
@@ -1471,7 +1475,7 @@ static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
 }
 
 /*
- * link managment
+ * link management
  */
 
 static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
@@ -1482,7 +1486,7 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
 
 	bp->flow_ctrl = 0;
 
-	/* reolve from gp_status in case of AN complete and not sgmii */
+	/* resolve from gp_status in case of AN complete and not sgmii */
 	if ((bp->req_autoneg & AUTONEG_FLOW_CTRL) &&
 	    (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
 	    (!(bp->phy_flags & PHY_SGMII_FLAG)) &&
@@ -1680,7 +1684,7 @@ static void bnx2x_link_int_ack(struct bnx2x *bp, int is_10g)
 	int port = bp->port;
 
 	/* first reset all status
-	 * we asume only one line will be change at a time */
+	 * we assume only one line will be change at a time */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 		       (NIG_XGXS0_LINK_STATUS |
 			NIG_SERDES0_LINK_STATUS |
@@ -1819,7 +1823,7 @@ static void bnx2x_bmac_enable(struct bnx2x *bp, int is_lb)
 	u32 wb_write[2];
 	u32 val;
 
-	DP(NETIF_MSG_LINK, "enableing BigMAC\n");
+	DP(NETIF_MSG_LINK, "enabling BigMAC\n");
 	/* reset and unreset the BigMac */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
@@ -1940,7 +1944,7 @@ static void bnx2x_emac_enable(struct bnx2x *bp)
 	u32 val;
 	int timeout;
 
-	DP(NETIF_MSG_LINK, "enableing EMAC\n");
+	DP(NETIF_MSG_LINK, "enabling EMAC\n");
 	/* reset and unreset the emac core */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
@@ -2033,7 +2037,7 @@ static void bnx2x_emac_enable(struct bnx2x *bp)
 				      EMAC_TX_MODE_EXT_PAUSE_EN);
 	}
 
-	/* KEEP_VLAN_TAG, promiscous */
+	/* KEEP_VLAN_TAG, promiscuous */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
 	EMAC_WR(EMAC_REG_EMAC_RX_MODE, val);
@@ -2161,7 +2165,6 @@ static void bnx2x_pbf_update(struct bnx2x *bp)
 	u32 count = 1000;
 	u32 pause = 0;
 
-
 	/* disable port */
 	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
 
@@ -2803,7 +2806,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
 			bp->phy_addr = ext_phy_type;
 			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
@@ -2824,7 +2827,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
 			bp->phy_addr = ext_phy_type;
 			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
@@ -2857,7 +2860,7 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 			bnx2x_bits_en(bp,
 				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled extenal phy int\n");
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 			break;
 
 		default:
@@ -2994,13 +2997,13 @@ static void bnx2x_link_initialize(struct bnx2x *bp)
 			/* AN enabled */
 			bnx2x_set_brcm_cl37_advertisment(bp);
 
-			/* program duplex & pause advertisment (for aneg) */
+			/* program duplex & pause advertisement (for aneg) */
 			bnx2x_set_ieee_aneg_advertisment(bp);
 
 			/* enable autoneg */
 			bnx2x_set_autoneg(bp);
 
-			/* enalbe and restart AN */
+			/* enable and restart AN */
 			bnx2x_restart_autoneg(bp);
 		}
 
@@ -3158,7 +3161,7 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	int port = bp->port;
 
 	DP(NETIF_MSG_TIMER,
-	   "spe (%x:%x)  command %x  hw_cid %x  data (%x:%x)  left %x\n",
+	   "spe (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
 	   (u32)U64_HI(bp->spq_mapping), (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
 	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
@@ -3464,7 +3467,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_PRTY_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_PRTY_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block parity atention\n");
+				BNX2X_ERR("FATAL HW block parity attention\n");
 		}
 	}
 
@@ -3906,7 +3909,7 @@ static void bnx2x_stop_stats(struct bnx2x *bp)
 
 		while (bp->stats_state != STATS_STATE_DISABLE) {
 			if (!timeout) {
-				BNX2X_ERR("timeout wating for stats stop\n");
+				BNX2X_ERR("timeout waiting for stats stop\n");
 				break;
 			}
 			timeout--;
@@ -4173,21 +4176,18 @@ static void bnx2x_update_net_stats(struct bnx2x *bp)
 
 	nstats->rx_bytes = bnx2x_hilo(&estats->total_bytes_received_hi);
 
-	nstats->tx_bytes =
-		bnx2x_hilo(&estats->total_bytes_transmitted_hi);
+	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
-	nstats->rx_dropped = estats->checksum_discard +
-				   estats->mac_discard;
+	nstats->rx_dropped = estats->checksum_discard + estats->mac_discard;
 	nstats->tx_dropped = 0;
 
 	nstats->multicast =
 		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi);
 
-	nstats->collisions =
-		estats->single_collision_transmit_frames +
-		estats->multiple_collision_transmit_frames +
-		estats->late_collision_frames +
-		estats->excessive_collision_frames;
+	nstats->collisions = estats->single_collision_transmit_frames +
+			     estats->multiple_collision_transmit_frames +
+			     estats->late_collision_frames +
+			     estats->excessive_collision_frames;
 
 	nstats->rx_length_errors = estats->runt_packets_received +
 				   estats->jabber_packets_received;
@@ -4195,7 +4195,7 @@ static void bnx2x_update_net_stats(struct bnx2x *bp)
 	nstats->rx_crc_errors = estats->crc_receive_errors;
 	nstats->rx_frame_errors = estats->alignment_errors;
 	nstats->rx_fifo_errors = estats->brb_discard +
-				       estats->brb_truncate_discard;
+				 estats->brb_truncate_discard;
 	nstats->rx_missed_errors = estats->xxoverflow_discard;
 
 	nstats->rx_errors = nstats->rx_length_errors +
@@ -4205,7 +4205,7 @@ static void bnx2x_update_net_stats(struct bnx2x *bp)
 			    nstats->rx_fifo_errors;
 
 	nstats->tx_aborted_errors = estats->late_collision_frames +
-					  estats->excessive_collision_frames;
+				    estats->excessive_collision_frames;
 	nstats->tx_carrier_errors = estats->false_carrier_detections;
 	nstats->tx_fifo_errors = 0;
 	nstats->tx_heartbeat_errors = 0;
@@ -4626,7 +4626,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		fp->rx_bd_prod = fp->rx_comp_prod = ring_prod;
 		fp->rx_pkt = fp->rx_calls = 0;
 
-		/* Warning! this will genrate an interrupt (to the TSTORM) */
+		/* Warning! this will generate an interrupt (to the TSTORM) */
 		/* must only be done when chip is initialized */
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
 		       TSTORM_RCQ_PROD_OFFSET(port, j), ring_prod);
@@ -4850,7 +4850,7 @@ static void bnx2x_init_internal(struct bnx2x *bp)
 /*      DP(NETIF_MSG_IFUP, "tstorm_config: 0x%08x\n",
 	   (*(u32 *)&tstorm_config)); */
 
-	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx untill link is up */
+	bp->rx_mode = BNX2X_RX_MODE_NONE; /* no rx until link is up */
 	bnx2x_set_storm_rx_mode(bp);
 
 	for_each_queue(bp, i)
@@ -5359,7 +5359,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		REG_RD(bp, USEM_REG_PASSIVE_BUFFER + 8);
 #endif
 		bnx2x_init_block(bp, QM_COMMON_START, QM_COMMON_END);
-		/* softrest pulse */
+		/* soft reset pulse */
 		REG_WR(bp, QM_REG_SOFT_RESET, 1);
 		REG_WR(bp, QM_REG_SOFT_RESET, 0);
 
@@ -5413,7 +5413,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		REG_WR(bp, SRC_REG_SOFT_RST, 1);
 		for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
 			REG_WR(bp, i, 0xc0cac01a);
-			/* TODO: repleace with something meaningfull */
+			/* TODO: replace with something meaningful */
 		}
 		/* SRCH COMMON comes here */
 		REG_WR(bp, SRC_REG_SOFT_RST, 0);
@@ -5647,7 +5647,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 
 	bnx2x_link_reset(bp);
 
-	/* Reset pciex errors for debug */
+	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
 	REG_WR(bp, 0x2120, 0xffffffff);
 	REG_WR(bp, 0x2814, 0xffffffff);
@@ -5681,8 +5681,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	return 0;
 }
 
-
-/* send the MCP a request, block untill there is a reply */
+/* send the MCP a request, block until there is a reply */
 static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 {
 	u32 rc = 0;
@@ -5869,7 +5868,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 	for (i = 0; i < 16*1024; i += 64)
 		* (u64 *)((char *)bp->t2 + i + 56) = bp->t2_mapping + i + 64;
 
-	/* now sixup the last line in the block to point to the next block */
+	/* now fixup the last line in the block to point to the next block */
 	*(u64 *)((char *)bp->t2 + 1024*16-8) = bp->t2_mapping;
 
 	/* Timer block array (MAX_CONN*8) phys uncached for now 1024 conns */
@@ -5950,11 +5949,11 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 	int i;
 
 	free_irq(bp->msix_table[0].vector, bp->dev);
-	DP(NETIF_MSG_IFDOWN, "rleased sp irq (%d)\n",
+	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
 	   bp->msix_table[0].vector);
 
 	for_each_queue(bp, i) {
-		DP(NETIF_MSG_IFDOWN, "about to rlease fp #%d->%d irq  "
+		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
 		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
 		   bnx2x_fp(bp, i, state));
 
@@ -6010,7 +6009,6 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 {
 
-
 	int i, rc;
 
 	DP(NETIF_MSG_IFUP, "about to request sp irq\n");
@@ -6109,8 +6107,8 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	/* can take a while if any port is running */
 	int timeout = 500;
 
-	/* DP("waiting for state to become %d on IDX [%d]\n",
-	state, sb_idx); */
+	DP(NETIF_MSG_IFUP, "%s for state to become %x on IDX [%d]\n",
+	   poll ? "polling" : "waiting", state, idx);
 
 	might_sleep();
 
@@ -6136,7 +6134,6 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 
 	}
 
-
 	/* timeout! */
 	BNX2X_ERR("timeout waiting for ramrod %d on %d\n", state, idx);
 	return -EBUSY;
@@ -6146,7 +6143,7 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 static int bnx2x_setup_leading(struct bnx2x *bp)
 {
 
-	/* reset IGU staae */
+	/* reset IGU state */
 	bnx2x_ack_sb(bp, DEF_SB_ID, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
 	/* SETUP ramrod */
@@ -6196,18 +6193,15 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		rc = FW_MSG_CODE_DRV_LOAD_COMMON;
 	}
 
-	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
-
 	/* if we can't use msix we only need one fp,
 	 * so try to enable msix with the requested number of fp's
 	 * and fallback to inta with one fp
 	 */
 	if (req_irq) {
-
 		if (use_inta) {
 			bp->num_queues = 1;
 		} else {
-			if (use_multi > 1 && use_multi <= 16)
+			if ((use_multi > 1) && (use_multi <= 16))
 				/* user requested number */
 				bp->num_queues = use_multi;
 			else if (use_multi == 1)
@@ -6216,15 +6210,17 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 				bp->num_queues = 1;
 
 			if (bnx2x_enable_msix(bp)) {
-				/* faild to enable msix */
+				/* failed to enable msix */
 				bp->num_queues = 1;
 				if (use_multi)
-					BNX2X_ERR("Muti requested but failed"
+					BNX2X_ERR("Multi requested but failed"
 						  " to enable MSI-X\n");
 			}
 		}
 	}
 
+	DP(NETIF_MSG_IFUP, "set number of queues to %d\n", bp->num_queues);
+
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
@@ -6257,12 +6253,6 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	atomic_set(&bp->intr_sem, 0);
 
-	/* Reenable SP tasklet */
-	/*if (bp->sp_task_en) { 	       */
-	/*        tasklet_enable(&bp->sp_task);*/
-	/*} else {      		       */
-	/*        bp->sp_task_en = 1;          */
-	/*}     			       */
 
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp);
@@ -6401,14 +6391,14 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 
 	int rc;
 
-	/* halt the connnection */
+	/* halt the connection */
 	bp->fp[index].state = BNX2X_FP_STATE_HALTING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, index, 0, 0, 0);
 
 
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, index,
 				       &(bp->fp[index].state), 1);
-	if (rc) /* timout */
+	if (rc) /* timeout */
 		return rc;
 
 	/* delete cfc entry */
@@ -6423,7 +6413,7 @@ static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 static void bnx2x_stop_leading(struct bnx2x *bp)
 {
 
-	/* if the other port is hadling traffic,
+	/* if the other port is handling traffic,
 	   this can take a lot of time */
 	int timeout = 500;
 
@@ -6462,16 +6452,10 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
-	/* Calling flush_scheduled_work() may deadlock because
-	 * linkwatch_event() may be on the workqueue and it will try to get
-	 * the rtnl_lock which we are holding.
-	 */
-
-	while (bp->in_reset_task)
-		msleep(1);
+	cancel_work_sync(&bp->reset_task);
 
 	/* Delete the timer: do it before disabling interrupts, as it
-	   may be stil STAT_QUERY ramrod pending after stopping the timer */
+	   may be still STAT_QUERY ramrod pending after stopping the timer */
 	del_timer_sync(&bp->timer);
 
 	/* Wait until stat ramrod returns and all SP tasks complete */
@@ -6581,10 +6565,10 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 
 			bp->phy_flags |= PHY_SGMII_FLAG;
 
-			bp->supported |= (/* SUPPORTED_10baseT_Half |
-					     SUPPORTED_10baseT_Full |
-					     SUPPORTED_100baseT_Half |
-					     SUPPORTED_100baseT_Full |*/
+			bp->supported |= (SUPPORTED_10baseT_Half |
+					  SUPPORTED_10baseT_Full |
+					  SUPPORTED_100baseT_Half |
+					  SUPPORTED_100baseT_Full |
 					  SUPPORTED_1000baseT_Full |
 					  SUPPORTED_TP | SUPPORTED_FIBRE |
 					  SUPPORTED_Autoneg |
@@ -6734,8 +6718,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) {
+		if (bp->supported & SUPPORTED_10baseT_Full) {
 			bp->req_line_speed = SPEED_10;
 			bp->advertising = (ADVERTISED_10baseT_Full |
 					   ADVERTISED_TP);
@@ -6749,8 +6732,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF) {
+		if (bp->supported & SUPPORTED_10baseT_Half) {
 			bp->req_line_speed = SPEED_10;
 			bp->req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_10baseT_Half |
@@ -6765,8 +6747,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL) {
+		if (bp->supported & SUPPORTED_100baseT_Full) {
 			bp->req_line_speed = SPEED_100;
 			bp->advertising = (ADVERTISED_100baseT_Full |
 					   ADVERTISED_TP);
@@ -6780,8 +6761,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF) {
+		if (bp->supported & SUPPORTED_100baseT_Half) {
 			bp->req_line_speed = SPEED_100;
 			bp->req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_100baseT_Half |
@@ -6796,8 +6776,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_1G:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G) {
+		if (bp->supported & SUPPORTED_1000baseT_Full) {
 			bp->req_line_speed = SPEED_1000;
 			bp->advertising = (ADVERTISED_1000baseT_Full |
 					   ADVERTISED_TP);
@@ -6811,8 +6790,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_2_5G:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) {
+		if (bp->supported & SUPPORTED_2500baseT_Full) {
 			bp->req_line_speed = SPEED_2500;
 			bp->advertising = (ADVERTISED_2500baseT_Full |
 					   ADVERTISED_TP);
@@ -6828,15 +6806,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_CX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
-		if (!(bp->phy_flags & PHY_XGXS_FLAG)) {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  phy_flags 0x%x\n",
-				  bp->link_config, bp->phy_flags);
-			return;
-		}
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
+		if (bp->supported & SUPPORTED_10000baseT_Full) {
 			bp->req_line_speed = SPEED_10000;
 			bp->advertising = (ADVERTISED_10000baseT_Full |
 					   ADVERTISED_FIBRE);
@@ -6932,7 +6902,7 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	val = SHMEM_RD(bp, validity_map[port]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+	    != (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		BNX2X_ERR("MCP validity signature bad\n");
 
 	bp->fw_seq = (SHMEM_RD(bp, drv_fw_mb[port].drv_mb_header) &
@@ -7014,14 +6984,8 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	return;
 
 set_mac: /* only supposed to happen on emulation/FPGA */
-	BNX2X_ERR("warning constant MAC workaround active\n");
-	bp->dev->dev_addr[0] = 0;
-	bp->dev->dev_addr[1] = 0x50;
-	bp->dev->dev_addr[2] = 0xc2;
-	bp->dev->dev_addr[3] = 0x2c;
-	bp->dev->dev_addr[4] = 0x71;
-	bp->dev->dev_addr[5] = port ? 0x0d : 0x0e;
-
+	BNX2X_ERR("warning rendom MAC workaround active\n");
+	random_ether_addr(bp->dev->dev_addr);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, 6);
 
 }
@@ -7047,20 +7011,18 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = bp->req_duplex;
 	}
 
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
+	if (bp->phy_flags & PHY_XGXS_FLAG)
 		cmd->port = PORT_FIBRE;
-	} else {
+	else
 		cmd->port = PORT_TP;
-	}
 
 	cmd->phy_address = bp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
 
-	if (bp->req_autoneg & AUTONEG_SPEED) {
+	if (bp->req_autoneg & AUTONEG_SPEED)
 		cmd->autoneg = AUTONEG_ENABLE;
-	} else {
+	else
 		cmd->autoneg = AUTONEG_DISABLE;
-	}
 
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
@@ -7452,13 +7414,13 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(NETIF_MSG_NVM,
-		   "Invalid paramter: offset 0x%x  buf_size 0x%x\n",
+		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -7568,7 +7530,7 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 	u32 val;
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -7621,13 +7583,13 @@ static int bnx2x_nvram_write(struct bnx2x *bp, u32 offset, u8 *data_buf,
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(NETIF_MSG_NVM,
-		   "Invalid paramter: offset 0x%x  buf_size 0x%x\n",
+		   "Invalid parameter: offset 0x%x  buf_size 0x%x\n",
 		   offset, buf_size);
 		return -EINVAL;
 	}
 
 	if (offset + buf_size > bp->flash_size) {
-		DP(NETIF_MSG_NVM, "Invalid paramter: offset (0x%x) +"
+		DP(NETIF_MSG_NVM, "Invalid parameter: offset (0x%x) +"
 				  " buf_size (0x%x) > flash_size (0x%x)\n",
 		   offset, buf_size, bp->flash_size);
 		return -EINVAL;
@@ -8314,7 +8276,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       ETH_TX_BD_ETH_ADDR_TYPE_SHIFT);
 	tx_bd->general_data |= 1; /* header nbd */
 
-	/* remeber the first bd of the packet */
+	/* remember the first bd of the packet */
 	tx_buf->first_bd = bd_prod;
 
 	DP(NETIF_MSG_TX_QUEUED,
@@ -8427,7 +8389,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_bd->vlan = cpu_to_le16(pkt_prod);
 			/* this marks the bd
 			 * as one that has no individual mapping
-			 * the FW ignors this flag in a bd not maked start
+			 * the FW ignores this flag in a bd not marked start
 			 */
 			tx_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
 			DP(NETIF_MSG_TX_QUEUED,
@@ -8525,11 +8487,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *bnx2x_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 /* Called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
 {
@@ -8584,7 +8541,7 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIPHY:
 		data->phy_id = bp->phy_addr;
 
-		/* fallthru */
+		/* fallthrough */
 	case SIOCGMIIREG: {
 		u32 mii_regval;
 
@@ -8633,7 +8590,7 @@ static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	/* This does not race with packet allocation
-	 * because the actuall alloc size is
+	 * because the actual alloc size is
 	 * only updated as part of load
 	 */
 	dev->mtu = new_mtu;
@@ -8695,14 +8652,10 @@ static void bnx2x_reset_task(struct work_struct *work)
 	if (!netif_running(bp->dev))
 		return;
 
-	bp->in_reset_task = 1;
-
 	bnx2x_netif_stop(bp);
 
 	bnx2x_nic_unload(bp, 0);
 	bnx2x_nic_load(bp, 0);
-
-	bp->in_reset_task = 0;
 }
 
 static int __devinit bnx2x_init_board(struct pci_dev *pdev,
@@ -8783,8 +8736,6 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 
 	spin_lock_init(&bp->phy_lock);
 
-	bp->in_reset_task = 0;
-
 	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
 	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
 
@@ -8813,7 +8764,7 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 	bnx2x_get_hwinfo(bp);
 
 	if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		printk(KERN_ERR PFX "FPGA detacted. MCP disabled,"
+		printk(KERN_ERR PFX "FPGA detected. MCP disabled,"
 		       " will only init first device\n");
 		onefunc = 1;
 		nomcp = 1;
@@ -8882,14 +8833,32 @@ err_out:
 	return rc;
 }
 
+static int __devinit bnx2x_get_pcie_width(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
+
+	val = (val & PCICFG_LINK_WIDTH) >> PCICFG_LINK_WIDTH_SHIFT;
+	return val;
+}
+
+/* return value of 1=2.5GHz 2=5GHz */
+static int __devinit bnx2x_get_pcie_speed(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
+
+	val = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
+	return val;
+}
+
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	static int version_printed;
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
-	int rc, i;
+	int rc;
 	int port = PCI_FUNC(pdev->devfn);
+	DECLARE_MAC_BUF(mac);
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -8906,6 +8875,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	if (port && onefunc) {
 		printk(KERN_ERR PFX "second function disabled. exiting\n");
+		free_netdev(dev);
 		return 0;
 	}
 
@@ -8918,7 +8888,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	dev->hard_start_xmit = bnx2x_start_xmit;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->get_stats = bnx2x_get_stats;
 	dev->ethtool_ops = &bnx2x_ethtool_ops;
 	dev->open = bnx2x_open;
 	dev->stop = bnx2x_close;
@@ -8944,7 +8913,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	rc = register_netdev(dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Cannot register net device\n");
+		dev_err(&pdev->dev, "Cannot register net device\n");
 		if (bp->regview)
 			iounmap(bp->regview);
 		if (bp->doorbells)
@@ -8958,33 +8927,22 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 
-	bp->name = board_info[ent->driver_data].name;
-	printk(KERN_INFO "%s: %s (%c%d) PCI%s %s %dMHz "
-	       "found at mem %lx, IRQ %d, ",
-	       dev->name, bp->name,
+	bp->name = board_info[ent->driver_data];
+	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
+	       " IRQ %d, ", dev->name, bp->name,
 	       ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 	       ((CHIP_ID(bp) & 0x0ff0) >> 4),
-	       ((bp->flags & PCIX_FLAG) ? "-X" : ""),
-	       ((bp->flags & PCI_32BIT_FLAG) ? "32-bit" : "64-bit"),
-	       bp->bus_speed_mhz,
-	       dev->base_addr,
-	       bp->pdev->irq);
-
-	printk("node addr ");
-	for (i = 0; i < 6; i++)
-		printk("%2.2x", dev->dev_addr[i]);
-	printk("\n");
-
+	       bnx2x_get_pcie_width(bp),
+	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
+	       dev->base_addr, bp->pdev->irq);
+	printk(KERN_CONT "node addr %s\n", print_mac(mac, dev->dev_addr));
 	return 0;
 }
-
 static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2x *bp = netdev_priv(dev);
 
-	flush_scheduled_work();
-	/*tasklet_kill(&bp->sp_task);*/
 	unregister_netdev(dev);
 
 	if (bp->regview)
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4f7ae6f..92b3187 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -717,7 +717,7 @@ struct bnx2x {
 	dma_addr_t      	qm_mapping;
 #endif
 
-	char    		*name;
+	const char    		*name;
 	u16     		bus_speed_mhz;
 	u8      		wol;
 	u8      		pad;
@@ -867,6 +867,11 @@ struct bnx2x {
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
+/* PCIE link and speed */
+#define PCICFG_LINK_WIDTH		0x1f00000
+#define PCICFG_LINK_WIDTH_SHIFT		20
+#define PCICFG_LINK_SPEED		0xf0000
+#define PCICFG_LINK_SPEED_SHIFT		16
 
 /* stuff added to make the code fit 80Col */
 
-- 
1.5.3.2




