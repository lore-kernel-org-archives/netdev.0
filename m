From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/71] cassini/niu/sun*: Move the Sun drivers
Date: Sat, 30 Jul 2011 20:26:31 -0700
Message-ID: <1312082850-24914-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Sam Creasey <sammy@sammy.net>,
	Adrian Sun <asun@darksunrising.com>,
	Benjamin Herrenscmidt <benh@kernel.crashing.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43146 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144Ab1GaD1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:46 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Sun drivers into drivers/net/ethernet/sun/ and make
the necessary Kconfig and Makefile changes.

Oliver Hartkopp <socketcan@hartkopp.net> suggested removing the
sun* prefix on the driver names.  This type of change I will
leave up to the driver maintainers.

CC: Sam Creasey <sammy@sammy.net>
CC: Adrian Sun <asun@darksunrising.com>
CC: Benjamin Herrenscmidt <benh@kernel.crashing.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                 |    1 +
 drivers/net/Kconfig                         |   66 ---------------------
 drivers/net/Makefile                        |   10 +---
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/sun/Kconfig            |   82 +++++++++++++++++++++++++++
 drivers/net/ethernet/sun/Makefile           |   11 ++++
 drivers/net/{ => ethernet/sun}/cassini.c    |    0
 drivers/net/{ => ethernet/sun}/cassini.h    |    0
 drivers/net/{ => ethernet/sun}/niu.c        |    0
 drivers/net/{ => ethernet/sun}/niu.h        |    0
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
 24 files changed, 98 insertions(+), 76 deletions(-)
 create mode 100644 drivers/net/ethernet/sun/Kconfig
 create mode 100644 drivers/net/ethernet/sun/Makefile
 rename drivers/net/{ => ethernet/sun}/cassini.c (100%)
 rename drivers/net/{ => ethernet/sun}/cassini.h (100%)
 rename drivers/net/{ => ethernet/sun}/niu.c (100%)
 rename drivers/net/{ => ethernet/sun}/niu.h (100%)
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
index e922c04..a0cc8ac8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6095,6 +6095,7 @@ S:	Maintained
 F:	arch/m68k/kernel/*sun3*
 F:	arch/m68k/sun3*/
 F:	arch/m68k/include/asm/sun3*
+F:	drivers/net/ethernet/i825xx/sun3*
 
 SUPERH
 M:	Paul Mundt <lethal@linux-sh.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b76de82..7977002 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -363,64 +363,6 @@ config SH_ETH
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
@@ -1603,14 +1545,6 @@ config MYRI10GE_DCA
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
index e641f70..cfbb060 100644
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
 
@@ -64,7 +57,7 @@ obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
@@ -207,7 +200,6 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
 obj-$(CONFIG_FS_ENET) += fs_enet/
 
-obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 7efbb7c..5edd237 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -21,5 +21,6 @@ source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
+source "drivers/net/ethernet/sun/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 86da8b8..18d8a89 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -12,3 +12,4 @@ obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
+obj-$(CONFIG_NET_VENDOR_SUN) += sun/
diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
new file mode 100644
index 0000000..84e06ec
--- /dev/null
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -0,0 +1,82 @@
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
index 0000000..4f25217
--- /dev/null
+++ b/drivers/net/ethernet/sun/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for the Sun network device drivers.
+#
+
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
1.7.6

