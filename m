From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 4/9] bnx2x: removed dcb unused code
Date: Sun, 18 Mar 2012 16:33:40 -0400
Message-ID: <1332102825-7838-5-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4959 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755099Ab2CRNsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:33 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   20 --------------------
 1 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index a2850fa..87560f6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -121,26 +121,6 @@ static void bnx2x_pfc_clear(struct bnx2x *bp)
 {
 	struct bnx2x_nig_brb_pfc_port_params nig_params = {0};
 	nig_params.pause_enable = 1;
-#ifdef BNX2X_SAFC
-	if (bp->flags & SAFC_TX_FLAG) {
-		u32 high = 0, low = 0;
-		int i;
-
-		for (i = 0; i < BNX2X_MAX_PRIORITY; i++) {
-			if (bp->pri_map[i] == 1)
-				high |= (1 << i);
-			if (bp->pri_map[i] == 0)
-				low |= (1 << i);
-		}
-
-		nig_params.llfc_low_priority_classes = high;
-		nig_params.llfc_low_priority_classes = low;
-
-		nig_params.pause_enable = 0;
-		nig_params.llfc_enable = 1;
-		nig_params.llfc_out_en = 1;
-	}
-#endif /* BNX2X_SAFC */
 	bnx2x_acquire_phy_lock(bp);
 	bp->link_params.feature_config_flags &= ~FEATURE_CONFIG_PFC_ENABLED;
 	bnx2x_update_pfc(&bp->link_params, &bp->link_vars, &nig_params);
-- 
1.7.9.rc2
