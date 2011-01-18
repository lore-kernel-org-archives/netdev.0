From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 3/8] bnx2x: LED fix for BCM8727 over BCM57712
Date: Tue, 18 Jan 2011 16:33:31 +0200
Message-ID: <1295361211.5281.86.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3544 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab1AROcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LED on BCM57712+BCM8727 systems requires different settings

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index bdf3c67..36a8844 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3166,7 +3166,23 @@ u8 bnx2x_set_led(struct link_params *params,
 		if (!vars->link_up)
 			break;
 	case LED_MODE_ON:
-		if (SINGLE_MEDIA_DIRECT(params)) {
+		if (params->phy[EXT_PHY1].type ==
+		    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727 &&
+		    CHIP_IS_E2(bp) && params->num_phys == 2) {
+			/**
+			* This is a work-around for E2+8727 Configurations
+			*/
+			if (mode == LED_MODE_ON ||
+				speed == SPEED_10000){
+				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
+				REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
+
+				tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+				EMAC_WR(bp, EMAC_REG_EMAC_LED,
+					(tmp | EMAC_LED_OVERRIDE));
+				return rc;
+			}
+		} else if (SINGLE_MEDIA_DIRECT(params)) {
 			/**
 			* This is a work-around for HW issue found when link
 			* is up in CL73
-- 
1.7.1








