From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 32/71] ioc3-eth/meth: Move the SGI drivers
Date: Sat, 30 Jul 2011 20:26:51 -0700
Message-ID: <1312082850-24914-33-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ralf Baechle <ralf@linux-mips.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab1GaD2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:05 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the SGI drivers into drivers/net/ethernet/sgi/ and make the
necessary Kconfig and Makefile changes.

CC: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   14 -------------
 drivers/net/Makefile                      |    2 -
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/sgi/Kconfig          |   30 +++++++++++++++++++++++++++++
 drivers/net/ethernet/sgi/Makefile         |    6 +++++
 drivers/net/{ => ethernet/sgi}/ioc3-eth.c |    0
 drivers/net/{ => ethernet/sgi}/meth.c     |    0
 drivers/net/{ => ethernet/sgi}/meth.h     |    0
 10 files changed, 39 insertions(+), 17 deletions(-)
 create mode 100644 drivers/net/ethernet/sgi/Kconfig
 create mode 100644 drivers/net/ethernet/sgi/Makefile
 rename drivers/net/{ => ethernet/sgi}/ioc3-eth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.c (100%)
 rename drivers/net/{ => ethernet/sgi}/meth.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index c1930ef6..3d9ddd9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3406,7 +3406,7 @@ IOC3 ETHERNET DRIVER
 M:	Ralf Baechle <ralf@linux-mips.org>
 L:	linux-mips@linux-mips.org
 S:	Maintained
-F:	drivers/net/ioc3-eth.c
+F:	drivers/net/ethernet/sgi/ioc3-eth.c
 
 IOC3 SERIAL DRIVER
 M:	Pat Gefre <pfg@sgi.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 565b2fe..1e889b3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -244,16 +244,6 @@ config KORINA
 	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
 	  based system say Y. Otherwise say N.
 
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
@@ -262,10 +252,6 @@ config MIPS_SIM_NET
 	  emulated by the MIPS Simulator.
 	  If you are not using a MIPSsim or are unsure, say N.
 
-config SGI_O2MACE_ETH
-	tristate "SGI O2 MACE Fast Ethernet support"
-	depends on SGI_IP32=y
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 25f78c4..a40549b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -103,7 +103,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
-obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 
@@ -111,7 +110,6 @@ obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
-obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ed42850..7d25fa4 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -37,6 +37,7 @@ source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
+source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3de8249..ec58715 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SFC) += sfc/
+obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
new file mode 100644
index 0000000..d2f403d
--- /dev/null
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -0,0 +1,30 @@
+#
+# SGI device configuration
+#
+
+config NET_VENDOR_SGI
+	bool "SGI devices"
+	depends on (PCI && SGI_IP27) || SGI_IP32
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
diff --git a/drivers/net/ethernet/sgi/Makefile b/drivers/net/ethernet/sgi/Makefile
new file mode 100644
index 0000000..e5bedd2
--- /dev/null
+++ b/drivers/net/ethernet/sgi/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the SGI device drivers.
+#
+
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
-- 
1.7.6

