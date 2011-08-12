From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] davinci*/tlan/cpmac: Move the Texas Instruments (TI) drivers
Date: Fri, 12 Aug 2011 03:52:47 -0700
Message-ID: <1313146371-6562-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, Sriram <srk@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Samuel Chessman <chessman@tux.org>,
	<torben.mathiasen@compaq.com>, Eugene Konev <ejka@imfi.kspu.ru>,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab1HLKw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:58 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Texas Instruments drivers to drivers/net/ethernet/ti/ and
make the necessary Kconfig and Makefile changes.

CC: Sriram <srk@ti.com>
CC: Vinay Hegde <vinay.hegde@ti.com>
CC: Cyril Chemparathy <cyril@ti.com>
CC: Samuel Chessman <chessman@tux.org>
CC: <torben.mathiasen@compaq.com>
CC: Eugene Konev <ejka@imfi.kspu.ru>
CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                   |    4 +-
 drivers/net/Kconfig                           |   56 ------------------
 drivers/net/Makefile                          |    7 --
 drivers/net/ethernet/Kconfig                  |    1 +
 drivers/net/ethernet/Makefile                 |    1 +
 drivers/net/ethernet/ti/Kconfig               |   76 +++++++++++++++++++++++++
 drivers/net/ethernet/ti/Makefile              |    9 +++
 drivers/net/{ => ethernet/ti}/cpmac.c         |    0
 drivers/net/{ => ethernet/ti}/davinci_cpdma.c |    0
 drivers/net/{ => ethernet/ti}/davinci_cpdma.h |    0
 drivers/net/{ => ethernet/ti}/davinci_emac.c  |    0
 drivers/net/{ => ethernet/ti}/davinci_mdio.c  |    0
 drivers/net/{ => ethernet/ti}/tlan.c          |    0
 drivers/net/{ => ethernet/ti}/tlan.h          |    0
 14 files changed, 89 insertions(+), 65 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/Kconfig
 create mode 100644 drivers/net/ethernet/ti/Makefile
 rename drivers/net/{ => ethernet/ti}/cpmac.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_cpdma.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_cpdma.h (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_emac.c (100%)
 rename drivers/net/{ => ethernet/ti}/davinci_mdio.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index d31fd9e..622f4fc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1908,7 +1908,7 @@ CPMAC ETHERNET DRIVER
 M:	Florian Fainelli <florian@openwrt.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/cpmac.c
+F:	drivers/net/ethernet/ti/cpmac.c
 
 CPU FREQUENCY DRIVERS
 M:	Dave Jones <davej@redhat.com>
@@ -6420,7 +6420,7 @@ L:	tlan-devel@lists.sourceforge.net (subscribers-only)
 W:	http://sourceforge.net/projects/tlan/
 S:	Maintained
 F:	Documentation/networking/tlan.txt
-F:	drivers/net/tlan.*
+F:	drivers/net/ethernet/ti/tlan.*
 
 TOMOYO SECURITY MODULE
 M:	Kentaro Takeda <takedakn@nttdata.co.jp>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 134c3a4..e8d65fe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -323,37 +323,6 @@ config NET_NETX
 	  To compile this driver as a module, choose M here. The module
 	  will be called netx-eth.
 
-config TI_DAVINCI_EMAC
-	tristate "TI DaVinci EMAC Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	select TI_DAVINCI_MDIO
-	select TI_DAVINCI_CPDMA
-	select PHYLIB
-	help
-	  This driver supports TI's DaVinci Ethernet .
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_emac_driver.  This is recommended.
-
-config TI_DAVINCI_MDIO
-	tristate "TI DaVinci MDIO Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	select PHYLIB
-	help
-	  This driver supports TI's DaVinci MDIO module.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_mdio.  This is recommended.
-
-config TI_DAVINCI_CPDMA
-	tristate "TI DaVinci CPDMA Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	help
-	  This driver supports TI's DaVinci CPDMA dma engine.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_cpdma.  This is recommended.
-
 config DM9000
 	tristate "DM9000 support"
 	depends on ARM || BLACKFIN || MIPS
@@ -500,31 +469,6 @@ config R6040
 	  To compile this driver as a module, choose M here: the module
 	  will be called r6040. This is recommended.
 
-config TLAN
-	tristate "TI ThunderLAN support"
-	depends on NET_PCI && (PCI || EISA)
-	---help---
-	  If you have a PCI Ethernet network card based on the ThunderLAN chip
-	  which is supported by this driver, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Devices currently supported by this driver are Compaq Netelligent,
-	  Compaq NetFlex and Olicom cards.  Please read the file
-	  <file:Documentation/networking/tlan.txt> for more details.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called tlan.
-
-	  Please email feedback to <torben.mathiasen@compaq.com>.
-
-config CPMAC
-	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
-	depends on NET_ETHERNET && EXPERIMENTAL && AR7
-	select PHYLIB
-	help
-	  TI AR7 CPMAC Ethernet support
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 938484f..96112dd 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -5,11 +5,6 @@
 obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
-
-obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
-obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
-obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
-
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
@@ -23,7 +18,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_FEALNX) += fealnx.o
@@ -67,7 +61,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
-obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f53a4bc..3983e70 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -63,6 +63,7 @@ source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
+source "drivers/net/ethernet/ti/Kconfig"
 source "drivers/net/ethernet/toshiba/Kconfig"
 source "drivers/net/ethernet/tundra/Kconfig"
 source "drivers/net/ethernet/via/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4491d84..873d275 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
