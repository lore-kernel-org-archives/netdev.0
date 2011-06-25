From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 20/72] pasemic_mac*: Move the PA Semi driver
Date: Sat, 25 Jun 2011 06:58:31 -0700
Message-ID: <1309010363-22750-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Olof Johansson <olof@lixom.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165Ab1FYOAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:09 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the PA Semi driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Olof Johansson <olof@lixom.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                     |    2 +-
 drivers/net/Kconfig                             |    9 ---------
 drivers/net/Makefile                            |    2 --
 drivers/net/ethernet/Kconfig                    |   10 ++++++++++
 drivers/net/ethernet/Makefile                   |    1 +
 drivers/net/{ => ethernet}/pasemi_mac.c         |    0
 drivers/net/{ => ethernet}/pasemi_mac.h         |    0
 drivers/net/{ => ethernet}/pasemi_mac_ethtool.c |    0
 8 files changed, 12 insertions(+), 12 deletions(-)
 rename drivers/net/{ => ethernet}/pasemi_mac.c (100%)
 rename drivers/net/{ => ethernet}/pasemi_mac.h (100%)
 rename drivers/net/{ => ethernet}/pasemi_mac_ethtool.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5fd73ec..65f1282 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4719,7 +4719,7 @@ PA SEMI ETHERNET DRIVER
 M:	Olof Johansson <olof@lixom.net>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/pasemi_mac.*
+F:	drivers/net/ethernet/pasemi_mac*
 
 PA SEMI SMBUS DRIVER
 M:	Olof Johansson <olof@lixom.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 802e246..de6ff15 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1625,15 +1625,6 @@ if NETDEV_10000
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
index 6198d42..a7bbf98 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -166,8 +166,6 @@ obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
-obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
-pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 9b333a7..3174234 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,16 @@ source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
+
+config PASEMI_MAC
+	tristate "PA Semi 1/10Gbit MAC"
+	depends on PPC_PASEMI && PCI && INET
+	select PHYLIB
+	select INET_LRO
+	---help---
+	  This driver supports the on-chip 1/10Gbit Ethernet controller on
+	  PA Semi's PWRficient line of chips.
+
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6f14a35..a7eee02 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
+obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/ethernet/pasemi_mac.c
similarity index 100%
rename from drivers/net/pasemi_mac.c
rename to drivers/net/ethernet/pasemi_mac.c
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/ethernet/pasemi_mac.h
similarity index 100%
rename from drivers/net/pasemi_mac.h
rename to drivers/net/ethernet/pasemi_mac.h
diff --git a/drivers/net/pasemi_mac_ethtool.c b/drivers/net/ethernet/pasemi_mac_ethtool.c
similarity index 100%
rename from drivers/net/pasemi_mac_ethtool.c
rename to drivers/net/ethernet/pasemi_mac_ethtool.c
-- 
1.7.5.4

