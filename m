From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC 2/2] phy: bcm-ns-usb3: fix MDIO_BUS dependency
Date: Thu, 22 Jun 2017 00:06:07 +0200
Message-ID: <20170621220626.46691-2-arnd@arndb.de>
References: <20170621220626.46691-1-arnd@arndb.de>
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621220626.46691-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver attempts to 'select MDIO_DEVICE', but the code
is actually a loadable module when PHYLIB=m:

drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_mdiodev_phy_write':
phy-bcm-ns-usb3.c:(.text.bcm_ns_usb3_mdiodev_phy_write+0x28): undefined reference to `mdiobus_write'
drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_module_exit':
phy-bcm-ns-usb3.c:(.exit.text+0x18): undefined reference to `mdio_driver_unregister'
drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_module_init':
phy-bcm-ns-usb3.c:(.init.text+0x18): undefined reference to `mdio_driver_register'
phy-bcm-ns-usb3.c:(.init.text+0x38): undefined reference to `mdio_driver_unregister'

Using 'depends on MDIO_BUS' instead will avoid the link error.

Fixes: af850e14a7ae ("phy: bcm-ns-usb3: add MDIO driver using proper bus layer")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/phy/broadcom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/phy/broadcom/Kconfig b/drivers/phy/broadcom/Kconfig
index 37371b89b14f..64fc59c3ae6d 100644
--- a/drivers/phy/broadcom/Kconfig
+++ b/drivers/phy/broadcom/Kconfig
@@ -30,8 +30,8 @@ config PHY_BCM_NS_USB3
 	tristate "Broadcom Northstar USB 3.0 PHY Driver"
 	depends on ARCH_BCM_IPROC || COMPILE_TEST
 	depends on HAS_IOMEM && OF
+	depends on MDIO_BUS
 	select GENERIC_PHY
-	select MDIO_DEVICE
 	help
 	  Enable this to support Broadcom USB 3.0 PHY connected to the USB
 	  controller on Northstar family.
-- 
2.9.0
