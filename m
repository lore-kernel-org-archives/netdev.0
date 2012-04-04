From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 9/10] bnx2x: Change comments and white spaces
Date: Wed, 4 Apr 2012 07:41:31 +0300
Message-ID: <1333514492-20425-10-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4920 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891Ab2DDEri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:38 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

A semantic patch, fixing style issues in the bnx2x's link code.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  660 ++++++++--------------
 1 files changed, 241 insertions(+), 419 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 4df6199..08d82ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -139,7 +139,6 @@
 
 
 
-/* */
 #define SFP_EEPROM_CON_TYPE_ADDR		0x2
 	#define SFP_EEPROM_CON_TYPE_VAL_LC	0x7
 	#define SFP_EEPROM_CON_TYPE_VAL_COPPER	0x21
@@ -405,8 +404,7 @@ static void bnx2x_ets_e2e3a0_disabled(struct link_params *params)
 
 	DP(NETIF_MSG_LINK, "ETS E2E3 disabled configuration\n");
 
-	/*
-	 * mapping between entry  priority to client number (0,1,2 -debug and
+	/* mapping between entry  priority to client number (0,1,2 -debug and
 	 * management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
 	 * 3bits client num.
 	 *   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
@@ -414,8 +412,7 @@ static void bnx2x_ets_e2e3a0_disabled(struct link_params *params)
 	 */
 
 	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, 0x4688);
-	/*
-	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	/* Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries, 3 -
 	 * COS0 entry, 4 - COS1 entry.
 	 * COS1 | COS0 | DEBUG1 | DEBUG0 | MGMT
@@ -426,13 +423,11 @@ static void bnx2x_ets_e2e3a0_disabled(struct link_params *params)
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x7);
 	/* defines which entries (clients) are subjected to WFQ arbitration */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0);
-	/*
-	 * For strict priority entries defines the number of consecutive
+	/* For strict priority entries defines the number of consecutive
 	 * slots for the highest priority.
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
-	/*
-	 * mapping between the CREDIT_WEIGHT registers and actual client
+	/* mapping between the CREDIT_WEIGHT registers and actual client
 	 * numbers
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP, 0);
@@ -444,8 +439,7 @@ static void bnx2x_ets_e2e3a0_disabled(struct link_params *params)
 	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, 0);
 	/* ETS mode disable */
 	REG_WR(bp, PBF_REG_ETS_ENABLED, 0);
-	/*
-	 * If ETS mode is enabled (there is no strict priority) defines a WFQ
+	/* If ETS mode is enabled (there is no strict priority) defines a WFQ
 	 * weight for COS0/COS1.
 	 */
 	REG_WR(bp, PBF_REG_COS0_WEIGHT, 0x2710);
@@ -472,10 +466,9 @@ static u32 bnx2x_ets_get_min_w_val_nig(const struct link_vars *vars)
 			min_w_val = ETS_E3B0_NIG_MIN_W_VAL_UP_TO_10GBPS;
 	} else
 		min_w_val = ETS_E3B0_NIG_MIN_W_VAL_20GBPS;
-	/**
-	 *  If the link isn't up (static configuration for example ) The
-	 *  link will be according to 20GBPS.
-	*/
+	/* If the link isn't up (static configuration for example ) The
+	 * link will be according to 20GBPS.
+	 */
 	return min_w_val;
 }
 /******************************************************************************
@@ -539,8 +532,7 @@ static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	const u8 port = params->port;
 	const u32 min_w_val = bnx2x_ets_get_min_w_val_nig(vars);
-	/**
-	 * mapping between entry  priority to client number (0,1,2 -debug and
+	/* Mapping between entry  priority to client number (0,1,2 -debug and
 	 * management clients, 3 - COS0 client, 4 - COS1, ... 8 -
 	 * COS5)(HIGHEST) 4bits client num.TODO_ETS - Should be done by
 	 * reset value or init tool
@@ -552,18 +544,14 @@ static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
 		REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT2_LSB, 0x76543210);
 		REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT2_MSB, 0x8);
 	}
-	/**
-	* For strict priority entries defines the number of consecutive
-	* slots for the highest priority.
-	*/
-	/* TODO_ETS - Should be done by reset value or init tool */
+	/* For strict priority entries defines the number of consecutive
+	 * slots for the highest priority.
+	 */
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_NUM_STRICT_ARB_SLOTS :
 		   NIG_REG_P1_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
-	/**
-	 * mapping between the CREDIT_WEIGHT registers and actual client
+	/* Mapping between the CREDIT_WEIGHT registers and actual client
 	 * numbers
 	 */
-	/* TODO_ETS - Should be done by reset value or init tool */
 	if (port) {
 		/*Port 1 has 6 COS*/
 		REG_WR(bp, NIG_REG_P1_TX_ARB_CLIENT_CREDIT_MAP2_LSB, 0x210543);
@@ -575,8 +563,7 @@ static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_CREDIT_MAP2_MSB, 0x5);
 	}
 
