From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 35/72] via-*: Move the VIA drivers
Date: Sat, 25 Jun 2011 06:58:46 -0700
Message-ID: <1309010363-22750-36-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Roger Luethi <rl@hellgate.ch>,
	Francois Romieu <romieu@fr.zoreil.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071Ab1FYOAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:00 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the VIA drivers into drivers/net/ethernet/via/ and make the
necessary Kconfig and Makefile changes.

CC: Roger Luethi <rl@hellgate.ch>
CC: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                   |    4 +-
 drivers/net/Kconfig                           |   36 -----------------
 drivers/net/Makefile                          |    2 -
 drivers/net/ethernet/Kconfig                  |    1 +
 drivers/net/ethernet/Makefile                 |    1 +
 drivers/net/ethernet/via/Kconfig              |   52 +++++++++++++++++++++++++
 drivers/net/ethernet/via/Makefile             |    6 +++
 drivers/net/{ => ethernet/via}/via-rhine.c    |    0
 drivers/net/{ => ethernet/via}/via-velocity.c |    0
 drivers/net/{ => ethernet/via}/via-velocity.h |    0
 10 files changed, 62 insertions(+), 40 deletions(-)
 create mode 100644 drivers/net/ethernet/via/Kconfig
 create mode 100644 drivers/net/ethernet/via/Makefile
 rename drivers/net/{ => ethernet/via}/via-rhine.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 98b3caf..70df907 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6749,7 +6749,7 @@ F:	include/linux/vhost.h
 VIA RHINE NETWORK DRIVER
 M:	Roger Luethi <rl@hellgate.ch>
 S:	Maintained
-F:	drivers/net/via-rhine.c
+F:	drivers/net/ethernet/via/via-rhine.c
 
 VIAPRO SMBUS DRIVER
 M:	Jean Delvare <khali@linux-fr.org>
@@ -6777,7 +6777,7 @@ VIA VELOCITY NETWORK DRIVER
 M:	Francois Romieu <romieu@fr.zoreil.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/via-velocity.*
+F:	drivers/net/ethernet/via/via-velocity.*
 
 VLAN (802.1Q)
 M:	Patrick McHardy <kaber@trash.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1f0c3bf..bb68fac 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -767,30 +767,6 @@ config KS8851_MLL
 	  This platform driver is for Micrel KS8851 Address/data bus
 	  multiplexed network chip.
 
-config VIA_RHINE
-	tristate "VIA Rhine support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  If you have a VIA "Rhine" based network card (Rhine-I (VT86C100A),
-	  Rhine-II (VT6102), or Rhine-III (VT6105)), say Y here. Rhine-type
-	  Ethernet functions can also be found integrated on South Bridges
-	  (e.g. VT8235).
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called via-rhine.
-
-config VIA_RHINE_MMIO
-	bool "Use MMIO instead of PIO"
-	depends on VIA_RHINE
-	help
-	  This instructs the driver to use PCI shared memory (MMIO) instead of
-	  programmed I/O ports (PIO). Enabling this gives an improvement in
-	  processing time in parts of the driver.
-
-	  If unsure, say Y.
-
 config SC92031
 	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
@@ -967,18 +943,6 @@ config SIS190
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis190.  This is recommended.
 
-config VIA_VELOCITY
-	tristate "VIA Velocity support"
-	depends on PCI
-	select CRC32
-	select CRC_CCITT
-	select MII
-	help
-	  If you have a VIA "Velocity" based network card say Y here.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called via-velocity.
-
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
 	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f32b45c..47decf6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -48,8 +48,6 @@ obj-$(CONFIG_KS8842)	+= ks8842.o
 obj-$(CONFIG_KS8851)	+= ks8851.o
 obj-$(CONFIG_KS8851_MLL)	+= ks8851_mll.o
 obj-$(CONFIG_KSZ884X_PCI)	+= ksz884x.o
-obj-$(CONFIG_VIA_RHINE) += via-rhine.o
-obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 2795982..be94115 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -59,5 +59,6 @@ config TEHUTI
 	  Tehuti Networks 10G Ethernet NIC
 
 source "drivers/net/ethernet/tulip/Kconfig"
+source "drivers/net/ethernet/via/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index eb3d827..e07d818 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -35,3 +35,4 @@ obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_NET_TULIP) += tulip/
+obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
new file mode 100644
index 0000000..e606aa1
--- /dev/null
+++ b/drivers/net/ethernet/via/Kconfig
@@ -0,0 +1,52 @@
+#
+# VIA device configuration
+#
+
+config NET_VENDOR_VIA
+	bool "VIA devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about VIA devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config VIA_RHINE
+	tristate "VIA Rhine support"
+	depends on NET_VENDOR_VIA && PCI
+	select CRC32
+	select MII
+	---help---
+	  If you have a VIA "Rhine" based network card (Rhine-I (VT86C100A),
+	  Rhine-II (VT6102), or Rhine-III (VT6105)), say Y here. Rhine-type
+	  Ethernet functions can also be found integrated on South Bridges
+	  (e.g. VT8235).
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called via-rhine.
+
+config VIA_RHINE_MMIO
+	bool "Use MMIO instead of PIO"
+	depends on VIA_RHINE
+	---help---
+	  This instructs the driver to use PCI shared memory (MMIO) instead of
+	  programmed I/O ports (PIO). Enabling this gives an improvement in
+	  processing time in parts of the driver.
+
+	  If unsure, say Y.
+
+config VIA_VELOCITY
+	tristate "VIA Velocity support"
+	depends on NET_VENDOR_VIA && PCI
+	select CRC32
+	select CRC_CCITT
+	select MII
+	---help---
+	  If you have a VIA "Velocity" based network card say Y here.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called via-velocity.
diff --git a/drivers/net/ethernet/via/Makefile b/drivers/net/ethernet/via/Makefile
new file mode 100644
index 0000000..46c5d4a
--- /dev/null
+++ b/drivers/net/ethernet/via/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the VIA device drivers.
+#
+
+obj-$(CONFIG_VIA_RHINE) += via-rhine.o
+obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
diff --git a/drivers/net/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
similarity index 100%
rename from drivers/net/via-rhine.c
rename to drivers/net/ethernet/via/via-rhine.c
diff --git a/drivers/net/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
similarity index 100%
rename from drivers/net/via-velocity.c
rename to drivers/net/ethernet/via/via-velocity.c
diff --git a/drivers/net/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
similarity index 100%
rename from drivers/net/via-velocity.h
rename to drivers/net/ethernet/via/via-velocity.h
-- 
1.7.5.4

