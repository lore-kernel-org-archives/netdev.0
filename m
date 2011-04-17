From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: Fix port identification problem
Date: Sun, 17 Apr 2011 09:35:32 +0300
Message-ID: <1303022132.18593.16.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4845 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab1DQGgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 02:36:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes port identification on optic devices when there's no link on the port.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index f505015..89cb977 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -2114,19 +2114,18 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 	for (i = 0; i < (data * 2); i++) {
 		if ((i % 2) == 0)
 			bnx2x_set_led(&bp->link_params, &bp->link_vars,
-				      LED_MODE_OPER, SPEED_1000);
+				      LED_MODE_ON, SPEED_1000);
 		else
 			bnx2x_set_led(&bp->link_params, &bp->link_vars,
-				      LED_MODE_OFF, 0);
+				      LED_MODE_FRONT_PANEL_OFF, 0);
 
 		msleep_interruptible(500);
 		if (signal_pending(current))
 			break;
 	}
 
-	if (bp->link_vars.link_up)
-		bnx2x_set_led(&bp->link_params, &bp->link_vars, LED_MODE_OPER,
-			      bp->link_vars.line_speed);
+	bnx2x_set_led(&bp->link_params, &bp->link_vars,
+		      LED_MODE_OPER, bp->link_vars.line_speed);
 
 	return 0;
 }
-- 
1.7.1






