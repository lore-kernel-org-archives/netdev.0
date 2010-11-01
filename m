From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 2/8] bnx2x: Fix waiting for reset complete on
 BCM848x3 PHYs
Date: Mon, 1 Nov 2010 17:32:27 +0200
Message-ID: <1288625547.3533.14.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab0KAMOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM848x3 requires additional of 50ms after reset done indication, instead of fixed time of 200ms

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 89b33e2..b6588c5 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -5302,7 +5302,7 @@ static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 autoneg_val, an_1000_val, an_10_100_val;
-	bnx2x_wait_reset_complete(bp, phy);
+
 	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
 		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
@@ -5431,6 +5431,7 @@ static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
 
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
+	bnx2x_wait_reset_complete(bp, phy);
 
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	return bnx2x_848xx_cmn_config_init(phy, params, vars);
@@ -5453,8 +5454,9 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 		       port);
-	msleep(200); /* 100 is not enough */
-
+	bnx2x_wait_reset_complete(bp, phy);
+	/* Wait for GPHY to come out of reset */
+	msleep(50);
 	/* BCM84823 requires that XGXS links up first @ 10G for normal
 	behavior */
 	temp = vars->line_speed;
-- 
1.7.1




