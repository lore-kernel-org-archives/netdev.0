From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 71/72] sh_eth: Move the Renesas SuperH driver
Date: Sat, 25 Jun 2011 06:59:22 -0700
Message-ID: <1309010363-22750-72-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shirmoda.uh@renesas.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330Ab1FYOAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:39 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Renesas driver into drivers/net/ethernet/renesas/ and make
the necessary Kconfig and Makefile changes.

CC: Yoshihiro Shimoda <yoshihiro.shirmoda.uh@renesas.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                         |   15 ---------------
 drivers/net/Makefile                        |    1 -
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/renesas/Kconfig        |   18 ++++++++++++++++++
 drivers/net/ethernet/renesas/Makefile       |    5 +++++
 drivers/net/{ => ethernet/renesas}/sh_eth.c |    0
 drivers/net/{ => ethernet/renesas}/sh_eth.h |    0
 8 files changed, 25 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/renesas/Kconfig
 create mode 100644 drivers/net/ethernet/renesas/Makefile
 rename drivers/net/{ => ethernet/renesas}/sh_eth.c (100%)
 rename drivers/net/{ => ethernet/renesas}/sh_eth.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dfae2ec..07e798e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -221,21 +221,6 @@ menuconfig NET_ETHERNET
 
 if NET_ETHERNET
 
-config SH_ETH
-	tristate "Renesas SuperH Ethernet support"
-	depends on SUPERH && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
-		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
-		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7757)
-	select CRC32
-	select MII
-	select MDIO_BITBANG
-	select PHYLIB
-	help
-	  Renesas SuperH Ethernet device driver.
-	  This driver supporting CPUs are:
-		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c24b5ef..b9fc5a0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_ROADRUNNER) += rrunner.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_RIONET) += rionet.o
-obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 #
 # end link order section
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index b7d8d9b..ab12ecd 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -240,6 +240,7 @@ config R6040
 	  will be called r6040. This is recommended.
 
 source "drivers/net/ethernet/realtek/Kconfig"
+source "drivers/net/ethernet/renesas/Kconfig"
 
 config S6GMAC
 	tristate "S6105 GMAC ethernet support"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c1a1c61..c3fa3be 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_RADISYS) += radisys/
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
new file mode 100644
index 0000000..f57ae23
--- /dev/null
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -0,0 +1,18 @@
+#
+# Renesas device configuration
+#
+
+config SH_ETH
+	tristate "Renesas SuperH Ethernet support"
+	depends on SUPERH && \
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
+		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
+		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7757)
+	select CRC32
+	select MII
+	select MDIO_BITBANG
+	select PHYLIB
+	---help---
+	  Renesas SuperH Ethernet device driver.
+	  This driver supporting CPUs are:
+		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
diff --git a/drivers/net/ethernet/renesas/Makefile b/drivers/net/ethernet/renesas/Makefile
new file mode 100644
index 0000000..1c278a8
--- /dev/null
+++ b/drivers/net/ethernet/renesas/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Renesas device drivers.
+#
+
+obj-$(CONFIG_SH_ETH) += sh_eth.o
diff --git a/drivers/net/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
similarity index 100%
rename from drivers/net/sh_eth.c
rename to drivers/net/ethernet/renesas/sh_eth.c
diff --git a/drivers/net/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
similarity index 100%
rename from drivers/net/sh_eth.h
rename to drivers/net/ethernet/renesas/sh_eth.h
-- 
1.7.5.4

