From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 4/4] bnxt_en: Fix ethtool -a reporting.
Date: Mon, 28 Mar 2016 19:46:07 -0400
Message-ID: <1459208767-4225-5-git-send-email-michael.chan@broadcom.com>
References: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:26215 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbcC1Xzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 19:55:42 -0400
In-Reply-To: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To report flow control tx/rx settings accurately regardless of autoneg
setting, we should use link_info->req_flow_ctrl.  Before this patch,
the reported settings were only correct when autoneg was on.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 9ada166..2e472f6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -855,10 +855,8 @@ static void bnxt_get_pauseparam(struct net_device *dev,
 	if (BNXT_VF(bp))
 		return;
 	epause->autoneg = !!(link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL);
-	epause->rx_pause =
-		((link_info->auto_pause_setting & BNXT_LINK_PAUSE_RX) != 0);
-	epause->tx_pause =
-		((link_info->auto_pause_setting & BNXT_LINK_PAUSE_TX) != 0);
+	epause->rx_pause = !!(link_info->req_flow_ctrl & BNXT_LINK_PAUSE_RX);
+	epause->tx_pause = !!(link_info->req_flow_ctrl & BNXT_LINK_PAUSE_TX);
 }
 
 static int bnxt_set_pauseparam(struct net_device *dev,
-- 
1.8.3.1
