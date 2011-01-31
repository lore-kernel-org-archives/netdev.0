From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 03/10] bnx2x: Set comments according to
 preferred Linux style
Date: Mon, 31 Jan 2011 16:21:55 +0200
Message-ID: <1296483715.17181.113.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab1AaOYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:24:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains cosmetic changes only of restyling comments according to Linux coding standard, and add comment for get_emac_base function.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |  651 ++++++++++++++++++++++------------------
 1 files changed, 364 insertions(+), 287 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 564301f..0d8b5b1 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -217,7 +217,7 @@ void bnx2x_ets_disabled(struct link_params *params)
 
 	DP(NETIF_MSG_LINK, "ETS disabled configuration\n");
 
-	/**
+	/*
 	 * mapping between entry  priority to client number (0,1,2 -debug and
 	 * management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
 	 * 3bits client num.
@@ -226,7 +226,7 @@ void bnx2x_ets_disabled(struct link_params *params)
 	 */
 
 	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, 0x4688);
-	/**
+	/*
 	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries, 3 -
 	 * COS0 entry, 4 - COS1 entry.
@@ -238,12 +238,12 @@ void bnx2x_ets_disabled(struct link_params *params)
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x7);
 	/* defines which entries (clients) are subjected to WFQ arbitration */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0);
-	/**
-	* For strict priority entries defines the number of consecutive
-	* slots for the highest priority.
-	*/
+	/*
+	 * For strict priority entries defines the number of consecutive
+	 * slots for the highest priority.
+	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
-	/**
+	/*
 	 * mapping between the CREDIT_WEIGHT registers and actual client
 	 * numbers
 	 */
@@ -256,7 +256,7 @@ void bnx2x_ets_disabled(struct link_params *params)
 	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, 0);
 	/* ETS mode disable */
 	REG_WR(bp, PBF_REG_ETS_ENABLED, 0);
-	/**
+	/*
 	 * If ETS mode is enabled (there is no strict priority) defines a WFQ
 	 * weight for COS0/COS1.
 	 */
@@ -274,19 +274,19 @@ void bnx2x_ets_bw_limit_common(const struct link_params *params)
 	/* ETS disabled configuration */
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "ETS enabled BW limit configuration\n");
-	/**
-	* defines which entries (clients) are subjected to WFQ arbitration
-	* COS0 0x8
-	* COS1 0x10
-	*/
+	/*
+	 * defines which entries (clients) are subjected to WFQ arbitration
+	 * COS0 0x8
+	 * COS1 0x10
+	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0x18);
-	/**
-	* mapping between the ARB_CREDIT_WEIGHT registers and actual
-	* client numbers (WEIGHT_0 does not actually have to represent
-	* client 0)
-	*    PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
-	*  cos1-001     cos0-000     dbg1-100     dbg0-011     MCP-010
-	*/
+	/*
+	 * mapping between the ARB_CREDIT_WEIGHT registers and actual
+	 * client numbers (WEIGHT_0 does not actually have to represent
+	 * client 0)
+	 *    PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
+	 *  cos1-001     cos0-000     dbg1-100     dbg0-011     MCP-010
+	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP, 0x111A);
 
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_0,
@@ -299,14 +299,14 @@ void bnx2x_ets_bw_limit_common(const struct link_params *params)
 
 	/* Defines the number of consecutive slots for the strict priority */
 	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0);
-	/**
-	* Bitmap of 5bits length. Each bit specifies whether the entry behaves
-	* as strict.  Bits 0,1,2 - debug and management entries, 3 - COS0
-	* entry, 4 - COS1 entry.
-	* COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
-	* bit4   bit3	  bit2     bit1	   bit0
-	* MCP and debug are strict
-	*/
+	/*
+	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	 * as strict.  Bits 0,1,2 - debug and management entries, 3 - COS0
+	 * entry, 4 - COS1 entry.
+	 * COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
+	 * bit4   bit3	  bit2     bit1	   bit0
+	 * MCP and debug are strict
+	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x7);
 
 	/* Upper bound that COS0_WEIGHT can reach in the WFQ arbiter.*/
@@ -355,7 +355,7 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	u32 val	= 0;
 
 	DP(NETIF_MSG_LINK, "ETS enabled strict configuration\n");
-	/**
+	/*
 	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries,
 	 * 3 - COS0 entry, 4 - COS1 entry.
@@ -364,7 +364,7 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	 * MCP and debug are strict
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x1F);
-	/**
+	/*
 	 * For strict priority entries defines the number of consecutive slots
 	 * for the highest priority.
 	 */
@@ -377,14 +377,14 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	/* Defines the number of consecutive slots for the strict priority */
 	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, strict_cos);
 
-	/**
-	* mapping between entry  priority to client number (0,1,2 -debug and
-	* management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
-	* 3bits client num.
-	*   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
-	* dbg0-010     dbg1-001     cos1-100     cos0-011     MCP-000
-	* dbg0-010     dbg1-001     cos0-011     cos1-100     MCP-000
-	*/
+	/*
+	 * mapping between entry  priority to client number (0,1,2 -debug and
+	 * management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
+	 * 3bits client num.
+	 *   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
+	 * dbg0-010     dbg1-001     cos1-100     cos0-011     MCP-000
+	 * dbg0-010     dbg1-001     cos0-011     cos1-100     MCP-000
+	 */
 	val = (0 == strict_cos) ? 0x2318 : 0x22E0;
 	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, val);
 
@@ -599,14 +599,14 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
 
-	/**
-	* Setting this bit causes MAC control frames (except for pause
-	* frames) to be passed on for processing. This setting has no
-	* affect on the operation of the pause frames. This bit effects
-	* all packets regardless of RX Parser packet sorting logic.
-	* Turn the PFC off to make sure we are in Xon state before
-	* enabling it.
-	*/
+	/*
+	 * Setting this bit causes MAC control frames (except for pause
+	 * frames) to be passed on for processing. This setting has no
+	 * affect on the operation of the pause frames. This bit effects
+	 * all packets regardless of RX Parser packet sorting logic.
+	 * Turn the PFC off to make sure we are in Xon state before
+	 * enabling it.
+	 */
 	EMAC_WR(bp, EMAC_REG_RX_PFC_MODE, 0);
 	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED) {
 		DP(NETIF_MSG_LINK, "PFC is enabled\n");
@@ -760,12 +760,12 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_PFC_CONTROL, wb_data, 2);
 
