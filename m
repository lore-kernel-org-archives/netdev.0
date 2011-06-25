From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 25/72] smsc*/smc911x: Move the SMSC drivers
Date: Sat, 25 Jun 2011 06:58:36 -0700
Message-ID: <1309010363-22750-26-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Dustin McIntire <dustin@sensoria.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301Ab1FYOAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:21 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the SMSC drivers into drivers/net/ethernet/smsc/ and make the
necessary Kconfig and Makefile changes.

CC: Dustin McIntire <dustin@sensoria.com>
CC: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                |    4 +-
 drivers/net/Kconfig                        |   54 ---------------------
 drivers/net/Makefile                       |    3 -
 drivers/net/ethernet/Kconfig               |    1 +
 drivers/net/ethernet/Makefile              |    1 +
 drivers/net/ethernet/smsc/Kconfig          |   71 ++++++++++++++++++++++++++++
 drivers/net/ethernet/smsc/Makefile         |    7 +++
 drivers/net/{ => ethernet/smsc}/smc911x.c  |    0
 drivers/net/{ => ethernet/smsc}/smc911x.h  |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.c |    0
 drivers/net/{ => ethernet/smsc}/smsc911x.h |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.c |    0
 drivers/net/{ => ethernet/smsc}/smsc9420.h |    0
 13 files changed, 82 insertions(+), 59 deletions(-)
 create mode 100644 drivers/net/ethernet/smsc/Kconfig
 create mode 100644 drivers/net/ethernet/smsc/Makefile
 rename drivers/net/{ => ethernet/smsc}/smc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc911x.h (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.c (100%)
 rename drivers/net/{ => ethernet/smsc}/smsc9420.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 76e60e4..90925d9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5812,13 +5812,13 @@ M:	Steve Glendinning <steve.glendinning@smsc.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	include/linux/smsc911x.h
-F:	drivers/net/smsc911x.*
+F:	drivers/net/ethernet/smsc/smsc911x.*
 
 SMSC9420 PCI ETHERNET DRIVER
 M:	Steve Glendinning <steve.glendinning@smsc.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/smsc9420.*
+F:	drivers/net/ethernet/smsc/smsc9420.*
 
 SN-IA64 (Itanium) SUB-PLATFORM
 M:	Jes Sorensen <jes@sgi.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 305b8b9..a2c032c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -503,44 +503,6 @@ config GRETH
 	help
 	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
 
-config SMC911X
-	tristate "SMSC LAN911[5678] support"
-	select CRC32
-	select MII
-	depends on ARM || SUPERH || MN10300
-	help
-	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
-	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-	  Say Y if you want it compiled into the kernel, 
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module. The module will be 
-	  called smc911x.  If you want to compile it as a module, say M 
-	  here and read <file:Documentation/kbuild/modules.txt>
-
-config SMSC911X
-	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH || BLACKFIN || MIPS || MN10300
-	select CRC32
-	select MII
-	select PHYLIB
-	---help---
-	  Say Y here if you want support for SMSC LAN911x and LAN921x families
-	  of ethernet controllers.
-
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
-	  will be called smsc911x.
-
-config SMSC911X_ARCH_HOOKS
-	def_bool n
-	depends on SMSC911X
-	help
-	  If the arch enables this, it allows the arch to implement various
-	  hooks for more comprehensive interrupt control and also to override
-	  the source of the MAC address.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
@@ -859,22 +821,6 @@ config SIS900
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis900.  This is recommended.
 
-config SMSC9420
-	tristate "SMSC LAN9420 PCI ethernet adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select PHYLIB
-	select SMSC_PHY
-	help
-	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
-	  Say Y if you want it compiled into the kernel,
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module. The module will be
-	  called smsc9420.  If you want to compile it as a module, say M
-	  here and read <file:Documentation/kbuild/modules.txt>
-
 config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 04d7613..0d016c1 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -39,7 +39,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_TLAN) += tlan.o
