From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Fix MDIO_THUNDER dependencies
Date: Mon, 12 Jun 2017 17:18:51 -0700
Message-ID: <20170613001852.10073-1-f.fainelli@gmail.com>
Cc: rdunlap@infradead.org, arnd@arndb.de,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 90eff9096c01 ("net: phy: Allow splitting MDIO
bus/device support from PHYs") we could create a configuration where
MDIO_DEVICE=y and PHYLIB=m which leads to the following undefined
references:

 drivers/built-in.o: In function `thunder_mdiobus_pci_remove':
>> mdio-thunder.c:(.text+0x2a212f): undefined reference to
>> `mdiobus_unregister'
>> mdio-thunder.c:(.text+0x2a2138): undefined reference to
>> `mdiobus_free'
   drivers/built-in.o: In function `thunder_mdiobus_pci_probe':
   mdio-thunder.c:(.text+0x2a22e7): undefined reference to
`devm_mdiobus_alloc_size'
   mdio-thunder.c:(.text+0x2a236f): undefined reference to
`of_mdiobus_register'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index c360dd6ead22..3ab6c58d4be6 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -127,6 +127,7 @@ config MDIO_THUNDER
 	tristate "ThunderX SOCs MDIO buses"
 	depends on 64BIT
 	depends on PCI
+	depends on !(MDIO_DEVICE=y && PHYLIB=m)
 	select MDIO_CAVIUM
 	help
 	  This driver supports the MDIO interfaces found on Cavium
-- 
2.9.3
