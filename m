From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/12] bnx2x: make local function static and remove dead code
Date: Thu, 21 Oct 2010 10:50:56 -0700
Message-ID: <20101021175149.043365875@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Vladislav Zolotarov <vladz@broad
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36322 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756438Ab0JUSBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:07 -0400
Content-Disposition: inline; filename=bnx2-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make many functions that are only used in one file static.
Remove dead code for override_led_value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bnx2x/bnx2x.h          |    5 -
 drivers/net/bnx2x/bnx2x_cmn.c      |    3 
 drivers/net/bnx2x/bnx2x_cmn.h      |   55 --------------
 drivers/net/bnx2x/bnx2x_init_ops.h |   34 +++++----
 drivers/net/bnx2x/bnx2x_link.c     |  137 ++-----------------------------------
 drivers/net/bnx2x/bnx2x_link.h     |   15 ----
 drivers/net/bnx2x/bnx2x_main.c     |   55 ++++++++------
 7 files changed, 62 insertions(+), 242 deletions(-)

--- a/drivers/net/bnx2x/bnx2x_cmn.c	2010-10-21 09:07:02.398927994 -0700
+++ b/drivers/net/bnx2x/bnx2x_cmn.c	2010-10-21 09:07:40.146592717 -0700
@@ -25,6 +25,7 @@
 
 #include "bnx2x_init.h"
 
+static int bnx2x_setup_irqs(struct bnx2x *bp);
 
 /* free skb in the packet ring at pos idx
  * return idx of last bd freed
@@ -2187,7 +2188,7 @@ int bnx2x_change_mac_addr(struct net_dev
 }
 
 
-int bnx2x_setup_irqs(struct bnx2x *bp)
+static int bnx2x_setup_irqs(struct bnx2x *bp)
 {
 	int rc = 0;
 	if (bp->flags & USING_MSIX_FLAG) {
--- a/drivers/net/bnx2x/bnx2x_cmn.h	2010-10-21 09:07:02.422930326 -0700
+++ b/drivers/net/bnx2x/bnx2x_cmn.h	2010-10-21 09:29:12.413291701 -0700
@@ -117,13 +117,6 @@ void bnx2x_setup_cnic_irq_info(struct bn
 void bnx2x_int_enable(struct bnx2x *bp);
 
 /**
- * Disable HW interrupts.
- *
- * @param bp
- */
-void bnx2x_int_disable(struct bnx2x *bp);
-
-/**
  * Disable interrupts. This function ensures that there are no
  * ISRs or SP DPCs (sp_task) are running after it returns.
  *
@@ -192,17 +185,6 @@ int bnx2x_setup_client(struct bnx2x *bp,
 		       int is_leading);
 
 /**
- * Bring down an eth client.
- *
- * @param bp
- * @param p
- *
- * @return int
- */
-int bnx2x_stop_fw_client(struct bnx2x *bp,
-			 struct bnx2x_client_ramrod_params *p);
-
-/**
  * Set number of queues according to mode
  *
  * @param bp
@@ -250,34 +232,6 @@ int bnx2x_release_hw_lock(struct bnx2x *
  */
 void bnx2x_set_eth_mac(struct bnx2x *bp, int set);
 
-#ifdef BCM_CNIC
-/**
- * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
- * MAC(s). The function will wait until the ramrod completion
- * returns.
- *
- * @param bp driver handle
- * @param set set or clear the CAM entry
- *
- * @return 0 if cussess, -ENODEV if ramrod doesn't return.
- */
-int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set);
-#endif
-
-/**
- * Initialize status block in FW and HW
- *
- * @param bp driver handle
- * @param dma_addr_t mapping
- * @param int sb_id
- * @param int vfid
- * @param u8 vf_valid
- * @param int fw_sb_id
- * @param int igu_sb_id
- */
-void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
-			  u8 vf_valid, int fw_sb_id, int igu_sb_id);
-
 /**
  * Set MAC filtering configurations.
  *
@@ -326,7 +280,6 @@ void bnx2x_sp_event(struct bnx2x_fastpat
  * @return int
  */
 int bnx2x_func_start(struct bnx2x *bp);
