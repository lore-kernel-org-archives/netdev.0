From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ieee802154: don't select COMMON_CLK
Date: Wed, 19 Apr 2017 19:32:25 +0200
Message-ID: <20170419173233.3726121-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Harry Morris <harrymorris12@gmail.com>,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A device driver must not select the COMMON_CLK subsystem, as that conflicts
with platforms that provide a legacy implementation of the clk API:

drivers/clk/clk.o: In function `clk_enable':
clk.c:(.text.clk_enable+0x0): multiple definition of `clk_enable'
arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_enable+0x0): first defined here
drivers/clk/clk.o: In function `clk_round_rate':
clk.c:(.text.clk_round_rate+0x0): multiple definition of `clk_round_rate'
arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_round_rate+0x0): first defined here
drivers/clk/clk.o: In function `clk_get_parent':
clk.c:(.text.clk_get_parent+0x0): multiple definition of `clk_get_parent'
arch/arm/mach-sa1100/clock.o:clock.c:(.text.clk_get_parent+0x0): first defined here
drivers/clk/clk.o: In function `clk_get_rate':
clk.c:(.text.clk_get_rate+0x0): multiple definition of `clk_get_rate'

This changes the 'select' into 'depends on', as all other similar drivers do.

Fixes: d931acd575d6 ("ieee802154: Add CA8210 IEEE 802.15.4 device driver")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ieee802154/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index ce4864dc3c6e..303ba4133920 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -86,8 +86,8 @@ config IEEE802154_ADF7242
 config IEEE802154_CA8210
 	tristate "Cascoda CA8210 transceiver driver"
 	depends on IEEE802154_DRIVERS && MAC802154
+	depends on COMMON_CLK
 	depends on SPI
-	select COMMON_CLK
 	---help---
 	  Say Y here to enable the CA8210 SPI 802.15.4 wireless
 	  controller.
-- 
2.9.0
