From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 09/72] smc: Move the SMC drivers
Date: Sat, 25 Jun 2011 06:58:20 -0700
Message-ID: <1309010363-22750-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945Ab1FYN7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:55 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the SMC drivers into drivers/net/ethernet/smc/ and the
necessary Kconfig and Makefile changes.  Also did some cleanup
of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.

CC: Nicolas Pitre <nico@fluxnic.net>
CC: Donald Becker <becker@scyld.com>
CC: Erik Stahlman <erik@vt.edu>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                              |    2 +-
 drivers/net/Kconfig                      |   51 -------------------------
 drivers/net/Makefile                     |    4 --
 drivers/net/ethernet/8390/Kconfig        |   21 ++--------
 drivers/net/ethernet/Kconfig             |    1 +
 drivers/net/ethernet/Makefile            |    1 +
 drivers/net/ethernet/smc/Kconfig         |   61 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/smc/Makefile        |    7 +++
 drivers/net/{ => ethernet/smc}/epic100.c |    0
 drivers/net/{ => ethernet/smc}/smc9194.c |    0
 drivers/net/{ => ethernet/smc}/smc9194.h |    0
 drivers/net/{ => ethernet/smc}/smc91x.c  |    0
 drivers/net/{ => ethernet/smc}/smc91x.h  |    0
 13 files changed, 75 insertions(+), 73 deletions(-)
 create mode 100644 drivers/net/ethernet/smc/Kconfig
 create mode 100644 drivers/net/ethernet/smc/Makefile
 rename drivers/net/{ => ethernet/smc}/epic100.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc9194.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc9194.h (100%)
 rename drivers/net/{ => ethernet/smc}/smc91x.c (100%)
 rename drivers/net/{ => ethernet/smc}/smc91x.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4929f4a..4dcfdc8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5778,7 +5778,7 @@ F:	mm/sl?b.c
 SMC91x ETHERNET DRIVER
 M:	Nicolas Pitre <nico@fluxnic.net>
 S:	Odd Fixes
-F:	drivers/net/smc91x.*
+F:	drivers/net/ethernet/smc/smc91x.*
 
 SMM665 HARDWARE MONITOR DRIVER
 M:	Guenter Roeck <linux@roeck-us.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 802be52..c3399a5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -538,39 +538,6 @@ config BFIN_MAC_USE_HWSTAMP
 	help
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
 
-config SMC9194
-	tristate "SMC 9194 support"
-	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
-	select CRC32
-	---help---
-	  This is support for the SMC9xxx based Ethernet cards. Choose this
-	  option if you have a DELL laptop with the docking station, or
-	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
-	  into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc9194.
-
-config SMC91X
-	tristate "SMC 91C9x/91C1xxx support"
-	select CRC32
-	select MII
-	depends on ARM || M32R || SUPERH || \
-		MIPS || BLACKFIN || MN10300 || COLDFIRE
-	help
-	  This is a driver for SMC's 91x series of Ethernet chipsets,
-	  including the SMC91C94 and the SMC91C111. Say Y if you want it
-	  compiled into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt>  and the Ethernet-HOWTO,
-	  available from  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc91x.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
-
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
 	depends on CPU_PXA168
@@ -1145,17 +1112,6 @@ config SIS900
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis900.  This is recommended.
 
-config EPIC100
-	tristate "SMC EtherPower II"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
-	  which is based on the SMC83c17x (EPIC/100).
-	  More specific information and updates are available from
-	  <http://www.scyld.com/network/epic100.html>.
-
 config SMSC9420
 	tristate "SMSC LAN9420 PCI ethernet adapter support"
 	depends on NET_PCI && PCI
@@ -1886,13 +1842,6 @@ config MYRI10GE_DCA
 	  driver.  DCA is a method for warming the CPU cache before data
 	  is used, with the intent of lessening the impact of cache misses.
 
-config NETXEN_NIC
-	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
-	depends on PCI
-	select FW_LOADER
-	help
-	  This enables the support for NetXen's Gigabit Ethernet card.
-
 config NIU
 	tristate "Sun Neptune 10Gbit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9dcbcc7..aa3296f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -55,7 +55,6 @@ obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
 obj-$(CONFIG_TLAN) += tlan.o
-obj-$(CONFIG_EPIC100) += epic100.o
 obj-$(CONFIG_SMSC9420) += smsc9420.o
 obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
@@ -95,7 +94,6 @@ obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
@@ -184,7 +182,6 @@ obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_VXGE) += vxge/
 obj-$(CONFIG_MYRI10GE) += myri10ge/
-obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
@@ -232,7 +229,6 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
 obj-$(CONFIG_FS_ENET) += fs_enet/
 
-obj-$(CONFIG_NETXEN_NIC) += netxen/
 obj-$(CONFIG_NIU) += niu.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 3c20f26..db03f52 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -242,22 +242,9 @@ config STNIC
 
 	  If unsure, say N.
 