-int bnx2x_func_stop(struct bnx2x *bp);
 
 /**
  * Prepare ILT configurations according to current driver
@@ -396,14 +349,6 @@ int bnx2x_enable_msix(struct bnx2x *bp);
 int bnx2x_enable_msi(struct bnx2x *bp);
 
 /**
- * Request IRQ vectors from OS.
- *
- * @param bp
- *
- * @return int
- */
-int bnx2x_setup_irqs(struct bnx2x *bp);
-/**
  * NAPI callback
  *
  * @param napi
--- a/drivers/net/bnx2x/bnx2x_link.c	2010-10-21 09:08:06.953189571 -0700
+++ b/drivers/net/bnx2x/bnx2x_link.c	2010-10-21 09:17:53.595192308 -0700
@@ -181,6 +181,12 @@
 		(_bank + (_addr & 0xf)), \
 		_val)
 
+static u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
+			  u8 devad, u16 reg, u16 *ret_val);
+
+static u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
+			   u8 devad, u16 reg, u16 val);
+
 static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
 {
 	u32 val = REG_RD(bp, reg);
@@ -594,7 +600,7 @@ static u8 bnx2x_bmac2_enable(struct link
 	return 0;
 }
 
-u8 bnx2x_bmac_enable(struct link_params *params,
+static u8 bnx2x_bmac_enable(struct link_params *params,
 			    struct link_vars *vars,
 			    u8 is_lb)
 {
@@ -2537,122 +2543,6 @@ static void bnx2x_set_xgxs_loopback(stru
 	}
 }
 
-/*
- *------------------------------------------------------------------------
- * bnx2x_override_led_value -
- *
- * Override the led value of the requested led
- *
- *------------------------------------------------------------------------
- */
-u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
-			  u32 led_idx, u32 value)
-{
-	u32 reg_val;
-
-	/* If port 0 then use EMAC0, else use EMAC1*/
-	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	DP(NETIF_MSG_LINK,
-		 "bnx2x_override_led_value() port %x led_idx %d value %d\n",
-		 port, led_idx, value);
-
-	switch (led_idx) {
-	case 0: /* 10MB led */
-		/* Read the current value of the LED register in
-		the EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/* If value is 1, set the 10M_OVERRIDE bit,
-		otherwise reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_10MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_10MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 1: /*100MB led    */
-		/*Read the current value of the LED register in
-		the EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/*  Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/*  If value is 1, set the 100M_OVERRIDE bit,
-		otherwise reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_100MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_100MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 2: /* 1000MB led */
-		/* Read the current value of the LED register in the
-		EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/* If value is 1, set the 1000M_OVERRIDE bit, otherwise
-		reset it. */
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_1000MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_1000MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 3: /* 2500MB led */
-		/*  Read the current value of the LED register in the
-		EMAC block*/
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/*  If value is 1, set the 2500M_OVERRIDE bit, otherwise
-		reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_2500MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_2500MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 4: /*10G led */
-		if (port == 0) {
-			REG_WR(bp, NIG_REG_LED_10G_P0,
-				    value);
-		} else {
-			REG_WR(bp, NIG_REG_LED_10G_P1,
-				    value);
-		}
-		break;
-	case 5: /* TRAFFIC led */
-		/* Find if the traffic control is via BMAC or EMAC */
-		if (port == 0)
-			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC0_EN);
-		else
-			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC1_EN);
-
-		/*  Override the traffic led in the EMAC:*/
-		if (reg_val == 1) {
-			/* Read the current value of the LED register in
-			the EMAC block */
-			reg_val = REG_RD(bp, emac_base +
-					     EMAC_REG_EMAC_LED);
-			/* Set the TRAFFIC_OVERRIDE bit to 1 */
-			reg_val |= EMAC_LED_OVERRIDE;
-			/* If value is 1, set the TRAFFIC bit, otherwise
-			reset it.*/
-			reg_val = (value == 1) ? (reg_val | EMAC_LED_TRAFFIC) :
-				(reg_val & ~EMAC_LED_TRAFFIC);
-			REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		} else { /* Override the traffic led in the BMAC: */
-			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
-				   + port*4, 1);
-			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 + port*4,
-				    value);
-		}
-		break;
-	default:
-		DP(NETIF_MSG_LINK,
-			 "bnx2x_override_led_value() unknown led index %d "
-			 "(should be 0-5)\n", led_idx);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-
 u8 bnx2x_set_led(struct link_params *params,
 		 struct link_vars *vars, u8 mode, u32 speed)
 {
@@ -4099,9 +3989,9 @@ static u8 bnx2x_8727_read_sfp_module_eep
 	return -EINVAL;
 }
 
