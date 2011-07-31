From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 40/71] toshiba: Move the Toshiba drivers
Date: Sat, 30 Jul 2011 20:26:59 -0700
Message-ID: <1312082850-24914-41-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Geoff Levand <geoff@infradead.org>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38846 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab1GaD2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:12 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Toshiba ethernet drivers into drivers/net/ethernet/toshiba
and make the necessary Kconfig and Makefile changes.

CC: Geoff Levand <geoff@infradead.org>
CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   36 --------------
 drivers/net/Makefile                               |    6 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/toshiba/Kconfig               |   52 ++++++++++++++++++++
 drivers/net/ethernet/toshiba/Makefile              |   10 ++++
 drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.c |    0
 drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.h |    0
 .../{ => ethernet/toshiba}/ps3_gelic_wireless.c    |    0
 .../{ => ethernet/toshiba}/ps3_gelic_wireless.h    |    0
 drivers/net/{ => ethernet/toshiba}/spider_net.c    |    0
 drivers/net/{ => ethernet/toshiba}/spider_net.h    |    0
 .../{ => ethernet/toshiba}/spider_net_ethtool.c    |    0
 drivers/net/{ => ethernet/toshiba}/tc35815.c       |    0
 15 files changed, 66 insertions(+), 44 deletions(-)
 create mode 100644 drivers/net/ethernet/toshiba/Kconfig
 create mode 100644 drivers/net/ethernet/toshiba/Makefile
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_net.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_wireless.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/ps3_gelic_wireless.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net.h (100%)
 rename drivers/net/{ => ethernet/toshiba}/spider_net_ethtool.c (100%)
 rename drivers/net/{ => ethernet/toshiba}/tc35815.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8843c16..9c7d151 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5089,7 +5089,7 @@ M:	Geoff Levand <geoff@infradead.org>
 L:	netdev@vger.kernel.org
 L:	cbe-oss-dev@lists.ozlabs.org
 S:	Maintained
-F:	drivers/net/ps3_gelic_net.*
+F:	drivers/net/ethernet/toshiba/ps3_gelic_net.*
 
 PS3 PLATFORM SUPPORT
 M:	Geoff Levand <geoff@infradead.org>
@@ -6046,7 +6046,7 @@ M:	Jens Osterkamp <jens@de.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	Documentation/networking/spider_net.txt
-F:	drivers/net/spider_net*
+F:	drivers/net/ethernet/toshiba/spider_net*
 
 SPU FILE SYSTEM
 M:	Jeremy Kerr <jk@ozlabs.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 53c491c..429d4b6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -478,11 +478,6 @@ config FORCEDETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
 
-config TC35815
-	tristate "TOSHIBA TC35815 Ethernet support"
-	depends on NET_PCI && PCI && MIPS
-	select PHYLIB
-
 config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on NET_PCI && PCI
@@ -658,14 +653,6 @@ config SIS190
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
@@ -674,29 +661,6 @@ config TSI108_ETH
 	  To compile this driver as a module, choose M here: the module
 	  will be called tsi108_eth.
 
-config GELIC_NET
-	tristate "PS3 Gigabit Ethernet driver"
-	depends on PPC_PS3
-	select PS3_SYS_MANAGER
-	help
-	  This driver supports the network device on the PS3 game
-	  console.  This driver has built-in support for Ethernet.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called ps3_gelic.
-
-config GELIC_WIRELESS
-	bool "PS3 Wireless support"
-	depends on WLAN
-	depends on GELIC_NET
-	select WIRELESS_EXT
-	help
-	  This option adds the support for the wireless feature of PS3.
-	  If you have the wireless-less model of PS3 or have no plan to
-	  use wireless feature, disabling this option saves memory.  As
-	  the driver automatically distinguishes the models, you can
-	  safely enable this option even if you have a wireless-less model.
-
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	depends on PPC || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e008859..275ed4a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -29,12 +29,6 @@ obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_FEALNX) += fealnx.o
-spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
-obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
-gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
-ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
-obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index d90f47f3..9754247 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -48,6 +48,7 @@ source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
+source "drivers/net/ethernet/toshiba/Kconfig"
 source "drivers/net/ethernet/via/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index cf27ae0..7e7a319 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -39,4 +39,5 @@ obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
+obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/toshiba/Kconfig b/drivers/net/ethernet/toshiba/Kconfig
new file mode 100644
index 0000000..184558b
--- /dev/null
+++ b/drivers/net/ethernet/toshiba/Kconfig
@@ -0,0 +1,52 @@
+#
+# Toshiba network device configuration
+#
+
+config NET_VENDOR_TOSHIBA
+	bool "Toshiba devices"
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB) || PPC_PS3
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Toshiba cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config GELIC_NET
+	tristate "PS3 Gigabit Ethernet driver"
+	depends on NET_VENDOR_TOSHIBA && PPC_PS3
+	select PS3_SYS_MANAGER
+	---help---
+	  This driver supports the network device on the PS3 game
+	  console.  This driver has built-in support for Ethernet.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called ps3_gelic.
+
+config GELIC_WIRELESS
+	bool "PS3 Wireless support"
+	depends on GELIC_NET && WLAN
+	select WIRELESS_EXT
+	---help---
+	  This option adds the support for the wireless feature of PS3.
+	  If you have the wireless-less model of PS3 or have no plan to
+	  use wireless feature, disabling this option saves memory.  As
+	  the driver automatically distinguishes the models, you can
+	  safely enable this option even if you have a wireless-less model.
+
+config SPIDER_NET
+	tristate "Spider Gigabit Ethernet driver"
+	depends on NET_VENDOR_TOSHIBA && PCI && (PPC_IBM_CELL_BLADE || \
+		   PPC_CELLEB)
+	select FW_LOADER
+	---help---
+	  This driver supports the Gigabit Ethernet chips present on the
+	  Cell Processor-Based Blades from IBM.
+
+config TC35815
+	tristate "TOSHIBA TC35815 Ethernet support"
+	depends on NET_VENDOR_TOSHIBA && PCI && MIPS
+	select PHYLIB
diff --git a/drivers/net/ethernet/toshiba/Makefile b/drivers/net/ethernet/toshiba/Makefile
new file mode 100644
index 0000000..71d861f
--- /dev/null
+++ b/drivers/net/ethernet/toshiba/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for the Toshiba network device drivers.
+#
+
+obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
+gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
+ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
+spidernet-y += spider_net.o spider_net_ethtool.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
+obj-$(CONFIG_TC35815) += tc35815.o
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
similarity index 100%
rename from drivers/net/ps3_gelic_net.c
rename to drivers/net/ethernet/toshiba/ps3_gelic_net.c
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ethernet/toshiba/ps3_gelic_net.h
similarity index 100%
rename from drivers/net/ps3_gelic_net.h
rename to drivers/net/ethernet/toshiba/ps3_gelic_net.h
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
similarity index 100%
rename from drivers/net/ps3_gelic_wireless.c
rename to drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
diff --git a/drivers/net/ps3_gelic_wireless.h b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.h
similarity index 100%
rename from drivers/net/ps3_gelic_wireless.h
rename to drivers/net/ethernet/toshiba/ps3_gelic_wireless.h
diff --git a/drivers/net/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
similarity index 100%
rename from drivers/net/spider_net.c
rename to drivers/net/ethernet/toshiba/spider_net.c
diff --git a/drivers/net/spider_net.h b/drivers/net/ethernet/toshiba/spider_net.h
similarity index 100%
rename from drivers/net/spider_net.h
rename to drivers/net/ethernet/toshiba/spider_net.h
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/ethernet/toshiba/spider_net_ethtool.c
similarity index 100%
rename from drivers/net/spider_net_ethtool.c
rename to drivers/net/ethernet/toshiba/spider_net_ethtool.c
diff --git a/drivers/net/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
similarity index 100%
rename from drivers/net/tc35815.c
rename to drivers/net/ethernet/toshiba/tc35815.c
-- 
1.7.6

