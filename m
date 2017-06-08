From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 7/7] net: dsa: mv88e6xxx: prefix PHY macros
Date: Thu,  8 Jun 2017 18:34:14 -0400
Message-ID: <20170608223414.594-8-vivien.didelot@savoirfairelinux.com>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix the PHY_* macros with a Marvell specific MV88E6XXX_ prefix.
There is no functional changes.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/phy.c | 11 ++++++-----
 drivers/net/dsa/mv88e6xxx/phy.h |  4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index 0db624f0993c..3500ac0ea848 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -62,7 +62,7 @@ int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy, int reg, u16 val)
 
 static int mv88e6xxx_phy_page_get(struct mv88e6xxx_chip *chip, int phy, u8 page)
 {
-	return mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+	return mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_PAGE, page);
 }
 
 static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
@@ -72,7 +72,8 @@ static void mv88e6xxx_phy_page_put(struct mv88e6xxx_chip *chip, int phy)
 	/* Restore PHY page Copper 0x0 for access via the registered
 	 * MDIO bus
 	 */
-	err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, PHY_PAGE_COPPER);
+	err = mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_PAGE,
+				  MV88E6XXX_PHY_PAGE_COPPER);
 	if (unlikely(err)) {
 		dev_err(chip->dev,
 			"failed to restore PHY %d page Copper (%d)\n",
@@ -86,7 +87,7 @@ int mv88e6xxx_phy_page_read(struct mv88e6xxx_chip *chip, int phy,
 	int err;
 
 	/* There is no paging for registers 22 */
-	if (reg == PHY_PAGE)
+	if (reg == MV88E6XXX_PHY_PAGE)
 		return -EINVAL;
 
 	err = mv88e6xxx_phy_page_get(chip, phy, page);
@@ -104,12 +105,12 @@ int mv88e6xxx_phy_page_write(struct mv88e6xxx_chip *chip, int phy,
 	int err;
 
 	/* There is no paging for registers 22 */
-	if (reg == PHY_PAGE)
+	if (reg == MV88E6XXX_PHY_PAGE)
 		return -EINVAL;
 
 	err = mv88e6xxx_phy_page_get(chip, phy, page);
 	if (!err) {
-		err = mv88e6xxx_phy_write(chip, phy, PHY_PAGE, page);
+		err = mv88e6xxx_phy_write(chip, phy, MV88E6XXX_PHY_PAGE, page);
 		mv88e6xxx_phy_page_put(chip, phy);
 	}
 
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index 4131a4e8206a..556b74a0502a 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -14,8 +14,8 @@
 #ifndef _MV88E6XXX_PHY_H
 #define _MV88E6XXX_PHY_H
 
-#define PHY_PAGE		0x16
-#define PHY_PAGE_COPPER		0x00
+#define MV88E6XXX_PHY_PAGE		0x16
+#define MV88E6XXX_PHY_PAGE_COPPER	0x00
 
 /* PHY Registers accesses implementations */
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
-- 
2.13.1
