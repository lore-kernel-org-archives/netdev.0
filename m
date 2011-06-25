From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 40/72] spider_net: Move the spider_net (IBM) driver
Date: Sat, 25 Jun 2011 06:58:51 -0700
Message-ID: <1309010363-22750-41-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128Ab1FYOAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:06 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the spider_net (IBM) driver into drivers/net/ethernet/ibm/ and
make the necessary Kconfig and Makefile changes

CC: Utz Bacher <utz.bacher@de.ibm.com>
CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    8 --------
 drivers/net/Makefile                               |    2 --
 drivers/net/ethernet/ibm/Kconfig                   |   11 ++++++++++-
 drivers/net/ethernet/ibm/Makefile                  |    2 ++
 drivers/net/{ => ethernet/ibm}/spider_net.c        |    0
 drivers/net/{ => ethernet/ibm}/spider_net.h        |    2 +-
 .../net/{ => ethernet/ibm}/spider_net_ethtool.c    |    0
 8 files changed, 14 insertions(+), 13 deletions(-)
 rename drivers/net/{ => ethernet/ibm}/spider_net.c (100%)
 rename drivers/net/{ => ethernet/ibm}/spider_net.h (99%)
 rename drivers/net/{ => ethernet/ibm}/spider_net_ethtool.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 27bb4a2..7fa33bd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5992,7 +5992,7 @@ M:	Jens Osterkamp <jens@de.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	Documentation/networking/spider_net.txt
-F:	drivers/net/spider_net*
+F:	drivers/net/ethernet/ibm/spider_net*
 
 SPU FILE SYSTEM
 M:	Jeremy Kerr <jk@ozlabs.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4bfd5e3..b8894ad 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -797,14 +797,6 @@ config SIS190
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis190.  This is recommended.
 
-config SPIDER_NET
-	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
-	select FW_LOADER
-	help
-	  This driver supports the Gigabit Ethernet chips present on the
-	  Cell Processor-Based Blades from IBM.
-
 config TSI108_ETH
 	tristate "Tundra TSI108 gigabit Ethernet support"
 	depends on TSI108_BRIDGE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3aca65c..fe9b44c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -25,8 +25,6 @@ obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_FEALNX) += fealnx.o
-spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
index ac755a3..54fcdcb 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -4,7 +4,8 @@
 
 config NET_VENDOR_IBM
 	bool "IBM devices"
-	depends on MCA || PPC_PSERIES || PPC_DCR || IBMEBUS
+	depends on MCA || PPC_PSERIES || PPC_DCR || IBMEBUS || (PCI && \
+		  (PPC_IBM_CELL_BLADE || PPC_CELLEB))
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -51,3 +52,11 @@ config EHEA
 
 	  To compile the driver as a module, choose M here. The module
 	  will be called ehea.
+
+config SPIDER_NET
+	tristate "Spider Gigabit Ethernet driver"
+	depends on NET_VENDOR_IBM && PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
+	select FW_LOADER
+	---help---
+	  This driver supports the Gigabit Ethernet chips present on the
+	  Cell Processor-Based Blades from IBM.
diff --git a/drivers/net/ethernet/ibm/Makefile b/drivers/net/ethernet/ibm/Makefile
index a63a8c3..76c1646 100644
--- a/drivers/net/ethernet/ibm/Makefile
+++ b/drivers/net/ethernet/ibm/Makefile
@@ -6,3 +6,5 @@ obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_EHEA) += ehea/
+spidernet-y += spider_net.o spider_net_ethtool.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o ../sun/sungem_phy.o
diff --git a/drivers/net/spider_net.c b/drivers/net/ethernet/ibm/spider_net.c
similarity index 100%
rename from drivers/net/spider_net.c
rename to drivers/net/ethernet/ibm/spider_net.c
diff --git a/drivers/net/spider_net.h b/drivers/net/ethernet/ibm/spider_net.h
similarity index 99%
rename from drivers/net/spider_net.h
rename to drivers/net/ethernet/ibm/spider_net.h
index a891ad0..9bfce7c 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/ethernet/ibm/spider_net.h
@@ -27,7 +27,7 @@
 
 #define VERSION "2.0 B"
 
-#include "./ethernet/sun/sungem_phy.h"
+#include "../sun/sungem_phy.h"
 
 extern int spider_net_stop(struct net_device *netdev);
 extern int spider_net_open(struct net_device *netdev);
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/ethernet/ibm/spider_net_ethtool.c
similarity index 100%
rename from drivers/net/spider_net_ethtool.c
rename to drivers/net/ethernet/ibm/spider_net_ethtool.c
-- 
1.7.5.4

