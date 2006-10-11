From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 07/10] sky2: dont reset PHY twice
Date: Wed, 11 Oct 2006 14:22:32 -0700
Message-ID: <20061011212311.189180352@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27343 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161514AbWJKVaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:30:12 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-phy-one-reset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't need to reset PHY twice on startup.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:59:45.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 14:21:36.000000000 -0700
@@ -356,16 +356,7 @@
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
 	}
 
-	ctrl = gm_phy_read(hw, port, PHY_MARV_CTRL);
-	if (sky2->autoneg == AUTONEG_DISABLE)
-		ctrl &= ~PHY_CT_ANE;
-	else
-		ctrl |= PHY_CT_ANE;
-
-	ctrl |= PHY_CT_RESET;
-	gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
-
-	ctrl = 0;
+	ctrl = PHY_CT_RESET;
 	ct1000 = 0;
 	adv = PHY_AN_CSMA;
 	reg = 0;
@@ -450,8 +441,6 @@
 			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_ON);
 		else
 			sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
-
-		ctrl |= PHY_CT_RESET;
 	}
 
 	gma_write16(hw, port, GM_GP_CTRL, reg);

--
Stephen Hemminger <shemminger@osdl.org>