-	/**
-	* Set Time (based unit is 512 bit time) between automatic
-	* re-sending of PP packets amd enable automatic re-send of
-	* Per-Priroity Packet as long as pp_gen is asserted and
-	* pp_disable is low.
-	*/
+	/*
+	 * Set Time (based unit is 512 bit time) between automatic
+	 * re-sending of PP packets amd enable automatic re-send of
+	 * Per-Priroity Packet as long as pp_gen is asserted and
+	 * pp_disable is low.
+	 */
 	val = 0x8000;
 	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
 		val |= (1<<16); /* enable automatic re-send */
@@ -816,17 +816,25 @@ static void bnx2x_update_pfc_brb(struct link_params *params,
 			full_xon_th =
 			  PFC_BRB_MAC_FULL_XON_THRESHOLD_NON_PAUSEABLE;
 		}
-	/* The number of free blocks below which the pause signal to class 0
-	   of MAC #n is asserted. n=0,1 */
+	/*
+	 * The number of free blocks below which the pause signal to class 0
+	 * of MAC #n is asserted. n=0,1
+	 */
 	REG_WR(bp, BRB1_REG_PAUSE_0_XOFF_THRESHOLD_0 , pause_xoff_th);
-	/* The number of free blocks above which the pause signal to class 0
-	   of MAC #n is de-asserted. n=0,1 */
+	/*
+	 * The number of free blocks above which the pause signal to class 0
+	 * of MAC #n is de-asserted. n=0,1
+	 */
 	REG_WR(bp, BRB1_REG_PAUSE_0_XON_THRESHOLD_0 , pause_xon_th);
-	/* The number of free blocks below which the full signal to class 0
-	   of MAC #n is asserted. n=0,1 */
+	/*
+	 * The number of free blocks below which the full signal to class 0
+	 * of MAC #n is asserted. n=0,1
+	 */
 	REG_WR(bp, BRB1_REG_FULL_0_XOFF_THRESHOLD_0 , full_xoff_th);
-	/* The number of free blocks above which the full signal to class 0
-	   of MAC #n is de-asserted. n=0,1 */
+	/*
+	 * The number of free blocks above which the full signal to class 0
+	 * of MAC #n is de-asserted. n=0,1
+	 */
 	REG_WR(bp, BRB1_REG_FULL_0_XON_THRESHOLD_0 , full_xon_th);
 
 	if (set_pfc && pfc_params) {
@@ -850,25 +858,25 @@ static void bnx2x_update_pfc_brb(struct link_params *params,
 			full_xon_th =
 			  PFC_BRB_MAC_FULL_XON_THRESHOLD_NON_PAUSEABLE;
 		}
-		/**
+		/*
 		 * The number of free blocks below which the pause signal to
 		 * class 1 of MAC #n is asserted. n=0,1
-		 **/
+		 */
 		REG_WR(bp, BRB1_REG_PAUSE_1_XOFF_THRESHOLD_0, pause_xoff_th);
-		/**
+		/*
 		 * The number of free blocks above which the pause signal to
 		 * class 1 of MAC #n is de-asserted. n=0,1
-		 **/
+		 */
 		REG_WR(bp, BRB1_REG_PAUSE_1_XON_THRESHOLD_0, pause_xon_th);
-		/**
+		/*
 		 * The number of free blocks below which the full signal to
 		 * class 1 of MAC #n is asserted. n=0,1
-		 **/
+		 */
 		REG_WR(bp, BRB1_REG_FULL_1_XOFF_THRESHOLD_0, full_xoff_th);
-		/**
+		/*
 		 * The number of free blocks above which the full signal to
 		 * class 1 of MAC #n is de-asserted. n=0,1
-		 **/
+		 */
 		REG_WR(bp, BRB1_REG_FULL_1_XON_THRESHOLD_0, full_xon_th);
 	}
 }
@@ -887,7 +895,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 		FEATURE_CONFIG_PFC_ENABLED;
 	DP(NETIF_MSG_LINK, "updating pfc nig parameters\n");
 
-	/**
+	/*
 	 * When NIG_LLH0_XCM_MASK_REG_LLHX_XCM_MASK_BCN bit is set
 	 * MAC control frames (that are not pause packets)
 	 * will be forwarded to the XCM.
@@ -895,7 +903,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 	xcm_mask = REG_RD(bp,
 				port ? NIG_REG_LLH1_XCM_MASK :
 				NIG_REG_LLH0_XCM_MASK);
-	/**
+	/*
 	 * nig params will override non PFC params, since it's possible to
 	 * do transition from PFC to SAFC
 	 */
