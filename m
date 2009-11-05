From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 01/10] bnx2x: Fix Parallel-Detect settings
Date: Thu, 5 Nov 2009 19:18:04 +0200
Message-ID: <1257441484.3390.48.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754899AbZKEPSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable Parallel-Detect for 10G and 1G only if the relevant speed capability is enabled

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index e32d337..b5964cb 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1107,18 +1107,21 @@ static void bnx2x_set_parallel_detection(struct link_params *params,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
 			      &control2);
-
-
-	control2 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
-
-
+	if (params->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
+		control2 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
+	else
+		control2 &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
+	DP(NETIF_MSG_LINK, "params->speed_cap_mask = 0x%x, control2 = 0x%x\n",
+		params->speed_cap_mask, control2);
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
 			      control2);
 
-	if (phy_flags & PHY_XGXS_FLAG) {
+	if ((phy_flags & PHY_XGXS_FLAG) &&
+	     (params->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
 		DP(NETIF_MSG_LINK, "XGXS\n");
 
 		CL45_WR_OVER_CL22(bp, params->port,
-- 
1.6.5.2




