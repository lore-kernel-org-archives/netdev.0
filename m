From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/ethernet: Move mac89x0.c from apple to cirrus
Date: Sat, 29 Oct 2011 20:09:01 +0200
Message-ID: <1319911741-9977-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macintosh CS89x0 based ethernet cards use a Crystal Semiconductor (Now
Cirrus Logic) CS89x0 chip, so the mac89x0 driver should be in
drivers/net/ethernet/cirrus instead of drivers/net/ethernet/apple.

This also fixes a build problem, as the driver needs a header file from the
cirrus directory:

drivers/net/ethernet/apple/mac89x0.c:107:20: error: cs89x0.h: No such file or directory

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/apple/Kconfig               |   12 ------------
 drivers/net/ethernet/apple/Makefile              |    1 -
 drivers/net/ethernet/cirrus/Kconfig              |   14 +++++++++++++-
 drivers/net/ethernet/cirrus/Makefile             |    1 +
 drivers/net/ethernet/{apple => cirrus}/mac89x0.c |    0
 5 files changed, 14 insertions(+), 14 deletions(-)
 rename drivers/net/ethernet/{apple => cirrus}/mac89x0.c (100%)

diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
index a759d54..1375e2d 100644
--- a/drivers/net/ethernet/apple/Kconfig
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -52,18 +52,6 @@ config BMAC
 	  To compile this driver as a module, choose M here: the module
 	  will be called bmac.
 
-config MAC89x0
-	tristate "Macintosh CS89x0 based ethernet cards"
-	depends on MAC
-	---help---
-	  Support for CS89x0 chipset based Ethernet cards.  If you have a
-	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. This module will
-	  be called mac89x0.
-
 config MACMACE
 	bool "Macintosh (AV) onboard MACE ethernet"
 	depends on MAC
diff --git a/drivers/net/ethernet/apple/Makefile b/drivers/net/ethernet/apple/Makefile
index 0d3a591..86eaa17 100644
--- a/drivers/net/ethernet/apple/Makefile
+++ b/drivers/net/ethernet/apple/Makefile
@@ -4,5 +4,4 @@
 
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
-obj-$(CONFIG_MAC89x0) += mac89x0.o
 obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 6cbb81c..1f8648f 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -6,7 +6,7 @@ config NET_VENDOR_CIRRUS
 	bool "Cirrus devices"
 	default y
 	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
-		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX)
+		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX) || MAC
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -47,4 +47,16 @@ config EP93XX_ETH
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
 
+config MAC89x0
+	tristate "Macintosh CS89x0 based ethernet cards"
+	depends on MAC
+	---help---
+	  Support for CS89x0 chipset based Ethernet cards.  If you have a
+	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called mac89x0.
+
 endif # NET_VENDOR_CIRRUS
diff --git a/drivers/net/ethernet/cirrus/Makefile b/drivers/net/ethernet/cirrus/Makefile
index 14bd77e..ca245e2 100644
--- a/drivers/net/ethernet/cirrus/Makefile
+++ b/drivers/net/ethernet/cirrus/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_EP93XX_ETH) += ep93xx_eth.o
+obj-$(CONFIG_MAC89x0) += mac89x0.o
diff --git a/drivers/net/ethernet/apple/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
similarity index 100%
rename from drivers/net/ethernet/apple/mac89x0.c
rename to drivers/net/ethernet/cirrus/mac89x0.c
-- 
1.7.0.4