+obj-$(CONFIG_NET_VENDOR_TI) += ti/
 obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
 obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
new file mode 100644
index 0000000..1284319
--- /dev/null
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -0,0 +1,76 @@
+#
+# TI device configuration
+#
+
+config NET_VENDOR_TI
+	bool "Texas Instruments (TI) devices"
+	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3))
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about TI devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_TI
+
+config TI_DAVINCI_EMAC
+	tristate "TI DaVinci EMAC Support"
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	select TI_DAVINCI_MDIO
+	select TI_DAVINCI_CPDMA
+	select PHYLIB
+	---help---
+	  This driver supports TI's DaVinci Ethernet .
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_emac_driver.  This is recommended.
+
+config TI_DAVINCI_MDIO
+	tristate "TI DaVinci MDIO Support"
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	select PHYLIB
+	---help---
+	  This driver supports TI's DaVinci MDIO module.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_mdio.  This is recommended.
+
+config TI_DAVINCI_CPDMA
+	tristate "TI DaVinci CPDMA Support"
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	---help---
+	  This driver supports TI's DaVinci CPDMA dma engine.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_cpdma.  This is recommended.
+
+config TLAN
+	tristate "TI ThunderLAN support"
+	depends on (PCI || EISA)
+	---help---
+	  If you have a PCI Ethernet network card based on the ThunderLAN chip
+	  which is supported by this driver, say Y and read the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Devices currently supported by this driver are Compaq Netelligent,
+	  Compaq NetFlex and Olicom cards.  Please read the file
+	  <file:Documentation/networking/tlan.txt> for more details.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called tlan.
+
+	  Please email feedback to <torben.mathiasen@compaq.com>.
+
+config CPMAC
+	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && AR7
+	select PHYLIB
+	---help---
+	  TI AR7 CPMAC Ethernet support
+
+endif # NET_VENDOR_TI
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
new file mode 100644
index 0000000..aedb3af
--- /dev/null
+++ b/drivers/net/ethernet/ti/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the TI network device drivers.
+#
+
+obj-$(CONFIG_TLAN) += tlan.o
+obj-$(CONFIG_CPMAC) += cpmac.o
+obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
+obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
+obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
diff --git a/drivers/net/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
similarity index 100%
rename from drivers/net/cpmac.c
rename to drivers/net/ethernet/ti/cpmac.c
diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
similarity index 100%
rename from drivers/net/davinci_cpdma.c
rename to drivers/net/ethernet/ti/davinci_cpdma.c
diff --git a/drivers/net/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
similarity index 100%
rename from drivers/net/davinci_cpdma.h
rename to drivers/net/ethernet/ti/davinci_cpdma.h
diff --git a/drivers/net/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
similarity index 100%
rename from drivers/net/davinci_emac.c
rename to drivers/net/ethernet/ti/davinci_emac.c
diff --git a/drivers/net/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
similarity index 100%
rename from drivers/net/davinci_mdio.c
rename to drivers/net/ethernet/ti/davinci_mdio.c
diff --git a/drivers/net/tlan.c b/drivers/net/ethernet/ti/tlan.c
similarity index 100%
rename from drivers/net/tlan.c
rename to drivers/net/ethernet/ti/tlan.c
diff --git a/drivers/net/tlan.h b/drivers/net/ethernet/ti/tlan.h
similarity index 100%
rename from drivers/net/tlan.h
rename to drivers/net/ethernet/ti/tlan.h
-- 
1.7.6

