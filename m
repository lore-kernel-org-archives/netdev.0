From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] net: phy: spi_ks8995: add dependency on GPIO
Date: Sat, 13 Feb 2016 19:33:15 +0530
Message-ID: <1455372195-10825-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Helmut Buchsbaum <helmut.buchsbaum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The builds of allmodconfig of s390, m68k, tilegx, tilepro is failing
with the error:
 drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value'
 drivers/net/phy/spi_ks8995.c:477:19: error: implicit declaration of function 'gpio_to_desc'

GPIO is now used to reset the switch so we should have a dependency on
GPIOLIB. While adding the dependency also add COMPILE_TEST so that we
can build test it.

Fixes: cd6f288cbaab ("net: phy: spi_ks8995: add support for resetting switch using GPIO")
Cc: Helmut Buchsbaum <helmut.buchsbaum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
---

v2: added COMPILE_TEST and gpio/consumer.h

 drivers/net/phy/Kconfig      | 1 +
 drivers/net/phy/spi_ks8995.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f0a7702..186f202 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -262,3 +262,4 @@ endif # PHYLIB
 config MICREL_KS8995MA
 	tristate "Micrel KS8995MA 5-ports 10/100 managed Ethernet switch"
 	depends on SPI
+	depends on GPIOLIB || COMPILE_TEST
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 5e7340f..55000f6 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -20,6 +20,7 @@
 #include <linux/device.h>
 #include <linux/of.h>
 #include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
 #include <linux/of_gpio.h>
 
 #include <linux/spi/spi.h>
-- 
1.9.1
