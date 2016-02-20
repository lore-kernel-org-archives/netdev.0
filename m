From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Remove unnecessary call to update PHY settings.
Date: Fri, 19 Feb 2016 19:43:20 -0500
Message-ID: <1455929001-12039-3-git-send-email-michael.chan@broadcom.com>
References: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:5458 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426229AbcBTAnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:43:24 -0500
In-Reply-To: <1455929001-12039-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

Fix bnxt_update_phy_setting() to check the correct parameters when
determining whether to update the PHY.  Requested line speed/duplex should
only be checked for forced speed mode.  This avoids unnecessary link
interruptions when loading the driver.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9b56058..78f6b5a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4554,20 +4554,18 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 	if (!(link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) &&
 	    link_info->force_pause_setting != link_info->req_flow_ctrl)
 		update_pause = true;
-	if (link_info->req_duplex != link_info->duplex_setting)
-		update_link = true;
 	if (!(link_info->autoneg & BNXT_AUTONEG_SPEED)) {
 		if (BNXT_AUTO_MODE(link_info->auto_mode))
 			update_link = true;
 		if (link_info->req_link_speed != link_info->force_link_speed)
 			update_link = true;
+		if (link_info->req_duplex != link_info->duplex_setting)
+			update_link = true;
 	} else {
 		if (link_info->auto_mode == BNXT_LINK_AUTO_NONE)
 			update_link = true;
 		if (link_info->advertising != link_info->auto_link_speeds)
 			update_link = true;
-		if (link_info->req_link_speed != link_info->auto_link_speed)
-			update_link = true;
 	}
 
 	if (update_link)
-- 
1.8.3.1
