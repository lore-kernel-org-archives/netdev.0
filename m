From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 32/72] ioc3-eth/meth/sgiseeq: Move the SGI drivers
Date: Sat, 25 Jun 2011 06:58:43 -0700
Message-ID: <1309010363-22750-33-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188Ab1FYOA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:27 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the SGI drivers into drivers/net/ethernet/sgi/ and make the
necessary Kconfig and Makefile changes.

CC: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   21 ----------------
 drivers/net/Makefile                      |    3 --
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/sgi/Kconfig          |   37 +++++++++++++++++++++++++++++
 drivers/net/ethernet/sgi/Makefile         |    7 +++++
 drivers/net/{ => ethernet/sgi}/ioc3-eth.c |    0
 drivers/net/{ => ethernet/sgi}/meth.c     |    0
 drivers/net/{ => ethernet/sgi}/meth.h     |    0
 drivers/net/{ => ethernet/sgi}/sgiseeq.c  |    0
 drivers/net/{ => ethernet/sgi}/sgiseeq.h  |    0
 12 files changed, 47 insertions(+), 25 deletions(-)
 create mode 100644 drivers/net/ethernet/sgi/Kconfig
 create mode 100644 drivers/net/ethernet/sgi/Makefile
 rename drivers/net/{ => ethernet/sgi}/ioc3-eth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.h (100%)
 rename drivers/net/{ => ethernet/sgi}/sgiseeq.c (100%)
 rename drivers/net/{ => ethernet/sgi}/sgiseeq.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 26d1029..c9bf3b5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3386,7 +3386,7 @@ IOC3 ETHERNET DRIVER
 M:	Ralf Baechle <ralf@linux-mips.org>
 L:	linux-mips@linux-mips.org
 S:	Maintained
-F:	drivers/net/ioc3-eth.c
+F:	drivers/net/ethernet/sgi/ioc3-eth.c
 
 IOC3 SERIAL DRIVER
 M:	Pat Gefre <pfg@sgi.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0846518..17db195 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -304,16 +304,6 @@ config MIPS_AU1X00_ENET
 	  If you have an Alchemy Semi AU1X00 based system
 	  say Y.  Otherwise, say N.
 
-config SGI_IOC3_ETH
-	bool "SGI IOC3 Ethernet"
-	depends on PCI && SGI_IP27
-	select CRC32
-	select MII
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device"
 	depends on MIPS_SIM
@@ -322,10 +312,6 @@ config MIPS_SIM_NET
 	  emulated by the MIPS Simulator.
 	  If you are not using a MIPSsim or are unsure, say N.
 
-config SGI_O2MACE_ETH
-	tristate "SGI O2 MACE Fast Ethernet support"
-	depends on SGI_IP32=y
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
@@ -848,13 +834,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config SGISEEQ
-	tristate "SGI Seeq ethernet controller support"
-	depends on SGI_HAS_SEEQ
-	help
-	  Say Y here if you have an Seeq based Ethernet network card. This is
-	  used in many Silicon Graphics machines.
-
 config 68360_ENET
 	bool "Motorola 68360 ethernet controller"
 	depends on M68360
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ec07331..24d89c0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -101,8 +101,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
-obj-$(CONFIG_SGISEEQ) += sgiseeq.o
-obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
@@ -125,7 +123,6 @@ obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
-obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_TUN) += tun.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 369f5bb..0c4ba94 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -44,6 +44,7 @@ source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
+source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 189d112..5a27837 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SFC) += sfc/
+obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
new file mode 100644
index 0000000..a6fed1d
--- /dev/null
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -0,0 +1,37 @@
+#
+# SGI device configuration
+#
+
+config NET_VENDOR_SGI
+	bool "SGI devices"
+	depends on (PCI && SGI_IP27) || SGI_IP32 || SGI_HAS_SEEQ
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SGI devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config SGI_IOC3_ETH
+	bool "SGI IOC3 Ethernet"
+	depends on NET_VENDOR_SGI && PCI && SGI_IP27
+	select CRC32
+	select MII
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+config SGI_O2MACE_ETH
+	tristate "SGI O2 MACE Fast Ethernet support"
+	depends on NET_VENDOR_SGI && SGI_IP32=y
+
+config SGISEEQ
+	tristate "SGI Seeq ethernet controller support"
+	depends on NET_VENDOR_SGI && SGI_HAS_SEEQ
+	---help---
+	  Say Y here if you have an Seeq based Ethernet network card. This is
+	  used in many Silicon Graphics machines.
diff --git a/drivers/net/ethernet/sgi/Makefile b/drivers/net/ethernet/sgi/Makefile
new file mode 100644
index 0000000..3c5ba8c
--- /dev/null
+++ b/drivers/net/ethernet/sgi/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the SGI device drivers.
+#
+
+obj-$(CONFIG_SGISEEQ) += sgiseeq.o
+obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
+obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
similarity index 100%
rename from drivers/net/ioc3-eth.c
rename to drivers/net/ethernet/sgi/ioc3-eth.c
diff --git a/drivers/net/meth.c b/drivers/net/ethernet/sgi/meth.c
similarity index 100%
rename from drivers/net/meth.c
rename to drivers/net/ethernet/sgi/meth.c
diff --git a/drivers/net/meth.h b/drivers/net/ethernet/sgi/meth.h
similarity index 100%
rename from drivers/net/meth.h
rename to drivers/net/ethernet/sgi/meth.h
diff --git a/drivers/net/sgiseeq.c b/drivers/net/ethernet/sgi/sgiseeq.c
similarity index 100%
rename from drivers/net/sgiseeq.c
rename to drivers/net/ethernet/sgi/sgiseeq.c
diff --git a/drivers/net/sgiseeq.h b/drivers/net/ethernet/sgi/sgiseeq.h
similarity index 100%
rename from drivers/net/sgiseeq.h
rename to drivers/net/ethernet/sgi/sgiseeq.h
-- 
1.7.5.4

