From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 44/72] s6gmac/tsi108_eth: Move the s6gmac/tsi108_eth drivers
Date: Sat, 25 Jun 2011 06:58:55 -0700
Message-ID: <1309010363-22750-45-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Oskar Schirmer <os@emlix.com>, Kong Lai <kong.lai@tundra.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab1FYOAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:10 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the s6gmac/tsi108_eth drivers to drivers/net/ethernet/ and
make the necessary Kconfig and Makefile changes.

CC: Oskar Schirmer <os@emlix.com>
CC: Kong Lai <kong.lai@tundra.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                     |   19 -------------------
 drivers/net/Makefile                    |    2 --
 drivers/net/ethernet/Kconfig            |   21 +++++++++++++++++++++
 drivers/net/ethernet/Makefile           |    2 ++
 drivers/net/{ => ethernet}/s6gmac.c     |    0
 drivers/net/{ => ethernet}/tsi108_eth.c |    0
 drivers/net/{ => ethernet}/tsi108_eth.h |    0
 7 files changed, 23 insertions(+), 21 deletions(-)
 rename drivers/net/{ => ethernet}/s6gmac.c (100%)
 rename drivers/net/{ => ethernet}/tsi108_eth.c (100%)
 rename drivers/net/{ => ethernet}/tsi108_eth.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ed588b5..981d7d8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -677,14 +677,6 @@ config YELLOWFIN
 	  To compile this driver as a module, choose M here: the module
 	  will be called yellowfin.  This is recommended.
 
-config TSI108_ETH
-	tristate "Tundra TSI108 gigabit Ethernet support"
-	depends on TSI108_BRIDGE
-	help
-	  This driver supports Tundra TSI108 gigabit Ethernet ports.
-	  To compile this driver as a module, choose M here: the module
-	  will be called tsi108_eth.
-
 config GELIC_NET
 	tristate "PS3 Gigabit Ethernet driver"
 	depends on PPC_PS3
@@ -728,17 +720,6 @@ config JME
 	  To compile this driver as a module, choose M here. The module
 	  will be called jme.
 
-config S6GMAC
-	tristate "S6105 GMAC ethernet support"
-	depends on XTENSA_VARIANT_S6000
-	select PHYLIB
-	help
-	  This driver supports the on chip ethernet device on the
-	  S6105 xtensa processor.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called s6gmac.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f9f3478..2bb8a4e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -43,7 +43,6 @@ obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
-obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
@@ -91,7 +90,6 @@ obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
-obj-$(CONFIG_S6GMAC) += s6gmac.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 9ade631..c23e7b5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -72,6 +72,18 @@ config PASEMI_MAC
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+
+config S6GMAC
+	tristate "S6105 GMAC ethernet support"
+	depends on XTENSA_VARIANT_S6000
+	select PHYLIB
+	---help---
+	  This driver supports the on chip ethernet device on the
+	  S6105 xtensa processor.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called s6gmac.
+
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
@@ -88,6 +100,15 @@ config TEHUTI
 	  Tehuti Networks 10G Ethernet NIC
 
 source "drivers/net/ethernet/tulip/Kconfig"
+
+config TSI108_ETH
+	tristate "Tundra TSI108 gigabit Ethernet support"
+	depends on TSI108_BRIDGE
+	---help---
+	  This driver supports Tundra TSI108 gigabit Ethernet ports.
+	  To compile this driver as a module, choose M here: the module
+	  will be called tsi108_eth.
+
 source "drivers/net/ethernet/via/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5704a3b..a243610 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
@@ -43,4 +44,5 @@ obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_NET_TULIP) += tulip/
+obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/s6gmac.c b/drivers/net/ethernet/s6gmac.c
similarity index 100%
rename from drivers/net/s6gmac.c
rename to drivers/net/ethernet/s6gmac.c
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/ethernet/tsi108_eth.c
similarity index 100%
rename from drivers/net/tsi108_eth.c
rename to drivers/net/ethernet/tsi108_eth.c
diff --git a/drivers/net/tsi108_eth.h b/drivers/net/ethernet/tsi108_eth.h
similarity index 100%
rename from drivers/net/tsi108_eth.h
rename to drivers/net/ethernet/tsi108_eth.h
-- 
1.7.5.4