-obj-$(CONFIG_SMSC9420) += smsc9420.o
 obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
@@ -149,8 +148,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_SMC911X) += smc911x.o
-obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 704e664..4daf50d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -40,6 +40,7 @@ source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
+source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e5c02d9..2bce3e6 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
+obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_TEHUTI) += tehuti.o
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
new file mode 100644
index 0000000..6f6d36f
--- /dev/null
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -0,0 +1,71 @@
+#
+# SMSC device configuration
+#
+
+config NET_VENDOR_SMSC
+	bool "SMSC (Smart Mixed-Signal Connectivity) devices"
+	depends on ARM || SUPERH || BLACKFIN || MIPS || MN10300 || PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SMSC devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config SMC911X
+	tristate "SMSC LAN911[5678] support"
+	depends on NET_VENDOR_SMSC && (ARM || SUPERH || MN10300)
+	select CRC32
+	select MII
+	---help---
+	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
+	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
+	  Say Y if you want it compiled into the kernel,
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module. The module will be
+	  called smc911x.  If you want to compile it as a module, say M
+	  here and read <file:Documentation/kbuild/modules.txt>
+
+config SMSC911X
+	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
+	depends on NET_VENDOR_SMSC && (ARM || SUPERH || BLACKFIN || MIPS || \
+		 MN10300)
+	select CRC32
+	select MII
+	select PHYLIB
+	---help---
+	  Say Y here if you want support for SMSC LAN911x and LAN921x families
+	  of ethernet controllers.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>. The module
+	  will be called smsc911x.
+
+config SMSC911X_ARCH_HOOKS
+	def_bool n
+	depends on SMSC911X
+	---help---
+	  If the arch enables this, it allows the arch to implement various
+	  hooks for more comprehensive interrupt control and also to override
+	  the source of the MAC address.
+
+config SMSC9420
+	tristate "SMSC LAN9420 PCI ethernet adapter support"
+	depends on NET_VENDOR_SMSC && PCI
+	select CRC32
+	select PHYLIB
+	select SMSC_PHY
+	---help---
+	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
+	  Say Y if you want it compiled into the kernel,
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module. The module will be
+	  called smsc9420.  If you want to compile it as a module, say M
+	  here and read <file:Documentation/kbuild/modules.txt>
diff --git a/drivers/net/ethernet/smsc/Makefile b/drivers/net/ethernet/smsc/Makefile
new file mode 100644
index 0000000..7520c7c
--- /dev/null
+++ b/drivers/net/ethernet/smsc/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the SMSC network device drivers.
+#
+
+obj-$(CONFIG_SMC911X) += smc911x.o
+obj-$(CONFIG_SMSC911X) += smsc911x.o
+obj-$(CONFIG_SMSC9420) += smsc9420.o
diff --git a/drivers/net/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
similarity index 100%
rename from drivers/net/smc911x.c
rename to drivers/net/ethernet/smsc/smc911x.c
diff --git a/drivers/net/smc911x.h b/drivers/net/ethernet/smsc/smc911x.h
similarity index 100%
rename from drivers/net/smc911x.h
rename to drivers/net/ethernet/smsc/smc911x.h
diff --git a/drivers/net/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
similarity index 100%
rename from drivers/net/smsc911x.c
rename to drivers/net/ethernet/smsc/smsc911x.c
diff --git a/drivers/net/smsc911x.h b/drivers/net/ethernet/smsc/smsc911x.h
similarity index 100%
rename from drivers/net/smsc911x.h
rename to drivers/net/ethernet/smsc/smsc911x.h
diff --git a/drivers/net/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
similarity index 100%
rename from drivers/net/smsc9420.c
rename to drivers/net/ethernet/smsc/smsc9420.c
diff --git a/drivers/net/smsc9420.h b/drivers/net/ethernet/smsc/smsc9420.h
similarity index 100%
rename from drivers/net/smsc9420.h
rename to drivers/net/ethernet/smsc/smsc9420.h
-- 
1.7.5.4

