From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 8/8] bnx2x: Fix warning message during
 57712/8727 initialization
Date: Tue, 5 Jul 2011 14:07:16 +0300
Message-ID: <1309864036.4050.87.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2049 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932066Ab1GELHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:07:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear warning message "MDC/MDIO access timeout" during first driver load by setting MDIO clock.
This warning has no significant meaning, since it occurs prior to the first PHY initialization.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 03a2085..bcd8f00 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -11684,16 +11684,12 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	if (reset_ext_phy) {
-		bnx2x_set_mdio_clk(bp, params->chip_id, port);
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			if (params->phy[phy_index].link_reset) {
-				bnx2x_set_aer_mmd(params,
-						  &params->phy[phy_index]);
+			if (params->phy[phy_index].link_reset)
 				params->phy[phy_index].link_reset(
 					&params->phy[phy_index],
 					params);
-			}
 			if (params->phy[phy_index].flags &
 			    FLAGS_REARM_LATCH_SIGNAL)
 				clear_latch_ind = 1;
-- 
1.7.1







