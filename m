From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net] net: phy: Kconfig: Fix PHY infrastructure menu in menuconfig
Date: Mon, 18 Sep 2017 14:59:20 +0200
Message-ID: <20170918125920.10298-1-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Russell King <rmk+kernel@arm.linux.org.uk>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the integration of PHYLINK, the configuration option which
used to be under the PHY infrastructure menu in menuconfig ended
up one level up (the network device driver section)

By placing PHYLINK option right after PHYLIB entry, it broke the
way Kconfig used to build the menu. See kconfig-language.txt, section
"Menu structure", 2nd method.

This is fixed by placing the PHYLINK option just before PHYLIB.

Fixes: 9525ae83959b ("phylink: add phylink infrastructure")
Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
---
 drivers/net/phy/Kconfig | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a9d16a3af514..cd931cf9dcc2 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -160,15 +160,6 @@ config MDIO_XGENE
 
 endif
 
-menuconfig PHYLIB
-	tristate "PHY Device support and infrastructure"
-	depends on NETDEVICES
-	select MDIO_DEVICE
-	help
-	  Ethernet controllers are usually attached to PHY
-	  devices.  This option provides infrastructure for
-	  managing PHY devices.
-
 config PHYLINK
 	tristate
 	depends on NETDEVICES
@@ -179,6 +170,15 @@ config PHYLINK
 	  configuration links, PHYs, and Serdes links with MAC level
 	  autonegotiation modes.
 
+menuconfig PHYLIB
+	tristate "PHY Device support and infrastructure"
+	depends on NETDEVICES
+	select MDIO_DEVICE
+	help
+	  Ethernet controllers are usually attached to PHY
+	  devices.  This option provides infrastructure for
+	  managing PHY devices.
+
 if PHYLIB
 
 config SWPHY
-- 
2.13.5
