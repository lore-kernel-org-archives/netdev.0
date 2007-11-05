From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] sky2: dont change LED after autoneg
Date: Mon, 05 Nov 2007 15:52:11 -0800
Message-ID: <20071105235340.143067950@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49337 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632AbXKEX4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:56:45 -0500
Content-Disposition: inline; filename=sky2-noled-aneg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't need to change LED's after auto negotiation, the chip
sets them correctly.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-11-05 15:05:00.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:05:01.000000000 -0800
@@ -1820,29 +1820,6 @@ static void sky2_link_up(struct sky2_por
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->flags & SKY2_HW_NEWER_PHY) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
-
-		switch(sky2->speed) {
-		case SPEED_10:
-			led |= PHY_M_LEDC_INIT_CTRL(7);
-			break;
-
-		case SPEED_100:
-			led |= PHY_M_LEDC_STA1_CTRL(7);
-			break;
-
-		case SPEED_1000:
-			led |= PHY_M_LEDC_STA0_CTRL(7);
-			break;
-		}
-
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, led);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	}
-
 	if (netif_msg_link(sky2))
 		printk(KERN_INFO PFX
 		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

