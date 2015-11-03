From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] arcnet/com20020: add LEDS_CLASS dependency
Date: Tue, 03 Nov 2015 14:51:29 +0100
Message-ID: <10338405.rWTFsWuIBE@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Michael Grzeschik <m.grzeschik@pengutronix.de>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added led trigger support in the com20020-pci driver causes
build errors when CONFIG_LEDS_CLASS is disabled:

drivers/built-in.o: In function `com20020pci_probe':
(.text+0x185dc4): undefined reference to `devm_led_classdev_register'
(.text+0x185dd8): undefined reference to `devm_led_classdev_register'

This adds a Kconfig dependency to prevent the invalid configurations.
Other drivers appear to be split 50:50 between 'select' and 'depends on'
for this symbol, I picked 'depends on' as I could not find a common
policy and it generally causes fewer problems.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 8890624a4e8c ("arcnet: com20020-pci: add led trigger support")
---
Found on ARM randconfig build tests

diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index 2a9c3c3abe9b..39bd16f3f86d 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -103,6 +103,7 @@ config ARCNET_RIM_I
 
 config ARCNET_COM20020
 	tristate "ARCnet COM20020 chipset driver"
+	depends on LEDS_CLASS
 	help
 	  This is the driver for the new COM20020 chipset. It supports such
 	  things as promiscuous mode, so packet sniffing is possible, and
