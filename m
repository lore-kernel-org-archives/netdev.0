From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH] net: phy: mdio-sun4i: don't select REGULATOR
Date: Sat,  6 Sep 2014 00:28:23 +0200
Message-ID: <1409956103-23473-1-git-send-email-b.galvani@gmail.com>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mdio-sun4i driver automatically selects REGULATOR and
REGULATOR_FIXED_VOLTAGE because it uses the regulator API. But a
driver selecting a subsystem increases the chance of generating
circular Kconfig dependencies, especially when other drivers depend on
the selected symbol.

Since the regulator API functions are replaced with no-ops when
REGULATOR is disabled, the driver can be built successfully even
without regulator support and so those 'select' dependencies can be
safely dropped.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/phy/Kconfig | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 28437ab..14afa4f 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -159,8 +159,6 @@ config MDIO_OCTEON
 config MDIO_SUN4I
 	tristate "Allwinner sun4i MDIO interface support"
 	depends on ARCH_SUNXI
-	select REGULATOR
-	select REGULATOR_FIXED_VOLTAGE
 	help
 	  This driver supports the MDIO interface found in the network
 	  interface units of the Allwinner SoC that have an EMAC (A10,
-- 
1.9.1
