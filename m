From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 1/4] qed: Remove the endian-ness conversion for pri_to_tc value.
Date: Mon, 8 Aug 2016 21:57:40 -0400
Message-ID: <1470707863-11712-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59013 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752455AbcHIClE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:41:04 -0400
In-Reply-To: <1470707863-11712-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Endian-ness conversion is not needed for priority-to-TC field as the
field is already being read/written by the driver in big-endian way.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index d0dc28f..6869330 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -483,7 +483,7 @@ qed_dcbx_get_ets_data(struct qed_hwfn *p_hwfn,
 	bw_map[1] = be32_to_cpu(p_ets->tc_bw_tbl[1]);
 	tsa_map[0] = be32_to_cpu(p_ets->tc_tsa_tbl[0]);
 	tsa_map[1] = be32_to_cpu(p_ets->tc_tsa_tbl[1]);
-	pri_map = be32_to_cpu(p_ets->pri_tc_tbl[0]);
+	pri_map = p_ets->pri_tc_tbl[0];
 	for (i = 0; i < QED_MAX_PFC_PRIORITIES; i++) {
 		p_params->ets_tc_bw_tbl[i] = ((u8 *)bw_map)[i];
 		p_params->ets_tc_tsa_tbl[i] = ((u8 *)tsa_map)[i];
@@ -944,7 +944,6 @@ qed_dcbx_set_ets_data(struct qed_hwfn *p_hwfn,
 		val = (((u32)p_params->ets_pri_tc_tbl[i]) << ((7 - i) * 4));
 		p_ets->pri_tc_tbl[0] |= val;
 	}
-	p_ets->pri_tc_tbl[0] = cpu_to_be32(p_ets->pri_tc_tbl[0]);
 	for (i = 0; i < 2; i++) {
 		p_ets->tc_bw_tbl[i] = cpu_to_be32(p_ets->tc_bw_tbl[i]);
 		p_ets->tc_tsa_tbl[i] = cpu_to_be32(p_ets->tc_tsa_tbl[i]);
-- 
1.8.3.1
