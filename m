From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] nuvoton: Move the Nuvoton driver
Date: Fri, 12 Aug 2011 03:52:44 -0700
Message-ID: <1313146371-6562-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Wan ZongShun <mcuos.com@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32672 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004Ab1HLKw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:56 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Nuvoton driver into drivers/net/ethernet/nuvoton/ and
make the necessary Kconfig and Makefile changes.

CC: Wan ZongShun <mcuos.com@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/arm/Kconfig                            |    9 ------
 drivers/net/arm/Makefile                           |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/nuvoton/Kconfig               |   29 ++++++++++++++++++++
 drivers/net/ethernet/nuvoton/Makefile              |    5 +++
 .../net/{arm => ethernet/nuvoton}/w90p910_ether.c  |    0
 8 files changed, 37 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/nuvoton/Kconfig
 create mode 100644 drivers/net/ethernet/nuvoton/Makefile
 rename drivers/net/{arm => ethernet/nuvoton}/w90p910_ether.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index ee4ebb4..d31fd9e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1127,7 +1127,7 @@ F:	arch/arm/mach-nuc93x/
 F:	drivers/input/keyboard/w90p910_keypad.c
 F:	drivers/input/touchscreen/w90p910_ts.c
 F:	drivers/watchdog/nuc900_wdt.c
-F:	drivers/net/arm/w90p910_ether.c
+F:	drivers/net/ethernet/nuvoton/w90p910_ether.c
 F:	drivers/mtd/nand/nuc900_nand.c
 F:	drivers/rtc/rtc-nuc900.c
 F:	drivers/spi/spi_nuc900.c
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index fc94b4b..57d16b9 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -10,12 +10,3 @@ config ARM_AT91_ETHER
 	help
 	  If you wish to compile a kernel for the AT91RM9200 and enable
 	  ethernet support, then you should always answer Y to this.
-
-config W90P910_ETH
-	tristate "Nuvoton w90p910 Ethernet support"
-	depends on ARM && ARCH_W90X900
-	select PHYLIB
-	select MII
-	help
-	  Say Y here if you want to use built-in Ethernet ports
-	  on w90p910 processor.
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index 462b3a4..fc0f85c 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -4,4 +4,3 @@
 #
 
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
-obj-$(CONFIG_W90P910_ETH)	+= w90p910_ether.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ff07408..3893065 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -37,6 +37,7 @@ source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+source "drivers/net/ethernet/nuvoton/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3a17413..e1f0b94 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
diff --git a/drivers/net/ethernet/nuvoton/Kconfig b/drivers/net/ethernet/nuvoton/Kconfig
new file mode 100644
index 0000000..3b91c3b
--- /dev/null
+++ b/drivers/net/ethernet/nuvoton/Kconfig
@@ -0,0 +1,29 @@
+#
+# Nuvoton network device configuration
+#
+
+config NET_VENDOR_NUVOTON
+	bool "Nuvoton devices"
+	depends on ARM && ARCH_W90X900
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Nuvoton cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_NUVOTON
+
+config W90P910_ETH
+	tristate "Nuvoton w90p910 Ethernet support"
+	depends on ARM && ARCH_W90X900
+	select PHYLIB
+	select MII
+	---help---
+	  Say Y here if you want to use built-in Ethernet ports
+	  on w90p910 processor.
+
+endif # NET_VENDOR_NUVOTON
diff --git a/drivers/net/ethernet/nuvoton/Makefile b/drivers/net/ethernet/nuvoton/Makefile
new file mode 100644
index 0000000..171aa04
--- /dev/null
+++ b/drivers/net/ethernet/nuvoton/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Nuvoton network device drivers.
+#
+
+obj-$(CONFIG_W90P910_ETH) += w90p910_ether.o
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
similarity index 100%
rename from drivers/net/arm/w90p910_ether.c
rename to drivers/net/ethernet/nuvoton/w90p910_ether.c
-- 
1.7.6

