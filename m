From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/6] sky2: PHY register settings
Date: Mon, 14 May 2007 12:38:11 -0700
Message-ID: <20070514193945.599249746@linux-foundation.org>
References: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43864 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754537AbXENTnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:43:32 -0400
Content-Disposition: inline; filename=sky2-downshift.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Align the PHY setup of the sky2 driver with the vendor sk98lin (10.0.4.3)
driver. The PHY register settings are mostly black magic, even with access
to the documentation it isn't clear what the right values are. The changes
are mostly comments, the code change only affects the Yukon FE (100 mbit only)
version.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- 2.6.21-rc1.orig/drivers/net/sky2.c	2007-05-14 12:06:25.000000000 -0700
+++ 2.6.21-rc1/drivers/net/sky2.c	2007-05-14 12:10:13.000000000 -0700
@@ -304,10 +304,13 @@ static void sky2_phy_init(struct sky2_hw
 			   PHY_M_EC_MAC_S_MSK);
 		ectrl |= PHY_M_EC_MAC_S(MAC_TX_CLK_25_MHZ);
 
+		/* on PHY 88E1040 Rev.D0 (and newer) downshift control changed */
 		if (hw->chip_id == CHIP_ID_YUKON_EC)
+			/* set downshift counter to 3x and enable downshift */
 			ectrl |= PHY_M_EC_DSC_2(2) | PHY_M_EC_DOWN_S_ENA;
 		else
-			ectrl |= PHY_M_EC_M_DSC(2) | PHY_M_EC_S_DSC(3);
+			/* set master & slave downshift counter to 1x */
+			ectrl |= PHY_M_EC_M_DSC(0) | PHY_M_EC_S_DSC(1);
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_CTRL, ectrl);
 	}
@@ -324,10 +327,12 @@ static void sky2_phy_init(struct sky2_hw
 			/* enable automatic crossover */
 			ctrl |= PHY_M_PC_MDI_XMODE(PHY_M_PC_ENA_AUTO);
 
+			/* downshift on PHY 88E1112 and 88E1149 is changed */
 			if (sky2->autoneg == AUTONEG_ENABLE
 			    && (hw->chip_id == CHIP_ID_YUKON_XL
 				|| hw->chip_id == CHIP_ID_YUKON_EC_U
 				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
+				/* set downshift counter to 3x and enable downshift */
 				ctrl &= ~PHY_M_PC_DSC_MSK;
 				ctrl |= PHY_M_PC_DSC(2) | PHY_M_PC_DOWN_S_ENA;
 			}

--
Stephen Hemminger <shemminger@linux-foundation.org>