@@ -985,7 +993,7 @@ void bnx2x_update_pfc(struct link_params *params,
 		      struct link_vars *vars,
 		      struct bnx2x_nig_brb_pfc_port_params *pfc_params)
 {
-	/**
+	/*
 	 * The PFC and pause are orthogonal to one another, meaning when
 	 * PFC is enabled, the pause are disabled, and when PFC is
 	 * disabled, pause are set according to the pause result.
@@ -1331,6 +1339,23 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	return 0;
 }
 
+/*
+ * get_emac_base
+ *
+ * @param cb
+ * @param mdc_mdio_access
+ * @param port
+ *
+ * @return u32
+ *
+ * This function selects the MDC/MDIO access (through emac0 or
+ * emac1) depend on the mdc_mdio_access, port, port swapped. Each
+ * phy has a default access mode, which could also be overridden
+ * by nvram configuration. This parameter, whether this is the
+ * default phy configuration, or the nvram overrun
+ * configuration, is passed here as mdc_mdio_access and selects
+ * the emac_base for the CL45 read/writes operations
+ */
 static u32 bnx2x_get_emac_base(struct bnx2x *bp,
 			       u32 mdc_mdio_access, u8 port)
 {
@@ -1363,13 +1388,16 @@ static u32 bnx2x_get_emac_base(struct bnx2x *bp,
 
 }
 
+/******************************************************************/
+/*			CL45 access functions			  */
+/******************************************************************/
 u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 		    u8 devad, u16 reg, u16 val)
 {
 	u32 tmp, saved_mode;
 	u8 i, rc = 0;
-
-	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	/*
+	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
 
@@ -1436,8 +1464,8 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 	u32 val, saved_mode;
 	u16 i;
 	u8 rc = 0;
-
-	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	/*
+	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
 
@@ -1506,7 +1534,7 @@ u8 bnx2x_phy_read(struct link_params *params, u8 phy_addr,
 		  u8 devad, u16 reg, u16 *ret_val)
 {
 	u8 phy_index;
-	/**
+	/*
 	 * Probe for the phy according to the given phy_addr, and execute
 	 * the read request on it
 	 */
@@ -1524,7 +1552,7 @@ u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 		   u8 devad, u16 reg, u16 val)
 {
 	u8 phy_index;
-	/**
+	/*
 	 * Probe for the phy according to the given phy_addr, and execute
 	 * the write request on it
 	 */
@@ -1814,8 +1842,10 @@ static void bnx2x_set_swap_lanes(struct link_params *params,
 				 struct bnx2x_phy *phy)
 {
 	struct bnx2x *bp = params->bp;
-	/* Each two bits represents a lane number:
-	   No swap is 0123 => 0x1b no need to enable the swap */
+	/*
+	 *  Each two bits represents a lane number:
+	 *  No swap is 0123 => 0x1b no need to enable the swap
+	 */
 	u16 ser_lane, rx_lane_swap, tx_lane_swap;
 
 	ser_lane = ((params->lane_config &
@@ -2031,8 +2061,10 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 			  MDIO_REG_BANK_COMBO_IEEE0,
 			  MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
-	/* program speed
-	   - needed only if the speed is greater than 1G (2.5G or 10G) */
+	/*
+	 * program speed
+	 *  - needed only if the speed is greater than 1G (2.5G or 10G)
+	 */
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_SERDES_DIGITAL,
 			  MDIO_SERDES_DIGITAL_MISC1, &reg_val);
@@ -2089,8 +2121,10 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
-	/* resolve pause mode and advertisement
-	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
+	/*
+	 * Resolve pause mode and advertisement.
+	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec
+	 */
 
 	switch (phy->req_flow_ctrl) {
 	case BNX2X_FLOW_CTRL_AUTO:
@@ -2415,8 +2449,10 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 			     "ustat_val(0x8371) = 0x%x\n", ustat_val);
 		return;
 	}
-	/* Step 3: Check CL37 Message Pages received to indicate LP
-	supports only CL37 */
+	/*
+	 * Step 3: Check CL37 Message Pages received to indicate LP
+	 * supports only CL37
+	 */
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_REMOTE_PHY,
 			  MDIO_REMOTE_PHY_MISC_RX_STATUS,
@@ -2431,9 +2467,13 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 			 cl37_fsm_recieved);
 		return;
 	}
-	/* The combined cl37/cl73 fsm state information indicating that we are
-	connected to a device which does not support cl73, but does support
-	cl37 BAM. In this case we disable cl73 and restart cl37 auto-neg */
+	/*
+	 * The combined cl37/cl73 fsm state information indicating that
+	 * we are connected to a device which does not support cl73, but
+	 * does support cl37 BAM. In this case we disable cl73 and
+	 * restart cl37 auto-neg
+	 */
+
 	/* Disable CL73 */
 	CL22_WR_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_CL73_IEEEB0,
@@ -2833,9 +2873,7 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	u32 mask;
 	struct bnx2x *bp = params->bp;
 
-	/* setting the status to report on link up
-	   for either XGXS or SerDes */
-
+	/* Setting the status to report on link up for either XGXS or SerDes */
 	if (params->switch_cfg == SWITCH_CFG_10G) {
 		mask = (NIG_MASK_XGXS0_LINK10G |
 			NIG_MASK_XGXS0_LINK_STATUS);
@@ -2878,7 +2916,7 @@ static void bnx2x_rearm_latch_signal(struct bnx2x *bp, u8 port,
 {
 	u32 latch_status = 0;
 
-	/**
+	/*
 	 * Disable the MI INT ( external phy int ) by writing 1 to the
 	 * status register. Link down indication is high-active-signal,
 	 * so in this case we need to write the status to clear the XOR
@@ -2914,16 +2952,19 @@ static void bnx2x_link_int_ack(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 
-	/* first reset all status
-	 * we assume only one line will be change at a time */
+	/*
+	 * First reset all status we assume only one line will be
+	 * change at a time
+	 */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 		       (NIG_STATUS_XGXS0_LINK10G |
 			NIG_STATUS_XGXS0_LINK_STATUS |
 			NIG_STATUS_SERDES0_LINK_STATUS));
 	if (vars->phy_link_up) {
 		if (is_10g) {
-			/* Disable the 10G link interrupt
-			 * by writing 1 to the status register
+			/*
+			 * Disable the 10G link interrupt by writing 1 to the
+			 * status register
 			 */
 			DP(NETIF_MSG_LINK, "10G XGXS phy link up\n");
 			bnx2x_bits_en(bp,
@@ -2931,9 +2972,9 @@ static void bnx2x_link_int_ack(struct link_params *params,
 				      NIG_STATUS_XGXS0_LINK10G);
 
 		} else if (params->switch_cfg == SWITCH_CFG_10G) {
-			/* Disable the link interrupt
-			 * by writing 1 to the relevant lane
-			 * in the status register
+			/*
+			 * Disable the link interrupt by writing 1 to the
+			 * relevant lane in the status register
 			 */
 			u32 ser_lane = ((params->lane_config &
 				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
@@ -2948,8 +2989,9 @@ static void bnx2x_link_int_ack(struct link_params *params,
 
 		} else { /* SerDes */
 			DP(NETIF_MSG_LINK, "SerDes phy link up\n");
-			/* Disable the link interrupt
-			 * by writing 1 to the status register
+			/*
+			 * Disable the link interrupt by writing 1 to the status
+			 * register
 			 */
 			bnx2x_bits_en(bp,
 				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
@@ -3126,19 +3168,19 @@ u8 bnx2x_set_led(struct link_params *params,
 		break;
 
 	case LED_MODE_OPER:
-		/**
+		/*
 		 * For all other phys, OPER mode is same as ON, so in case
 		 * link is down, do nothing
-		 **/
+		 */
 		if (!vars->link_up)
 			break;
 	case LED_MODE_ON:
 		if (params->phy[EXT_PHY1].type ==
 		    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727 &&
 		    CHIP_IS_E2(bp) && params->num_phys == 2) {
-			/**
-			* This is a work-around for E2+8727 Configurations
-			*/
+			/*
+			 * This is a work-around for E2+8727 Configurations
+			 */
 			if (mode == LED_MODE_ON ||
 				speed == SPEED_10000){
 				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
@@ -3150,10 +3192,10 @@ u8 bnx2x_set_led(struct link_params *params,
 				return rc;
 			}
 		} else if (SINGLE_MEDIA_DIRECT(params)) {
-			/**
-			* This is a work-around for HW issue found when link
-			* is up in CL73
-			*/
+			/*
+			 * This is a work-around for HW issue found when link
+			 * is up in CL73
+			 */
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
 		} else {
@@ -3174,8 +3216,10 @@ u8 bnx2x_set_led(struct link_params *params,
 		     (speed == SPEED_1000) ||
 		     (speed == SPEED_100) ||
 		     (speed == SPEED_10))) {
-			/* On Everest 1 Ax chip versions for speeds less than
-			10G LED scheme is different */
+			/*
+			 * On Everest 1 Ax chip versions for speeds less than
+			 * 10G LED scheme is different
+			 */
 			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
 			       + port*4, 1);
 			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 +
@@ -3195,7 +3239,7 @@ u8 bnx2x_set_led(struct link_params *params,
 
 }
 
-/**
+/*
  * This function comes to reflect the actual link state read DIRECTLY from the
  * HW
  */
@@ -3254,15 +3298,15 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	u8 rc = 0;
 	u8 phy_index, non_ext_phy;
 	struct bnx2x *bp = params->bp;
-	/**
-	* In case of external phy existence, the line speed would be the
-	* line speed linked up by the external phy. In case it is direct
-	* only, then the line_speed during initialization will be
-	* equal to the req_line_speed
-	*/
+	/*
+	 * In case of external phy existence, the line speed would be the
+	 * line speed linked up by the external phy. In case it is direct
+	 * only, then the line_speed during initialization will be
+	 * equal to the req_line_speed
+	 */
 	vars->line_speed = params->phy[INT_PHY].req_line_speed;
 
-	/**
+	/*
 	 * Initialize the internal phy in case this is a direct board
 	 * (no external phys), or this board has external phy which requires
 	 * to first.
@@ -3290,17 +3334,16 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	if (!non_ext_phy)
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			/**
+			/*
 			 * No need to initialize second phy in case of first
 			 * phy only selection. In case of second phy, we do
 			 * need to initialize the first phy, since they are
 			 * connected.
-			 **/
+			 */
 			if (phy_index == EXT_PHY2 &&
 			    (bnx2x_phy_selection(params) ==
 			     PORT_HW_CFG_PHY_SELECTION_FIRST_PHY)) {
-				DP(NETIF_MSG_LINK, "Not initializing"
-						   "second phy\n");
+				DP(NETIF_MSG_LINK, "Ignoring second phy\n");
 				continue;
 			}
 			params->phy[phy_index].config_init(
@@ -3424,7 +3467,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	msleep(20);
 	return rc;
 }
-/**
+/*
  * The bnx2x_link_update function should be called upon link
  * interrupt.
  * Link is considered up as follows:
@@ -3476,14 +3519,14 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	/* disable emac */
 	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
-	/**
-	* Step 1:
-	* Check external link change only for external phys, and apply
-	* priority selection between them in case the link on both phys
-	* is up. Note that the instead of the common vars, a temporary
-	* vars argument is used since each phy may have different link/
-	* speed/duplex result
-	*/
+	/*
+	 * Step 1:
+	 * Check external link change only for external phys, and apply
+	 * priority selection between them in case the link on both phys
+	 * is up. Note that the instead of the common vars, a temporary
+	 * vars argument is used since each phy may have different link/
+	 * speed/duplex result
+	 */
 	for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 	      phy_index++) {
 		struct bnx2x_phy *phy = &params->phy[phy_index];
@@ -3508,22 +3551,22 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 			switch (bnx2x_phy_selection(params)) {
 			case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
 			case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
-			/**
+			/*
 			 * In this option, the first PHY makes sure to pass the
 			 * traffic through itself only.
 			 * Its not clear how to reset the link on the second phy
-			 **/
+			 */
 				active_external_phy = EXT_PHY1;
 				break;
 			case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
-			/**
+			/*
 			 * In this option, the first PHY makes sure to pass the
 			 * traffic through the second PHY.
-			 **/
+			 */
 				active_external_phy = EXT_PHY2;
 				break;
 			default:
-			/**
+			/*
 			 * Link indication on both PHYs with the following cases
 			 * is invalid:
 			 * - FIRST_PHY means that second phy wasn't initialized,
@@ -3531,7 +3574,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 			 * - SECOND_PHY means that first phy should not be able
 			 * to link up by itself (using configuration)
 			 * - DEFAULT should be overriden during initialiazation
-			 **/
+			 */
 				DP(NETIF_MSG_LINK, "Invalid link indication"
 					   "mpc=0x%x. DISABLING LINK !!!\n",
 					   params->multi_phy_config);
@@ -3541,18 +3584,18 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		}
 	}
 	prev_line_speed = vars->line_speed;
-	/**
-	* Step 2:
-	* Read the status of the internal phy. In case of
-	* DIRECT_SINGLE_MEDIA board, this link is the external link,
-	* otherwise this is the link between the 577xx and the first
-	* external phy
-	*/
+	/*
+	 * Step 2:
+	 * Read the status of the internal phy. In case of
+	 * DIRECT_SINGLE_MEDIA board, this link is the external link,
+	 * otherwise this is the link between the 577xx and the first
+	 * external phy
+	 */
 	if (params->phy[INT_PHY].read_status)
 		params->phy[INT_PHY].read_status(
 			&params->phy[INT_PHY],
 			params, vars);
-	/**
+	/*
 	 * The INT_PHY flow control reside in the vars. This include the
 	 * case where the speed or flow control are not set to AUTO.
 	 * Otherwise, the active external phy flow control result is set
@@ -3562,13 +3605,13 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	 */
 	if (active_external_phy > INT_PHY) {
 		vars->flow_ctrl = phy_vars[active_external_phy].flow_ctrl;
-		/**
+		/*
 		 * Link speed is taken from the XGXS. AN and FC result from
 		 * the external phy.
 		 */
 		vars->link_status |= phy_vars[active_external_phy].link_status;
 
-		/**
+		/*
 		 * if active_external_phy is first PHY and link is up - disable
 		 * disable TX on second external PHY
 		 */
@@ -3604,7 +3647,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	DP(NETIF_MSG_LINK, "vars->flow_ctrl = 0x%x, vars->link_status = 0x%x,"
 		   " ext_phy_line_speed = %d\n", vars->flow_ctrl,
 		   vars->link_status, ext_phy_line_speed);
-	/**
+	/*
 	 * Upon link speed change set the NIG into drain mode. Comes to
 	 * deals with possible FIFO glitch due to clk change when speed
 	 * is decreased without link down indicator
@@ -3635,14 +3678,14 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_link_int_ack(params, vars, link_10g);
 
-	/**
-	* In case external phy link is up, and internal link is down
-	* (not initialized yet probably after link initialization, it
-	* needs to be initialized.
-	* Note that after link down-up as result of cable plug, the xgxs
-	* link would probably become up again without the need
-	* initialize it
-	*/
+	/*
+	 * In case external phy link is up, and internal link is down
+	 * (not initialized yet probably after link initialization, it
+	 * needs to be initialized.
+	 * Note that after link down-up as result of cable plug, the xgxs
+	 * link would probably become up again without the need
+	 * initialize it
+	 */
 	if (!(SINGLE_MEDIA_DIRECT(params))) {
 		DP(NETIF_MSG_LINK, "ext_phy_link_up = %d, int_link_up = %d,"
 			   " init_preceding = %d\n", ext_phy_link_up,
@@ -3662,9 +3705,9 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 						vars);
 		}
 	}
-	/**
-	 *  Link is up only if both local phy and external phy (in case of
-	 *  non-direct board) are up
+	/*
+	 * Link is up only if both local phy and external phy (in case of
+	 * non-direct board) are up
 	 */
 	vars->link_up = (vars->phy_link_up &&
 			 (ext_phy_link_up ||
@@ -3994,26 +4037,32 @@ static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 	}
 	/* XAUI workaround in 8073 A0: */
 
-	/* After loading the boot ROM and restarting Autoneg,
-	poll Dev1, Reg $C820: */
+	/*
+	 * After loading the boot ROM and restarting Autoneg, poll
+	 * Dev1, Reg $C820:
+	 */
 
 	for (cnt = 0; cnt < 1000; cnt++) {
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
 				&val);
-		  /* If bit [14] = 0 or bit [13] = 0, continue on with
-		   system initialization (XAUI work-around not required,
-		    as these bits indicate 2.5G or 1G link up). */
+		  /*
+		   * If bit [14] = 0 or bit [13] = 0, continue on with
+		   * system initialization (XAUI work-around not required, as
+		   * these bits indicate 2.5G or 1G link up).
+		   */
 		if (!(val & (1<<14)) || !(val & (1<<13))) {
 			DP(NETIF_MSG_LINK, "XAUI work-around not required\n");
 			return 0;
 		} else if (!(val & (1<<15))) {
-			DP(NETIF_MSG_LINK, "clc bit 15 went off\n");
-			 /* If bit 15 is 0, then poll Dev1, Reg $C841 until
-			  it's MSB (bit 15) goes to 1 (indicating that the
-			  XAUI workaround has completed),
-			  then continue on with system initialization.*/
+			DP(NETIF_MSG_LINK, "bit 15 went off\n");
+			/*
+			 * If bit 15 is 0, then poll Dev1, Reg $C841 until it's
+			 * MSB (bit15) goes to 1 (indicating that the XAUI
+			 * workaround has completed), then continue on with
+			 * system initialization.
+			 */
 			for (cnt1 = 0; cnt1 < 1000; cnt1++) {
 				bnx2x_cl45_read(bp, phy,
 					MDIO_PMA_DEVAD,
@@ -4119,10 +4168,6 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
 
-	/**
-	 * If this is forced speed, set to KR or KX (all other are not
-	 * supported)
-	 */
 	/* Swap polarity if required - Must be done only in non-1G mode */
 	if (params->lane_config & PORT_HW_CFG_SWAP_PHY_POLARITY_ENABLED) {
 		/* Configure the 8073 to swap _P and _N of the KR lines */
@@ -4165,8 +4210,10 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 			val = (1<<7);
 		} else if (phy->req_line_speed ==  SPEED_2500) {
 			val = (1<<5);
-			/* Note that 2.5G works only
-			when used with 1G advertisment */
+			/*
+			 * Note that 2.5G works only when used with 1G
+			 * advertisment
+			 */
 		} else
 			val = (1<<5);
 	} else {
@@ -4175,8 +4222,7 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 			PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 			val |= (1<<7);
 
-		/* Note that 2.5G works only when
-		used with 1G advertisment */
+		/* Note that 2.5G works only when used with 1G advertisment */
 		if (phy->speed_cap_mask &
 			(PORT_HW_CFG_SPEED_CAPABILITY_D0_1G |
 			 PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
@@ -4216,9 +4262,11 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	/* Add support for CL37 (passive mode) III */
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
 
-	/* The SNR will improve about 2db by changing
-	BW and FEE main tap. Rest commands are executed
-	after link is up*/
+	/*
+	 * The SNR will improve about 2db by changing BW and FEE main
+	 * tap. Rest commands are executed after link is up
+	 * Change FFE main cursor to 5 in EDC register
+	 */
 	if (bnx2x_8073_is_snr_needed(bp, phy))
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_EDC_FFE_MAIN,
@@ -4302,12 +4350,11 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 
 	link_up = (((val1 & 4) == 4) || (an1000_status & (1<<1)));
 	if (link_up && bnx2x_8073_is_snr_needed(bp, phy)) {
-		/* The SNR will improve about 2dbby
-		changing the BW and FEE main tap.*/
-		/* The 1st write to change FFE main
-		tap is set before restart AN */
-		/* Change PLL Bandwidth in EDC
-		register */
+		/*
+		 * The SNR will improve about 2dbby changing the BW and FEE main
+		 * tap. The 1st write to change FFE main tap is set before
+		 * restart AN. Change PLL Bandwidth in EDC register
+		 */
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_PLL_BANDWIDTH,
 				 0x26BC);
@@ -4351,10 +4398,10 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 			bnx2x_cl45_read(bp, phy,
 					MDIO_XS_DEVAD,
 					MDIO_XS_REG_8073_RX_CTRL_PCIE, &val1);
-			/**
-			* Set bit 3 to invert Rx in 1G mode and clear this bit
-			* when it`s in 10G mode.
-			*/
+			/*
+			 * Set bit 3 to invert Rx in 1G mode and clear this bit
+			 * when it`s in 10G mode.
+			 */
 			if (vars->line_speed == SPEED_1000) {
 				DP(NETIF_MSG_LINK, "Swapping 1G polarity for"
 					      "the 8073\n");
@@ -4589,8 +4636,10 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
 			 0x8002);
-	/* Wait appropriate time for two-wire command to finish before
-	polling the status register */
+	/*
+	 * Wait appropriate time for two-wire command to finish before
+	 * polling the status register
+	 */
 	msleep(1);
 
 	/* Wait up to 500us for command complete status */
@@ -4669,8 +4718,10 @@ static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	{
 		u8 copper_module_type;
 
-		/* Check if its active cable( includes SFP+ module)
-		of passive cable*/
+		/*
+		 * Check if its active cable (includes SFP+ module)
+		 * of passive cable
+		 */
 		if (bnx2x_read_sfp_module_eeprom(phy,
 					       params,
 					       SFP_EEPROM_FC_TX_TECH_ADDR,
@@ -4729,8 +4780,10 @@ static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "EDC mode is set to 0x%x\n", *edc_mode);
 	return 0;
 }
-/* This function read the relevant field from the module ( SFP+ ),
-	and verify it is compliant with this board */
+/*
+ * This function read the relevant field from the module (SFP+), and verify it
+ * is compliant with this board
+ */
 static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 				  struct link_params *params)
 {
@@ -4808,8 +4861,11 @@ static u8 bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 	u8 val;
 	struct bnx2x *bp = params->bp;
 	u16 timeout;
-	/* Initialization time after hot-plug may take up to 300ms for some
-	phys type ( e.g. JDSU ) */
+	/*
+	 * Initialization time after hot-plug may take up to 300ms for
+	 * some phys type ( e.g. JDSU )
+	 */
+
 	for (timeout = 0; timeout < 60; timeout++) {
 		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
 		    == 0) {
@@ -4828,16 +4884,14 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 	/* Make sure GPIOs are not using for LED mode */
 	u16 val;
 	/*
-	 * In the GPIO register, bit 4 is use to detemine if the GPIOs are
+	 * In the GPIO register, bit 4 is use to determine if the GPIOs are
 	 * operating as INPUT or as OUTPUT. Bit 1 is for input, and 0 for
 	 * output
 	 * Bits 0-1 determine the gpios value for OUTPUT in case bit 4 val is 0
 	 * Bits 8-9 determine the gpios value for INPUT in case bit 4 val is 1
 	 * where the 1st bit is the over-current(only input), and 2nd bit is
 	 * for power( only output )
-	*/
-
-	/*
+	 *
 	 * In case of NOC feature is disabled and power is up, set GPIO control
 	 *  as input to enable listening of over-current indication
 	 */
@@ -4882,9 +4936,10 @@ static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 
 		DP(NETIF_MSG_LINK, "Setting LRM MODE\n");
 
-		/* Changing to LRM mode takes quite few seconds.
-		So do it only if current mode is limiting
-		( default is LRM )*/
+		/*
+		 * Changing to LRM mode takes quite few seconds. So do it only
+		 * if current mode is limiting (default is LRM)
+		 */
 		if (cur_limiting_mode != EDC_MODE_LIMITING)
 			return 0;
 
@@ -5008,8 +5063,10 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
 		bnx2x_8727_power_module(bp, phy, 1);
 
-	/* Check and set limiting mode / LRM mode on 8726.
-	On 8727 it is done automatically */
+	/*
+	 * Check and set limiting mode / LRM mode on 8726. On 8727 it
+	 * is done automatically
+	 */
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
 		bnx2x_8726_set_limiting_mode(bp, phy, edc_mode);
 	else
@@ -5040,7 +5097,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 			  MISC_REGISTERS_GPIO_HIGH,
 			  params->port);
 
-	/* Get current gpio val refelecting module plugged in / out*/
+	/* Get current gpio val reflecting module plugged in / out*/
 	gpio_val = bnx2x_get_gpio(bp, MISC_REGISTERS_GPIO_3, port);
 
 	/* Call the handling function in case module is detected */
@@ -5063,8 +5120,10 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
 				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
 				   port);
-		/* Module was plugged out. */
-		/* Disable transmit for this module */
+		/*
+		 * Module was plugged out.
+		 * Disable transmit for this module
+		 */
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
 			bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
@@ -5103,9 +5162,9 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x pcs_status 0x%x 1Gbps"
 			" link_status 0x%x\n", rx_sd, pcs_status, val2);
-	/* link is up if both bit 0 of pmd_rx_sd and
-	 * bit 0 of pcs_status are set, or if the autoneg bit
-	 * 1 is set
+	/*
+	 * link is up if both bit 0 of pmd_rx_sd and bit 0 of pcs_status
+	 * are set, or if the autoneg bit 1 is set
 	 */
 	link_up = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
 	if (link_up) {
@@ -5300,11 +5359,12 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 
 	bnx2x_8726_external_rom_boot(phy, params);
 
-	/* Need to call module detected on initialization since
-	the module detection triggered by actual module
-	insertion might occur before driver is loaded, and when
-	driver is loaded, it reset all registers, including the
-	transmitter */
+	/*
+	 * Need to call module detected on initialization since the module
+	 * detection triggered by actual module insertion might occur before
+	 * driver is loaded, and when driver is loaded, it reset all
+	 * registers, including the transmitter
+	 */
 	bnx2x_sfp_module_detection(phy, params);
 
 	if (phy->req_line_speed == SPEED_1000) {
@@ -5337,8 +5397,10 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
 		bnx2x_cl45_write(bp, phy,
 				MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
-		/* Enable RX-ALARM control to receive
-		interrupt for 1G speed change */
+		/*
+		 * Enable RX-ALARM control to receive interrupt for 1G speed
+		 * change
+		 */
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x4);
 		bnx2x_cl45_write(bp, phy,
@@ -5461,7 +5523,7 @@ static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
 				struct link_params *params) {
 	u32 swap_val, swap_override;
 	u8 port;
-	/**
+	/*
 	 * The PHY reset is controlled by GPIO 1. Fake the port number
 	 * to cancel the swap done in set_gpio()
 	 */
@@ -5496,14 +5558,17 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, lasi_ctrl_val);
 
-	/* Initially configure  MOD_ABS to interrupt when
-	module is presence( bit 8) */
+	/*
+	 * Initially configure MOD_ABS to interrupt when module is
+	 * presence( bit 8)
+	 */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
-	/* Set EDC off by setting OPTXLOS signal input to low
-	(bit 9).
-	When the EDC is off it locks onto a reference clock and
-	avoids becoming 'lost'.*/
+	/*
+	 * Set EDC off by setting OPTXLOS signal input to low (bit 9).
+	 * When the EDC is off it locks onto a reference clock and avoids
+	 * becoming 'lost'
+	 */
 	mod_abs &= ~(1<<8);
 	if (!(phy->flags & FLAGS_NOC))
 		mod_abs &= ~(1<<9);
@@ -5518,7 +5583,7 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	if (phy->flags & FLAGS_NOC)
 		val |= (3<<5);
 
-	/**
+	/*
 	 * Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
 	 * status which reflect SFP+ module over-current
 	 */
@@ -5545,7 +5610,7 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, &tmp1);
 		DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
-		/**
+		/*
 		 * Power down the XAUI until link is up in case of dual-media
 		 * and 1G
 		 */
@@ -5571,7 +5636,7 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1300);
 	} else {
-		/**
+		/*
 		 * Since the 8727 has only single reset pin, need to set the 10G
 		 * registers although it is default
 		 */
@@ -5587,7 +5652,8 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 0x0008);
 	}
 
-	/* Set 2-wire transfer rate of SFP+ module EEPROM
+	/*
+	 * Set 2-wire transfer rate of SFP+ module EEPROM
 	 * to 100Khz since some DACs(direct attached cables) do
 	 * not work at 400Khz.
 	 */
@@ -5631,12 +5697,14 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "MOD_ABS indication "
 			    "show module is absent\n");
 
-		/* 1. Set mod_abs to detect next module
-		presence event
-		   2. Set EDC off by setting OPTXLOS signal input to low
-			(bit 9).
-			When the EDC is off it locks onto a reference clock and
-			avoids becoming 'lost'.*/
+		/*
+		 * 1. Set mod_abs to detect next module
+		 *    presence event
+		 * 2. Set EDC off by setting OPTXLOS signal input to low
+		 *    (bit 9).
+		 *    When the EDC is off it locks onto a reference clock and
+		 *    avoids becoming 'lost'.
+		 */
 		mod_abs &= ~(1<<8);
 		if (!(phy->flags & FLAGS_NOC))
 			mod_abs &= ~(1<<9);
@@ -5644,8 +5712,10 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-		/* Clear RX alarm since it stays up as long as
-		the mod_abs wasn't changed */
+		/*
+		 * Clear RX alarm since it stays up as long as
+		 * the mod_abs wasn't changed
+		 */
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
@@ -5654,15 +5724,14 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		/* Module is present */
 		DP(NETIF_MSG_LINK, "MOD_ABS indication "
 			    "show module is present\n");
-		/* First thing, disable transmitter,
-		and if the module is ok, the
-		module_detection will enable it*/
-
-		/* 1. Set mod_abs to detect next module
-		absent event ( bit 8)
-		   2. Restore the default polarity of the OPRXLOS signal and
-		this signal will then correctly indicate the presence or
-		absence of the Rx signal. (bit 9) */
+		/*
+		 * First disable transmitter, and if the module is ok, the
+		 * module_detection will enable it
+		 * 1. Set mod_abs to detect next module absent event ( bit 8)
+		 * 2. Restore the default polarity of the OPRXLOS signal and
+		 * this signal will then correctly indicate the presence or
+		 * absence of the Rx signal. (bit 9)
+		 */
 		mod_abs |= (1<<8);
 		if (!(phy->flags & FLAGS_NOC))
 			mod_abs |= (1<<9);
@@ -5670,10 +5739,12 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-		/* Clear RX alarm since it stays up as long as
-		the mod_abs wasn't changed. This is need to be done
-		before calling the module detection, otherwise it will clear
-		the link update alarm */
+		/*
+		 * Clear RX alarm since it stays up as long as the mod_abs
+		 * wasn't changed. This is need to be done before calling the
+		 * module detection, otherwise it will clear* the link update
+		 * alarm
+		 */
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
@@ -5690,9 +5761,8 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 	}
 
 	DP(NETIF_MSG_LINK, "8727 RX_ALARM_STATUS 0x%x\n",
-		 rx_alarm_status);
-	/* No need to check link status in case of
-	module plugged in/out */
+		   rx_alarm_status);
+	/* No need to check link status in case of module plugged in/out */
 }
 
 static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
@@ -5728,7 +5798,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
 
-	/**
+	/*
 	 * If a module is present and there is need to check
 	 * for over current
 	 */
@@ -5748,12 +5818,8 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 					    " Please remove the SFP+ module and"
 					    " restart the system to clear this"
 					    " error.\n",
-				   params->port);
-
-			/*
-			 * Disable all RX_ALARMs except for
-			 * mod_abs
-			 */
+			 params->port);
+			/* Disable all RX_ALARMs except for mod_abs */
 			bnx2x_cl45_write(bp, phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_RX_ALARM_CTRL, (1<<5));
@@ -5796,11 +5862,15 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 			MDIO_PMA_DEVAD,
 			MDIO_PMA_REG_8073_SPEED_LINK_STATUS, &link_status);
 
-	/* Bits 0..2 --> speed detected,
-	   bits 13..15--> link is down */
+	/*
+	 * Bits 0..2 --> speed detected,
+	 * Bits 13..15--> link is down
+	 */
 	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
 		link_up = 1;
 		vars->line_speed = SPEED_10000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 10G\n",
+			   params->port);
 	} else if ((link_status & (1<<0)) && (!(link_status & (1<<13)))) {
 		link_up = 1;
 		vars->line_speed = SPEED_1000;
@@ -5822,7 +5892,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_8727_PCS_GP, &val1);
-		/**
+		/*
 		 * In case of dual-media board and 1G, power up the XAUI side,
 		 * otherwise power it down. For 10G it is done automatically
 		 */
@@ -5964,7 +6034,11 @@ static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 autoneg_val, an_1000_val, an_10_100_val;
-
+	/*
+	 * This phy uses the NIG latch mechanism since link indication
+	 * arrives through its LED4 and not via its LASI signal, so we
+	 * get steady signal instead of clear on read
+	 */
 	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
 		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
@@ -6123,8 +6197,9 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	bnx2x_wait_reset_complete(bp, phy);
 	/* Wait for GPHY to come out of reset */
 	msleep(50);
-	/* BCM84823 requires that XGXS links up first @ 10G for normal
-	behavior */
+	/*
+	 * BCM84823 requires that XGXS links up first @ 10G for normal behavior
+	 */
 	temp = vars->line_speed;
 	vars->line_speed = SPEED_10000;
 	bnx2x_set_autoneg(&params->phy[INT_PHY], params, vars, 0);
@@ -6445,7 +6520,7 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 			if (!((val &
 			       MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_MASK)
 			  >> MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_SHIFT)) {
-				DP(NETIF_MSG_LINK, "Seting LINK_SIGNAL\n");
+				DP(NETIF_MSG_LINK, "Setting LINK_SIGNAL\n");
 				bnx2x_cl45_write(bp, phy,
 						 MDIO_PMA_DEVAD,
 						 MDIO_PMA_REG_8481_LINK_SIGNAL,
@@ -6554,9 +6629,7 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "10G-base-T PMA status 0x%x->0x%x\n",
 		   val2, val1);
 	link_up = ((val1 & 4) == 4);
-	/* if link is up
-	 * print the AN outcome of the SFX7101 PHY
-	 */
+	/* if link is up print the AN outcome of the SFX7101 PHY */
 	if (link_up) {
 		bnx2x_cl45_read(bp, phy,
 				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
@@ -7019,7 +7092,7 @@ static void bnx2x_populate_preemphasis(struct bnx2x *bp, u32 shmem_base,
 	/* Get the 4 lanes xgxs config rx and tx */
 	u32 rx = 0, tx = 0, i;
 	for (i = 0; i < 2; i++) {
-		/**
+		/*
 		 * INT_PHY and EXT_PHY1 share the same value location in the
 		 * shmem. When num_phys is greater than 1, than this value
 		 * applies only to EXT_PHY1
@@ -7173,11 +7246,11 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
 	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, phy_index);
 
-	/**
-	* The shmem address of the phy version is located on different
-	* structures. In case this structure is too old, do not set
-	* the address
-	*/
+	/*
+	 * The shmem address of the phy version is located on different
+	 * structures. In case this structure is too old, do not set
+	 * the address
+	 */
 	config2 = REG_RD(bp, shmem_base + offsetof(struct shmem_region,
 					dev_info.shared_hw_config.config2));
 	if (phy_index == EXT_PHY1) {
@@ -7206,7 +7279,7 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 	}
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, mdc_mdio_access, port);
 
-	/**
+	/*
 	 * In case mdc/mdio_access of the external phy is different than the
 	 * mdc/mdio access of the XGXS, a HW lock must be taken in each access
 	 * to prevent one port interfere with another port's CL45 operations.
@@ -7758,8 +7831,10 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 				 (val | 1<<10));
 	}
 
-	/* Toggle Transmitter: Power down and then up with 600ms
-	   delay between */
+	/*
+	 * Toggle Transmitter: Power down and then up with 600ms delay
+	 * between
+	 */
 	msleep(600);
 
 	/* PART3 - complete TX_POWER_DOWN process, and set GPIO2 back to low */
@@ -7942,8 +8017,10 @@ static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		/* GPIO1 affects both ports, so there's need to pull
-		it for single port alone */
+		/*
+		 * GPIO1 affects both ports, so there's need to pull
+		 * it for single port alone
+		 */
 		rc = bnx2x_8726_common_init_phy(bp, shmem_base_path,
 						shmem2_base_path,
 						phy_index, chip_id);
@@ -7953,8 +8030,8 @@ static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 	default:
 		DP(NETIF_MSG_LINK,
-			 "bnx2x_common_init_phy: ext_phy 0x%x not required\n",
-			 ext_phy_type);
+			   "ext_phy 0x%x common init not required\n",
+			   ext_phy_type);
 		break;
 	}
 
-- 
1.7.1








