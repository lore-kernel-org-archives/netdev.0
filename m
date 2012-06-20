From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2x: treat 0 speed as link down (copper)
Date: Wed, 20 Jun 2012 11:49:32 +0300
Message-ID: <1340182175-916-4-git-send-email-yuvalmin@broadcom.com>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1933 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928Ab2FTIwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:52:21 -0400
In-Reply-To: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 121275e..17ddb9f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10179,17 +10179,19 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
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
