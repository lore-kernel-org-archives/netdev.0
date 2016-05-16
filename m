From: Alexander Graf <agraf@suse.de>
Subject: [PATCH] phy dp83867: depend on CONFIG_OF_MDIO
Date: Mon, 16 May 2016 13:28:15 +0200
Message-ID: <1463398095-123269-1-git-send-email-agraf@suse.de>
Cc: linux-kernel@vger.kernel.org, michal.simek@xilinx.com,
	Dan Murphy <dmurphy@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DP83867 phy driver doesn't actually work when CONFIG_OF_MDIO isn't enabled.
It simply passes the device tree test, but leaves all internal configuration
initialized at 0. Then it configures the phy with those values and renders a
previously working configuration useless.

This patch makes sure that we only build the DP83867 phy code when
CONFIG_OF_MDIO is set, to not run into that problem.

Signed-off-by: Alexander Graf <agraf@suse.de>
---
 drivers/net/phy/Kconfig   | 1 +
 drivers/net/phy/dp83867.c | 7 -------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..4265ad5 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -148,6 +148,7 @@ config DP83848_PHY
 
 config DP83867_PHY
 	tristate "Drivers for Texas Instruments DP83867 Gigabit PHY"
+	depends on OF_MDIO
 	---help---
 	  Currently supports the DP83867 PHY.
 
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 2afa61b..ff867ba 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -99,7 +99,6 @@ static int dp83867_config_intr(struct phy_device *phydev)
 	return phy_write(phydev, MII_DP83867_MICR, micr_status);
 }
 
-#ifdef CONFIG_OF_MDIO
 static int dp83867_of_init(struct phy_device *phydev)
 {
 	struct dp83867_private *dp83867 = phydev->priv;
@@ -123,12 +122,6 @@ static int dp83867_of_init(struct phy_device *phydev)
 	return of_property_read_u32(of_node, "ti,fifo-depth",
 				   &dp83867->fifo_depth);
 }
-#else
-static int dp83867_of_init(struct phy_device *phydev)
-{
-	return 0;
-}
-#endif /* CONFIG_OF_MDIO */
 
 static int dp83867_config_init(struct phy_device *phydev)
 {
-- 
1.8.5.6