-u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
-				struct link_params *params, u16 addr,
-				     u8 byte_cnt, u8 *o_buf)
+static u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+				       struct link_params *params, u16 addr,
+				       u8 byte_cnt, u8 *o_buf)
 {
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
 		return bnx2x_8726_read_sfp_module_eeprom(phy, params, addr,
@@ -6819,13 +6709,6 @@ u8 bnx2x_phy_probe(struct link_params *p
 	return 0;
 }
 
-u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx)
-{
-	if (phy_idx < params->num_phys)
-		return params->phy[phy_idx].supported;
-	return 0;
-}
-
 static void set_phy_vars(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
--- a/drivers/net/bnx2x/bnx2x_link.h	2010-10-21 09:08:51.333479227 -0700
+++ b/drivers/net/bnx2x/bnx2x_link.h	2010-10-21 09:11:15.483340148 -0700
@@ -279,12 +279,6 @@ u8 bnx2x_phy_read(struct link_params *pa
 
 u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 		   u8 devad, u16 reg, u16 val);
-
-u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
-		   u8 devad, u16 reg, u16 *ret_val);
-
-u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
-		    u8 devad, u16 reg, u16 val);
 /* Reads the link_status from the shmem,
    and update the link vars accordingly */
 void bnx2x_link_status_update(struct link_params *input,
@@ -304,8 +298,6 @@ u8 bnx2x_set_led(struct link_params *par
 #define LED_MODE_OPER			2
 #define LED_MODE_FRONT_PANEL_OFF	3
 
-u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port, u32 led_idx, u32 value);
-
 /* bnx2x_handle_module_detect_int should be called upon module detection
    interrupt */
 void bnx2x_handle_module_detect_int(struct link_params *params);
@@ -325,19 +317,12 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x
 /* Reset the external of SFX7101 */
 void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy);
 
-u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
-				struct link_params *params, u16 addr,
-			      u8 byte_cnt, u8 *o_buf);
-
 void bnx2x_hw_reset_phy(struct link_params *params);
 
 /* Checks if HW lock is required for this phy/board type */
 u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base,
 			  u32 shmem2_base);
 
-/* Returns the aggregative supported attributes of the phys on board */
-u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx);
-
 /* Check swap bit and adjust PHY order */
 u32 bnx2x_phy_selection(struct link_params *params);
 
--- a/drivers/net/bnx2x/bnx2x_main.c	2010-10-21 09:12:03.547940839 -0700
+++ b/drivers/net/bnx2x/bnx2x_main.c	2010-10-21 09:28:15.491832825 -0700
@@ -403,7 +403,7 @@ static inline void storm_memset_hc_disab
 /* used only at init
  * locking is done by mcp
  */
