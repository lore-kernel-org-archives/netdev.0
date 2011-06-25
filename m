From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 39/72] mv643xx/pxa168: Move the Marvell drivers
Date: Sat, 25 Jun 2011 06:58:50 -0700
Message-ID: <1309010363-22750-40-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>,
	Lennert Buytenhek <buytenh@marvell.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab1FYOAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:34 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Marvell drivers into driver/net/ethernet/marvell and make
the necessary Kconfig and Makefile changes.

CC: Sachin Sanap <ssanap@marvell.com>
CC: Zhangfei Gao <zgao6@marvell.com>
CC: Philip Rakity <prakity@marvell.com>
CC: Mark Brown <markb@marvell.com>
CC: Lennert Buytenhek <buytenh@marvell.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                      |    2 +-
 drivers/net/Kconfig                              |   23 ------------
 drivers/net/Makefile                             |    2 -
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/marvell/Kconfig             |   40 ++++++++++++++++++++++
 drivers/net/ethernet/marvell/Makefile            |    6 +++
 drivers/net/{ => ethernet/marvell}/mv643xx_eth.c |    0
 drivers/net/{ => ethernet/marvell}/pxa168_eth.c  |    0
 9 files changed, 49 insertions(+), 26 deletions(-)
 create mode 100644 drivers/net/ethernet/marvell/Kconfig
 create mode 100644 drivers/net/ethernet/marvell/Makefile
 rename drivers/net/{ => ethernet/marvell}/mv643xx_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/pxa168_eth.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index bbb609b..27bb4a2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4076,7 +4076,7 @@ MARVELL MV643XX ETHERNET DRIVER
 M:	Lennert Buytenhek <buytenh@wantstofly.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/mv643xx_eth.*
+F:	drivers/net/ethernet/marvell/mv643xx_eth.*
 F:	include/linux/mv643xx.h
 
 MARVELL MWL8K WIRELESS DRIVER
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index be261ec..4bfd5e3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -373,16 +373,6 @@ config BFIN_MAC_USE_HWSTAMP
 	help
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
 
-config PXA168_ETH
-	tristate "Marvell pxa168 ethernet support"
-	depends on CPU_PXA168
-	select PHYLIB
-	help
-	  This driver supports the pxa168 Ethernet ports.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called pxa168_eth.
-
 config NET_NETX
 	tristate "NetX Ethernet support"
 	select MII
@@ -846,19 +836,6 @@ config GELIC_WIRELESS
 	  the driver automatically distinguishes the models, you can
 	  safely enable this option even if you have a wireless-less model.
 
-config MV643XX_ETH
-	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
-	select INET_LRO
-	select PHYLIB
-	help
-	  This driver supports the gigabit ethernet MACs in the
-	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
-	  in the Marvell Orion ARM SoC family.
-
-	  Some boards that use the Discovery chipset are the Momenco
-	  Ocelot C and Jaguar ATX and Pegasos II.
-
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	depends on PPC || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c68cdea..3aca65c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
-obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
@@ -98,7 +97,6 @@ obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
-obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f434fc8..9b5eca3 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -27,6 +27,7 @@ source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
+source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3a9f47d..23ebc6e 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
+obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
new file mode 100644
index 0000000..c32e941
--- /dev/null
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -0,0 +1,40 @@
+#
+# Marvell device configuration
+#
+
+config NET_VENDOR_MARVELL
+	bool "Marvell devices"
+	depends on CPU_PXA168 || ((MV64X60 || PPC32 || PLAT_ORION) && INET)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Marvell devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config PXA168_ETH
+	tristate "Marvell pxa168 ethernet support"
+	depends on NET_VENDOR_MARVELL && CPU_PXA168
+	select PHYLIB
+	---help---
+	  This driver supports the pxa168 Ethernet ports.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called pxa168_eth.
+
+config MV643XX_ETH
+	tristate "Marvell Discovery (643XX) and Orion ethernet support"
+	depends on NET_VENDOR_MARVELL && (MV64X60 || PPC32 || PLAT_ORION) \
+		   && INET
+	select INET_LRO
+	select PHYLIB
+	---help---
+	  This driver supports the gigabit ethernet MACs in the
+	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
+	  in the Marvell Orion ARM SoC family.
+
+	  Some boards that use the Discovery chipset are the Momenco
+	  Ocelot C and Jaguar ATX and Pegasos II.
diff --git a/drivers/net/ethernet/marvell/Makefile b/drivers/net/ethernet/marvell/Makefile
new file mode 100644
index 0000000..6809047
--- /dev/null
+++ b/drivers/net/ethernet/marvell/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Marvell network device drivers.
+#
+
+obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
+obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
similarity index 100%
rename from drivers/net/mv643xx_eth.c
rename to drivers/net/ethernet/marvell/mv643xx_eth.c
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
similarity index 100%
rename from drivers/net/pxa168_eth.c
rename to drivers/net/ethernet/marvell/pxa168_eth.c
-- 
1.7.5.4

