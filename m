From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 16/72] myri*: Move the Myricom drivers
Date: Sat, 25 Jun 2011 06:58:27 -0700
Message-ID: <1309010363-22750-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979Ab1FYOAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:05 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Myricom drivers into drivers/net/ethernet/myricom/ and make
the necessary Kconfig and Makefile changes.

CC: Andrew Gallatin <gallatin@myri.com>
CC: Brice Goglin <brice@myri.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   26 ------------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/myricom/Kconfig               |   42 ++++++++++++++++++++
 drivers/net/ethernet/myricom/Makefile              |    5 ++
 .../net/{ => ethernet/myricom}/myri10ge/Makefile   |    0
 .../net/{ => ethernet/myricom}/myri10ge/myri10ge.c |    0
 .../{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h |    0
 .../myricom}/myri10ge/myri10ge_mcp_gen_header.h    |    0
 11 files changed, 50 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/ethernet/myricom/Kconfig
 create mode 100644 drivers/net/ethernet/myricom/Makefile
 rename drivers/net/{ => ethernet/myricom}/myri10ge/Makefile (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge.c (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp.h (100%)
 rename drivers/net/{ => ethernet/myricom}/myri10ge/myri10ge_mcp_gen_header.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index b73e10b..81dfcff 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4276,7 +4276,7 @@ M:	Brice Goglin <brice@myri.com>
 L:	netdev@vger.kernel.org
 W:	http://www.myri.com/scs/download-Myri10GE.html
 S:	Supported
-F:	drivers/net/myri10ge/
+F:	drivers/net/ethernet/myricom/myri10ge/
 
 NATSEMI ETHERNET DRIVER (DP8381x)
 M:	Tim Hockin <thockin@hockin.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4e8b6c3..6b58ee3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1702,32 +1702,6 @@ config VXGE_DEBUG_TRACE_ALL
 	  the vxge driver. By default only few debug trace statements are
 	  enabled.
 
-config MYRI10GE
-	tristate "Myricom Myri-10G Ethernet support"
-	depends on PCI && INET
-	select FW_LOADER
-	select CRC32
-	select INET_LRO
-	---help---
-	  This driver supports Myricom Myri-10G Dual Protocol interface in
-	  Ethernet mode. If the eeprom on your board is not recent enough,
-	  you will need a newer firmware image.
-	  You may get this image or more information, at:
-
-	  <http://www.myri.com/scs/download-Myri10GE.html>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called myri10ge.
-
-config MYRI10GE_DCA
-	bool "Direct Cache Access (DCA) Support"
-	default y
-	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
-	---help---
-	  Say Y here if you want to use Direct Cache Access (DCA) in the
-	  driver.  DCA is a method for warming the CPU cache before data
-	  is used, with the intent of lessening the impact of cache misses.
-
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC_PASEMI && PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 6c2eb60..15c3598 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -168,7 +168,6 @@ obj-$(CONFIG_R8169) += r8169.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_VXGE) += vxge/
-obj-$(CONFIG_MYRI10GE) += myri10ge/
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 67b06b2..6149413 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -20,6 +20,7 @@ source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
+source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ecbe7fa..093b44f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
+obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/myricom/Kconfig b/drivers/net/ethernet/myricom/Kconfig
new file mode 100644
index 0000000..1227005
--- /dev/null
+++ b/drivers/net/ethernet/myricom/Kconfig
@@ -0,0 +1,42 @@
+#
+# Myricom device configuration
+#
+
+config NET_VENDOR_MYRI
+	bool "Myricom network devices"
+	depends on PCI || INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say
+	  Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Myricom cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config MYRI10GE
+	tristate "Myricom Myri-10G Ethernet support"
+	depends on NET_VENDOR_MYRI && PCI && INET
+	select FW_LOADER
+	select CRC32
+	select INET_LRO
+	---help---
+	  This driver supports Myricom Myri-10G Dual Protocol interface in
+	  Ethernet mode. If the eeprom on your board is not recent enough,
+	  you will need a newer firmware image.
+	  You may get this image or more information, at:
+
+	  <http://www.myri.com/scs/download-Myri10GE.html>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called myri10ge.
+
+config MYRI10GE_DCA
+	bool "Direct Cache Access (DCA) Support"
+	default y
+	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
diff --git a/drivers/net/ethernet/myricom/Makefile b/drivers/net/ethernet/myricom/Makefile
new file mode 100644
index 0000000..296c0a1
--- /dev/null
+++ b/drivers/net/ethernet/myricom/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Myricom network device drivers.
+#
+
+obj-$(CONFIG_MYRI10GE) += myri10ge/
diff --git a/drivers/net/myri10ge/Makefile b/drivers/net/ethernet/myricom/myri10ge/Makefile
similarity index 100%
rename from drivers/net/myri10ge/Makefile
rename to drivers/net/ethernet/myricom/myri10ge/Makefile
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
similarity index 100%
rename from drivers/net/myri10ge/myri10ge.c
rename to drivers/net/ethernet/myricom/myri10ge/myri10ge.c
diff --git a/drivers/net/myri10ge/myri10ge_mcp.h b/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
similarity index 100%
rename from drivers/net/myri10ge/myri10ge_mcp.h
rename to drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp.h
diff --git a/drivers/net/myri10ge/myri10ge_mcp_gen_header.h b/drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp_gen_header.h
similarity index 100%
rename from drivers/net/myri10ge/myri10ge_mcp_gen_header.h
rename to drivers/net/ethernet/myricom/myri10ge/myri10ge_mcp_gen_header.h
-- 
1.7.5.4

