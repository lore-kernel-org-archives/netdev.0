From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH] netdev/phy: Make get_phy_id() static and quit EXPORTing it.
Date: Tue, 15 May 2012 13:46:52 -0700
Message-ID: <1337114812-3912-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

This function is only referenced from within phy_device.c, so there is
no reason to export it.  In fact, we can make it static.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/phy/phy_device.c |    3 +--
 include/linux/phy.h          |    1 -
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e8c42d6..de86a55 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -207,7 +207,7 @@ static struct phy_device* phy_device_create(struct mii_bus *bus,
  * Description: Reads the ID registers of the PHY at @addr on the
  *   @bus, stores it in @phy_id and returns zero on success.
  */
-int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
+static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 {
 	int phy_reg;
 
@@ -230,7 +230,6 @@ int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id)
 
 	return 0;
 }
-EXPORT_SYMBOL(get_phy_id);
 
 /**
  * get_phy_device - reads the specified PHY device and returns its @phy_device struct
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6fe0a37..9039009 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -477,7 +477,6 @@ static inline int phy_write(struct phy_device *phydev, u32 regnum, u16 val)
 	return mdiobus_write(phydev->bus, phydev->addr, regnum, val);
 }
 
-int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
 struct phy_device* get_phy_device(struct mii_bus *bus, int addr);
 int phy_device_register(struct phy_device *phy);
 int phy_init_hw(struct phy_device *phydev);
-- 
1.7.2.3
