From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 20/24] mdio_bus: Add comment to mdiobus_scan() and __mdiobus_register()
Date: Mon,  4 Jan 2016 18:36:58 +0100
Message-ID: <1451929022-5580-21-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34979 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963AbcADRi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:26 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it clear that mdiobus_scan () will only find devices which have a
vendor/product ID in registers 2 and 3. These are typically PHY
devices. Other sort of MDIO devices, such as switches, are not
expected to be found during the scan.

Similarly, __mdiobus_register(), which calls mdiobus_scan() will only
find PHY devices, and other sorts of MDIO devices are expected to be
instantiated from device tree.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio_bus.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 0d369ad19d17..6f9ca51446db 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -291,7 +291,9 @@ static inline void of_mdiobus_link_mdiodev(struct mii_bus *mdio,
  * Description: Called by a bus driver to bring up all the PHYs
  *   on a given bus, and attach them to the bus. Drivers should use
  *   mdiobus_register() rather than __mdiobus_register() unless they
- *   need to pass a specific owner module.
+ *   need to pass a specific owner module. MDIO devices which are not
+ *   PHYs will not be brought up by this function. They are expected to
+ *   to be explicitly listed in DT and instantiated by of_mdiobus_register().
  *
  * Returns 0 on success or < 0 on error.
  */
@@ -394,6 +396,18 @@ void mdiobus_free(struct mii_bus *bus)
 }
 EXPORT_SYMBOL(mdiobus_free);
 
+/**
+ * mdiobus_scan - scan a bus for MDIO devices.
+ * @bus: mii_bus to scan
+ * @addr: address on bus to scan
+ *
+ * This function scans the MDIO bus, looking for devices which can be
+ * identified using a vendor/product ID in registers 2 and 3. Not all
+ * MDIO devices have such registers, but PHY devices typically
+ * do. Hence this function assumes anything found is a PHY, or can be
+ * treated as a PHY. Other MDIO devices, such as switches, will
+ * probably not be found during the scan.
+ */
 struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 {
 	struct phy_device *phydev;
-- 
2.6.4
