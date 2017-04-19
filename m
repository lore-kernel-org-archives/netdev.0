From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 1/4] qed: Fix possible error in populating max_tc field.
Date: Wed, 19 Apr 2017 03:19:52 -0700
Message-ID: <20170419101955.26444-2-sudarsana.kalluru@cavium.com>
References: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0043.outbound.protection.outlook.com ([104.47.41.43]:11418
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761967AbdDSKU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 06:20:26 -0400
In-Reply-To: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some adapters may not publish the max_tc value. Populate the default
value for max_tc field in case the mfw didn't provide one.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 5bd36a4..c24436c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -583,6 +583,13 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 		   p_params->ets_cbs,
 		   p_ets->pri_tc_tbl[0], p_params->max_ets_tc);
 
+	if (p_params->ets_enabled && !p_params->max_ets_tc) {
+		p_params->max_ets_tc = QED_MAX_PFC_PRIORITIES;
+		DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+			   "ETS params: max_ets_tc is forced to %d\n",
+		p_params->max_ets_tc);
+	}
+
 	/* 8 bit tsa and bw data corresponding to each of the 8 TC's are
 	 * encoded in a type u32 array of size 2.
 	 */
-- 
1.8.3.1
