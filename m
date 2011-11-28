From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next v2 9/9] bnx2x: Change value comparison order
Date: Mon, 28 Nov 2011 12:49:53 +0200
Message-ID: <1322477393-22904-10-git-send-email-yanivr@broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2519 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140Ab1K1Iu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 03:50:59 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change comparison order such that the variable will come before the compared value.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   46 +++++++++++-----------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index d745054..4df9505 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -466,7 +466,7 @@ static u32 bnx2x_ets_get_min_w_val_nig(const struct link_vars *vars)
 	u32 min_w_val = 0;
 	/* Calculate min_w_val.*/
 	if (vars->link_up) {
-		if (SPEED_20000 == vars->line_speed)
+		if (vars->line_speed == SPEED_20000)
 			min_w_val = ETS_E3B0_NIG_MIN_W_VAL_20GBPS;
 		else
 			min_w_val = ETS_E3B0_NIG_MIN_W_VAL_UP_TO_10GBPS;
@@ -516,7 +516,7 @@ static void bnx2x_ets_e3b0_set_credit_upper_bound_nig(
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_CREDIT_UPPER_BOUND_5 :
 		   NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_5, credit_upper_bound);
 
-	if (0 == port) {
+	if (!port) {
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_6,
 			credit_upper_bound);
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_UPPER_BOUND_7,
@@ -610,7 +610,7 @@ static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
 		   NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_4, 0x0);
 	REG_WR(bp, (port) ? NIG_REG_P1_TX_ARB_CREDIT_WEIGHT_5 :
 		   NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_5, 0x0);
-	if (0 == port) {
+	if (!port) {
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_6, 0x0);
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_7, 0x0);
 		REG_WR(bp, NIG_REG_P0_TX_ARB_CREDIT_WEIGHT_8, 0x0);
@@ -638,7 +638,7 @@ static void bnx2x_ets_e3b0_set_credit_upper_bound_pbf(
 	* In 2 port mode port0 has COS0-5 that can be used for WFQ.In 4
 	* port mode port1 has COS0-2 that can be used for WFQ.
 	*/
-	if (0 == port) {
+	if (!port) {
 		base_upper_bound = PBF_REG_COS0_UPPER_BOUND_P0;
 		max_cos = DCBX_E3B0_MAX_NUM_COS_PORT0;
 	} else {
@@ -700,7 +700,7 @@ static void bnx2x_ets_e3b0_pbf_disabled(const struct link_params *params)
 	* In 2 port mode port0 has COS0-5 that can be used for WFQ.
 	* In 4 port mode port1 has COS0-2 that can be used for WFQ.
 	*/
-	if (0 == port) {
+	if (!port) {
 		base_weight = PBF_REG_COS0_WEIGHT_P0;
 		max_cos = DCBX_E3B0_MAX_NUM_COS_PORT0;
 	} else {
@@ -883,7 +883,7 @@ static int bnx2x_ets_e3b0_get_total_bw(
 
 	/* Calculate total BW requested */
 	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
-		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
+		if (ets_params->cos[cos_idx].state == bnx2x_cos_state_bw) {
 			is_bw_cos_exist = 1;
 			if (!ets_params->cos[cos_idx].params.bw_params.bw) {
 				DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config BW"
@@ -901,8 +901,8 @@ static int bnx2x_ets_e3b0_get_total_bw(
 	}
 
 	/* Check total BW is valid */
-	if ((1 == is_bw_cos_exist) && (100 != *total_bw)) {
-		if (0 == *total_bw) {
+	if ((is_bw_cos_exist == 1) && (*total_bw != 100)) {
+		if (*total_bw == 0) {
 			DP(NETIF_MSG_LINK,
 			   "bnx2x_ets_E3B0_config total BW shouldn't be 0\n");
 			return -EINVAL;
@@ -943,7 +943,7 @@ static int bnx2x_ets_e3b0_sp_pri_to_cos_set(const struct link_params *params,
 	const u8 max_num_of_cos = (port) ? DCBX_E3B0_MAX_NUM_COS_PORT1 :
 		DCBX_E3B0_MAX_NUM_COS_PORT0;
 
-	if (DCBX_INVALID_COS != sp_pri_to_cos[pri]) {
+	if (sp_pri_to_cos[pri] != DCBX_INVALID_COS) {
 		DP(NETIF_MSG_LINK, "bnx2x_ets_e3b0_sp_pri_to_cos_set invalid "
 				   "parameter There can't be two COS's with "
 				   "the same strict pri\n");
@@ -1034,8 +1034,8 @@ static int bnx2x_ets_e3b0_sp_set_pri_cli_reg(const struct link_params *params,
 
 	/* Set all the strict priority first */
 	for (i = 0; i < max_num_of_cos; i++) {
-		if (DCBX_INVALID_COS != sp_pri_to_cos[i]) {
-			if (DCBX_MAX_NUM_COS <= sp_pri_to_cos[i]) {
+		if (sp_pri_to_cos[i] != DCBX_INVALID_COS) {
+			if (sp_pri_to_cos[i] >= DCBX_MAX_NUM_COS) {
 				DP(NETIF_MSG_LINK,
 					   "bnx2x_ets_e3b0_sp_set_pri_cli_reg "
 					   "invalid cos entry\n");
@@ -1049,7 +1049,7 @@ static int bnx2x_ets_e3b0_sp_set_pri_cli_reg(const struct link_params *params,
 			    sp_pri_to_cos[i], pri_set);
 			pri_bitmask = 1 << sp_pri_to_cos[i];
 			/* COS is used remove it from bitmap.*/
-			if (0 == (pri_bitmask & cos_bit_to_set)) {
+			if (!(pri_bitmask & cos_bit_to_set)) {
 				DP(NETIF_MSG_LINK,
 					"bnx2x_ets_e3b0_sp_set_pri_cli_reg "
 					"invalid There can't be two COS's with"
@@ -1144,7 +1144,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 	/* Prepare BW parameters*/
 	bnx2x_status = bnx2x_ets_e3b0_get_total_bw(params, ets_params,
 						   &total_bw);
-	if (0 != bnx2x_status) {
+	if (bnx2x_status) {
 		DP(NETIF_MSG_LINK,
 		   "bnx2x_ets_E3B0_config get_total_bw failed\n");
 		return -EINVAL;
@@ -1185,7 +1185,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 			   "bnx2x_ets_e3b0_config cos state not valid\n");
 			return -EINVAL;
 		}
-		if (0 != bnx2x_status) {
+		if (bnx2x_status) {
 			DP(NETIF_MSG_LINK,
 			   "bnx2x_ets_e3b0_config set cos bw failed\n");
 			return bnx2x_status;
@@ -1196,7 +1196,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 	bnx2x_status = bnx2x_ets_e3b0_sp_set_pri_cli_reg(params,
 							 sp_pri_to_cos);
 
-	if (0 != bnx2x_status) {
+	if (bnx2x_status) {
 		DP(NETIF_MSG_LINK,
 		   "bnx2x_ets_E3B0_config set_pri_cli_reg failed\n");
 		return bnx2x_status;
@@ -1207,7 +1207,7 @@ int bnx2x_ets_e3b0_config(const struct link_params *params,
 					      cos_sp_bitmap,
 					      cos_bw_bitmap);
 
-	if (0 != bnx2x_status) {
+	if (bnx2x_status) {
 		DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config SP failed\n");
 		return bnx2x_status;
 	}
@@ -1271,9 +1271,9 @@ void bnx2x_ets_bw_limit(const struct link_params *params, const u32 cos0_bw,
 
 	DP(NETIF_MSG_LINK, "ETS enabled BW limit configuration\n");
 
-	if ((0 == total_bw) ||
-	    (0 == cos0_bw) ||
-	    (0 == cos1_bw)) {
+	if ((!total_bw) ||
+	    (!cos0_bw) ||
+	    (!cos1_bw)) {
 		DP(NETIF_MSG_LINK, "Total BW can't be zero\n");
 		return;
 	}
@@ -1329,7 +1329,7 @@ int bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
 	 * dbg0-010     dbg1-001     cos1-100     cos0-011     MCP-000
 	 * dbg0-010     dbg1-001     cos0-011     cos1-100     MCP-000
 	 */
-	val = (0 == strict_cos) ? 0x2318 : 0x22E0;
+	val = (!strict_cos) ? 0x2318 : 0x22E0;
 	REG_WR(bp, NIG_REG_P0_TX_ARB_PRIORITY_CLIENT, val);
 
 	return 0;
@@ -1439,7 +1439,7 @@ void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 	if (!vars->link_up)
 		return;
 
-	if (MAC_TYPE_EMAC == vars->mac_type) {
+	if (vars->mac_type == MAC_TYPE_EMAC) {
 		DP(NETIF_MSG_LINK, "About to read PFC stats from EMAC\n");
 		bnx2x_emac_get_pfc_stat(params, pfc_frames_sent,
 					pfc_frames_received);
@@ -2285,7 +2285,7 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 	/* default - pause configuration */
 	reg_th_config = &config_val.pauseable_th;
 	bnx2x_status = bnx2x_pfc_brb_get_config_params(params, &config_val);
-	if (0 != bnx2x_status)
+	if (bnx2x_status)
 		return bnx2x_status;
 
 	if (pfc_enabled) {
@@ -2619,7 +2619,7 @@ int bnx2x_update_pfc(struct link_params *params,
 
 	/* update BRB params */
 	bnx2x_status = bnx2x_update_pfc_brb(params, vars, pfc_params);
-	if (0 != bnx2x_status)
+	if (bnx2x_status)
 		return bnx2x_status;
 
 	if (!vars->link_up)
-- 
1.7.7.1
