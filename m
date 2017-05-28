From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 03/10] qed: Don't inherit RoCE DCBx for V2
Date: Sun, 28 May 2017 18:01:53 +0300
Message-ID: <1495983720-10853-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0073.outbound.protection.outlook.com ([104.47.40.73]:43936
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750880AbdE1PDd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:03:33 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Older firmware used by device didn't distinguish between RoCE and RoCE
V2 from DCBx configuration perspective, and as a result we've used to
take a the RoCE-related configuration and apply to it for both.

Since we now support configuring each its own values, there's no reason
to reflect [& configure] that both are using the same.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index af34638..e2a62c0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -310,17 +310,6 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 		}
 	}
 
-	/* If RoCE-V2 TLV is not detected, driver need to use RoCE app
-	 * data for RoCE-v2 not the default app data.
-	 */
-	if (!p_data->arr[DCBX_PROTOCOL_ROCE_V2].update &&
-	    p_data->arr[DCBX_PROTOCOL_ROCE].update) {
-		tc = p_data->arr[DCBX_PROTOCOL_ROCE].tc;
-		priority = p_data->arr[DCBX_PROTOCOL_ROCE].priority;
-		qed_dcbx_update_app_info(p_data, p_hwfn, true, true,
-					 priority, tc, DCBX_PROTOCOL_ROCE_V2);
-	}
-
 	/* Update ramrod protocol data and hw_info fields
 	 * with default info when corresponding APP TLV's are not detected.
 	 * The enabled field has a different logic for ethernet as only for
-- 
1.9.3
