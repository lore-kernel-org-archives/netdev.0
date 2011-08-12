From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] via-*: Move the VIA drivers
Date: Fri, 12 Aug 2011 00:33:00 -0700
Message-ID: <1313134384-7287-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Roger Luethi <rl@hellgate.ch>,
	Francois Romieu <romieu@fr.zoreil.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58636 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1HLHdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:11 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the VIA drivers into drivers/net/ethernet/via/ and make the
necessary Kconfig and Makefile changes.

CC: Roger Luethi <rl@hellgate.ch>
CC: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                   |    4 +-
 drivers/net/Kconfig                           |   36 ----------------
 drivers/net/Makefile                          |    2 -
 drivers/net/ethernet/Kconfig                  |    1 +
 drivers/net/ethernet/Makefile                 |    1 +
 drivers/net/ethernet/via/Kconfig              |   56 +++++++++++++++++++++++++
 drivers/net/ethernet/via/Makefile             |    6 +++
 drivers/net/{ => ethernet/via}/via-rhine.c    |    0
 drivers/net/{ => ethernet/via}/via-velocity.c |    0
 drivers/net/{ => ethernet/via}/via-velocity.h |    0
 10 files changed, 66 insertions(+), 40 deletions(-)
 create mode 100644 drivers/net/ethernet/via/Kconfig
 create mode 100644 drivers/net/ethernet/via/Makefile
 rename drivers/net/{ => ethernet/via}/via-rhine.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.c (100%)
 rename drivers/net/{ => ethernet/via}/via-velocity.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index b9acfde..51d9281 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6988,7 +6988,7 @@ F:	include/linux/vhost.h
 VIA RHINE NETWORK DRIVER
 M:	Roger Luethi <rl@hellgate.ch>
 S:	Maintained
-F:	drivers/net/via-rhine.c
+F:	drivers/net/ethernet/via/via-rhine.c
 
 VIAPRO SMBUS DRIVER
 M:	Jean Delvare <khali@linux-fr.org>
@@ -7016,7 +7016,7 @@ VIA VELOCITY NETWORK DRIVER
 M:	Francois Romieu <romieu@fr.zoreil.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/via-velocity.*
+F:	drivers/net/ethernet/via/via-velocity.*
 
 VLAN (802.1Q)
 M:	Patrick McHardy <kaber@trash.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index cb6c694..c1e491a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -614,30 +614,6 @@ config KS8851_MLL
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
 config CPMAC
 	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
 	depends on NET_ETHERNET && EXPERIMENTAL && AR7
@@ -793,18 +769,6 @@ config SIS190
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
index 69ca6a0..7e1128f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -51,8 +51,6 @@ obj-$(CONFIG_KS8842)	+= ks8842.o
 obj-$(CONFIG_KS8851)	+= ks8851.o
 obj-$(CONFIG_KS8851_MLL)	+= ks8851_mll.o
 obj-$(CONFIG_KSZ884X_PCI)	+= ksz884x.o
-obj-$(CONFIG_VIA_RHINE) += via-rhine.o
-obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 1c447d9..bdc0df8 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -45,5 +45,6 @@ source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
+source "drivers/net/ethernet/via/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 48c8656..ac60ac9 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -36,3 +36,4 @@ obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
+obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
new file mode 100644
index 0000000..7199194
--- /dev/null
+++ b/drivers/net/ethernet/via/Kconfig
@@ -0,0 +1,56 @@
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
+if NET_VENDOR_VIA
+
+config VIA_RHINE
+	tristate "VIA Rhine support"
+	depends on PCI
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
+	depends on PCI
+	select CRC32
+	select CRC_CCITT
+	select MII
+	---help---
+	  If you have a VIA "Velocity" based network card say Y here.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called via-velocity.
+
+endif # NET_VENDOR_VIA
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
1.7.6

