From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: w5100: don't build spi driver without w5100
Date: Mon, 18 Apr 2016 23:58:30 +0200
Message-ID: <1461016722-2637993-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The w5100-spi driver front-end only makes sense when the w5100
core driver is enabled, not for a configuration that only has w5300:

drivers/net/built-in.o: In function `w5100_spi_remove':
drivers/net/ethernet/wiznet/w5100-spi.c:277: undefined reference to `w5100_remove'
drivers/net/built-in.o: In function `w5100_spi_probe':
drivers/net/ethernet/wiznet/w5100-spi.c:272: undefined reference to `w5100_probe'
drivers/net/built-in.o: In function `w5200_spi_init':
drivers/net/ethernet/wiznet/w5100-spi.c:125: undefined reference to `w5100_ops_priv'
drivers/net/built-in.o: In function `w5200_spi_readbulk':
drivers/net/ethernet/wiznet/w5100-spi.c:125: undefined reference to `w5100_ops_priv'
drivers/net/built-in.o: In function `w5200_spi_writebulk':
drivers/net/ethernet/wiznet/w5100-spi.c:125: undefined reference to `w5100_ops_priv'
drivers/net/built-in.o:(.data+0x3ed1c): undefined reference to `w5100_pm_ops'

This adds an appropriate Kconfig dependency.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 630cf09751fe ("net: w5100: support SPI interface mode")
---
 drivers/net/ethernet/wiznet/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index 1f15376e9856..f3385a1999a2 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -71,7 +71,7 @@ endchoice
 
 config WIZNET_W5100_SPI
 	tristate "WIZnet W5100/W5200 Ethernet support for SPI mode"
-	depends on WIZNET_BUS_ANY
+	depends on WIZNET_BUS_ANY && WIZNET_W5100
 	depends on SPI
 	---help---
 	  In SPI mode host system accesses registers using SPI protocol
-- 
2.7.0
