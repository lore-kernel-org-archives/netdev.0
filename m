From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Use mii_advertise_flowctrl
Date: Wed, 14 Dec 2011 13:10:00 -0800
Message-ID: <1323897002-17295-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4926 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758127Ab1LNVJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:09:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces tg3's internal tg3_advert_flowctrl_1000T function
with mii_advertise_flowctrl provided by the kernel headers.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 90ef942..0766d03 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1671,22 +1671,6 @@ static void tg3_link_report(struct tg3 *tp)
 	}
 }
 
-static u16 tg3_advert_flowctrl_1000T(u8 flow_ctrl)
-{
-	u16 miireg;
-
-	if ((flow_ctrl & FLOW_CTRL_TX) && (flow_ctrl & FLOW_CTRL_RX))
-		miireg = ADVERTISE_PAUSE_CAP;
-	else if (flow_ctrl & FLOW_CTRL_TX)
-		miireg = ADVERTISE_PAUSE_ASYM;
-	else if (flow_ctrl & FLOW_CTRL_RX)
-		miireg = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
-	else
-		miireg = 0;
-
-	return miireg;
-}
-
 static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
 {
 	u16 miireg;
@@ -1787,7 +1771,7 @@ static void tg3_adjust_link(struct net_device *dev)
 		if (phydev->duplex == DUPLEX_HALF)
 			mac_mode |= MAC_MODE_HALF_DUPLEX;
 		else {
-			lcl_adv = tg3_advert_flowctrl_1000T(
+			lcl_adv = mii_advertise_flowctrl(
 				  tp->link_config.flowctrl);
 
 			if (phydev->pause)
@@ -3589,7 +3573,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 
 	new_adv = ADVERTISE_CSMA;
 	new_adv |= ethtool_adv_to_mii_adv_t(advertise) & ADVERTISE_ALL;
-	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
+	new_adv |= mii_advertise_flowctrl(flowctrl);
 
 	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
 	if (err)
@@ -3777,7 +3761,7 @@ static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
 
 	advmsk = ADVERTISE_ALL;
 	if (tp->link_config.active_duplex == DUPLEX_FULL) {
-		tgtadv |= tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
+		tgtadv |= mii_advertise_flowctrl(tp->link_config.flowctrl);
 		advmsk |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 	}
 
-- 
1.7.3.4
