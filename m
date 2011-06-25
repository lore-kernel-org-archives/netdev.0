From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 11/72] cassini/niu/sun*: Move the Sun drivers
Date: Sat, 25 Jun 2011 06:58:22 -0700
Message-ID: <1309010363-22750-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sam Creasey <sammy@sammy.net>,
	Adrian Sun <asun@darksunrising.com>,
	Benjamin Herrenscmidt <benh@kernel.crashing.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979Ab1FYN74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:56 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Sun drivers into drivers/net/ethernet/sun/ and make
the necessary Kconfig and Makefile changes.

CC: Sam Creasey <sammy@sammy.net>
CC: Adrian Sun <asun@darksunrising.com>
CC: Benjamin Herrenscmidt <benh@kernel.crashing.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                 |    1 +
 drivers/net/Kconfig                         |   75 ----------------------
 drivers/net/Makefile                        |   11 +---
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/sun/Kconfig            |   91 +++++++++++++++++++++++++++
 drivers/net/ethernet/sun/Makefile           |   12 ++++
 drivers/net/{ => ethernet/sun}/cassini.c    |    0
 drivers/net/{ => ethernet/sun}/cassini.h    |    0
 drivers/net/{ => ethernet/sun}/niu.c        |    0
 drivers/net/{ => ethernet/sun}/niu.h        |    0
 drivers/net/{ => ethernet/sun}/sun3_82586.c |    0
 drivers/net/{ => ethernet/sun}/sun3_82586.h |    0
 drivers/net/{ => ethernet/sun}/sunbmac.c    |    0
 drivers/net/{ => ethernet/sun}/sunbmac.h    |    0
 drivers/net/{ => ethernet/sun}/sungem.c     |    0
 drivers/net/{ => ethernet/sun}/sungem.h     |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.c |    0
 drivers/net/{ => ethernet/sun}/sungem_phy.h |    0
 drivers/net/{ => ethernet/sun}/sunhme.c     |    0
 drivers/net/{ => ethernet/sun}/sunhme.h     |    0
 drivers/net/{ => ethernet/sun}/sunqe.c      |    0
 drivers/net/{ => ethernet/sun}/sunqe.h      |    0
 drivers/net/{ => ethernet/sun}/sunvnet.c    |    0
 drivers/net/{ => ethernet/sun}/sunvnet.h    |    0
 drivers/net/spider_net.h                    |    2 +-
 26 files changed, 108 insertions(+), 86 deletions(-)
 create mode 100644 drivers/net/ethernet/sun/Kconfig
 create mode 100644 drivers/net/ethernet/sun/Makefile
 rename drivers/net/{ => ethernet/sun}/cassini.c (100%)
 rename drivers/net/{ => ethernet/sun}/cassini.h (100%)
 rename drivers/net/{ => ethernet/sun}/niu.c (100%)
 rename drivers/net/{ => ethernet/sun}/niu.h (100%)
 rename drivers/net/{ => ethernet/sun}/sun3_82586.c (100%)
 rename drivers/net/{ => ethernet/sun}/sun3_82586.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunbmac.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem.h (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.c (100%)
 rename drivers/net/{ => ethernet/sun}/sungem_phy.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunhme.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunqe.h (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.c (100%)
 rename drivers/net/{ => ethernet/sun}/sunvnet.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f567d4e..cc9c060 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6042,6 +6042,7 @@ S:	Maintained
 F:	arch/m68k/kernel/*sun3*
 F:	arch/m68k/sun3*/
 F:	arch/m68k/include/asm/sun3*
+F:	drivers/net/ethernet/sun/sun3*
 
 SUPERH
 M:	Paul Mundt <lethal@linux-sh.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8c57e20..7ac2b56 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -345,15 +345,6 @@ config BVME6000_NET
 	  in your kernel.
 	  To compile this driver as a module, choose M here.
 
-config SUN3_82586
-	bool "Sun3 on-board Intel 82586 support"
-	depends on SUN3
-	help
-	  This driver enables support for the on-board Intel 82586 based
-	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
-	  that this driver does not support 82586-based adapters on additional
-	  VME boards.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
@@ -434,64 +425,6 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
 
-config HAPPYMEAL
-	tristate "Sun Happy Meal 10/100baseT support"
-	depends on SBUS || PCI
-	select CRC32
-	help
-	  This driver supports the "hme" interface present on most Ultra
-	  systems and as an option on older Sbus systems. This driver supports
-	  both PCI and Sbus devices. This driver also supports the "qfe" quad
-	  100baseT device available in both PCI and Sbus configurations.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunhme.
-
-config SUNBMAC
-	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
-	depends on SBUS && EXPERIMENTAL
-	select CRC32
-	help
-	  This driver supports the "be" interface available as an Sbus option.
-	  This is Sun's older 100baseT Ethernet device.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunbmac.
-
-config SUNQE
-	tristate "Sun QuadEthernet support"
-	depends on SBUS
-	select CRC32
-	help
-	  This driver supports the "qe" 10baseT Ethernet device, available as
-	  an Sbus option. Note that this is not the same as Quad FastEthernet
-	  "qfe" which is supported by the Happy Meal driver instead.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunqe.
-
-config SUNGEM
-	tristate "Sun GEM support"
-	depends on PCI
-	select CRC32
-	help
-	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
-	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
-
-config CASSINI
-	tristate "Sun Cassini support"
-	depends on PCI
-	select CRC32
-	help
-	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
-	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/817-4341-10.pdf>
-
-config SUNVNET
-	tristate "Sun Virtual Network support"
-	depends on SUN_LDOMS
-	help
-	  Support for virtual network devices under Sun Logical Domains.
-
 config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
 	depends on NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
@@ -1795,14 +1728,6 @@ config MYRI10GE_DCA
 	  driver.  DCA is a method for warming the CPU cache before data
 	  is used, with the intent of lessening the impact of cache misses.
 
-config NIU
-	tristate "Sun Neptune 10Gbit Ethernet support"
-	depends on PCI
-	select CRC32
-	help
-	  This enables support for cards based upon Sun's
-	  Neptune chipset.
-
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC_PASEMI && PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 111fc02..60880d2 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -44,13 +44,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_HAPPYMEAL) += sunhme.o
-obj-$(CONFIG_SUNQE) += sunqe.o
-obj-$(CONFIG_SUNBMAC) += sunbmac.o
-obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
-obj-$(CONFIG_CASSINI) += cassini.o
-obj-$(CONFIG_SUNVNET) += sunvnet.o
-
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
@@ -65,7 +58,7 @@ obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
@@ -132,7 +125,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
-obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
@@ -226,7 +218,6 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
 obj-$(CONFIG_FS_ENET) += fs_enet/
 
-obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 50c118c..82d7438 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -20,5 +20,6 @@ source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
+source "drivers/net/ethernet/sun/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 37d891d..a3ce80c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
+obj-$(CONFIG_NET_VENDOR_SUN) += sun/
diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
new file mode 100644
index 0000000..fe80457
--- /dev/null
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -0,0 +1,91 @@
+#
+# Sun network device configuration
+#
+
+config NET_VENDOR_SUN
+	bool "Sun devices"
+	depends on SUN3 || SBUS || PCI || SUN_LDOMS
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say
+	  Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Sun network interfaces. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config SUN3_82586
+	bool "Sun3 on-board Intel 82586 support"
+	depends on NET_VENDOR_SUN && SUN3
+	---help---
+	  This driver enables support for the on-board Intel 82586 based
+	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
+	  that this driver does not support 82586-based adapters on additional
+	  VME boards.
+
+config HAPPYMEAL
+	tristate "Sun Happy Meal 10/100baseT support"
+	depends on NET_VENDOR_SUN && (SBUS || PCI)
+	select CRC32
+	---help---
+	  This driver supports the "hme" interface present on most Ultra
+	  systems and as an option on older Sbus systems. This driver supports
+	  both PCI and Sbus devices. This driver also supports the "qfe" quad
+	  100baseT device available in both PCI and Sbus configurations.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunhme.
+
+config SUNBMAC
+	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
+	depends on NET_VENDOR_SUN && SBUS && EXPERIMENTAL
+	select CRC32
+	---help---
+	  This driver supports the "be" interface available as an Sbus option.
+	  This is Sun's older 100baseT Ethernet device.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunbmac.
+
+config SUNQE
+	tristate "Sun QuadEthernet support"
+	depends on NET_VENDOR_SUN && SBUS
+	select CRC32
+	---help---
+	  This driver supports the "qe" 10baseT Ethernet device, available as
+	  an Sbus option. Note that this is not the same as Quad FastEthernet
+	  "qfe" which is supported by the Happy Meal driver instead.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunqe.
+
+config SUNGEM
+	tristate "Sun GEM support"
+	depends on NET_VENDOR_SUN && PCI
+	select CRC32
+	---help---
+	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
+	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/806-3985-10.pdf>.
+
+config CASSINI
+	tristate "Sun Cassini support"
+	depends on NET_VENDOR_SUN && PCI
+	select CRC32
+	---help---
+	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
+	  <http://www.sun.com/products-n-solutions/hardware/docs/pdf/817-4341-10.pdf>
+
+config SUNVNET
+	tristate "Sun Virtual Network support"
+	depends on NET_VENDOR_SUN && SUN_LDOMS
+	---help---
+	  Support for virtual network devices under Sun Logical Domains.
+
+config NIU
+	tristate "Sun Neptune 10Gbit Ethernet support"
+	depends on NET_VENDOR_SUN && PCI
+	select CRC32
+	---help---
+	  This enables support for cards based upon Sun's
+	  Neptune chipset.
diff --git a/drivers/net/ethernet/sun/Makefile b/drivers/net/ethernet/sun/Makefile
new file mode 100644
index 0000000..da1cbb8
--- /dev/null
+++ b/drivers/net/ethernet/sun/Makefile
@@ -0,0 +1,12 @@
+#
+# Makefile for the Sun network device drivers.
+#
+
+obj-$(CONFIG_SUN3_82586) += sun3_82586.o
+obj-$(CONFIG_HAPPYMEAL) += sunhme.o
+obj-$(CONFIG_SUNQE) += sunqe.o
+obj-$(CONFIG_SUNBMAC) += sunbmac.o
+obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
+obj-$(CONFIG_CASSINI) += cassini.o
+obj-$(CONFIG_SUNVNET) += sunvnet.o
+obj-$(CONFIG_NIU) += niu.o
diff --git a/drivers/net/cassini.c b/drivers/net/ethernet/sun/cassini.c
similarity index 100%
rename from drivers/net/cassini.c
rename to drivers/net/ethernet/sun/cassini.c
diff --git a/drivers/net/cassini.h b/drivers/net/ethernet/sun/cassini.h
similarity index 100%
rename from drivers/net/cassini.h
rename to drivers/net/ethernet/sun/cassini.h
diff --git a/drivers/net/niu.c b/drivers/net/ethernet/sun/niu.c
similarity index 100%
rename from drivers/net/niu.c
rename to drivers/net/ethernet/sun/niu.c
diff --git a/drivers/net/niu.h b/drivers/net/ethernet/sun/niu.h
similarity index 100%
rename from drivers/net/niu.h
rename to drivers/net/ethernet/sun/niu.h
diff --git a/drivers/net/sun3_82586.c b/drivers/net/ethernet/sun/sun3_82586.c
similarity index 100%
rename from drivers/net/sun3_82586.c
rename to drivers/net/ethernet/sun/sun3_82586.c
diff --git a/drivers/net/sun3_82586.h b/drivers/net/ethernet/sun/sun3_82586.h
similarity index 100%
rename from drivers/net/sun3_82586.h
rename to drivers/net/ethernet/sun/sun3_82586.h
diff --git a/drivers/net/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
similarity index 100%
rename from drivers/net/sunbmac.c
rename to drivers/net/ethernet/sun/sunbmac.c
diff --git a/drivers/net/sunbmac.h b/drivers/net/ethernet/sun/sunbmac.h
similarity index 100%
rename from drivers/net/sunbmac.h
rename to drivers/net/ethernet/sun/sunbmac.h
diff --git a/drivers/net/sungem.c b/drivers/net/ethernet/sun/sungem.c
similarity index 100%
rename from drivers/net/sungem.c
rename to drivers/net/ethernet/sun/sungem.c
diff --git a/drivers/net/sungem.h b/drivers/net/ethernet/sun/sungem.h
similarity index 100%
rename from drivers/net/sungem.h
rename to drivers/net/ethernet/sun/sungem.h
diff --git a/drivers/net/sungem_phy.c b/drivers/net/ethernet/sun/sungem_phy.c
similarity index 100%
rename from drivers/net/sungem_phy.c
rename to drivers/net/ethernet/sun/sungem_phy.c
diff --git a/drivers/net/sungem_phy.h b/drivers/net/ethernet/sun/sungem_phy.h
similarity index 100%
rename from drivers/net/sungem_phy.h
rename to drivers/net/ethernet/sun/sungem_phy.h
diff --git a/drivers/net/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
similarity index 100%
rename from drivers/net/sunhme.c
rename to drivers/net/ethernet/sun/sunhme.c
diff --git a/drivers/net/sunhme.h b/drivers/net/ethernet/sun/sunhme.h
similarity index 100%
rename from drivers/net/sunhme.h
rename to drivers/net/ethernet/sun/sunhme.h
diff --git a/drivers/net/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
similarity index 100%
rename from drivers/net/sunqe.c
rename to drivers/net/ethernet/sun/sunqe.c
diff --git a/drivers/net/sunqe.h b/drivers/net/ethernet/sun/sunqe.h
similarity index 100%
rename from drivers/net/sunqe.h
rename to drivers/net/ethernet/sun/sunqe.h
diff --git a/drivers/net/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
similarity index 100%
rename from drivers/net/sunvnet.c
rename to drivers/net/ethernet/sun/sunvnet.c
diff --git a/drivers/net/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
similarity index 100%
rename from drivers/net/sunvnet.h
rename to drivers/net/ethernet/sun/sunvnet.h
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index 020f64a..a891ad0 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -27,7 +27,7 @@
 
 #define VERSION "2.0 B"
 
-#include "sungem_phy.h"
+#include "./ethernet/sun/sungem_phy.h"
 
 extern int spider_net_stop(struct net_device *netdev);
 extern int spider_net_open(struct net_device *netdev);
-- 
1.7.5.4

