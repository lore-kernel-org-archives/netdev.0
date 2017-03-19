From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 7/7] net: phy: clean up mmd_phy_indirect()
Date: Sun, 19 Mar 2017 11:00:50 +0000
Message-ID: <E1cpYZu-0006VB-Ho@rmk-PC.armlinux.org.uk>
References: <20170319105943.GR21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43358 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdCSLKQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 07:10:16 -0400
In-Reply-To: <20170319105943.GR21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make mmd_phy_indirect() use the same terminology as the rest of the
code, making clear what each address is - phy address, devad, and
register number.

While here, remove the "inline" from this static function, leaving
it to the compiler to decide whether to inline this function, and
get rid of unnecessary parens.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index 80795ccd3fab..357a4d0d7641 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -9,17 +9,17 @@
 #include <linux/export.h>
 #include <linux/phy.h>
 
-static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
-				    int addr)
+static void mmd_phy_indirect(struct mii_bus *bus, int phy_addr, int devad,
+			     u16 regnum)
 {
 	/* Write the desired MMD Devad */
-	bus->write(bus, addr, MII_MMD_CTRL, devad);
+	bus->write(bus, phy_addr, MII_MMD_CTRL, devad);
 
 	/* Write the desired MMD register address */
-	bus->write(bus, addr, MII_MMD_DATA, prtad);
+	bus->write(bus, phy_addr, MII_MMD_DATA, regnum);
 
 	/* Select the Function : DATA with no post increment */
-	bus->write(bus, addr, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
+	bus->write(bus, phy_addr, MII_MMD_CTRL, devad | MII_MMD_CTRL_NOINCR);
 }
 
 /**
@@ -49,7 +49,7 @@ int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
 		int phy_addr = phydev->mdio.addr;
 
 		mutex_lock(&bus->mdio_lock);
-		mmd_phy_indirect(bus, regnum, devad, phy_addr);
+		mmd_phy_indirect(bus, phy_addr, devad, regnum);
 
 		/* Read the content of the MMD's selected register */
 		val = bus->read(bus, phy_addr, MII_MMD_DATA);
@@ -88,7 +88,7 @@ int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
 		int phy_addr = phydev->mdio.addr;
 
 		mutex_lock(&bus->mdio_lock);
-		mmd_phy_indirect(bus, regnum, devad, phy_addr);
+		mmd_phy_indirect(bus, phy_addr, devad, regnum);
 
 		/* Write the data into MMD's selected register */
 		bus->write(bus, phy_addr, MII_MMD_DATA, val);
-- 
2.7.4