-void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val)
+static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val)
 {
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS, addr);
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_DATA, val);
@@ -429,7 +429,8 @@ static u32 bnx2x_reg_rd_ind(struct bnx2x
 #define DMAE_DP_DST_PCI		"pci dst_addr [%x:%08x]"
 #define DMAE_DP_DST_NONE	"dst_addr [none]"
 
-void bnx2x_dp_dmae(struct bnx2x *bp, struct dmae_command *dmae, int msglvl)
+static void bnx2x_dp_dmae(struct bnx2x *bp, struct dmae_command *dmae,
+			  int msglvl)
 {
 	u32 src_type = dmae->opcode & DMAE_COMMAND_SRC;
 
@@ -551,8 +552,9 @@ u32 bnx2x_dmae_opcode(struct bnx2x *bp,
 	return opcode;
 }
 
-void bnx2x_prep_dmae_with_comp(struct bnx2x *bp, struct dmae_command *dmae,
-			       u8 src_type, u8 dst_type)
+static void bnx2x_prep_dmae_with_comp(struct bnx2x *bp,
+				      struct dmae_command *dmae,
+				      u8 src_type, u8 dst_type)
 {
 	memset(dmae, 0, sizeof(struct dmae_command));
 
@@ -567,7 +569,8 @@ void bnx2x_prep_dmae_with_comp(struct bn
 }
 
 /* issue a dmae command over the init-channel and wailt for completion */
-int bnx2x_issue_dmae_with_comp(struct bnx2x *bp, struct dmae_command *dmae)
+static int bnx2x_issue_dmae_with_comp(struct bnx2x *bp,
+				      struct dmae_command *dmae)
 {
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
 	int cnt = CHIP_REV_IS_SLOW(bp) ? (400000) : 40;
@@ -674,8 +677,8 @@ void bnx2x_read_dmae(struct bnx2x *bp, u
 	bnx2x_issue_dmae_with_comp(bp, &dmae);
 }
 
-void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
-			       u32 addr, u32 len)
+static void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
+				      u32 addr, u32 len)
 {
 	int dmae_wr_max = DMAE_LEN32_WR_MAX(bp);
 	int offset = 0;
@@ -1267,7 +1270,7 @@ static void bnx2x_igu_int_disable(struct
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }
 
-void bnx2x_int_disable(struct bnx2x *bp)
+static void bnx2x_int_disable(struct bnx2x *bp)
 {
 	if (bp->common.int_block == INT_BLOCK_HC)
 		bnx2x_hc_int_disable(bp);
@@ -2236,7 +2239,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u
 }
 
 /* must be called under rtnl_lock */
-void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
+static void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 {
 	u32 mask = (1 << cl_id);
 
@@ -2303,7 +2306,7 @@ void bnx2x_rxq_set_mac_filters(struct bn
 		bp->mac_filters.unmatched_unicast & ~mask;
 }
 
-void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p)
+static void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p)
 {
 	struct tstorm_eth_function_common_config tcfg = {0};
 	u16 rss_flgs;
@@ -2460,7 +2463,7 @@ static void bnx2x_pf_tx_cl_prep(struct b
 	txq_init->hc_rate = bp->tx_ticks ? (1000000 / bp->tx_ticks) : 0;
 }
 
-void bnx2x_pf_init(struct bnx2x *bp)
+static void bnx2x_pf_init(struct bnx2x *bp)
 {
 	struct bnx2x_func_init_params func_init = {0};
 	struct bnx2x_rss_params rss = {0};
@@ -3928,7 +3931,7 @@ void bnx2x_setup_ndsb_state_machine(stru
 	hc_sm->time_to_expire = 0xFFFFFFFF;
 }
 
-void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
+static void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 			  u8 vf_valid, int fw_sb_id, int igu_sb_id)
 {
 	int igu_seg_id;
@@ -6021,6 +6024,9 @@ alloc_mem_err:
 /*
  * Init service functions
  */
+static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
+			     int *state_p, int flags);
+
 int bnx2x_func_start(struct bnx2x *bp)
 {
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_START, 0, 0, 0, 1);
@@ -6030,7 +6036,7 @@ int bnx2x_func_start(struct bnx2x *bp)
 				 WAIT_RAMROD_COMMON);
 }
 
-int bnx2x_func_stop(struct bnx2x *bp)
+static int bnx2x_func_stop(struct bnx2x *bp)
 {
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_STOP, 0, 0, 0, 1);
 
@@ -6103,8 +6109,8 @@ static void bnx2x_set_mac_addr_gen(struc
 	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, ramrod_flags);
 }
 
