From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 09/10] bnx2x: Fix register access timeout in 10M
Date: Thu, 5 Nov 2009 19:18:32 +0200
Message-ID: <1257441512.3390.56.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2641 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172AbZKEPS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In BCM8481 when link speed goes from 1G to 10M, driver received timeout
since the MAC clock hasn't synced yet with the new speed, so it is required
first to program the MAC with the new speed, and only then configure other
parameters

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index d2c9e19..41b9b7b 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -6322,10 +6322,11 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 		bnx2x_bmac_enable(params, vars, 0);
 		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
 	} else {
-		bnx2x_emac_enable(params, vars, 0);
 		rc = bnx2x_emac_program(params, vars->line_speed,
 				      vars->duplex);
 
+		bnx2x_emac_enable(params, vars, 0);
+
 		/* AN complete? */
 		if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
 			if (!(vars->phy_flags &
-- 
1.6.5.2




