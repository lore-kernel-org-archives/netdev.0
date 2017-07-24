From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/10] bnxt_en: Set ETS min_bw parameter for older firmware.
Date: Mon, 24 Jul 2017 12:34:26 -0400
Message-ID: <1500914069-15724-8-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34326 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754033AbdGXQev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:51 -0400
Received: by mail-qk0-f182.google.com with SMTP id t2so58628953qkc.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:51 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to the ETS weight, older firmware also requires the min_bw
parameter to be set for it to work properly.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 6 ++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index c014589..aa1f3a2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -93,6 +93,12 @@ static int bnxt_hwrm_queue_cos2bw_cfg(struct bnxt *bp, struct ieee_ets *ets,
 			cos2bw.tsa =
 				QUEUE_COS2BW_QCFG_RESP_QUEUE_ID0_TSA_ASSIGN_ETS;
 			cos2bw.bw_weight = ets->tc_tx_bw[i];
+			/* older firmware requires min_bw to be set to the
+			 * same weight value in percent.
+			 */
+			cos2bw.min_bw =
+				cpu_to_le32((ets->tc_tx_bw[i] * 100) |
+					    BW_VALUE_UNIT_PERCENT1_100);
 		}
 		memcpy(data, &cos2bw.queue_id, sizeof(cos2bw) - 4);
 		if (i == 0) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
index ecd0a5e..d2e0af9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h
@@ -26,6 +26,7 @@ struct bnxt_cos2bw_cfg {
 	u8			queue_id;
 	__le32			min_bw;
 	__le32			max_bw;
+#define BW_VALUE_UNIT_PERCENT1_100		(0x1UL << 29)
 	u8			tsa;
 	u8			pri_lvl;
 	u8			bw_weight;
-- 
1.8.3.1
