From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 59/72] r6040: Move the RDC driver
Date: Sat, 25 Jun 2011 06:59:10 -0700
Message-ID: <1309010363-22750-60-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sten Wang <sten.wang@rdc.com.tw>,
	Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533Ab1FYOAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:35 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the RDC driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Sten Wang <sten.wang@rdc.com.tw>
CC: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                        |    2 +-
 drivers/net/Kconfig                |   13 -------------
 drivers/net/Makefile               |    1 -
 drivers/net/ethernet/Kconfig       |   14 ++++++++++++++
 drivers/net/ethernet/Makefile      |    1 +
 drivers/net/{ => ethernet}/r6040.c |    0
 6 files changed, 16 insertions(+), 15 deletions(-)
 rename drivers/net/{ => ethernet}/r6040.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9ddb715..f1f555d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5258,7 +5258,7 @@ RDC R6040 FAST ETHERNET DRIVER
 M:	Florian Fainelli <florian@openwrt.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/r6040.c
+F:	drivers/net/ethernet/r6040.c
 
 RDS - RELIABLE DATAGRAM SOCKETS
 M:	Andy Grover <andy.grover@oracle.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 82da415..463e4cf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -404,19 +404,6 @@ config FEALNX
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet 
 	  cards. <http://www.myson.com.tw/>
 
-config R6040
-	tristate "RDC R6040 Fast Ethernet Adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	select PHYLIB
-	help
-	  This is a driver for the R6040 Fast Ethernet MACs found in the
-	  the RDC R-321x System-on-chips.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called r6040. This is recommended.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b7e875a..f57a0be 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -16,7 +16,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_SKFP) += skfp/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f5eb70e..3c10879 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -98,6 +98,20 @@ config PASEMI_MAC
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/radisys/Kconfig"
+
+config R6040
+	tristate "RDC R6040 Fast Ethernet Adapter support"
+	depends on PCI
+	select CRC32
+	select MII
+	select PHYLIB
+	---help---
+	  This is a driver for the R6040 Fast Ethernet MACs found in the
+	  the RDC R-321x System-on-chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called r6040. This is recommended.
+
 source "drivers/net/ethernet/realtek/Kconfig"
 
 config S6GMAC
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 2ccb194..537631b 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_RADISYS) += radisys/
+obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
diff --git a/drivers/net/r6040.c b/drivers/net/ethernet/r6040.c
similarity index 100%
rename from drivers/net/r6040.c
rename to drivers/net/ethernet/r6040.c
-- 
1.7.5.4

