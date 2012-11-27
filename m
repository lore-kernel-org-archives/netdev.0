From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 9/9] bnx2x: Change duplex setting in EEE
 function
Date: Tue, 27 Nov 2012 15:46:36 +0200
Message-ID: <1354023996-3512-10-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4633 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755504Ab2K0Lrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:32 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not a real problem, since the EEE is supported for devices where the
actual_phy_selection is zero, such that the req_duplex of params will match
the one of the phy struct.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index ebab35d..3e7d824 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10119,7 +10119,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			return rc;
 		}
 
-		if ((params->req_duplex[actual_phy_selection] == DUPLEX_FULL) &&
+		if ((phy->req_duplex == DUPLEX_FULL) &&
 		    (params->eee_mode & EEE_MODE_ADV_LPI) &&
 		    (bnx2x_eee_calc_timer(params) ||
 		     !(params->eee_mode & EEE_MODE_ENABLE_LPI)))
@@ -13451,7 +13451,7 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 	if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE)) {
 		if (!not_kr2_device) {
 			DP(NETIF_MSG_LINK, "BP=0x%x, NP=0x%x\n", base_page,
-			   next_page);
+				       next_page);
 			bnx2x_kr2_recovery(params, vars, phy);
 		}
 		return;
-- 
1.7.1
