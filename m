From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 38/72] ks8*/ksz8*: Move the Micrel drivers
Date: Sat, 25 Jun 2011 06:58:49 -0700
Message-ID: <1309010363-22750-39-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ben Dooks <ben@simtec.co.uk>,
	Tristram Ha <Tristram.Ha@micrel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148Ab1FYOAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:07 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Micrel drivers into drivers/net/ethernet/micrel/ and
make the necessary Kconfig and Makefile changes.

CC: Ben Dooks <ben@simtec.co.uk>
CC: Tristram Ha <Tristram.Ha@micrel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                            |   35 ----------------
 drivers/net/Makefile                           |    4 --
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/micrel/Kconfig            |   51 ++++++++++++++++++++++++
 drivers/net/ethernet/micrel/Makefile           |    8 ++++
 drivers/net/{ => ethernet/micrel}/ks8842.c     |    0
 drivers/net/{ => ethernet/micrel}/ks8851.c     |    0
 drivers/net/{ => ethernet/micrel}/ks8851.h     |    0
 drivers/net/{ => ethernet/micrel}/ks8851_mll.c |    0
 drivers/net/{ => ethernet/micrel}/ksz884x.c    |    0
 11 files changed, 61 insertions(+), 39 deletions(-)
 create mode 100644 drivers/net/ethernet/micrel/Kconfig
 create mode 100644 drivers/net/ethernet/micrel/Makefile
 rename drivers/net/{ => ethernet/micrel}/ks8842.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851_mll.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ksz884x.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 71efe31..be261ec 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -531,17 +531,6 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
-config KSZ884X_PCI
-	tristate "Micrel KSZ8841/2 PCI"
-	depends on NET_PCI && PCI
-	select MII
-	select CRC32
-	help
-	  This PCI driver is for Micrel KSZ8841/KSZ8842 PCI Ethernet chip.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ksz884x.
-
 config APRICOT
 	tristate "Apricot Xen-II on board Ethernet"
 	depends on NET_PCI && ISA
@@ -645,30 +634,6 @@ config TLAN
 
 	  Please email feedback to <torben.mathiasen@compaq.com>.
 
-config KS8842
-	tristate "Micrel KSZ8841/42 with generic bus interface"
-	depends on HAS_IOMEM && DMA_ENGINE
-	help
-	  This platform driver is for KSZ8841(1-port) / KS8842(2-port)
-	  ethernet switch chip (managed, VLAN, QoS) from Micrel or
-	  Timberdale(FPGA).
-
-config KS8851
-	tristate "Micrel KS8851 SPI"
-	depends on SPI
-	select MII
-	select CRC32
-	help
-	  SPI driver for Micrel KS8851 SPI attached network chip.
-
-config KS8851_MLL
-	tristate "Micrel KS8851 MLL"
-	depends on HAS_IOMEM
-	select MII
-	help
-	  This platform driver is for Micrel KS8851 Address/data bus
-	  multiplexed network chip.
-
 config SC92031
 	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0b1c240..c68cdea 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -32,10 +32,6 @@ gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKFP) += skfp/
-obj-$(CONFIG_KS8842)	+= ks8842.o
-obj-$(CONFIG_KS8851)	+= ks8851.o
-obj-$(CONFIG_KS8851_MLL)	+= ks8851_mll.o
-obj-$(CONFIG_KSZ884X_PCI)	+= ksz884x.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8654b69..f434fc8 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -28,6 +28,7 @@ source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
+source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a09193f..3a9f47d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
+obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_ISA) += isa/
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
new file mode 100644
index 0000000..c315bff
--- /dev/null
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -0,0 +1,51 @@
+#
+# Micrel device configuration
+#
+
+config NET_VENDOR_MICREL
+	bool "Micrel devices"
+	depends on HAS_IOMEM || DMA_ENGINE || SPI || PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Micrel devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config KS8842
+	tristate "Micrel KSZ8841/42 with generic bus interface"
+	depends on NET_VENDOR_MICREL && HAS_IOMEM && DMA_ENGINE
+	---help---
+	  This platform driver is for KSZ8841(1-port) / KS8842(2-port)
+	  ethernet switch chip (managed, VLAN, QoS) from Micrel or
+	  Timberdale(FPGA).
+
+config KS8851
+	tristate "Micrel KS8851 SPI"
+	depends on NET_VENDOR_MICREL && SPI
+	select MII
+	select CRC32
+	---help---
+	  SPI driver for Micrel KS8851 SPI attached network chip.
+
+config KS8851_MLL
+	tristate "Micrel KS8851 MLL"
+	depends on NET_VENDOR_MICREL && HAS_IOMEM
+	select MII
+	---help---
+	  This platform driver is for Micrel KS8851 Address/data bus
+	  multiplexed network chip.
+
+config KSZ884X_PCI
+	tristate "Micrel KSZ8841/2 PCI"
+	depends on NET_VENDOR_MICREL && PCI
+	select MII
+	select CRC32
+	---help---
+	  This PCI driver is for Micrel KSZ8841/KSZ8842 PCI Ethernet chip.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ksz884x.
diff --git a/drivers/net/ethernet/micrel/Makefile b/drivers/net/ethernet/micrel/Makefile
new file mode 100644
index 0000000..c050942
--- /dev/null
+++ b/drivers/net/ethernet/micrel/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the Micrel network device drivers.
+#
+
+obj-$(CONFIG_KS8842) += ks8842.o
+obj-$(CONFIG_KS8851) += ks8851.o
+obj-$(CONFIG_KS8851_MLL) += ks8851_mll.o
+obj-$(CONFIG_KSZ884X_PCI) += ksz884x.o
diff --git a/drivers/net/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
similarity index 100%
rename from drivers/net/ks8842.c
rename to drivers/net/ethernet/micrel/ks8842.c
diff --git a/drivers/net/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
similarity index 100%
rename from drivers/net/ks8851.c
rename to drivers/net/ethernet/micrel/ks8851.c
diff --git a/drivers/net/ks8851.h b/drivers/net/ethernet/micrel/ks8851.h
similarity index 100%
rename from drivers/net/ks8851.h
rename to drivers/net/ethernet/micrel/ks8851.h
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
similarity index 100%
rename from drivers/net/ks8851_mll.c
rename to drivers/net/ethernet/micrel/ks8851_mll.c
diff --git a/drivers/net/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
similarity index 100%
rename from drivers/net/ksz884x.c
rename to drivers/net/ethernet/micrel/ksz884x.c
-- 
1.7.5.4