-int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
-		      int *state_p, int flags)
+static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
+			     int *state_p, int flags)
 {
 	/* can take a while if any port is running */
 	int cnt = 5000;
@@ -6154,7 +6160,7 @@ int bnx2x_wait_ramrod(struct bnx2x *bp,
 	return -EBUSY;
 }
 
-u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
+static u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
 {
 	if (CHIP_IS_E1H(bp))
 		return E1H_FUNC_MAX * rel_offset + BP_FUNC(bp);
@@ -6273,7 +6279,7 @@ static void bnx2x_invlidate_e1_mc_list(s
  *
  * @return 0 if cussess, -ENODEV if ramrod doesn't return.
  */
-int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
+static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 {
 	u8 cam_offset = (CHIP_IS_E1(bp) ? ((BP_PORT(bp) ? 32 : 0) + 2) :
 			 bnx2x_e1h_cam_offset(bp, CAM_ISCSI_ETH_LINE));
@@ -6383,11 +6389,11 @@ static inline void bnx2x_set_ctx_validat
 				       ETH_CONNECTION_TYPE);
 }
 
-int bnx2x_setup_fw_client(struct bnx2x *bp,
-			  struct bnx2x_client_init_params *params,
-			  u8 activate,
-			  struct client_init_ramrod_data *data,
-			  dma_addr_t data_mapping)
+static int bnx2x_setup_fw_client(struct bnx2x *bp,
+				 struct bnx2x_client_init_params *params,
+				 u8 activate,
+				 struct client_init_ramrod_data *data,
+				 dma_addr_t data_mapping)
 {
 	u16 hc_usec;
 	int ramrod = RAMROD_CMD_ID_ETH_CLIENT_SETUP;
@@ -6633,7 +6639,8 @@ int bnx2x_setup_client(struct bnx2x *bp,
 	return rc;
 }
 
-int bnx2x_stop_fw_client(struct bnx2x *bp, struct bnx2x_client_ramrod_params *p)
+static int bnx2x_stop_fw_client(struct bnx2x *bp,
+				struct bnx2x_client_ramrod_params *p)
 {
 	int rc;
 
@@ -7440,7 +7447,7 @@ reset_task_exit:
  * Init service functions
  */
 
-u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
+static u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
 {
 	u32 base = PXP2_REG_PGL_PRETEND_FUNC_F0;
 	u32 stride = PXP2_REG_PGL_PRETEND_FUNC_F1 - base;
--- a/drivers/net/bnx2x/bnx2x.h	2010-10-21 09:17:27.792614143 -0700
+++ b/drivers/net/bnx2x/bnx2x.h	2010-10-21 09:18:25.394360028 -0700
@@ -1288,15 +1288,11 @@ struct bnx2x_func_init_params {
 
 #define WAIT_RAMROD_POLL	0x01
 #define WAIT_RAMROD_COMMON	0x02
-int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
-			     int *state_p, int flags);
 
 /* dmae */
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
-void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
-			       u32 addr, u32 len);
 void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx);
 u32 bnx2x_dmae_opcode_add_comp(u32 opcode, u8 comp_type);
 u32 bnx2x_dmae_opcode_clr_src_reset(u32 opcode);
@@ -1307,7 +1303,6 @@ int bnx2x_get_gpio(struct bnx2x *bp, int
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param);
-void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
 
 void bnx2x_calc_fc_adv(struct bnx2x *bp);
 int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
--- a/drivers/net/bnx2x/bnx2x_init_ops.h	2010-10-21 09:19:30.184783863 -0700
+++ b/drivers/net/bnx2x/bnx2x_init_ops.h	2010-10-21 09:32:58.333067774 -0700
@@ -16,7 +16,9 @@
 #define BNX2X_INIT_OPS_H
 
 static int bnx2x_gunzip(struct bnx2x *bp, const u8 *zbuf, int len);
-
+static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
+static void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
+				      u32 addr, u32 len);
 
 static void bnx2x_init_str_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 			      u32 len)
@@ -589,7 +591,7 @@ static int bnx2x_ilt_client_mem_op(struc
 	return rc;
 }
 
-int bnx2x_ilt_mem_op(struct bnx2x *bp, u8 memop)
+static int bnx2x_ilt_mem_op(struct bnx2x *bp, u8 memop)
 {
 	int rc = bnx2x_ilt_client_mem_op(bp, ILT_CLIENT_CDU, memop);
 	if (!rc)
@@ -635,7 +637,7 @@ static void bnx2x_ilt_line_init_op(struc
 	}
 }
 
-void bnx2x_ilt_boundry_init_op(struct bnx2x *bp,
+static void bnx2x_ilt_boundry_init_op(struct bnx2x *bp,
 				      struct ilt_client_info *ilt_cli,
 				      u32 ilt_start, u8 initop)
 {
@@ -688,8 +690,10 @@ void bnx2x_ilt_boundry_init_op(struct bn
 	}
 }
 
-void bnx2x_ilt_client_init_op_ilt(struct bnx2x *bp, struct bnx2x_ilt *ilt,
-				  struct ilt_client_info *ilt_cli, u8 initop)
+static void bnx2x_ilt_client_init_op_ilt(struct bnx2x *bp,
+					 struct bnx2x_ilt *ilt,
+					 struct ilt_client_info *ilt_cli,
+					 u8 initop)
 {
 	int i;
 
@@ -703,8 +707,8 @@ void bnx2x_ilt_client_init_op_ilt(struct
 	bnx2x_ilt_boundry_init_op(bp, ilt_cli, ilt->start_line, initop);
 }
 
-void bnx2x_ilt_client_init_op(struct bnx2x *bp,
-			      struct ilt_client_info *ilt_cli, u8 initop)
+static void bnx2x_ilt_client_init_op(struct bnx2x *bp,
+				     struct ilt_client_info *ilt_cli, u8 initop)
 {
 	struct bnx2x_ilt *ilt = BP_ILT(bp);
 
@@ -720,7 +724,7 @@ static void bnx2x_ilt_client_id_init_op(
 	bnx2x_ilt_client_init_op(bp, ilt_cli, initop);
 }
 
-void bnx2x_ilt_init_op(struct bnx2x *bp, u8 initop)
+static void bnx2x_ilt_init_op(struct bnx2x *bp, u8 initop)
 {
 	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_CDU, initop);
 	bnx2x_ilt_client_id_init_op(bp, ILT_CLIENT_QM, initop);
@@ -752,7 +756,7 @@ static void bnx2x_ilt_init_client_psz(st
  * called during init common stage, ilt clients should be initialized
  * prioir to calling this function
  */
-void bnx2x_ilt_init_page_size(struct bnx2x *bp, u8 initop)
+static void bnx2x_ilt_init_page_size(struct bnx2x *bp, u8 initop)
 {
 	bnx2x_ilt_init_client_psz(bp, ILT_CLIENT_CDU,
 				  PXP2_REG_RQ_CDU_P_SIZE, initop);
@@ -772,8 +776,8 @@ void bnx2x_ilt_init_page_size(struct bnx
 #define QM_INIT(cid_cnt)	(cid_cnt > QM_INIT_MIN_CID_COUNT)
 
 /* called during init port stage */
-void bnx2x_qm_init_cid_count(struct bnx2x *bp, int qm_cid_count,
-			     u8 initop)
+static void bnx2x_qm_init_cid_count(struct bnx2x *bp, int qm_cid_count,
+				    u8 initop)
 {
 	int port = BP_PORT(bp);
 
@@ -814,8 +818,8 @@ static void bnx2x_qm_set_ptr_table(struc
 }
 
 /* called during init common stage */
-void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
-			     u8 initop)
+static void bnx2x_qm_init_ptr_table(struct bnx2x *bp, int qm_cid_count,
+				    u8 initop)
 {
 	if (!QM_INIT(qm_cid_count))
 		return;
@@ -836,8 +840,8 @@ void bnx2x_qm_init_ptr_table(struct bnx2
 ****************************************************************************/
 
 /* called during init func stage */
-void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
-		       dma_addr_t t2_mapping, int src_cid_count)
+static void bnx2x_src_init_t2(struct bnx2x *bp, struct src_ent *t2,
+			      dma_addr_t t2_mapping, int src_cid_count)
 {
 	int i;
 	int port = BP_PORT(bp);


