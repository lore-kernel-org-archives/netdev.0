From: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH RFC 7/7] net: phy: clean up mmd_phy_indirect()
Date: Fri, 13 Jan 2017 15:22:14 +0000
Message-ID: <E1cS3gE-0003Y4-BR@rmk-PC.armlinux.org.uk>
References: <20170113152059.GR14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170113152059.GR14217-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make mmd_phy_indirect() use the same terminology as the rest of the
code, making clear what each address is - phy address, devad, and
register number.

While here, remove the "inline" from this static function, leaving
it to the compiler to decide whether to inline this function, and
get rid of unnecessary parens.

Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
