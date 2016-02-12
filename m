From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: phy: spi_ks8995: add dependency on GPIO
Date: Fri, 12 Feb 2016 15:48:26 +0530
Message-ID: <1455272306-30251-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The builds of allmodconfig of s390, m68k, tilegx, tilepro is failing
with the error:
 drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value'
 drivers/net/phy/spi_ks8995.c:477:19: error: implicit declaration of function 'gpio_to_desc'

GPIO is now used to reset the switch so we should have a dependency on
GPIOLIB. 

Fixes: cd6f288cbaab ("net: phy: spi_ks8995: add support for resetting switch using GPIO")
Cc: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/phy/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f0a7702..c6a4fe1 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -261,4 +261,4 @@ endif # PHYLIB
 
 config MICREL_KS8995MA
 	tristate "Micrel KS8995MA 5-ports 10/100 managed Ethernet switch"
-	depends on SPI
+	depends on SPI && GPIOLIB
-- 
1.9.1
