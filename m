From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 68/71] sh_eth: Move the Renesas SuperH driver
Date: Sat, 30 Jul 2011 20:27:27 -0700
Message-ID: <1312082850-24914-69-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Yoshihiro Shimoda <yoshihiro.shirmoda.uh@renesas.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63626 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab1GaD2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:52 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index b3da0bd..a4d2704 100644
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
index 8fa5b60..620abd7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,6 @@ obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_RIONET) += rionet.o
-obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 #
 # end link order section
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6e36196..df8940d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -133,6 +133,7 @@ source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+source "drivers/net/ethernet/renesas/Kconfig"
 source "drivers/net/ethernet/rdc/Kconfig"
 
 config S6GMAC
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c274820..09f26b6 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
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
1.7.6

