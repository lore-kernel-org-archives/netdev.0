From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 45/72] tlan/cpmac: Move the TI drivers
Date: Sat, 25 Jun 2011 06:58:56 -0700
Message-ID: <1309010363-22750-46-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Samuel Chessman <chessman@tux.org>,
	<torben.mathiasen@compaq.com>, Eugene Konev <ejka@imfi.kspu.ru>,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab1FYOAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:11 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the TI drivers to drivers/net/ethernet/ti/ and make the
necessary Kconfig and Makefile changes.

CC: Samuel Chessman <chessman@tux.org>
CC: <torben.mathiasen@compaq.com>
CC: Eugene Konev <ejka@imfi.kspu.ru>
CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                           |    4 +-
 drivers/net/Kconfig                   |   25 --------------------
 drivers/net/Makefile                  |    2 -
 drivers/net/ethernet/Kconfig          |    1 +
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/ethernet/ti/Kconfig       |   41 +++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/Makefile      |    6 +++++
 drivers/net/{ => ethernet/ti}/cpmac.c |    0
 drivers/net/{ => ethernet/ti}/tlan.c  |    0
 drivers/net/{ => ethernet/ti}/tlan.h  |    0
 10 files changed, 51 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/Kconfig
 create mode 100644 drivers/net/ethernet/ti/Makefile
 rename drivers/net/{ => ethernet/ti}/cpmac.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.c (100%)
 rename drivers/net/{ => ethernet/ti}/tlan.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index fa2f1bb..cd97122 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1880,7 +1880,7 @@ CPMAC ETHERNET DRIVER
 M:	Florian Fainelli <florian@openwrt.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/cpmac.c
+F:	drivers/net/ethernet/ti/cpmac.c
 
 CPU FREQUENCY DRIVERS
 M:	Dave Jones <davej@redhat.com>
@@ -6188,7 +6188,7 @@ L:	tlan-devel@lists.sourceforge.net (subscribers-only)
 W:	http://sourceforge.net/projects/tlan/
 S:	Maintained
 F:	Documentation/networking/tlan.txt
-F:	drivers/net/tlan.*
+F:	drivers/net/ethernet/ti/tlan.*
 
 TOMOYO SECURITY MODULE
 M:	Kentaro Takeda <takedakn@nttdata.co.jp>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 981d7d8..7aa7982 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -540,24 +540,6 @@ config SUNDANCE_MMIO
 
 	  If unsure, say N.
 
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
 config SC92031
 	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
@@ -570,13 +552,6 @@ config SC92031
 	  To compile this driver as a module, choose M here: the module
 	  will be called sc92031.  This is recommended.
 
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
index 2bb8a4e..4893db5 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
@@ -69,7 +68,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c23e7b5..ed7b4a6 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -99,6 +99,7 @@ config TEHUTI
 	---help---
 	  Tehuti Networks 10G Ethernet NIC
 
+source "drivers/net/ethernet/ti/Kconfig"
 source "drivers/net/ethernet/tulip/Kconfig"
 
 config TSI108_ETH
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a243610..444c988 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
 obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_NET_TI) += ti/
 obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
new file mode 100644
index 0000000..3f45912
--- /dev/null
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -0,0 +1,41 @@
+#
+# TI device configuration
+#
+
+config NET_VENDOR_TI
+	bool "TI devices"
+	depends on PCI || EISA || AR7
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
+config TLAN
+	tristate "TI ThunderLAN support"
+	depends on NET_VENDOR_TI && (PCI || EISA)
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
+	depends on NET_VENDOR_TI && EXPERIMENTAL && AR7
+	select PHYLIB
+	---help---
+	  TI AR7 CPMAC Ethernet support
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
new file mode 100644
index 0000000..9d9ad21
--- /dev/null
+++ b/drivers/net/ethernet/ti/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the TI network device drivers.
+#
+
+obj-$(CONFIG_TLAN) += tlan.o
+obj-$(CONFIG_CPMAC) += cpmac.o
diff --git a/drivers/net/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
similarity index 100%
rename from drivers/net/cpmac.c
rename to drivers/net/ethernet/ti/cpmac.c
diff --git a/drivers/net/tlan.c b/drivers/net/ethernet/ti/tlan.c
similarity index 100%
rename from drivers/net/tlan.c
rename to drivers/net/ethernet/ti/tlan.c
diff --git a/drivers/net/tlan.h b/drivers/net/ethernet/ti/tlan.h
similarity index 100%
rename from drivers/net/tlan.h
rename to drivers/net/ethernet/ti/tlan.h
-- 
1.7.5.4