-	/**
-	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	/* Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries, 3 -
 	 * COS0 entry, 4 - COS1 entry.
 	 * COS1 | COS0 | DEBUG1 | DEBUG0 | MGMT
@@ -591,13 +578,12 @@ static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_CLIENT_IS_SUBJECT2WFQ :
 		   NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0);
 
-	/**
-	* Please notice the register address are note continuous and a
-	* for here is note appropriate.In 2 port mode port0 only COS0-5
-	* can be used. DEBUG1,DEBUG1,MGMT are never used for WFQ* In 4
-	* port mode port1 only COS0-2 can be used. DEBUG1,DEBUG1,MGMT
-	* are never used for WFQ
-	*/
+	/* Please notice the register address are note continuous and a
+	 * for here is note appropriate.In 2 port mode port0 only COS0-5
+	 * can be used. DEBUG1,DEBUG1,MGMT are never used for WFQ* In 4
+	 * port mode port1 only COS0-2 can be used. DEBUG1,DEBUG1,MGMT
+	 * are never used for WFQ
+	 */
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_CREDIT_WEIGHT_0 :
 		   NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_0, 0x0);
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_CREDIT_WEIGHT_1 :
@@ -634,10 +620,9 @@ static void bnx2x_ets_e3b0_set_credit_upper_bound_pbf(
 	u32 base_upper_bound = 0;
 	u8 max_cos = 0;
 	u8 i = 0;
-	/**
-	* In 2 port mode port0 has COS0-5 that can be used for WFQ.In 4
-	* port mode port1 has COS0-2 that can be used for WFQ.
-	*/
+	/* In 2 port mode port0 has COS0-5 that can be used for WFQ.In 4
+	 * port mode port1 has COS0-2 that can be used for WFQ.
+	 */
 	if (!port) {
 		base_upper_bound = PBF_REG_COS0_UPPER_BOUND_P0;
 		max_cos = DCBX_E3B0_MAX_NUM_COS_PORT0;
@@ -667,8 +652,7 @@ static void bnx2x_ets_e3b0_pbf_disabled(const struct link_params *params)
 	u32 base_weight = 0;
 	u8 max_cos = 0;
 
-	/**
-	 * mapping between entry  priority to client number 0 - COS0
+	/* Mapping between entry  priority to client number 0 - COS0
 	 * client, 2 - COS1, ... 5 - COS5)(HIGHEST) 4bits client num.
 	 * TODO_ETS - Should be done by reset value or init tool
 	 */
@@ -696,10 +680,9 @@ static void bnx2x_ets_e3b0_pbf_disabled(const struct link_params *params)
 
 	REG_WR(bp, (port) ? PBF_REG_ETS_ARB_CLIENT_IS_SUBJECT2WFQ_P1 :
 		   PBF_REG_ETS_ARB_CLIENT_IS_SUBJECT2WFQ_P0 , 0);
-	/**
-	* In 2 port mode port0 has COS0-5 that can be used for WFQ.
-	* In 4 port mode port1 has COS0-2 that can be used for WFQ.
-	*/
+	/* In 2 port mode port0 has COS0-5 that can be used for WFQ.
+	 * In 4 port mode port1 has COS0-2 that can be used for WFQ.
+	 */
 	if (!port) {
 		base_weight = PBF_REG_COS0_WEIGHT_P0;
 		max_cos = DCBX_E3B0_MAX_NUM_COS_PORT0;
@@ -739,7 +722,7 @@ static int bnx2x_ets_e3b0_disabled(const struct link_params *params,
 /******************************************************************************
 * Description:
 *	Disable will return basicly the values to init values.
-*.
+*
 ******************************************************************************/
 int bnx2x_ets_disabled(struct link_params *params,
 		      struct link_vars *vars)
@@ -868,7 +851,7 @@ static int bnx2x_ets_e3b0_set_cos_bw(struct bnx2x *bp,
 /******************************************************************************
 * Description:
 *	Calculate the total BW.A value of 0 isn't legal.
-*.
+*
 ******************************************************************************/
 static int bnx2x_ets_e3b0_get_total_bw(
 	const struct link_params *params,
@@ -880,7 +863,6 @@ static int bnx2x_ets_e3b0_get_total_bw(
 	u8 is_bw_cos_exist = 0;
 
 	*total_bw = 0 ;
-
 	/* Calculate total BW requested */
 	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
 		if (ets_params->cos[cos_idx].state == bnx2x_cos_state_bw) {
@@ -888,10 +870,9 @@ static int bnx2x_ets_e3b0_get_total_bw(
 			if (!ets_params->cos[cos_idx].params.bw_params.bw) {
 				DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config BW"
 						   "was set to 0\n");
-				/*
-				 * This is to prevent a state when ramrods
+				/* This is to prevent a state when ramrods
 				 * can't be sent
-				*/
+				 */
 				ets_params->cos[cos_idx].params.bw_params.bw
 					 = 1;
 			}
@@ -909,8 +890,7 @@ static int bnx2x_ets_e3b0_get_total_bw(
 		}
 		DP(NETIF_MSG_LINK,
 		   "bnx2x_ets_E3B0_config total BW should be 100\n");
-		/*
-		 * We can handle a case whre the BW isn't 100 this can happen
+		/* We can handle a case whre the BW isn't 100 this can happen
 		 * if the TC are joined.
 		 */
 	}
@@ -920,7 +900,7 @@ static int bnx2x_ets_e3b0_get_total_bw(
 /******************************************************************************
 * Description:
 *	Invalidate all the sp_pri_to_cos.
-*.
+*
 ******************************************************************************/
 static void bnx2x_ets_e3b0_sp_pri_to_cos_init(u8 *sp_pri_to_cos)
 {
@@ -932,7 +912,7 @@ static void bnx2x_ets_e3b0_sp_pri_to_cos_init(u8 *sp_pri_to_cos)
 * Description:
 *	Calculate and set the SP (ARB_PRIORITY_CLIENT) NIG and PBF registers
 *	according to sp_pri_to_cos.
-*.
+*
 ******************************************************************************/
 static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 					    u8 *sp_pri_to_cos, const u8 pri,
@@ -965,7 +945,7 @@ static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 * Description:
 *	Returns the correct value according to COS and priority in
 *	the sp_pri_cli register.
-*.
+*
 ******************************************************************************/
 static u64 bnx2x_e3b0_sp_get_pri_cli_reg(const u8 cos, const u8 cos_offset,
 					 const u8 pri_set,
@@ -982,7 +962,7 @@ static u64 bnx2x_e3b0_sp_get_pri_cli_reg(const u8 cos, const u8 cos_offset,
 * Description:
 *	Returns the correct value according to COS and priority in the
 *	sp_pri_cli register for NIG.
-*.
+*
 ******************************************************************************/
 static u64 bnx2x_e3b0_sp_get_pri_cli_reg_nig(const u8 cos, const u8 pri_set)
 {
@@ -998,7 +978,7 @@ static u64 bnx2x_e3b0_sp_get_pri_cli_reg_nig(const u8 cos, const u8 pri_set)
 * Description:
 *	Returns the correct value according to COS and priority in the
 *	sp_pri_cli register for PBF.
-*.
+*
 ******************************************************************************/
 static u64 bnx2x_e3b0_sp_get_pri_cli_reg_pbf(const u8 cos, const u8 pri_set)
 {
@@ -1014,7 +994,7 @@ static u64 bnx2x_e3b0_sp_get_pri_cli_reg_pbf(const u8 cos, const u8 pri_set)
 * Description:
 *	Calculate and set the SP (ARB_PRIORITY_CLIENT) NIG and PBF registers
 *	according to sp_pri_to_cos.(which COS has higher priority)
-*.
+*
 ******************************************************************************/
 static int bnx2x_ets_e3b0_sp_set_pri_cli_reg(const struct link_params *params,
 					     u8 *sp_pri_to_cos)
@@ -1150,8 +1130,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 		return -EINVAL;
 	}
 
-	/*
-	 * Upper bound is set according to current link speed (min_w_val
+	/* Upper bound is set according to current link speed (min_w_val
 	 * should be the same for upper bound and COS credit val).
 	 */
 	bnx2x_ets_e3b0_set_credit_upper_bound_nig(params, min_w_val_nig);
@@ -1161,8 +1140,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 	for (cos_entry = 0; cos_entry < ets_params->num_of_cos; cos_entry++) {
 		if (bnx2x_cos_state_bw == ets_params->cos[cos_entry].state) {
 			cos_bw_bitmap |= (1 << cos_entry);
-			/*
-			 * The function also sets the BW in HW(not the mappin
+			/* The function also sets the BW in HW(not the mappin
 			 * yet)
 			 */
 			bnx2x_status = bnx2x_ets_e3b0_set_cos_bw(
@@ -1218,14 +1196,12 @@ static void bnx2x_ets_bw_limit_common(const struct link_params *params)
 	/* ETS disabled configuration */
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "ETS enabled BW limit configuration\n");
-	/*
-	 * defines which entries (clients) are subjected to WFQ arbitration
+	/* Defines which entries (clients) are subjected to WFQ arbitration
 	 * COS0 0x8
 	 * COS1 0x10
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_SUBJECT2WFQ, 0x18);
-	/*
-	 * mapping between the ARB_CREDIT_WEIGHT registers and actual
+	/* Mapping between the ARB_CREDIT_WEIGHT registers and actual
 	 * client numbers (WEIGHT_0 does not actually have to represent
 	 * client 0)
 	 *    PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
@@ -1243,8 +1219,7 @@ static void bnx2x_ets_bw_limit_common(const struct link_params *params)
 
 	/* Defines the number of consecutive slots for the strict priority */
 	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0);
-	/*
-	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	/* Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries, 3 - COS0
 	 * entry, 4 - COS1 entry.
 	 * COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
@@ -1299,8 +1274,7 @@ int bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	u32 val	= 0;
 
 	DP(NETIF_MSG_LINK, "ETS enabled strict configuration\n");
-	/*
-	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
+	/* Bitmap of 5bits length. Each bit specifies whether the entry behaves
 	 * as strict.  Bits 0,1,2 - debug and management entries,
 	 * 3 - COS0 entry, 4 - COS1 entry.
 	 *  COS1 | COS0 | DEBUG21 | DEBUG0 | MGMT
@@ -1308,8 +1282,7 @@ int bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	 * MCP and debug are strict
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_CLIENT_IS_STRICT, 0x1F);
-	/*
-	 * For strict priority entries defines the number of consecutive slots
+	/* For strict priority entries defines the number of consecutive slots
 	 * for the highest priority.
 	 */
 	REG_WR(bp, NIG_REG_P0_TX_ARB_NUM_STRICT_ARB_SLOTS, 0x100);
@@ -1321,8 +1294,7 @@ int bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	/* Defines the number of consecutive slots for the strict priority */
 	REG_WR(bp, PBF_REG_HIGH_PRIORITY_COS_NUM, strict_cos);
 
-	/*
-	 * mapping between entry  priority to client number (0,1,2 -debug and
+	/* Mapping between entry  priority to client number (0,1,2 -debug and
 	 * management clients, 3 - COS0 client, 4 - COS client)(HIGHEST)
 	 * 3bits client num.
 	 *   PRI4    |    PRI3    |    PRI2    |    PRI1    |    PRI0
@@ -1357,15 +1329,12 @@ static void bnx2x_update_pfc_xmac(struct link_params *params,
 	if (!(params->feature_config_flags &
 	      FEATURE_CONFIG_PFC_ENABLED)) {
 
-		/*
-		 * RX flow control - Process pause frame in receive direction
+		/* RX flow control - Process pause frame in receive direction
 		 */
 		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
 			pause_val |= XMAC_PAUSE_CTRL_REG_RX_PAUSE_EN;
 
-		/*
-		 * TX flow control - Send pause packet when buffer is full
-		 */
+		/* TX flow control - Send pause packet when buffer is full */
 		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
 			pause_val |= XMAC_PAUSE_CTRL_REG_TX_PAUSE_EN;
 	} else {/* PFC support */
@@ -1451,8 +1420,7 @@ void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 static void bnx2x_set_mdio_clk(struct bnx2x *bp, u32 chip_id, u8 port)
 {
 	u32 mode, emac_base;
-	/**
-	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	/* Set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
 
@@ -1572,15 +1540,6 @@ static void bnx2x_umac_enable(struct link_params *params,
 
 	DP(NETIF_MSG_LINK, "enabling UMAC\n");
 
-	/**
-	 * This register determines on which events the MAC will assert
-	 * error on the i/f to the NIG along w/ EOP.
-	 */
-
-	/**
-	 * BD REG_WR(bp, NIG_REG_P0_MAC_RSV_ERR_MASK +
-	 * params->port*0x14,      0xfffff.
-	 */
 	/* This register opens the gate for the UMAC despite its name */
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + params->port*4, 1);
 
@@ -1643,8 +1602,7 @@ static void bnx2x_umac_enable(struct link_params *params,
 		val |= UMAC_COMMAND_CONFIG_REG_LOOP_ENA;
 	REG_WR(bp, umac_base + UMAC_REG_COMMAND_CONFIG, val);
 
-	/*
-	 * Maximum Frame Length (RW). Defines a 14-Bit maximum frame
+	/* Maximum Frame Length (RW). Defines a 14-Bit maximum frame
 	 * length used by the MAC receive logic to check frames.
 	 */
 	REG_WR(bp, umac_base + UMAC_REG_MAXFR, 0x2710);
@@ -1660,8 +1618,7 @@ static void bnx2x_xmac_init(struct link_params *params, u32 max_speed)
 	struct bnx2x *bp = params->bp;
 	u32 is_port4mode = bnx2x_is_4_port_mode(bp);
 
-	/*
-	 * In 4-port mode, need to set the mode only once, so if XMAC is
+	/* In 4-port mode, need to set the mode only once, so if XMAC is
 	 * already out of reset, it means the mode has already been set,
 	 * and it must not* reset the XMAC again, since it controls both
 	 * ports of the path
@@ -1685,13 +1642,13 @@ static void bnx2x_xmac_init(struct link_params *params, u32 max_speed)
 	if (is_port4mode) {
 		DP(NETIF_MSG_LINK, "Init XMAC to 2 ports x 10G per path\n");
 
-		/*  Set the number of ports on the system side to up to 2 */
+		/* Set the number of ports on the system side to up to 2 */
 		REG_WR(bp, MISC_REG_XMAC_CORE_PORT_MODE, 1);
 
 		/* Set the number of ports on the Warp Core to 10G */
 		REG_WR(bp, MISC_REG_XMAC_PHY_PORT_MODE, 3);
 	} else {
-		/*  Set the number of ports on the system side to 1 */
+		/* Set the number of ports on the system side to 1 */
 		REG_WR(bp, MISC_REG_XMAC_CORE_PORT_MODE, 0);
 		if (max_speed == SPEED_10000) {
 			DP(NETIF_MSG_LINK,
@@ -1723,8 +1680,7 @@ static void bnx2x_xmac_disable(struct link_params *params)
 
 	if (REG_RD(bp, MISC_REG_RESET_REG_2) &
 	    MISC_REGISTERS_RESET_REG_2_XMAC) {
-		/*
-		 * Send an indication to change the state in the NIG back to XON
+		/* Send an indication to change the state in the NIG back to XON
 		 * Clearing this bit enables the next set of this bit to get
 		 * rising edge
 		 */
@@ -1749,13 +1705,11 @@ static int bnx2x_xmac_enable(struct link_params *params,
 
 	bnx2x_xmac_init(params, vars->line_speed);
 
-	/*
-	 * This register determines on which events the MAC will assert
+	/* This register determines on which events the MAC will assert
 	 * error on the i/f to the NIG along w/ EOP.
 	 */
 
-	/*
-	 * This register tells the NIG whether to send traffic to UMAC
+	/* This register tells the NIG whether to send traffic to UMAC
 	 * or XMAC
 	 */
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + params->port*4, 0);
@@ -1857,8 +1811,7 @@ static int bnx2x_emac_enable(struct link_params *params,
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
 	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
 
-	/*
-	 * Setting this bit causes MAC control frames (except for pause
+	/* Setting this bit causes MAC control frames (except for pause
 	 * frames) to be passed on for processing. This setting has no
 	 * affect on the operation of the pause frames. This bit effects
 	 * all packets regardless of RX Parser packet sorting logic.
@@ -1957,8 +1910,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 				   struct link_vars *vars,
 				   u8 is_lb)
 {
-	/*
-	 * Set rx control: Strip CRC and enable BigMAC to relay
+	/* Set rx control: Strip CRC and enable BigMAC to relay
 	 * control packets to the system as well
 	 */
 	u32 wb_data[2];
@@ -2010,8 +1962,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_PFC_CONTROL, wb_data, 2);
 
-	/*
-	 * Set Time (based unit is 512 bit time) between automatic
+	/* Set Time (based unit is 512 bit time) between automatic
 	 * re-sending of PP packets amd enable automatic re-send of
 	 * Per-Priroity Packet as long as pp_gen is asserted and
 	 * pp_disable is low.
@@ -2080,7 +2031,7 @@ static int bnx2x_pfc_brb_get_config_params(
 	config_val->default_class1.full_xon = 0;
 
 	if (CHIP_IS_E2(bp)) {
-		/*  class0 defaults */
+		/* Class0 defaults */
 		config_val->default_class0.pause_xoff =
 			DEFAULT0_E2_BRB_MAC_PAUSE_XOFF_THR;
 		config_val->default_class0.pause_xon =
@@ -2089,7 +2040,7 @@ static int bnx2x_pfc_brb_get_config_params(
 			DEFAULT0_E2_BRB_MAC_FULL_XOFF_THR;
 		config_val->default_class0.full_xon =
 			DEFAULT0_E2_BRB_MAC_FULL_XON_THR;
-		/*  pause able*/
+		/* Pause able*/
 		config_val->pauseable_th.pause_xoff =
 			PFC_E2_BRB_MAC_PAUSE_XOFF_THR_PAUSE;
 		config_val->pauseable_th.pause_xon =
@@ -2108,7 +2059,7 @@ static int bnx2x_pfc_brb_get_config_params(
 		config_val->non_pauseable_th.full_xon =
 			PFC_E2_BRB_MAC_FULL_XON_THR_NON_PAUSE;
 	} else if (CHIP_IS_E3A0(bp)) {
-		/*  class0 defaults */
+		/* Class0 defaults */
 		config_val->default_class0.pause_xoff =
 			DEFAULT0_E3A0_BRB_MAC_PAUSE_XOFF_THR;
 		config_val->default_class0.pause_xon =
@@ -2117,7 +2068,7 @@ static int bnx2x_pfc_brb_get_config_params(
 			DEFAULT0_E3A0_BRB_MAC_FULL_XOFF_THR;
 		config_val->default_class0.full_xon =
 			DEFAULT0_E3A0_BRB_MAC_FULL_XON_THR;
-		/*  pause able */
+		/* Pause able */
 		config_val->pauseable_th.pause_xoff =
 			PFC_E3A0_BRB_MAC_PAUSE_XOFF_THR_PAUSE;
 		config_val->pauseable_th.pause_xon =
@@ -2136,7 +2087,7 @@ static int bnx2x_pfc_brb_get_config_params(
 		config_val->non_pauseable_th.full_xon =
 			PFC_E3A0_BRB_MAC_FULL_XON_THR_NON_PAUSE;
 	} else if (CHIP_IS_E3B0(bp)) {
-		/*  class0 defaults */
+		/* Class0 defaults */
 		config_val->default_class0.pause_xoff =
 			DEFAULT0_E3B0_BRB_MAC_PAUSE_XOFF_THR;
 		config_val->default_class0.pause_xon =
@@ -2299,27 +2250,23 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 			reg_th_config = &config_val.non_pauseable_th;
 	} else
 		reg_th_config = &config_val.default_class0;
-	/*
-	 * The number of free blocks below which the pause signal to class 0
+	/* The number of free blocks below which the pause signal to class 0
 	 * of MAC #n is asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_PAUSE_0_XOFF_THRESHOLD_1 :
 	       BRB1_REG_PAUSE_0_XOFF_THRESHOLD_0 ,
 	       reg_th_config->pause_xoff);
-	/*
-	 * The number of free blocks above which the pause signal to class 0
+	/* The number of free blocks above which the pause signal to class 0
 	 * of MAC #n is de-asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_PAUSE_0_XON_THRESHOLD_1 :
 	       BRB1_REG_PAUSE_0_XON_THRESHOLD_0 , reg_th_config->pause_xon);
-	/*
-	 * The number of free blocks below which the full signal to class 0
+	/* The number of free blocks below which the full signal to class 0
 	 * of MAC #n is asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_FULL_0_XOFF_THRESHOLD_1 :
 	       BRB1_REG_FULL_0_XOFF_THRESHOLD_0 , reg_th_config->full_xoff);
-	/*
-	 * The number of free blocks above which the full signal to class 0
+	/* The number of free blocks above which the full signal to class 0
 	 * of MAC #n is de-asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_FULL_0_XON_THRESHOLD_1 :
@@ -2333,30 +2280,26 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 			reg_th_config = &config_val.non_pauseable_th;
 	} else
 		reg_th_config = &config_val.default_class1;
-	/*
-	 * The number of free blocks below which the pause signal to
+	/* The number of free blocks below which the pause signal to
 	 * class 1 of MAC #n is asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_PAUSE_1_XOFF_THRESHOLD_1 :
 	       BRB1_REG_PAUSE_1_XOFF_THRESHOLD_0,
 	       reg_th_config->pause_xoff);
 
-	/*
-	 * The number of free blocks above which the pause signal to
+	/* The number of free blocks above which the pause signal to
 	 * class 1 of MAC #n is de-asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_PAUSE_1_XON_THRESHOLD_1 :
 	       BRB1_REG_PAUSE_1_XON_THRESHOLD_0,
 	       reg_th_config->pause_xon);
-	/*
-	 * The number of free blocks below which the full signal to
+	/* The number of free blocks below which the full signal to
 	 * class 1 of MAC #n is asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_FULL_1_XOFF_THRESHOLD_1 :
 	       BRB1_REG_FULL_1_XOFF_THRESHOLD_0,
 	       reg_th_config->full_xoff);
-	/*
-	 * The number of free blocks above which the full signal to
+	/* The number of free blocks above which the full signal to
 	 * class 1 of MAC #n is de-asserted. n=0,1
 	 */
 	REG_WR(bp, (port) ? BRB1_REG_FULL_1_XON_THRESHOLD_1 :
@@ -2373,49 +2316,41 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 		REG_WR(bp, BRB1_REG_PER_CLASS_GUARANTY_MODE,
 			   e3b0_val.per_class_guaranty_mode);
 
-		/*
-		 * The hysteresis on the guarantied buffer space for the Lb
+		/* The hysteresis on the guarantied buffer space for the Lb
 		 * port before signaling XON.
 		 */
 		REG_WR(bp, BRB1_REG_LB_GUARANTIED_HYST,
 			   e3b0_val.lb_guarantied_hyst);
 
-		/*
-		 * The number of free blocks below which the full signal to the
+		/* The number of free blocks below which the full signal to the
 		 * LB port is asserted.
 		 */
 		REG_WR(bp, BRB1_REG_FULL_LB_XOFF_THRESHOLD,
 		       e3b0_val.full_lb_xoff_th);
-		/*
-		 * The number of free blocks above which the full signal to the
+		/* The number of free blocks above which the full signal to the
 		 * LB port is de-asserted.
 		 */
 		REG_WR(bp, BRB1_REG_FULL_LB_XON_THRESHOLD,
 		       e3b0_val.full_lb_xon_threshold);
-		/*
-		 * The number of blocks guarantied for the MAC #n port. n=0,1
+		/* The number of blocks guarantied for the MAC #n port. n=0,1
 		 */
 
-		/* The number of blocks guarantied for the LB port.*/
+		/* The number of blocks guarantied for the LB port. */
 		REG_WR(bp, BRB1_REG_LB_GUARANTIED,
 		       e3b0_val.lb_guarantied);
 
-		/*
-		 * The number of blocks guarantied for the MAC #n port.
-		 */
+		/* The number of blocks guarantied for the MAC #n port. */
 		REG_WR(bp, BRB1_REG_MAC_GUARANTIED_0,
 		       2 * e3b0_val.mac_0_class_t_guarantied);
 		REG_WR(bp, BRB1_REG_MAC_GUARANTIED_1,
 		       2 * e3b0_val.mac_1_class_t_guarantied);
-		/*
-		 * The number of blocks guarantied for class #t in MAC0. t=0,1
+		/* The number of blocks guarantied for class #t in MAC0. t=0,1
 		 */
 		REG_WR(bp, BRB1_REG_MAC_0_CLASS_0_GUARANTIED,
 		       e3b0_val.mac_0_class_t_guarantied);
 		REG_WR(bp, BRB1_REG_MAC_0_CLASS_1_GUARANTIED,
 		       e3b0_val.mac_0_class_t_guarantied);
-		/*
-		 * The hysteresis on the guarantied buffer space for class in
+		/* The hysteresis on the guarantied buffer space for class in
 		 * MAC0.  t=0,1
 		 */
 		REG_WR(bp, BRB1_REG_MAC_0_CLASS_0_GUARANTIED_HYST,
@@ -2423,15 +2358,13 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 		REG_WR(bp, BRB1_REG_MAC_0_CLASS_1_GUARANTIED_HYST,
 		       e3b0_val.mac_0_class_t_guarantied_hyst);
 
-		/*
-		 * The number of blocks guarantied for class #t in MAC1.t=0,1
+		/* The number of blocks guarantied for class #t in MAC1.t=0,1
 		 */
 		REG_WR(bp, BRB1_REG_MAC_1_CLASS_0_GUARANTIED,
 		       e3b0_val.mac_1_class_t_guarantied);
 		REG_WR(bp, BRB1_REG_MAC_1_CLASS_1_GUARANTIED,
 		       e3b0_val.mac_1_class_t_guarantied);
-		/*
-		 * The hysteresis on the guarantied buffer space for class #t
+		/* The hysteresis on the guarantied buffer space for class #t
 		 * in MAC1.  t=0,1
 		 */
 		REG_WR(bp, BRB1_REG_MAC_1_CLASS_0_GUARANTIED_HYST,
@@ -2514,15 +2447,13 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 		FEATURE_CONFIG_PFC_ENABLED;
 	DP(NETIF_MSG_LINK, "updating pfc nig parameters\n");
 
-	/*
-	 * When NIG_LLH0_XCM_MASK_REG_LLHX_XCM_MASK_BCN bit is set
+	/* When NIG_LLH0_XCM_MASK_REG_LLHX_XCM_MASK_BCN bit is set
 	 * MAC control frames (that are not pause packets)
 	 * will be forwarded to the XCM.
 	 */
 	xcm_mask = REG_RD(bp, port ? NIG_REG_LLH1_XCM_MASK :
 			  NIG_REG_LLH0_XCM_MASK);
-	/*
-	 * nig params will override non PFC params, since it's possible to
+	/* NIG params will override non PFC params, since it's possible to
 	 * do transition from PFC to SAFC
 	 */
 	if (set_pfc) {
@@ -2542,7 +2473,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 			llfc_out_en = nig_params->llfc_out_en;
 			llfc_enable = nig_params->llfc_enable;
 			pause_enable = nig_params->pause_enable;
-		} else  /*defaul non PFC mode - PAUSE */
+		} else  /* Default non PFC mode - PAUSE */
 			pause_enable = 1;
 
 		xcm_mask |= (port ? NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN :
@@ -2602,8 +2533,7 @@ int bnx2x_update_pfc(struct link_params *params,
 		      struct link_vars *vars,
 		      struct bnx2x_nig_brb_pfc_port_params *pfc_params)
 {
-	/*
-	 * The PFC and pause are orthogonal to one another, meaning when
+	/* The PFC and pause are orthogonal to one another, meaning when
 	 * PFC is enabled, the pause are disabled, and when PFC is
 	 * disabled, pause are set according to the pause result.
 	 */
@@ -3142,7 +3072,6 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 			      EMAC_MDIO_STATUS_10MB);
 
 	/* address */
-
 	tmp = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
@@ -3331,8 +3260,7 @@ int bnx2x_phy_read(struct link_params *params, u8 phy_addr,
 		   u8 devad, u16 reg, u16 *ret_val)
 {
 	u8 phy_index;
-	/*
-	 * Probe for the phy according to the given phy_addr, and execute
+	/* Probe for the phy according to the given phy_addr, and execute
 	 * the read request on it
 	 */
 	for (phy_index = 0; phy_index < params->num_phys; phy_index++) {
@@ -3349,8 +3277,7 @@ int bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 		    u8 devad, u16 reg, u16 val)
 {
 	u8 phy_index;
-	/*
-	 * Probe for the phy according to the given phy_addr, and execute
+	/* Probe for the phy according to the given phy_addr, and execute
 	 * the write request on it
 	 */
 	for (phy_index = 0; phy_index < params->num_phys; phy_index++) {
@@ -3376,7 +3303,7 @@ static u8 bnx2x_get_warpcore_lane(struct bnx2x_phy *phy,
 	if (bnx2x_is_4_port_mode(bp)) {
 		u32 port_swap, port_swap_ovr;
 
-		/*figure out path swap value */
+		/* Figure out path swap value */
 		path_swap_ovr = REG_RD(bp, MISC_REG_FOUR_PORT_PATH_SWAP_OVWR);
 		if (path_swap_ovr & 0x1)
 			path_swap = (path_swap_ovr & 0x2);
@@ -3386,7 +3313,7 @@ static u8 bnx2x_get_warpcore_lane(struct bnx2x_phy *phy,
 		if (path_swap)
 			path = path ^ 1;
 
-		/*figure out port swap value */
+		/* Figure out port swap value */
 		port_swap_ovr = REG_RD(bp, MISC_REG_FOUR_PORT_PORT_SWAP_OVWR);
 		if (port_swap_ovr & 0x1)
 			port_swap = (port_swap_ovr & 0x2);
@@ -3399,7 +3326,7 @@ static u8 bnx2x_get_warpcore_lane(struct bnx2x_phy *phy,
 		lane = (port<<1) + path;
 	} else { /* two port mode - no port swap */
 
-		/*figure out path swap value */
+		/* Figure out path swap value */
 		path_swap_ovr =
 			REG_RD(bp, MISC_REG_TWO_PORT_PATH_SWAP_OVWR);
 		if (path_swap_ovr & 0x1) {
@@ -3431,8 +3358,7 @@ static void bnx2x_set_aer_mmd(struct link_params *params,
 
 	if (USES_WARPCORE(bp)) {
 		aer_val = bnx2x_get_warpcore_lane(phy, params);
-		/*
-		 * In Dual-lane mode, two lanes are joined together,
+		/* In Dual-lane mode, two lanes are joined together,
 		 * so in order to configure them, the AER broadcast method is
 		 * used here.
 		 * 0x200 is the broadcast address for lanes 0,1
@@ -3512,8 +3438,7 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
-	/**
-	 * resolve pause mode and advertisement Please refer to Table
+	/* Resolve pause mode and advertisement Please refer to Table
 	 * 28B-3 of the 802.3ab-1999 spec
 	 */
 
@@ -3636,6 +3561,7 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 		vars->link_status |= LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE;
 	if (pause_result & (1<<1))
 		vars->link_status |= LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE;
+
 }
 
 static void bnx2x_ext_phy_update_adv_fc(struct bnx2x_phy *phy,
@@ -3665,6 +3591,7 @@ static void bnx2x_ext_phy_update_adv_fc(struct bnx2x_phy *phy,
 	bnx2x_pause_resolve(vars, pause_result);
 
 }
+
 static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 				   struct link_params *params,
 				   struct link_vars *vars)
@@ -3770,9 +3697,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 
 	/* Advertise pause */
 	bnx2x_ext_phy_set_pause(params, phy, vars);
-
-	/*
-	 * Set KR Autoneg Work-Around flag for Warpcore version older than D108
+	/* Set KR Autoneg Work-Around flag for Warpcore version older than D108
 	 */
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 			MDIO_WC_REG_UC_INFO_B1_VERSION, &val16);
@@ -3780,7 +3705,6 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Enable AN KR work-around\n");
 		vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
 	}
-
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 			MDIO_WC_REG_DIGITAL5_MISC7, &val16);
 
@@ -3854,7 +3778,7 @@ static void bnx2x_warpcore_set_10G_KR(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 			 MDIO_WC_REG_IEEE0BLK_AUTONEGNP, 0xB);
 
-	/*Enable encoded forced speed */
+	/* Enable encoded forced speed */
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_SERDESDIGITAL_MISC2, 0x30);
 
@@ -4216,8 +4140,7 @@ static int bnx2x_get_mod_abs_int_cfg(struct bnx2x *bp,
 				PORT_HW_CFG_E3_MOD_ABS_MASK) >>
 				PORT_HW_CFG_E3_MOD_ABS_SHIFT;
 
-		/*
-		 * Should not happen. This function called upon interrupt
+		/* Should not happen. This function called upon interrupt
 		 * triggered by GPIO ( since EPIO can only generate interrupts
 		 * to MCP).
 		 * So if this function was called and none of the GPIOs was set,
@@ -4317,7 +4240,7 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 					"link up, rx_tx_asic_rst 0x%x\n",
 					vars->rx_tx_asic_rst);
 			} else {
-				/*reset the lane to see if link comes up.*/
+				/* Reset the lane to see if link comes up.*/
 				bnx2x_warpcore_reset_lane(bp, phy, 1);
 				bnx2x_warpcore_reset_lane(bp, phy, 0);
 
@@ -4338,7 +4261,6 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 	} /*params->rx_tx_asic_rst*/
 
 }
-
 static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 				       struct link_params *params,
 				       struct link_vars *vars)
@@ -4496,7 +4418,7 @@ static void bnx2x_warpcore_link_reset(struct bnx2x_phy *phy,
 	/* Update those 1-copy registers */
 	CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
 			  MDIO_AER_BLOCK_AER_REG, 0);
-		/* Enable 1G MDIO (1-copy) */
+	/* Enable 1G MDIO (1-copy) */
 	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
 			MDIO_WC_REG_XGXSBLK0_XGXSCONTROL,
 			&val16);
@@ -4575,43 +4497,43 @@ void bnx2x_sync_link(struct link_params *params,
 		vars->duplex = DUPLEX_FULL;
 		switch (vars->link_status &
 			LINK_STATUS_SPEED_AND_DUPLEX_MASK) {
-			case LINK_10THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_10TFD:
-				vars->line_speed = SPEED_10;
-				break;
+		case LINK_10THD:
+			vars->duplex = DUPLEX_HALF;
+			/* Fall thru */
+		case LINK_10TFD:
+			vars->line_speed = SPEED_10;
+			break;
 
-			case LINK_100TXHD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_100T4:
-			case LINK_100TXFD:
-				vars->line_speed = SPEED_100;
-				break;
+		case LINK_100TXHD:
+			vars->duplex = DUPLEX_HALF;
+			/* Fall thru */
+		case LINK_100T4:
+		case LINK_100TXFD:
+			vars->line_speed = SPEED_100;
+			break;
 
-			case LINK_1000THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_1000TFD:
-				vars->line_speed = SPEED_1000;
-				break;
+		case LINK_1000THD:
+			vars->duplex = DUPLEX_HALF;
+			/* Fall thru */
+		case LINK_1000TFD:
+			vars->line_speed = SPEED_1000;
+			break;
 
-			case LINK_2500THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_2500TFD:
-				vars->line_speed = SPEED_2500;
-				break;
+		case LINK_2500THD:
+			vars->duplex = DUPLEX_HALF;
+			/* Fall thru */
+		case LINK_2500TFD:
+			vars->line_speed = SPEED_2500;
+			break;
 
-			case LINK_10GTFD:
-				vars->line_speed = SPEED_10000;
-				break;
-			case LINK_20GTFD:
-				vars->line_speed = SPEED_20000;
-				break;
-			default:
-				break;
+		case LINK_10GTFD:
+			vars->line_speed = SPEED_10000;
+			break;
+		case LINK_20GTFD:
+			vars->line_speed = SPEED_20000;
+			break;
+		default:
+			break;
 		}
 		vars->flow_ctrl = 0;
 		if (vars->link_status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED)
@@ -4786,9 +4708,8 @@ static void bnx2x_set_swap_lanes(struct link_params *params,
 				 struct bnx2x_phy *phy)
 {
 	struct bnx2x *bp = params->bp;
-	/*
-	 *  Each two bits represents a lane number:
-	 *  No swap is 0123 => 0x1b no need to enable the swap
+	/* Each two bits represents a lane number:
+	 * No swap is 0123 => 0x1b no need to enable the swap
 	 */
 	u16 rx_lane_swap, tx_lane_swap;
 
@@ -5002,8 +4923,7 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 			  MDIO_REG_BANK_COMBO_IEEE0,
 			  MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
-	/*
-	 * program speed
+	/* Program speed
 	 *  - needed only if the speed is greater than 1G (2.5G or 10G)
 	 */
 	CL22_RD_OVER_CL45(bp, phy,
@@ -5038,8 +4958,6 @@ static void bnx2x_set_brcm_cl37_advertisement(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
 
-	/* configure the 48 bits for BAM AN */
-
 	/* set extended capabilities */
 	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
 		val |= MDIO_OVER_1G_UP1_2_5G;
@@ -5185,11 +5103,8 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 	}
 }
 
-
-/*
- * link management
+/* Link management
  */
-
 static int bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
 					     struct link_params *params)
 {
@@ -5334,8 +5249,7 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 			     "ustat_val(0x8371) = 0x%x\n", ustat_val);
 		return;
 	}
-	/*
-	 * Step 3: Check CL37 Message Pages received to indicate LP
+	/* Step 3: Check CL37 Message Pages received to indicate LP
 	 * supports only CL37
 	 */
 	CL22_RD_OVER_CL45(bp, phy,
@@ -5352,8 +5266,7 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 			 cl37_fsm_received);
 		return;
 	}
-	/*
-	 * The combined cl37/cl73 fsm state information indicating that
+	/* The combined cl37/cl73 fsm state information indicating that
 	 * we are connected to a device which does not support cl73, but
 	 * does support cl37 BAM. In this case we disable cl73 and
 	 * restart cl37 auto-neg
@@ -5924,8 +5837,7 @@ static void bnx2x_rearm_latch_signal(struct bnx2x *bp, u8 port,
 {
 	u32 latch_status = 0;
 
-	/*
-	 * Disable the MI INT ( external phy int ) by writing 1 to the
+	/* Disable the MI INT ( external phy int ) by writing 1 to the
 	 * status register. Link down indication is high-active-signal,
 	 * so in this case we need to write the status to clear the XOR
 	 */
@@ -5960,8 +5872,7 @@ static void bnx2x_link_int_ack(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 	u32 mask;
-	/*
-	 * First reset all status we assume only one line will be
+	/* First reset all status we assume only one line will be
 	 * change at a time
 	 */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
@@ -5975,8 +5886,7 @@ static void bnx2x_link_int_ack(struct link_params *params,
 			if (is_10g_plus)
 				mask = NIG_STATUS_XGXS0_LINK10G;
 			else if (params->switch_cfg == SWITCH_CFG_10G) {
-				/*
-				 * Disable the link interrupt by writing 1 to
+				/* Disable the link interrupt by writing 1 to
 				 * the relevant lane in the status register
 				 */
 				u32 ser_lane =
@@ -6176,8 +6086,7 @@ int bnx2x_set_led(struct link_params *params,
 		break;
 
 	case LED_MODE_OPER:
-		/*
-		 * For all other phys, OPER mode is same as ON, so in case
+		/* For all other phys, OPER mode is same as ON, so in case
 		 * link is down, do nothing
 		 */
 		if (!vars->link_up)
@@ -6188,9 +6097,7 @@ int bnx2x_set_led(struct link_params *params,
 			 (params->phy[EXT_PHY1].type ==
 			  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8722)) &&
 		    CHIP_IS_E2(bp) && params->num_phys == 2) {
-			/*
-			 * This is a work-around for E2+8727 Configurations
-			 */
+			/* This is a work-around for E2+8727 Configurations */
 			if (mode == LED_MODE_ON ||
 				speed == SPEED_10000){
 				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
@@ -6199,8 +6106,7 @@ int bnx2x_set_led(struct link_params *params,
 				tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
 				EMAC_WR(bp, EMAC_REG_EMAC_LED,
 					(tmp | EMAC_LED_OVERRIDE));
-				/*
-				 * return here without enabling traffic
+				/* Return here without enabling traffic
 				 * LED blink and setting rate in ON mode.
 				 * In oper mode, enabling LED blink
 				 * and setting rate is needed.
@@ -6209,8 +6115,7 @@ int bnx2x_set_led(struct link_params *params,
 					return rc;
 			}
 		} else if (SINGLE_MEDIA_DIRECT(params)) {
-			/*
-			 * This is a work-around for HW issue found when link
+			/* This is a work-around for HW issue found when link
 			 * is up in CL73
 			 */
 			if ((!CHIP_IS_E3(bp)) ||
@@ -6258,10 +6163,7 @@ int bnx2x_set_led(struct link_params *params,
 		     (speed == SPEED_1000) ||
 		     (speed == SPEED_100) ||
 		     (speed == SPEED_10))) {
-			/*
-			 * On Everest 1 Ax chip versions for speeds less than
-			 * 10G LED scheme is different
-			 */
+			/* For speeds less than 10G LED scheme is different */
 			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
 			       + port*4, 1);
 			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 +
@@ -6281,8 +6183,7 @@ int bnx2x_set_led(struct link_params *params,
 
 }
 
-/*
- * This function comes to reflect the actual link state read DIRECTLY from the
+/* This function comes to reflect the actual link state read DIRECTLY from the
  * HW
  */
 int bnx2x_test_link(struct link_params *params, struct link_vars *vars,
@@ -6370,16 +6271,14 @@ static int bnx2x_link_initialize(struct link_params *params,
 	int rc = 0;
 	u8 phy_index, non_ext_phy;
 	struct bnx2x *bp = params->bp;
-	/*
-	 * In case of external phy existence, the line speed would be the
+	/* In case of external phy existence, the line speed would be the
 	 * line speed linked up by the external phy. In case it is direct
 	 * only, then the line_speed during initialization will be
 	 * equal to the req_line_speed
 	 */
 	vars->line_speed = params->phy[INT_PHY].req_line_speed;
 
-	/*
-	 * Initialize the internal phy in case this is a direct board
+	/* Initialize the internal phy in case this is a direct board
 	 * (no external phys), or this board has external phy which requires
 	 * to first.
 	 */
@@ -6411,8 +6310,7 @@ static int bnx2x_link_initialize(struct link_params *params,
 	} else {
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			/*
-			 * No need to initialize second phy in case of first
+			/* No need to initialize second phy in case of first
 			 * phy only selection. In case of second phy, we do
 			 * need to initialize the first phy, since they are
 			 * connected.
@@ -6599,8 +6497,7 @@ static int bnx2x_update_link_up(struct link_params *params,
 	msleep(20);
 	return rc;
 }
-/*
- * The bnx2x_link_update function should be called upon link
+/* The bnx2x_link_update function should be called upon link
  * interrupt.
  * Link is considered up as follows:
  * - DIRECT_SINGLE_MEDIA - Only XGXS link (internal link) needs
@@ -6657,8 +6554,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	if (!CHIP_IS_E3(bp))
 		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
-	/*
-	 * Step 1:
+	/* Step 1:
 	 * Check external link change only for external phys, and apply
 	 * priority selection between them in case the link on both phys
 	 * is up. Note that instead of the common vars, a temporary
@@ -6689,23 +6585,20 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 			switch (bnx2x_phy_selection(params)) {
 			case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
 			case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
-			/*
-			 * In this option, the first PHY makes sure to pass the
+			/* In this option, the first PHY makes sure to pass the
 			 * traffic through itself only.
 			 * Its not clear how to reset the link on the second phy
 			 */
 				active_external_phy = EXT_PHY1;
 				break;
 			case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
-			/*
-			 * In this option, the first PHY makes sure to pass the
+			/* In this option, the first PHY makes sure to pass the
 			 * traffic through the second PHY.
 			 */
 				active_external_phy = EXT_PHY2;
 				break;
 			default:
-			/*
-			 * Link indication on both PHYs with the following cases
+			/* Link indication on both PHYs with the following cases
 			 * is invalid:
 			 * - FIRST_PHY means that second phy wasn't initialized,
 			 * hence its link is expected to be down
@@ -6722,8 +6615,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		}
 	}
 	prev_line_speed = vars->line_speed;
-	/*
-	 * Step 2:
+	/* Step 2:
 	 * Read the status of the internal phy. In case of
 	 * DIRECT_SINGLE_MEDIA board, this link is the external link,
 	 * otherwise this is the link between the 577xx and the first
@@ -6733,8 +6625,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		params->phy[INT_PHY].read_status(
 			&params->phy[INT_PHY],
 			params, vars);
-	/*
-	 * The INT_PHY flow control reside in the vars. This include the
+	/* The INT_PHY flow control reside in the vars. This include the
 	 * case where the speed or flow control are not set to AUTO.
 	 * Otherwise, the active external phy flow control result is set
 	 * to the vars. The ext_phy_line_speed is needed to check if the
@@ -6743,14 +6634,12 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	 */
 	if (active_external_phy > INT_PHY) {
 		vars->flow_ctrl = phy_vars[active_external_phy].flow_ctrl;
-		/*
-		 * Link speed is taken from the XGXS. AN and FC result from
+		/* Link speed is taken from the XGXS. AN and FC result from
 		 * the external phy.
 		 */
 		vars->link_status |= phy_vars[active_external_phy].link_status;
 
-		/*
-		 * if active_external_phy is first PHY and link is up - disable
+		/* if active_external_phy is first PHY and link is up - disable
 		 * disable TX on second external PHY
 		 */
 		if (active_external_phy == EXT_PHY1) {
@@ -6787,8 +6676,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	DP(NETIF_MSG_LINK, "vars->flow_ctrl = 0x%x, vars->link_status = 0x%x,"
 		   " ext_phy_line_speed = %d\n", vars->flow_ctrl,
 		   vars->link_status, ext_phy_line_speed);
-	/*
-	 * Upon link speed change set the NIG into drain mode. Comes to
+	/* Upon link speed change set the NIG into drain mode. Comes to
 	 * deals with possible FIFO glitch due to clk change when speed
 	 * is decreased without link down indicator
 	 */
@@ -6813,8 +6701,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_link_int_ack(params, vars, link_10g_plus);
 
-	/*
-	 * In case external phy link is up, and internal link is down
+	/* In case external phy link is up, and internal link is down
 	 * (not initialized yet probably after link initialization, it
 	 * needs to be initialized.
 	 * Note that after link down-up as result of cable plug, the xgxs
@@ -6842,8 +6729,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 						vars);
 		}
 	}
-	/*
-	 * Link is up only if both local phy and external phy (in case of
+	/* Link is up only if both local phy and external phy (in case of
 	 * non-direct board) are up and no fault detected on active PHY.
 	 */
 	vars->link_up = (vars->phy_link_up &&
@@ -7069,8 +6955,7 @@ static int bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 	}
 	/* XAUI workaround in 8073 A0: */
 
-	/*
-	 * After loading the boot ROM and restarting Autoneg, poll
+	/* After loading the boot ROM and restarting Autoneg, poll
 	 * Dev1, Reg $C820:
 	 */
 
@@ -7079,8 +6964,7 @@ static int bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
 				&val);
-		  /*
-		   * If bit [14] = 0 or bit [13] = 0, continue on with
+		  /* If bit [14] = 0 or bit [13] = 0, continue on with
 		   * system initialization (XAUI work-around not required, as
 		   * these bits indicate 2.5G or 1G link up).
 		   */
@@ -7089,8 +6973,7 @@ static int bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 			return 0;
 		} else if (!(val & (1<<15))) {
 			DP(NETIF_MSG_LINK, "bit 15 went off\n");
-			/*
-			 * If bit 15 is 0, then poll Dev1, Reg $C841 until it's
+			/* If bit 15 is 0, then poll Dev1, Reg $C841 until it's
 			 * MSB (bit15) goes to 1 (indicating that the XAUI
 			 * workaround has completed), then continue on with
 			 * system initialization.
@@ -7240,8 +7123,7 @@ static int bnx2x_8073_config_init(struct bnx2x_phy *phy,
 			val = (1<<7);
 		} else if (phy->req_line_speed ==  SPEED_2500) {
 			val = (1<<5);
-			/*
-			 * Note that 2.5G works only when used with 1G
+			/* Note that 2.5G works only when used with 1G
 			 * advertisement
 			 */
 		} else
@@ -7292,8 +7174,7 @@ static int bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	/* Add support for CL37 (passive mode) III */
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
 
-	/*
-	 * The SNR will improve about 2db by changing BW and FEE main
+	/* The SNR will improve about 2db by changing BW and FEE main
 	 * tap. Rest commands are executed after link is up
 	 * Change FFE main cursor to 5 in EDC register
 	 */
@@ -7380,8 +7261,7 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 
 	link_up = (((val1 & 4) == 4) || (an1000_status & (1<<1)));
 	if (link_up && bnx2x_8073_is_snr_needed(bp, phy)) {
-		/*
-		 * The SNR will improve about 2dbby changing the BW and FEE main
+		/* The SNR will improve about 2dbby changing the BW and FEE main
 		 * tap. The 1st write to change FFE main tap is set before
 		 * restart AN. Change PLL Bandwidth in EDC register
 		 */
@@ -7428,8 +7308,7 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 			bnx2x_cl45_read(bp, phy,
 					MDIO_XS_DEVAD,
 					MDIO_XS_REG_8073_RX_CTRL_PCIE, &val1);
-			/*
-			 * Set bit 3 to invert Rx in 1G mode and clear this bit
+			/* Set bit 3 to invert Rx in 1G mode and clear this bit
 			 * when it`s in 10G mode.
 			 */
 			if (vars->line_speed == SPEED_1000) {
@@ -7551,8 +7430,7 @@ static void bnx2x_set_disable_pmd_transmit(struct link_params *params,
 					   u8 pmd_dis)
 {
 	struct bnx2x *bp = params->bp;
-	/*
-	 * Disable transmitter only for bootcodes which can enable it afterwards
+	/* Disable transmitter only for bootcodes which can enable it afterwards
 	 * (for D3 link)
 	 */
 	if (pmd_dis) {
@@ -7729,9 +7607,6 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	u32 data_array[4];
 	u16 addr32;
 	struct bnx2x *bp = params->bp;
-	/*DP(NETIF_MSG_LINK, "bnx2x_direct_read_sfp_module_eeprom:"
-					" addr %d, cnt %d\n",
-					addr, byte_cnt);*/
 	if (byte_cnt > 16) {
 		DP(NETIF_MSG_LINK,
 		   "Reading from eeprom is limited to 16 bytes\n");
@@ -7796,8 +7671,7 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
 			 0x8002);
-	/*
-	 * Wait appropriate time for two-wire command to finish before
+	/* Wait appropriate time for two-wire command to finish before
 	 * polling the status register
 	 */
 	msleep(1);
@@ -7890,8 +7764,7 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	{
 		u8 copper_module_type;
 		phy->media_type = ETH_PHY_DA_TWINAX;
-		/*
-		 * Check if its active cable (includes SFP+ module)
+		/* Check if its active cable (includes SFP+ module)
 		 * of passive cable
 		 */
 		if (bnx2x_read_sfp_module_eeprom(phy,
@@ -7968,8 +7841,7 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "EDC mode is set to 0x%x\n", *edc_mode);
 	return 0;
 }
-/*
- * This function read the relevant field from the module (SFP+), and verify it
+/* This function read the relevant field from the module (SFP+), and verify it
  * is compliant with this board
  */
 static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
@@ -8049,8 +7921,7 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 	u8 val;
 	struct bnx2x *bp = params->bp;
 	u16 timeout;
-	/*
-	 * Initialization time after hot-plug may take up to 300ms for
+	/* Initialization time after hot-plug may take up to 300ms for
 	 * some phys type ( e.g. JDSU )
 	 */
 
@@ -8072,8 +7943,7 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 				    u8 is_power_up) {
 	/* Make sure GPIOs are not using for LED mode */
 	u16 val;
-	/*
-	 * In the GPIO register, bit 4 is use to determine if the GPIOs are
+	/* In the GPIO register, bit 4 is use to determine if the GPIOs are
 	 * operating as INPUT or as OUTPUT. Bit 1 is for input, and 0 for
 	 * output
 	 * Bits 0-1 determine the GPIOs value for OUTPUT in case bit 4 val is 0
@@ -8089,8 +7959,7 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 	if (is_power_up)
 		val = (1<<4);
 	else
-		/*
-		 * Set GPIO control to OUTPUT, and set the power bit
+		/* Set GPIO control to OUTPUT, and set the power bit
 		 * to according to the is_power_up
 		 */
 		val = (1<<1);
@@ -8124,8 +7993,7 @@ static int bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 
 		DP(NETIF_MSG_LINK, "Setting LRM MODE\n");
 
-		/*
-		 * Changing to LRM mode takes quite few seconds. So do it only
+		/* Changing to LRM mode takes quite few seconds. So do it only
 		 * if current mode is limiting (default is LRM)
 		 */
 		if (cur_limiting_mode != EDC_MODE_LIMITING)
@@ -8260,8 +8128,7 @@ static void bnx2x_set_sfp_module_fault_led(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "Setting SFP+ module fault LED to %d\n", gpio_mode);
 	if (CHIP_IS_E3(bp)) {
-		/*
-		 * Low ==> if SFP+ module is supported otherwise
+		/* Low ==> if SFP+ module is supported otherwise
 		 * High ==> if SFP+ module is not on the approved vendor list
 		 */
 		bnx2x_set_e3_module_fault_led(params, gpio_mode);
@@ -8286,8 +8153,7 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 		return;
 	DP(NETIF_MSG_LINK, "Setting SFP+ module power to %d using pin cfg %d\n",
 		       power, pin_cfg);
-	/*
-	 * Low ==> corresponding SFP+ module is powered
+	/* Low ==> corresponding SFP+ module is powered
 	 * high ==> the SFP+ module is powered down
 	 */
 	bnx2x_set_cfg_pin(bp, pin_cfg, power ^ 1);
@@ -8421,14 +8287,12 @@ int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 		bnx2x_set_sfp_module_fault_led(params, MISC_REGISTERS_GPIO_LOW);
 	}
 
-	/*
-	 * Check and set limiting mode / LRM mode on 8726. On 8727 it
+	/* Check and set limiting mode / LRM mode on 8726. On 8727 it
 	 * is done automatically
 	 */
 	bnx2x_set_limiting_mode(params, phy, edc_mode);
 
-	/*
-	 * Enable transmit for this module if the module is approved, or
+	/* Enable transmit for this module if the module is approved, or
 	 * if unapproved modules should also enable the Tx laser
 	 */
 	if (rc == 0 ||
@@ -8483,8 +8347,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		bnx2x_set_gpio_int(bp, gpio_num,
 				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
 				   gpio_port);
-		/*
-		 * Module was plugged out.
+		/* Module was plugged out.
 		 * Disable transmit for this module
 		 */
 		phy->media_type = ETH_PHY_NOT_PRESENT;
@@ -8554,8 +8417,7 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x pcs_status 0x%x 1Gbps"
 			" link_status 0x%x\n", rx_sd, pcs_status, val2);
-	/*
-	 * link is up if both bit 0 of pmd_rx_sd and bit 0 of pcs_status
+	/* Link is up if both bit 0 of pmd_rx_sd and bit 0 of pcs_status
 	 * are set, or if the autoneg bit 1 is set
 	 */
 	link_up = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
@@ -8669,8 +8531,7 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	}
 	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
 
-	/*
-	 * If TX Laser is controlled by GPIO_0, do not let PHY go into low
+	/* If TX Laser is controlled by GPIO_0, do not let PHY go into low
 	 * power mode, if TX Laser is disabled
 	 */
 
@@ -8780,8 +8641,7 @@ static int bnx2x_8726_config_init(struct bnx2x_phy *phy,
 
 	bnx2x_8726_external_rom_boot(phy, params);
 
-	/*
-	 * Need to call module detected on initialization since the module
+	/* Need to call module detected on initialization since the module
 	 * detection triggered by actual module insertion might occur before
 	 * driver is loaded, and when driver is loaded, it reset all
 	 * registers, including the transmitter
@@ -8818,8 +8678,7 @@ static int bnx2x_8726_config_init(struct bnx2x_phy *phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
 		bnx2x_cl45_write(bp, phy,
 				MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
-		/*
-		 * Enable RX-ALARM control to receive interrupt for 1G speed
+		/* Enable RX-ALARM control to receive interrupt for 1G speed
 		 * change
 		 */
 		bnx2x_cl45_write(bp, phy,
@@ -8920,8 +8779,7 @@ static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
 				struct link_params *params) {
 	u32 swap_val, swap_override;
 	u8 port;
-	/*
-	 * The PHY reset is controlled by GPIO 1. Fake the port number
+	/* The PHY reset is controlled by GPIO 1. Fake the port number
 	 * to cancel the swap done in set_gpio()
 	 */
 	struct bnx2x *bp = params->bp;
@@ -8959,14 +8817,12 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_CTRL, lasi_ctrl_val);
 
-	/*
-	 * Initially configure MOD_ABS to interrupt when module is
+	/* Initially configure MOD_ABS to interrupt when module is
 	 * presence( bit 8)
 	 */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
-	/*
-	 * Set EDC off by setting OPTXLOS signal input to low (bit 9).
+	/* Set EDC off by setting OPTXLOS signal input to low (bit 9).
 	 * When the EDC is off it locks onto a reference clock and avoids
 	 * becoming 'lost'
 	 */
@@ -8987,8 +8843,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	if (phy->flags & FLAGS_NOC)
 		val |= (3<<5);
 
-	/*
-	 * Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
+	/* Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
 	 * status which reflect SFP+ module over-current
 	 */
 	if (!(phy->flags & FLAGS_NOC))
@@ -9014,8 +8869,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, &tmp1);
 		DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
-		/*
-		 * Power down the XAUI until link is up in case of dual-media
+		/* Power down the XAUI until link is up in case of dual-media
 		 * and 1G
 		 */
 		if (DUAL_MEDIA(params)) {
@@ -9040,8 +8894,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1300);
 	} else {
-		/*
-		 * Since the 8727 has only single reset pin, need to set the 10G
+		/* Since the 8727 has only single reset pin, need to set the 10G
 		 * registers although it is default
 		 */
 		bnx2x_cl45_write(bp, phy,
@@ -9056,8 +8909,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 0x0008);
 	}
 
-	/*
-	 * Set 2-wire transfer rate of SFP+ module EEPROM
+	/* Set 2-wire transfer rate of SFP+ module EEPROM
 	 * to 100Khz since some DACs(direct attached cables) do
 	 * not work at 400Khz.
 	 */
@@ -9080,8 +8932,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 phy->tx_preemphasis[1]);
 	}
 
-	/*
-	 * If TX Laser is controlled by GPIO_0, do not let PHY go into low
+	/* If TX Laser is controlled by GPIO_0, do not let PHY go into low
 	 * power mode, if TX Laser is disabled
 	 */
 	tx_en_mode = REG_RD(bp, params->shmem_base +
@@ -9121,8 +8972,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK,
 		   "MOD_ABS indication show module is absent\n");
 		phy->media_type = ETH_PHY_NOT_PRESENT;
-		/*
-		 * 1. Set mod_abs to detect next module
+		/* 1. Set mod_abs to detect next module
 		 *    presence event
 		 * 2. Set EDC off by setting OPTXLOS signal input to low
 		 *    (bit 9).
@@ -9136,8 +8986,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-		/*
-		 * Clear RX alarm since it stays up as long as
+		/* Clear RX alarm since it stays up as long as
 		 * the mod_abs wasn't changed
 		 */
 		bnx2x_cl45_read(bp, phy,
@@ -9148,8 +8997,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		/* Module is present */
 		DP(NETIF_MSG_LINK,
 		   "MOD_ABS indication show module is present\n");
-		/*
-		 * First disable transmitter, and if the module is ok, the
+		/* First disable transmitter, and if the module is ok, the
 		 * module_detection will enable it
 		 * 1. Set mod_abs to detect next module absent event ( bit 8)
 		 * 2. Restore the default polarity of the OPRXLOS signal and
@@ -9163,8 +9011,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-		/*
-		 * Clear RX alarm since it stays up as long as the mod_abs
+		/* Clear RX alarm since it stays up as long as the mod_abs
 		 * wasn't changed. This is need to be done before calling the
 		 * module detection, otherwise it will clear* the link update
 		 * alarm
@@ -9225,8 +9072,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
 
-	/*
-	 * If a module is present and there is need to check
+	/* If a module is present and there is need to check
 	 * for over current
 	 */
 	if (!(phy->flags & FLAGS_NOC) && !(rx_alarm_status & (1<<5))) {
@@ -9292,8 +9138,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 			MDIO_PMA_DEVAD,
 			MDIO_PMA_REG_8073_SPEED_LINK_STATUS, &link_status);
 
-	/*
-	 * Bits 0..2 --> speed detected,
+	/* Bits 0..2 --> speed detected,
 	 * Bits 13..15--> link is down
 	 */
 	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
@@ -9336,8 +9181,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_8727_PCS_GP, &val1);
-		/*
-		 * In case of dual-media board and 1G, power up the XAUI side,
+		/* In case of dual-media board and 1G, power up the XAUI side,
 		 * otherwise power it down. For 10G it is done automatically
 		 */
 		if (link_up)
@@ -9504,8 +9348,7 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 		/* Save spirom version */
 		bnx2x_save_848xx_spirom_version(phy, bp, params->port);
 	}
-	/*
-	 * This phy uses the NIG latch mechanism since link indication
+	/* This phy uses the NIG latch mechanism since link indication
 	 * arrives through its LED4 and not via its LASI signal, so we
 	 * get steady signal instead of clear on read
 	 */
@@ -9610,8 +9453,7 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	if (phy->req_duplex == DUPLEX_FULL)
 		autoneg_val |= (1<<8);
 
-	/*
-	 * Always write this if this is not 84833.
+	/* Always write this if this is not 84833.
 	 * For 84833, write it only when it's a forced speed.
 	 */
 	if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
@@ -9850,8 +9692,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	/* Wait for GPHY to come out of reset */
 	msleep(50);
 	if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
-		/*
-		 * BCM84823 requires that XGXS links up first @ 10G for normal
+		/* BCM84823 requires that XGXS links up first @ 10G for normal
 		 * behavior.
 		 */
 		u16 temp;
@@ -10327,8 +10168,7 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 		break;
 	}
 
-	/*
-	 * This is a workaround for E3+84833 until autoneg
+	/* This is a workaround for E3+84833 until autoneg
 	 * restart is fixed in f/w
 	 */
 	if (CHIP_IS_E3(bp)) {
@@ -10352,8 +10192,7 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "54618SE cfg init\n");
 	usleep_range(1000, 1000);
 
-	/*
-	 * This works with E3 only, no need to check the chip
+	/* This works with E3 only, no need to check the chip
 	 * before determining the port.
 	 */
 	port = params->port;
@@ -10375,7 +10214,7 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 			 MDIO_PMA_REG_CTRL, 0x8000);
 	bnx2x_wait_reset_complete(bp, phy, params);
 
-	/*wait for GPHY to reset */
+	/* Wait for GPHY to reset */
 	msleep(50);
 
 	/* Configure LED4: set to INTR (0x6). */
@@ -10581,13 +10420,11 @@ static void bnx2x_54618se_link_reset(struct bnx2x_phy *phy,
 	u32 cfg_pin;
 	u8 port;
 
-	/*
-	 * In case of no EPIO routed to reset the GPHY, put it
+	/* In case of no EPIO routed to reset the GPHY, put it
 	 * in low power mode.
 	 */
 	bnx2x_cl22_write(bp, phy, MDIO_PMA_REG_CTRL, 0x800);
-	/*
-	 * This works with E3 only, no need to check the chip
+	/* This works with E3 only, no need to check the chip
 	 * before determining the port.
 	 */
 	port = params->port;
@@ -10696,7 +10533,7 @@ static u8 bnx2x_54618se_read_status(struct bnx2x_phy *phy,
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 
 		if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
-			/* report LP advertised speeds */
+			/* Report LP advertised speeds */
 			bnx2x_cl22_read(bp, phy, 0x5, &val);
 
 			if (val & (1<<5))
@@ -10761,8 +10598,7 @@ static void bnx2x_54618se_config_loopback(struct bnx2x_phy *phy,
 	/* This register opens the gate for the UMAC despite its name */
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + params->port*4, 1);
 
-	/*
-	 * Maximum Frame Length (RW). Defines a 14-Bit maximum frame
+	/* Maximum Frame Length (RW). Defines a 14-Bit maximum frame
 	 * length used by the MAC receive logic to check frames.
 	 */
 	REG_WR(bp, umac_base + UMAC_REG_MAXFR, 0x2710);
@@ -11041,17 +10877,17 @@ static struct bnx2x_phy phy_warpcore = {
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
 	.supported	= (SUPPORTED_10baseT_Half |
-			     SUPPORTED_10baseT_Full |
-			     SUPPORTED_100baseT_Half |
-			     SUPPORTED_100baseT_Full |
-			     SUPPORTED_1000baseT_Full |
-			     SUPPORTED_10000baseT_Full |
-			     SUPPORTED_20000baseKR2_Full |
-			     SUPPORTED_20000baseMLD2_Full |
-			     SUPPORTED_FIBRE |
-			     SUPPORTED_Autoneg |
-			     SUPPORTED_Pause |
-			     SUPPORTED_Asym_Pause),
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_20000baseKR2_Full |
+			   SUPPORTED_20000baseMLD2_Full |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
 	.media_type	= ETH_PHY_UNSPECIFIED,
 	.ver_addr	= 0,
 	.req_flow_ctrl	= 0,
@@ -11405,9 +11241,8 @@ static void bnx2x_populate_preemphasis(struct bnx2x *bp, u32 shmem_base,
 	/* Get the 4 lanes xgxs config rx and tx */
 	u32 rx = 0, tx = 0, i;
 	for (i = 0; i < 2; i++) {
-		/*
-		 * INT_PHY and EXT_PHY1 share the same value location in the
-		 * shmem. When num_phys is greater than 1, than this value
+		/* INT_PHY and EXT_PHY1 share the same value location in
+		 * the shmem. When num_phys is greater than 1, than this value
 		 * applies only to EXT_PHY1
 		 */
 		if (phy_index == INT_PHY || phy_index == EXT_PHY1) {
@@ -11485,8 +11320,7 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 					offsetof(struct shmem_region, dev_info.
 					port_hw_config[port].default_cfg)) &
 				 PORT_HW_CFG_NET_SERDES_IF_MASK);
-		/*
-		 * Set the appropriate supported and flags indications per
+		/* Set the appropriate supported and flags indications per
 		 * interface type of the chip
 		 */
 		switch (serdes_net_if) {
@@ -11544,8 +11378,7 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 			break;
 		}
 
-		/*
-		 * Enable MDC/MDIO work-around for E3 A0 since free running MDC
+		/* Enable MDC/MDIO work-around for E3 A0 since free running MDC
 		 * was not set as expected. For B0, ECO will be enabled so there
 		 * won't be an issue there
 		 */
@@ -11658,8 +11491,7 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
 	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, phy_index);
 
-	/*
-	 * The shmem address of the phy version is located on different
+	/* The shmem address of the phy version is located on different
 	 * structures. In case this structure is too old, do not set
 	 * the address
 	 */
@@ -11693,8 +11525,7 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 
 	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) &&
 	    (phy->ver_addr)) {
-		/*
-		 * Remove 100Mb link supported for BCM84833 when phy fw
+		/* Remove 100Mb link supported for BCM84833 when phy fw
 		 * version lower than or equal to 1.39
 		 */
 		u32 raw_ver = REG_RD(bp, phy->ver_addr);
@@ -11704,8 +11535,7 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 					    SUPPORTED_100baseT_Full);
 	}
 
-	/*
-	 * In case mdc/mdio_access of the external phy is different than the
+	/* In case mdc/mdio_access of the external phy is different than the
 	 * mdc/mdio access of the XGXS, a HW lock must be taken in each access
 	 * to prevent one port interfere with another port's CL45 operations.
 	 */
@@ -11884,8 +11714,7 @@ int bnx2x_phy_probe(struct link_params *params)
 			dev_info.port_hw_config[params->port].media_type);
 		media_types = REG_RD(bp, sync_offset);
 
-		/*
-		 * Update media type for non-PMF sync only for the first time
+		/* Update media type for non-PMF sync only for the first time
 		 * In case the media type changes afterwards, it will be updated
 		 * using the update_status function
 		 */
@@ -11959,8 +11788,7 @@ void bnx2x_init_xmac_loopback(struct link_params *params,
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 	vars->mac_type = MAC_TYPE_XMAC;
 	vars->phy_flags = PHY_XGXS_FLAG;
-	/*
-	 * Set WC to loopback mode since link is required to provide clock
+	/* Set WC to loopback mode since link is required to provide clock
 	 * to the XMAC in 20G mode
 	 */
 	bnx2x_set_aer_mmd(params, &params->phy[0]);
@@ -12243,7 +12071,8 @@ static int bnx2x_8073_common_init_phy(struct bnx2x *bp,
 				NIG_MASK_MI_INT));
 
 		/* Need to take the phy out of low power mode in order
-			to write to access its registers */
+		 * to write to access its registers
+		 */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 			       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 			       port);
@@ -12291,8 +12120,7 @@ static int bnx2x_8073_common_init_phy(struct bnx2x *bp,
 				 (val | 1<<10));
 	}
 
-	/*
-	 * Toggle Transmitter: Power down and then up with 600ms delay
+	/* Toggle Transmitter: Power down and then up with 600ms delay
 	 * between
 	 */
 	msleep(600);
@@ -12435,8 +12263,7 @@ static int bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	reset_gpio = MISC_REGISTERS_GPIO_1;
 	port = 1;
 
-	/*
-	 * Retrieve the reset gpio/port which control the reset.
+	/* Retrieve the reset gpio/port which control the reset.
 	 * Default is GPIO1, PORT1
 	 */
 	bnx2x_get_ext_phy_reset_gpio(bp, shmem_base_path[0],
@@ -12611,8 +12438,7 @@ static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		/*
-		 * GPIO1 affects both ports, so there's need to pull
+		/* GPIO1 affects both ports, so there's need to pull
 		 * it for single port alone
 		 */
 		rc = bnx2x_8726_common_init_phy(bp, shmem_base_path,
@@ -12620,8 +12446,7 @@ static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 						phy_index, chip_id);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
-		/*
-		 * GPIO3's are linked, and so both need to be toggled
+		/* GPIO3's are linked, and so both need to be toggled
 		 * to obtain required 2us pulse.
 		 */
 		rc = bnx2x_84833_common_init_phy(bp, shmem_base_path,
@@ -12735,8 +12560,7 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 	DP(NETIF_MSG_LINK, "Link changed:%x %x->%x\n", vars->link_up,
 		       half_open_conn, lss_status);
 
-	/*
-	 * a. Update shmem->link_status accordingly
+	/* a. Update shmem->link_status accordingly
 	 * b. Update link_vars->link_up
 	 */
 	if (lss_status) {
@@ -12747,8 +12571,7 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 
 		/* activate nig drain */
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 1);
-		/*
-		 * Set LED mode to off since the PHY doesn't know about these
+		/* Set LED mode to off since the PHY doesn't know about these
 		 * errors
 		 */
 		led_mode = LED_MODE_OFF;
@@ -12800,8 +12623,7 @@ int bnx2x_check_half_open_conn(struct link_params *params,
 	    (REG_RD(bp, MISC_REG_RESET_REG_2) &
 	      (MISC_REGISTERS_RESET_REG_2_XMAC))) {
 		/* Check E3 XMAC */
-		/*
-		 * Note that link speed cannot be queried here, since it may be
+		/* Note that link speed cannot be queried here, since it may be
 		 * zero while link is down. In case UMAC is active, LSS will
 		 * simply not be set
 		 */
-- 
1.7.9.rc2
