From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 25/36] bnx2x: Keep only one HW path active
Date: Wed, 12 Aug 2009 21:23:51 +0300
Message-ID: <1250101431.27379.177.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619AbZHLSYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable bmac access while working with emac and keep the single lane SerDes in
reset while working with 4 lanes XGXS

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index dc3b69e..b81a057 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -397,7 +397,8 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 
 		/* enable access for bmac registers */
 		REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
-	}
+	} else
+		REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x0);
 
 	vars->mac_type = MAC_TYPE_EMAC;
 	return 0;
@@ -1021,8 +1022,8 @@ static u8 bnx2x_reset_unicore(struct link_params *params)
 			      MDIO_COMBO_IEEE0_MII_CONTROL,
 			      (mii_control |
 			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
-
-	bnx2x_set_serdes_access(params);
+	if (params->switch_cfg == SWITCH_CFG_1G)
+		bnx2x_set_serdes_access(params);
 
 	/* wait for the reset to self clear */
 	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
-- 
1.5.4.3




