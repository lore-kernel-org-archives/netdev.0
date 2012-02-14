From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 09/10] tg3: Use *_UNKNOWN ethtool definitions
Date: Mon, 13 Feb 2012 17:20:16 -0800
Message-ID: <1329182417-28223-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1648 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758698Ab2BNBVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces tg3's private SPEED_INVALID and DUPLEX_INVALID
definitions with SPEED_UNKNOWN and DUPLEX_UNKNOWN respectively.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   40 +++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/tg3.h |    3 --
 2 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 859bd22..302c69b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1819,8 +1819,8 @@ static void tg3_adjust_link(struct net_device *dev)
 		      (6 << TX_LENGTHS_IPG_SHIFT) |
 		      (32 << TX_LENGTHS_SLOT_TIME_SHIFT)));
 
-	if ((phydev->link && tp->link_config.active_speed == SPEED_INVALID) ||
-	    (!phydev->link && tp->link_config.active_speed != SPEED_INVALID) ||
+	if ((phydev->link && tp->link_config.active_speed == SPEED_UNKNOWN) ||
+	    (!phydev->link && tp->link_config.active_speed != SPEED_UNKNOWN) ||
 	    phydev->speed != tp->link_config.active_speed ||
 	    phydev->duplex != tp->link_config.active_duplex ||
 	    oldflowctrl != tp->link_config.active_flowctrl)
@@ -3813,8 +3813,8 @@ static void tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8
 				  DUPLEX_HALF;
 			break;
 		}
-		*speed = SPEED_INVALID;
-		*duplex = DUPLEX_INVALID;
+		*speed = SPEED_UNKNOWN;
+		*duplex = DUPLEX_UNKNOWN;
 		break;
 	}
 }
@@ -3906,7 +3906,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 
 		tg3_phy_autoneg_cfg(tp, new_adv,
 				    FLOW_CTRL_TX | FLOW_CTRL_RX);
-	} else if (tp->link_config.speed == SPEED_INVALID) {
+	} else if (tp->link_config.speed == SPEED_UNKNOWN) {
 		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
 			tp->link_config.advertising &=
 				~(ADVERTISED_1000baseT_Half |
@@ -3938,7 +3938,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 	}
 
 	if (tp->link_config.autoneg == AUTONEG_DISABLE &&
-	    tp->link_config.speed != SPEED_INVALID) {
+	    tp->link_config.speed != SPEED_UNKNOWN) {
 		u32 bmcr, orig_bmcr;
 
 		tp->link_config.active_speed = tp->link_config.speed;
@@ -4172,8 +4172,8 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	}
 
 	current_link_up = 0;
-	current_speed = SPEED_INVALID;
-	current_duplex = DUPLEX_INVALID;
+	current_speed = SPEED_UNKNOWN;
+	current_duplex = DUPLEX_UNKNOWN;
 	tp->phy_flags &= ~TG3_PHYFLG_MDIX_STATE;
 	tp->link_config.rmt_adv = 0;
 
@@ -5069,8 +5069,8 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 				    LED_CTRL_LNKLED_OVERRIDE |
 				    LED_CTRL_1000MBPS_ON));
 	} else {
-		tp->link_config.active_speed = SPEED_INVALID;
-		tp->link_config.active_duplex = DUPLEX_INVALID;
+		tp->link_config.active_speed = SPEED_UNKNOWN;
+		tp->link_config.active_duplex = DUPLEX_UNKNOWN;
 		tw32(MAC_LED_CTRL, (tp->led_ctrl |
 				    LED_CTRL_LNKLED_OVERRIDE |
 				    LED_CTRL_TRAFFIC_OVERRIDE));
@@ -5118,8 +5118,8 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 		tg3_phy_reset(tp);
 
 	current_link_up = 0;
-	current_speed = SPEED_INVALID;
-	current_duplex = DUPLEX_INVALID;
+	current_speed = SPEED_UNKNOWN;
+	current_duplex = DUPLEX_UNKNOWN;
 	tp->link_config.rmt_adv = 0;
 
 	err |= tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -10515,8 +10515,8 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				cmd->eth_tp_mdix = ETH_TP_MDI;
 		}
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_INVALID);
-		cmd->duplex = DUPLEX_INVALID;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 		cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
 	}
 	cmd->phy_address = tp->phy_addr;
@@ -10598,8 +10598,8 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		tp->link_config.advertising = (cmd->advertising |
 					      ADVERTISED_Autoneg);
-		tp->link_config.speed = SPEED_INVALID;
-		tp->link_config.duplex = DUPLEX_INVALID;
+		tp->link_config.speed = SPEED_UNKNOWN;
+		tp->link_config.duplex = DUPLEX_UNKNOWN;
 	} else {
 		tp->link_config.advertising = 0;
 		tp->link_config.speed = speed;
@@ -13347,11 +13347,11 @@ static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
 		adv |= ADVERTISED_FIBRE;
 
 	tp->link_config.advertising = adv;
-	tp->link_config.speed = SPEED_INVALID;
-	tp->link_config.duplex = DUPLEX_INVALID;
+	tp->link_config.speed = SPEED_UNKNOWN;
+	tp->link_config.duplex = DUPLEX_UNKNOWN;
 	tp->link_config.autoneg = AUTONEG_ENABLE;
-	tp->link_config.active_speed = SPEED_INVALID;
-	tp->link_config.active_duplex = DUPLEX_INVALID;
+	tp->link_config.active_speed = SPEED_UNKNOWN;
+	tp->link_config.active_duplex = DUPLEX_UNKNOWN;
 }
 
 static int __devinit tg3_phy_probe(struct tg3 *tp)
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 2ddd92e..300c6e5 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2702,9 +2702,6 @@ struct tg3_link_config {
 	u8				active_flowctrl;
 
 	u8				active_duplex;
-#define SPEED_INVALID		0xffff
-#define DUPLEX_INVALID		0xff
-#define AUTONEG_INVALID		0xff
 	u16				active_speed;
 	u32				rmt_adv;
 };
-- 
1.7.3.4
