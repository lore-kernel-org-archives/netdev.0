From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 21/71] pasemic_mac*: Move the PA Semi driver
Date: Sat, 30 Jul 2011 20:26:40 -0700
Message-ID: <1312082850-24914-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Olof Johansson <olof@lixom.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198Ab1GaD1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:52 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the PA Semi driver into drivers/net/ethernet/pasemi/ and
make the necessary Kconfig and Makefile changes.

CC: Olof Johansson <olof@lixom.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Olof Johansson <olof@lixom.net>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    9 -------
 drivers/net/Makefile                               |    2 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/pasemi/Kconfig                |   25 ++++++++++++++++++++
 drivers/net/ethernet/pasemi/Makefile               |    5 ++++
 drivers/net/{ => ethernet/pasemi}/pasemi_mac.c     |    0
 drivers/net/{ => ethernet/pasemi}/pasemi_mac.h     |    0
 .../net/{ => ethernet/pasemi}/pasemi_mac_ethtool.c |    0
 10 files changed, 33 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/pasemi/Kconfig
 create mode 100644 drivers/net/ethernet/pasemi/Makefile
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac.c (100%)
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac.h (100%)
 rename drivers/net/{ => ethernet/pasemi}/pasemi_mac_ethtool.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index e3d41a5..da22b40 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4758,7 +4758,7 @@ PA SEMI ETHERNET DRIVER
 M:	Olof Johansson <olof@lixom.net>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/pasemi_mac.*
+F:	drivers/net/ethernet/pasemi/*
 
 PA SEMI SMBUS DRIVER
 M:	Olof Johansson <olof@lixom.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3090c98..becb786 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1442,15 +1442,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config PASEMI_MAC
-	tristate "PA Semi 1/10Gbit MAC"
-	depends on PPC_PASEMI && PCI && INET
-	select PHYLIB
-	select INET_LRO
-	help
-	  This driver supports the on-chip 1/10Gbit Ethernet controller on
-	  PA Semi's PWRficient line of chips.
-
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 2a50b73..b396475 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -146,8 +146,6 @@ obj-$(CONFIG_R8169) += r8169.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
-obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
-pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 18b634e..16c206e 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -25,6 +25,7 @@ source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
+source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 288179b..a52dc26 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
+obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/pasemi/Kconfig b/drivers/net/ethernet/pasemi/Kconfig
new file mode 100644
index 0000000..97beb45
--- /dev/null
+++ b/drivers/net/ethernet/pasemi/Kconfig
@@ -0,0 +1,25 @@
+#
+# PA Semi network device configuration
+#
+
+config NET_VENDOR_PASEMI
+	bool "PA Semi devices"
+	depends on PPC_PASEMI && PCI && INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about PA Semi cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config PASEMI_MAC
+	tristate "PA Semi 1/10Gbit MAC"
+	depends on NET_VENDOR_PASEMI && PPC_PASEMI && PCI && INET
+	select PHYLIB
+	select INET_LRO
+	---help---
+	  This driver supports the on-chip 1/10Gbit Ethernet controller on
+	  PA Semi's PWRficient line of chips.
diff --git a/drivers/net/ethernet/pasemi/Makefile b/drivers/net/ethernet/pasemi/Makefile
new file mode 100644
index 0000000..05db543
--- /dev/null
+++ b/drivers/net/ethernet/pasemi/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the A Semi network device drivers.
+#
+
+obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
similarity index 100%
rename from drivers/net/pasemi_mac.c
rename to drivers/net/ethernet/pasemi/pasemi_mac.c
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
similarity index 100%
rename from drivers/net/pasemi_mac.h
rename to drivers/net/ethernet/pasemi/pasemi_mac.h
diff --git a/drivers/net/pasemi_mac_ethtool.c b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
similarity index 100%
rename from drivers/net/pasemi_mac_ethtool.c
rename to drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
-- 
1.7.6

