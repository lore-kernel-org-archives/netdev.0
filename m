From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH -next] net/phy: fix phy_bcm_nsp_usb3.c build and kconfig
Date: Mon, 30 Jan 2017 17:02:44 -0800
Message-ID: <8b028a54-08a1-8e53-04ab-3fa8c51d2369@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38250 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754684AbdAaBD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:03:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

This driver uses mdio* (PHYLIB) interfaces, so it should select
PHYLIB. PHYLIB depends on NETDEVICES to this driver should also
depend on NETDEVICES.

Fixes these build errors:

drivers/built-in.o: In function `nsp_usb3_phy_init':
phy-bcm-nsp-usb3.c:(.text+0x42d8): undefined reference to `mdiobus_write'
phy-bcm-nsp-usb3.c:(.text+0x42f4): undefined reference to `mdiobus_write'
phy-bcm-nsp-usb3.c:(.text+0x4310): undefined reference to `mdiobus_write'
phy-bcm-nsp-usb3.c:(.text+0x432c): undefined reference to `mdiobus_write'
phy-bcm-nsp-usb3.c:(.text+0x4348): undefined reference to `mdiobus_write'
drivers/built-in.o:phy-bcm-nsp-usb3.c:(.text+0x437a): more undefined references to `mdiobus_write' follow
drivers/built-in.o: In function `mdio_module_init':
phy-bcm-nsp-usb3.c:(.init.text+0x1e1): undefined reference to `mdio_driver_register'
drivers/built-in.o: In function `mdio_module_exit':
phy-bcm-nsp-usb3.c:(.exit.text+0xae): undefined reference to `mdio_driver_unregister'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 drivers/phy/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next-20170130.orig/drivers/phy/Kconfig
+++ linux-next-20170130/drivers/phy/Kconfig
@@ -504,8 +504,9 @@ config PHY_MESON8B_USB2
 
 config PHY_NSP_USB3
 	tristate "Broadcom NorthStar plus USB3 PHY driver"
-	depends on OF && (ARCH_BCM_NSP || COMPILE_TEST)
+	depends on OF && (ARCH_BCM_NSP || COMPILE_TEST) && NETDEVICES
 	select GENERIC_PHY
+	select PHYLIB
 	default ARCH_BCM_NSP
 	help
 	  Enable this to support the Broadcom Northstar plus USB3 PHY.