-config NET_VENDOR_SMC
-	bool "Western Digital/SMC cards"
-	depends on NET_VENDOR_8390 && (ISA || MCA || EISA || MAC)
-	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Western Digital cards. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
 config ULTRAMCA
 	tristate "SMC Ultra MCA support"
-	depends on NET_VENDOR_SMC && MCA
+	depends on NET_VENDOR_8390 && MCA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type and are running
@@ -269,7 +256,7 @@ config ULTRAMCA
 
 config ULTRA
 	tristate "SMC Ultra support"
-	depends on NET_VENDOR_SMC && ISA
+	depends on NET_VENDOR_8390 && ISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -288,7 +275,7 @@ config ULTRA
 
 config ULTRA32
 	tristate "SMC Ultra32 EISA support"
-	depends on NET_VENDOR_SMC && EISA
+	depends on NET_VENDOR_8390 && EISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -300,7 +287,7 @@ config ULTRA32
 
 config WD80x3
 	tristate "WD80*3 support"
-	depends on NET_VENDOR_SMC && ISA
+	depends on NET_VENDOR_8390 && ISA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ab591bb..ca75c40 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -18,5 +18,6 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
+source "drivers/net/ethernet/smc/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d8cf120..125b332 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
+obj-$(CONFIG_NET_VENDOR_SMC) += smc/
diff --git a/drivers/net/ethernet/smc/Kconfig b/drivers/net/ethernet/smc/Kconfig
new file mode 100644
index 0000000..492ac29
--- /dev/null
+++ b/drivers/net/ethernet/smc/Kconfig
@@ -0,0 +1,61 @@
+#
+# Western Digital/SMC network device configuration
+#
+
+config NET_VENDOR_SMC
+	bool "SMC/Western Digital devices"
+	depends on ISA || MAC || ARM || MIPS || M32R || SUPERH || \
+		BLACKFIN || MN10300 || COLDFIRE || PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Western Digital cards. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config SMC9194
+	tristate "SMC 9194 support"
+	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
+	select CRC32
+	---help---
+	  This is support for the SMC9xxx based Ethernet cards. Choose this
+	  option if you have a DELL laptop with the docking station, or
+	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
+	  into the kernel, and read the file
+	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc9194.
+
+config SMC91X
+	tristate "SMC 91C9x/91C1xxx support"
+	select CRC32
+	select MII
+	depends on NET_VENDOR_SMC && (ARM || M32R || SUPERH || \
+		MIPS || BLACKFIN || MN10300 || COLDFIRE)
+	---help---
+	  This is a driver for SMC's 91x series of Ethernet chipsets,
+	  including the SMC91C94 and the SMC91C111. Say Y if you want it
+	  compiled into the kernel, and read the file
+	  <file:Documentation/networking/smc9.txt>  and the Ethernet-HOWTO,
+	  available from  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver is also available as a module ( = code which can be
+	  inserted in and removed from the running kernel whenever you want).
+	  The module will be called smc91x.  If you want to compile it as a
+	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
+
+config EPIC100
+	tristate "SMC EtherPower II"
+	depends on NET_VENDOR_SMC && PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
+	  which is based on the SMC83c17x (EPIC/100).
+	  More specific information and updates are available from
+	  <http://www.scyld.com/network/epic100.html>.
diff --git a/drivers/net/ethernet/smc/Makefile b/drivers/net/ethernet/smc/Makefile
new file mode 100644
index 0000000..b414266
--- /dev/null
+++ b/drivers/net/ethernet/smc/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the SMC network device drivers.
+#
+
+obj-$(CONFIG_SMC9194) += smc9194.o
+obj-$(CONFIG_SMC91X) += smc91x.o
+obj-$(CONFIG_EPIC100) += epic100.o
diff --git a/drivers/net/epic100.c b/drivers/net/ethernet/smc/epic100.c
similarity index 100%
rename from drivers/net/epic100.c
rename to drivers/net/ethernet/smc/epic100.c
diff --git a/drivers/net/smc9194.c b/drivers/net/ethernet/smc/smc9194.c
similarity index 100%
rename from drivers/net/smc9194.c
rename to drivers/net/ethernet/smc/smc9194.c
diff --git a/drivers/net/smc9194.h b/drivers/net/ethernet/smc/smc9194.h
similarity index 100%
rename from drivers/net/smc9194.h
rename to drivers/net/ethernet/smc/smc9194.h
diff --git a/drivers/net/smc91x.c b/drivers/net/ethernet/smc/smc91x.c
similarity index 100%
rename from drivers/net/smc91x.c
rename to drivers/net/ethernet/smc/smc91x.c
diff --git a/drivers/net/smc91x.h b/drivers/net/ethernet/smc/smc91x.h
similarity index 100%
rename from drivers/net/smc91x.h
rename to drivers/net/ethernet/smc/smc91x.h
-- 
1.7.5.4

