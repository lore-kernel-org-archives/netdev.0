From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next (v2) 3/6] bnx2x: treat 0 speed as link down
 (copper)
Date: Thu, 21 Jun 2012 08:05:20 +0300
Message-ID: <1340255123-22371-4-git-send-email-yuvalmin@broadcom.com>
References: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, joe@perches.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1154 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456Ab2FUFHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 01:07:35 -0400
In-Reply-To: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 9a1705e..d4e8957 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10178,17 +10178,19 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Legacy speed status = 0x%x\n",
 		   legacy_status);
 		link_up = ((legacy_status & (1<<11)) == (1<<11));
-		if (link_up) {
-			legacy_speed = (legacy_status & (3<<9));
-			if (legacy_speed == (0<<9))
-				vars->line_speed = SPEED_10;
-			else if (legacy_speed == (1<<9))
-				vars->line_speed = SPEED_100;
-			else if (legacy_speed == (2<<9))
-				vars->line_speed = SPEED_1000;
-			else /* Should not happen */
-				vars->line_speed = 0;
+		legacy_speed = (legacy_status & (3<<9));
+		if (legacy_speed == (0<<9))
+			vars->line_speed = SPEED_10;
+		else if (legacy_speed == (1<<9))
+			vars->line_speed = SPEED_100;
+		else if (legacy_speed == (2<<9))
+			vars->line_speed = SPEED_1000;
+		else { /* Should not happen: Treat as link down */
+			vars->line_speed = 0;
+			link_up = 0;
+		}
 
+		if (link_up) {
 			if (legacy_status & (1<<8))
 				vars->duplex = DUPLEX_FULL;
 			else
-- 
1.7.9.rc2
