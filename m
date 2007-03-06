From: akpm@linux-foundation.org
Subject: [patch 19/19] network: add the missing phy_device speed information to phy_mii_ioctl
Date: Tue, 06 Mar 2007 02:42:03 -0800
Message-ID: <200703061042.l26Ag3q4019790@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shanlu@cs.uiuc.edu
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34741 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934077AbXCFKnB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:43:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shan Lu" <shanlu@cs.uiuc.edu>

Function `phy_mii_ioctl' returns physical device's information based on
user requests.  When requested to return the basic mode control register
information (BMCR), the original implementation only returns the physical
device's duplex information and forgets to return speed information, which
should not be because BMCR register is used to hold both duplex and speed
information.

The patch checks the BMCR value against speed-related flags and fills the
return structure's speed field accordingly.

Signed-off-by: Shan <shanlu@cs.uiuc.edu>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/phy/phy.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -puN drivers/net/phy/phy.c~network-add-the-missing-phy_device-speed-information-to-phy_mii_ioctl drivers/net/phy/phy.c
--- a/drivers/net/phy/phy.c~network-add-the-missing-phy_device-speed-information-to-phy_mii_ioctl
+++ a/drivers/net/phy/phy.c
@@ -382,6 +382,12 @@ int phy_mii_ioctl(struct phy_device *phy
 					phydev->duplex = DUPLEX_FULL;
 				else
 					phydev->duplex = DUPLEX_HALF;
+				if ((!phydev->autoneg) &&
+						(val & BMCR_SPEED1000))
+					phydev->speed = SPEED_1000;
+				else if ((!phydev->autoneg) &&
+						(val & BMCR_SPEED100))
+					phydev->speed = SPEED_100;
 				break;
 			case MII_ADVERTISE:
 				phydev->advertising = val;
_
