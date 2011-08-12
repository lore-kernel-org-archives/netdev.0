From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] tsi108*: Move the Tundra driver
Date: Fri, 12 Aug 2011 03:52:45 -0700
Message-ID: <1313146371-6562-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kong Lai <kong.lai@tundra.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54710 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478Ab1HLKw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:56 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tundra driver to drivers/net/ethernet/tundra/ and
make the necessary Kocnfig and Makefile changes.

CC: Kong Lai <kong.lai@tundra.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                            |    8 ------
 drivers/net/Makefile                           |    1 -
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/tundra/Kconfig            |   28 ++++++++++++++++++++++++
 drivers/net/ethernet/tundra/Makefile           |    5 ++++
 drivers/net/{ => ethernet/tundra}/tsi108_eth.c |    0
 drivers/net/{ => ethernet/tundra}/tsi108_eth.h |    0
 8 files changed, 35 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/ethernet/tundra/Kconfig
 create mode 100644 drivers/net/ethernet/tundra/Makefile
 rename drivers/net/{ => ethernet/tundra}/tsi108_eth.c (100%)
 rename drivers/net/{ => ethernet/tundra}/tsi108_eth.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 33df254..a96cf18 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -623,14 +623,6 @@ config YELLOWFIN
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
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	depends on PPC || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3b14f1a..d7ac2f8 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -42,7 +42,6 @@ obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
-obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3893065..8f404ea 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -52,6 +52,7 @@ source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/toshiba/Kconfig"
+source "drivers/net/ethernet/tundra/Kconfig"
 source "drivers/net/ethernet/via/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e1f0b94..6cf7f99 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -43,4 +43,5 @@ obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
+obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/tundra/Kconfig b/drivers/net/ethernet/tundra/Kconfig
new file mode 100644
index 0000000..03925d1
--- /dev/null
+++ b/drivers/net/ethernet/tundra/Kconfig
@@ -0,0 +1,28 @@
+#
+# Tundra network device configuration
+#
+
+config NET_VENDOR_TUNDRA
+	bool "Tundra devices"
+	depends on TSI108_BRIDGE
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Tundra cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_TUNDRA
+
+config TSI108_ETH
+	tristate "Tundra TSI108 gigabit Ethernet support"
+	depends on TSI108_BRIDGE
+	---help---
+	  This driver supports Tundra TSI108 gigabit Ethernet ports.
+	  To compile this driver as a module, choose M here: the module
+	  will be called tsi108_eth.
+
+endif # NET_VENDOR_TUNDRA
diff --git a/drivers/net/ethernet/tundra/Makefile b/drivers/net/ethernet/tundra/Makefile
new file mode 100644
index 0000000..439f693
--- /dev/null
+++ b/drivers/net/ethernet/tundra/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Tundra network device drivers.
+#
+
+obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
similarity index 100%
rename from drivers/net/tsi108_eth.c
rename to drivers/net/ethernet/tundra/tsi108_eth.c
diff --git a/drivers/net/tsi108_eth.h b/drivers/net/ethernet/tundra/tsi108_eth.h
similarity index 100%
rename from drivers/net/tsi108_eth.h
rename to drivers/net/ethernet/tundra/tsi108_eth.h
-- 
1.7.6

