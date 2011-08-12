From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ks8*/ksz8*: Move the Micrel drivers
Date: Fri, 12 Aug 2011 00:33:03 -0700
Message-ID: <1313134384-7287-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ben Dooks <ben@simtec.co.uk>,
	Tristram Ha <Tristram.Ha@micrel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58632 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921Ab1HLHdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:14 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Micrel drivers into drivers/net/ethernet/micrel/ and
make the necessary Kconfig and Makefile changes.

CC: Ben Dooks <ben@simtec.co.uk>
CC: Tristram Ha <Tristram.Ha@micrel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                              |   35 ------------
 drivers/net/Makefile                             |    4 --
 drivers/net/arm/Kconfig                          |    8 ---
 drivers/net/arm/Makefile                         |    1 -
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/micrel/Kconfig              |   64 ++++++++++++++++++++++
 drivers/net/ethernet/micrel/Makefile             |    9 +++
 drivers/net/{arm => ethernet/micrel}/ks8695net.c |    0
 drivers/net/{arm => ethernet/micrel}/ks8695net.h |    0
 drivers/net/{ => ethernet/micrel}/ks8842.c       |    0
 drivers/net/{ => ethernet/micrel}/ks8851.c       |    0
 drivers/net/{ => ethernet/micrel}/ks8851.h       |    0
 drivers/net/{ => ethernet/micrel}/ks8851_mll.c   |    0
 drivers/net/{ => ethernet/micrel}/ksz884x.c      |    0
 15 files changed, 75 insertions(+), 48 deletions(-)
 create mode 100644 drivers/net/ethernet/micrel/Kconfig
 create mode 100644 drivers/net/ethernet/micrel/Makefile
 rename drivers/net/{arm => ethernet/micrel}/ks8695net.c (100%)
 rename drivers/net/{arm => ethernet/micrel}/ks8695net.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8842.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851.h (100%)
 rename drivers/net/{ => ethernet/micrel}/ks8851_mll.c (100%)
 rename drivers/net/{ => ethernet/micrel}/ksz884x.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b645a73..a6edd354 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -467,17 +467,6 @@ config ADAPTEC_STARFIRE
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
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI
@@ -550,30 +539,6 @@ config TLAN
 
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
 config CPMAC
 	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
 	depends on NET_ETHERNET && EXPERIMENTAL && AR7
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 39fe730..e448e6e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -36,10 +36,6 @@ gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
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
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index b6f7302..4f748cc 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -11,14 +11,6 @@ config ARM_AT91_ETHER
 	  If you wish to compile a kernel for the AT91RM9200 and enable
 	  ethernet support, then you should always answer Y to this.
 
-config ARM_KS8695_ETHER
-	tristate "KS8695 Ethernet support"
-	depends on ARM && ARCH_KS8695
-	select MII
-	help
-	  If you wish to compile a kernel for the KS8695 and want to
-	  use the internal ethernet then you should answer Y to this.
-
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index a2532e6..316b06c 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -4,6 +4,5 @@
 #
 
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
-obj-$(CONFIG_ARM_KS8695_ETHER)	+= ks8695net.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
 obj-$(CONFIG_W90P910_ETH)	+= w90p910_ether.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 924c287..d90f47f3 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -32,6 +32,7 @@ source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/xscale/Kconfig"
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
+source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 025d7b7..cf27ae0 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
+obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
new file mode 100644
index 0000000..4227de6
--- /dev/null
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -0,0 +1,64 @@
+#
+# Micrel device configuration
+#
+
+config NET_VENDOR_MICREL
+	bool "Micrel devices"
+	depends on (HAS_IOMEM && DMA_ENGINE) || SPI || PCI || HAS_IOMEM || \
+		   (ARM && ARCH_KS8695)
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
+if NET_VENDOR_MICREL
+
+config ARM_KS8695_ETHER
+	tristate "KS8695 Ethernet support"
+	depends on ARM && ARCH_KS8695
+	select MII
+	---help---
+	  If you wish to compile a kernel for the KS8695 and want to
+	  use the internal ethernet then you should answer Y to this.
+
+config KS8842
+	tristate "Micrel KSZ8841/42 with generic bus interface"
+	depends on HAS_IOMEM && DMA_ENGINE
+	---help---
+	  This platform driver is for KSZ8841(1-port) / KS8842(2-port)
+	  ethernet switch chip (managed, VLAN, QoS) from Micrel or
+	  Timberdale(FPGA).
+
+config KS8851
+	tristate "Micrel KS8851 SPI"
+	depends on SPI
+	select MII
+	select CRC32
+	---help---
+	  SPI driver for Micrel KS8851 SPI attached network chip.
+
+config KS8851_MLL
+	tristate "Micrel KS8851 MLL"
+	depends on HAS_IOMEM
+	select MII
+	---help---
+	  This platform driver is for Micrel KS8851 Address/data bus
+	  multiplexed network chip.
+
+config KSZ884X_PCI
+	tristate "Micrel KSZ8841/2 PCI"
+	depends on PCI
+	select MII
+	select CRC32
+	---help---
+	  This PCI driver is for Micrel KSZ8841/KSZ8842 PCI Ethernet chip.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ksz884x.
+
+endif # NET_VENDOR_MICREL
diff --git a/drivers/net/ethernet/micrel/Makefile b/drivers/net/ethernet/micrel/Makefile
new file mode 100644
index 0000000..c83e4bc
--- /dev/null
+++ b/drivers/net/ethernet/micrel/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the Micrel network device drivers.
+#
+
+obj-$(CONFIG_ARM_KS8695_ETHER) += ks8695net.o
+obj-$(CONFIG_KS8842) += ks8842.o
+obj-$(CONFIG_KS8851) += ks8851.o
+obj-$(CONFIG_KS8851_MLL) += ks8851_mll.o
+obj-$(CONFIG_KSZ884X_PCI) += ksz884x.o
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
similarity index 100%
rename from drivers/net/arm/ks8695net.c
rename to drivers/net/ethernet/micrel/ks8695net.c
diff --git a/drivers/net/arm/ks8695net.h b/drivers/net/ethernet/micrel/ks8695net.h
similarity index 100%
rename from drivers/net/arm/ks8695net.h
rename to drivers/net/ethernet/micrel/ks8695net.h
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
1.7.6

