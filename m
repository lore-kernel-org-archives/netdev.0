From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 35/71] skge/sky2/mv643xx/pxa168: Move the Marvell Ethernet drivers
Date: Sat, 30 Jul 2011 20:26:54 -0700
Message-ID: <1312082850-24914-36-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>,
	Lennert Buytenhek <buytenh@marvell.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab1GaD2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:06 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Marvell Ethernet drivers into drivers/net/ethernet/marvell/
and make the necessary Kconfig and Makefile changes.

CC: Sachin Sanap <ssanap@marvell.com>
CC: Zhangfei Gao <zgao6@marvell.com>
CC: Philip Rakity <prakity@marvell.com>
CC: Mark Brown <markb@marvell.com>
CC: Lennert Buytenhek <buytenh@marvell.com>
CC: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                      |    5 +-
 drivers/net/Kconfig                              |   90 ------------------
 drivers/net/Makefile                             |    4 -
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/ethernet/marvell/Kconfig             |  107 ++++++++++++++++++++++
 drivers/net/ethernet/marvell/Makefile            |    8 ++
 drivers/net/{ => ethernet/marvell}/mv643xx_eth.c |    0
 drivers/net/{ => ethernet/marvell}/pxa168_eth.c  |    0
 drivers/net/{ => ethernet/marvell}/skge.c        |    0
 drivers/net/{ => ethernet/marvell}/skge.h        |    0
 drivers/net/{ => ethernet/marvell}/sky2.c        |    0
 drivers/net/{ => ethernet/marvell}/sky2.h        |    0
 13 files changed, 119 insertions(+), 97 deletions(-)
 create mode 100644 drivers/net/ethernet/marvell/Kconfig
 create mode 100644 drivers/net/ethernet/marvell/Makefile
 rename drivers/net/{ => ethernet/marvell}/mv643xx_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/pxa168_eth.c (100%)
 rename drivers/net/{ => ethernet/marvell}/skge.c (100%)
 rename drivers/net/{ => ethernet/marvell}/skge.h (100%)
 rename drivers/net/{ => ethernet/marvell}/sky2.c (100%)
 rename drivers/net/{ => ethernet/marvell}/sky2.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index d96c791..9b06d37 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4103,7 +4103,7 @@ MARVELL MV643XX ETHERNET DRIVER
 M:	Lennert Buytenhek <buytenh@wantstofly.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/mv643xx_eth.*
+F:	drivers/net/ethernet/marvell/mv643xx_eth.*
 F:	include/linux/mv643xx.h
 
 MARVELL MWIFIEX WIRELESS DRIVER
@@ -5816,8 +5816,7 @@ SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
 M:	Stephen Hemminger <shemminger@linux-foundation.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/skge.*
-F:	drivers/net/sky2.*
+F:	drivers/net/ethernet/marvell/sk*
 
 SLAB ALLOCATOR
 M:	Christoph Lameter <cl@linux-foundation.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7001b0d..ec5f7f4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -313,16 +313,6 @@ config BFIN_MAC_USE_HWSTAMP
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
@@ -803,73 +793,6 @@ config SIS190
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis190.  This is recommended.
 
-config SKGE
-	tristate "Marvell Yukon Gigabit Ethernet support"
-	depends on PCI
-	select CRC32
-	---help---
-	  This driver support the Marvell Yukon or SysKonnect SK-98xx/SK-95xx
-	  and related Gigabit Ethernet adapters. It is a new smaller driver
-	  with better performance and more complete ethtool support.
-
-	  It does not support the link failover and network management 
-	  features that "portable" vendor supplied sk98lin driver does.
-
-	  This driver supports adapters based on the original Yukon chipset:
-	  Marvell 88E8001, Belkin F5D5005, CNet GigaCard, DLink DGE-530T,
-	  Linksys EG1032/EG1064, 3Com 3C940/3C940B, SysKonnect SK-9871/9872.
-
-	  It does not support the newer Yukon2 chipset: a separate driver,
-	  sky2, is provided for these adapters.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called skge.  This is recommended.
-
-config SKGE_DEBUG
-	bool "Debugging interface"
-	depends on SKGE && DEBUG_FS
-	help
-	  This option adds the ability to dump driver state for debugging.
-	  The file /sys/kernel/debug/skge/ethX displays the state of the internal
-	  transmit and receive rings.
-
-	  If unsure, say N.
-
-config SKGE_GENESIS
-       bool "Support for older SysKonnect Genesis boards"
-       depends on SKGE
-       help
-         This enables support for the older and uncommon SysKonnect Genesis
-	 chips, which support MII via an external transceiver, instead of
-	 an internal one. Disabling this option will save some memory
-	 by making code smaller. If unsure say Y.
-
-config SKY2
-	tristate "Marvell Yukon 2 support"
-	depends on PCI
-	select CRC32
-	---help---
-	  This driver supports Gigabit Ethernet adapters based on the
-	  Marvell Yukon 2 chipset:
-	  Marvell 88E8021/88E8022/88E8035/88E8036/88E8038/88E8050/88E8052/
-	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
-
-	  There is companion driver for the older Marvell Yukon and
-	  SysKonnect Genesis based adapters: skge.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sky2.  This is recommended.
-
-config SKY2_DEBUG
-	bool "Debugging interface"
-	depends on SKY2 && DEBUG_FS
-	help
-	  This option adds the ability to dump driver state for debugging.
-	  The file /sys/kernel/debug/sky2/ethX displays the state of the internal
-	  transmit and receive rings.
-
-	  If unsure, say N.
-
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
 	depends on PCI
