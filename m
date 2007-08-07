From: Domen Puncer <domen.puncer@telargo.com>
Subject: [PATCH] phy layer: fix phy_mii_ioctl for autonegotiation
Date: Tue, 7 Aug 2007 12:12:41 +0200
Message-ID: <20070807101241.GA13994@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: macro@linux-mips.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out001.atlarge.net ([129.41.63.69]:53094 "EHLO
	out001.atlarge.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756330AbXHGKMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 06:12:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a thinko (?) in setting phydev->autoneg.


Signed-off-by: Domen Puncer <domen.puncer@telargo.com>

---
This fixes my "mii.h -> ethtool.h advertising #defines". I'm not sure
why and how they're translated, but it does work now.
Maybe they're just ignored, since mii-tool directly reads and writes
MII registers.


 drivers/net/phy/phy.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: work-powerpc.git/drivers/net/phy/phy.c
===================================================================
--- work-powerpc.git.orig/drivers/net/phy/phy.c
+++ work-powerpc.git/drivers/net/phy/phy.c
@@ -261,7 +261,7 @@ void phy_sanitize_settings(struct phy_de
 
 	/* Sanitize settings based on PHY capabilities */
 	if ((features & SUPPORTED_Autoneg) == 0)
-		phydev->autoneg = 0;
+		phydev->autoneg = AUTONEG_DISABLE;
 
 	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
 			features);
@@ -374,7 +374,7 @@ int phy_mii_ioctl(struct phy_device *phy
 		if (mii_data->phy_id == phydev->addr) {
 			switch(mii_data->reg_num) {
 			case MII_BMCR:
-				if (val & (BMCR_RESET|BMCR_ANENABLE))
+				if ((val & (BMCR_RESET|BMCR_ANENABLE)) == 0)
 					phydev->autoneg = AUTONEG_DISABLE;
 				else
 					phydev->autoneg = AUTONEG_ENABLE;
