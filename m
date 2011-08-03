From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 10/10] bnx2x: Clear MDIO access warning during first
 driver load
Date: Wed, 3 Aug 2011 12:00:12 +0300
Message-ID: <1312362012.21665.100.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2704 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab1HCJA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:00:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 01fb92c..d45b155 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -11724,12 +11724,16 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	if (reset_ext_phy) {
+		bnx2x_set_mdio_clk(bp, params->chip_id, port);
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			if (params->phy[phy_index].link_reset)
+			if (params->phy[phy_index].link_reset) {
+				bnx2x_set_aer_mmd(params,
+						  &params->phy[phy_index]);
 				params->phy[phy_index].link_reset(
 					&params->phy[phy_index],
 					params);
+			}
 			if (params->phy[phy_index].flags &
 			    FLAGS_REARM_LATCH_SIGNAL)
 				clear_latch_ind = 1;
-- 
1.7.1