@@ -951,19 +874,6 @@ config UGETH_TX_ON_DEMAND
 	bool "Transmit on Demand support"
 	depends on UCC_GETH
 
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
index d60c838..60b2d20 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -46,8 +46,6 @@ obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 obj-$(CONFIG_TC35815) += tc35815.o
-obj-$(CONFIG_SKGE) += skge.o
-obj-$(CONFIG_SKY2) += sky2.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_KS8842)	+= ks8842.o
 obj-$(CONFIG_KS8851)	+= ks8851.o
@@ -75,7 +73,6 @@ endif
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
-obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
@@ -111,7 +108,6 @@ obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
-obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 0eaf957..1c447d9 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -28,6 +28,7 @@ source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/xscale/Kconfig"
+source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index b5ca872..48c8656 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
+obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
new file mode 100644
index 0000000..dcdc258
--- /dev/null
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -0,0 +1,107 @@
+#
+# Marvell device configuration
+#
+
+config NET_VENDOR_MARVELL
+	bool "Marvell devices"
+	depends on PCI || CPU_PXA168 || MV64X60 || PPC32 || PLAT_ORION || INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Marvell devices. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config MV643XX_ETH
+	tristate "Marvell Discovery (643XX) and Orion ethernet support"
+	depends on NET_VENDOR_MARVELL && (MV64X60 || PPC32 || PLAT_ORION) && \
+		   INET
+	select INET_LRO
+	select PHYLIB
+	---help---
+	  This driver supports the gigabit ethernet MACs in the
+	  Marvell Discovery PPC/MIPS chipset family (MV643XX) and
+	  in the Marvell Orion ARM SoC family.
+
+	  Some boards that use the Discovery chipset are the Momenco
+	  Ocelot C and Jaguar ATX and Pegasos II.
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
+config SKGE
+	tristate "Marvell Yukon Gigabit Ethernet support"
+	depends on NET_VENDOR_MARVELL && PCI
+	select CRC32
+	---help---
+	  This driver support the Marvell Yukon or SysKonnect SK-98xx/SK-95xx
+	  and related Gigabit Ethernet adapters. It is a new smaller driver
+	  with better performance and more complete ethtool support.
+
+	  It does not support the link failover and network management
+	  features that "portable" vendor supplied sk98lin driver does.
+
+	  This driver supports adapters based on the original Yukon chipset:
+	  Marvell 88E8001, Belkin F5D5005, CNet GigaCard, DLink DGE-530T,
+	  Linksys EG1032/EG1064, 3Com 3C940/3C940B, SysKonnect SK-9871/9872.
+
+	  It does not support the newer Yukon2 chipset: a separate driver,
+	  sky2, is provided for these adapters.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called skge.  This is recommended.
+
+config SKGE_DEBUG
+	bool "Debugging interface"
+	depends on SKGE && DEBUG_FS
+	---help---
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/skge/ethX displays the state of the internal
+	  transmit and receive rings.
+
+	  If unsure, say N.
+
+config SKGE_GENESIS
+	bool "Support for older SysKonnect Genesis boards"
+	depends on SKGE
+	---help---
+	 This enables support for the older and uncommon SysKonnect Genesis
+	 chips, which support MII via an external transceiver, instead of
+	 an internal one. Disabling this option will save some memory
+	 by making code smaller. If unsure say Y.
+
+config SKY2
+	tristate "Marvell Yukon 2 support"
+	depends on NET_VENDOR_MARVELL && PCI
+	select CRC32
+	---help---
+	  This driver supports Gigabit Ethernet adapters based on the
+	  Marvell Yukon 2 chipset:
+	  Marvell 88E8021/88E8022/88E8035/88E8036/88E8038/88E8050/88E8052/
+	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
+
+	  There is companion driver for the older Marvell Yukon and
+	  SysKonnect Genesis based adapters: skge.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sky2.  This is recommended.
+
+config SKY2_DEBUG
+	bool "Debugging interface"
+	depends on SKY2 && DEBUG_FS
+	---help---
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/sky2/ethX displays the state of the internal
+	  transmit and receive rings.
+
+	  If unsure, say N.
diff --git a/drivers/net/ethernet/marvell/Makefile b/drivers/net/ethernet/marvell/Makefile
new file mode 100644
index 0000000..57e3234
--- /dev/null
+++ b/drivers/net/ethernet/marvell/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the Marvell device drivers.
+#
+
+obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
+obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
+obj-$(CONFIG_SKGE) += skge.o
+obj-$(CONFIG_SKY2) += sky2.o
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
similarity index 100%
rename from drivers/net/mv643xx_eth.c
rename to drivers/net/ethernet/marvell/mv643xx_eth.c
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
similarity index 100%
rename from drivers/net/pxa168_eth.c
rename to drivers/net/ethernet/marvell/pxa168_eth.c
diff --git a/drivers/net/skge.c b/drivers/net/ethernet/marvell/skge.c
similarity index 100%
rename from drivers/net/skge.c
rename to drivers/net/ethernet/marvell/skge.c
diff --git a/drivers/net/skge.h b/drivers/net/ethernet/marvell/skge.h
similarity index 100%
rename from drivers/net/skge.h
rename to drivers/net/ethernet/marvell/skge.h
diff --git a/drivers/net/sky2.c b/drivers/net/ethernet/marvell/sky2.c
similarity index 100%
rename from drivers/net/sky2.c
rename to drivers/net/ethernet/marvell/sky2.c
diff --git a/drivers/net/sky2.h b/drivers/net/ethernet/marvell/sky2.h
similarity index 100%
rename from drivers/net/sky2.h
rename to drivers/net/ethernet/marvell/sky2.h
-- 
1.7.6

