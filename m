From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 06/10] sky2: use duplex result bits
Date: Wed, 11 Oct 2006 14:22:31 -0700
Message-ID: <20061011212311.013625277@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52685 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422639AbWJKV1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:27:21 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-duplex-result.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The result of duplex negotiation is avaliable in the phy status
register, so use that to simplify code and avoid rereading the PHY.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:43:47.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 11:43:50.000000000 -0700
@@ -1714,26 +1714,7 @@
 	}
 
 	sky2->speed = sky2_phy_speed(hw, aux);
-	if (sky2->speed == SPEED_1000) {
-		u16 ctl2 = gm_phy_read(hw, port, PHY_MARV_1000T_CTRL);
-		u16 lpa2 = gm_phy_read(hw, port, PHY_MARV_1000T_STAT);
-		if (lpa2  & PHY_B_1000S_MSF) {
-			printk(KERN_ERR PFX "%s: master/slave fault",
-			       sky2->netdev->name);
-			return -1;
-		}
-
-		if ((ctl2 & PHY_M_1000C_AFD) && (lpa2 & PHY_B_1000S_LP_FD))
-			sky2->duplex = DUPLEX_FULL;
-		else
-			sky2->duplex = DUPLEX_HALF;
-	} else {
-		u16 adv = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
-		if ((aux & adv) & PHY_AN_FULL)
-			sky2->duplex = DUPLEX_FULL;
-		else
-			sky2->duplex = DUPLEX_HALF;
-	}
+	sky2->duplex = (aux & PHY_M_PS_FULL_DUP) ? DUPLEX_FULL : DUPLEX_HALF;
 
 	/* Pause bits are offset (9..8) */
 	if (hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)

--
Stephen Hemminger <shemminger@osdl.org>

