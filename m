From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] net/phy: fix mdio-octeon dependency and build
Date: Tue, 23 May 2017 08:19:49 -0700
Message-ID: <c37b4171-e3f2-c5cc-d734-6e1688c964f5@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

Fix build errors by making this driver depend on OF_MDIO, like
several other similar drivers do.

drivers/built-in.o: In function `octeon_mdiobus_remove':
mdio-octeon.c:(.text+0x196ee0): undefined reference to `mdiobus_unregister'
mdio-octeon.c:(.text+0x196ee8): undefined reference to `mdiobus_free'
drivers/built-in.o: In function `octeon_mdiobus_probe':
mdio-octeon.c:(.text+0x196f1d): undefined reference to `devm_mdiobus_alloc_size'
mdio-octeon.c:(.text+0x196ffe): undefined reference to `of_mdiobus_register'
mdio-octeon.c:(.text+0x197010): undefined reference to `mdiobus_free'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc:	Andrew Lunn <andrew@lunn.ch>
Cc:	Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Found in linux-next but applies to mainline also.

--- linux-next-20170523.orig/drivers/net/phy/Kconfig
+++ linux-next-20170523/drivers/net/phy/Kconfig
@@ -108,7 +108,7 @@ config MDIO_MOXART
 config MDIO_OCTEON
 	tristate "Octeon and some ThunderX SOCs MDIO buses"
 	depends on 64BIT
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && OF_MDIO
 	select MDIO_CAVIUM
 	help
 	  This module provides a driver for the Octeon and ThunderX MDIO
