From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 3/5] qed: Add additional DCBx debug messages.
Date: Thu, 20 Apr 2017 22:31:18 -0700
Message-ID: <20170421053120.12980-4-sudarsana.kalluru@cavium.com>
References: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0049.outbound.protection.outlook.com ([104.47.36.49]:24925
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035352AbdDUFcA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:32:00 -0400
In-Reply-To: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index d868b7e..507b79d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -556,8 +556,9 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 	p_params->pfc.prio[7] = !!(pfc_map & DCBX_PFC_PRI_EN_BITMAP_PRI_7);
 
 	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
-		   "PFC params: willing %d, pfc_bitmap %d\n",
-		   p_params->pfc.willing, pfc_map);
+		   "PFC params: willing %d, pfc_bitmap %u max_tc = %u enabled = %d\n",
+		   p_params->pfc.willing, pfc_map, p_params->pfc.max_tc,
+		   p_params->pfc.enabled);
 }
 
 static void
@@ -576,10 +577,10 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 	p_params->max_ets_tc = QED_MFW_GET_FIELD(p_ets->flags,
 						 DCBX_ETS_MAX_TCS);
 	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
-		   "ETS params: willing %d, ets_cbs %d pri_tc_tbl_0 %x max_ets_tc %d\n",
-		   p_params->ets_willing,
-		   p_params->ets_cbs,
-		   p_ets->pri_tc_tbl[0], p_params->max_ets_tc);
+		   "ETS params: willing %d, enabled = %d ets_cbs %d pri_tc_tbl_0 %x max_ets_tc %d\n",
+		   p_params->ets_willing, p_params->ets_enabled,
+		   p_params->ets_cbs, p_ets->pri_tc_tbl[0],
+		   p_params->max_ets_tc);
 
 	/* 8 bit tsa and bw data corresponding to each of the 8 TC's are
 	 * encoded in a type u32 array of size 2.
@@ -658,6 +659,7 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 	if (!enabled) {
 		p_operational->enabled = enabled;
 		p_operational->valid = false;
+		DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Dcbx is disabled\n");
 		return;
 	}
 
@@ -1145,6 +1147,9 @@ static int qed_dcbx_query_params(struct qed_hwfn *p_hwfn,
 		local_admin->config = DCBX_CONFIG_VERSION_DISABLED;
 	}
 
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Dcbx version = %d\n",
+		   local_admin->config);
+
 	if (params->override_flags & QED_DCBX_OVERRIDE_PFC_CFG)
 		qed_dcbx_set_pfc_data(p_hwfn, &local_admin->features.pfc,
 				      &params->config.params);
-- 
1.8.3.1
