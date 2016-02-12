From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: phy: spi_ks8995: include linux/gpio/consumer.h
Date: Fri, 12 Feb 2016 11:42:34 +0100
Message-ID: <1455273762-161477-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ks8995 phy driver just started using gpiod_* functions, which are
declared in linux/gpio/consumer.h, not linux/gpio.h, resulting in a
build failure in randconfig builds that do not have CONFIG_GPIOLIB
enabled:

drivers/net/phy/spi_ks8995.c: In function 'ks8995_probe':
drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value' [-Werror=implicit-function-declaration]

This changes the header inclusion so it builds in all configurations.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: cd6f288cbaab ("net: phy: spi_ks8995: add support for resetting switch using GPIO")
---
 drivers/net/phy/spi_ks8995.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 5e7340f6b37c..b5d50d458728 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -18,8 +18,8 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/device.h>
+#include <linux/gpio/consumer.h>
 #include <linux/of.h>
-#include <linux/gpio.h>
 #include <linux/of_gpio.h>
 
 #include <linux/spi/spi.h>
-- 
2.7.0
