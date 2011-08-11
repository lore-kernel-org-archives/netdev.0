From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] 8139*/atp/r8169/sc92031: Move the Realtek drivers
Date: Thu, 11 Aug 2011 16:39:56 -0700
Message-ID: <1313105998-2859-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234Ab1HKXkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 19:40:05 -0400
In-Reply-To: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
the necessary Kconfig and Makefile changes.

CC: Realtek linux nic maintainers <nic_swsd@realtek.com>
CC: Francois Romieu <romieu@fr.zoreil.com>
CC: Jeff Garzik <jgarzik@pobox.com>
CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                  |    2 +-
 drivers/net/Kconfig                          |  106 ----------------------
 drivers/net/Makefile                         |    5 -
 drivers/net/ethernet/Kconfig                 |    1 +
 drivers/net/ethernet/Makefile                |    1 +
 drivers/net/{ => ethernet/realtek}/8139cp.c  |    0
 drivers/net/{ => ethernet/realtek}/8139too.c |    0
 drivers/net/ethernet/realtek/Kconfig         |  126 ++++++++++++++++++++++++++
 drivers/net/ethernet/realtek/Makefile        |    9 ++
 drivers/net/{ => ethernet/realtek}/atp.c     |    0
 drivers/net/{ => ethernet/realtek}/atp.h     |    0
 drivers/net/{ => ethernet/realtek}/r8169.c   |    0
 drivers/net/{ => ethernet/realtek}/sc92031.c |    0
 13 files changed, 138 insertions(+), 112 deletions(-)
 rename drivers/net/{ => ethernet/realtek}/8139cp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/8139too.c (100%)
 create mode 100644 drivers/net/ethernet/realtek/Kconfig
 create mode 100644 drivers/net/ethernet/realtek/Makefile
 rename drivers/net/{ => ethernet/realtek}/atp.c (100%)
 rename drivers/net/{ => ethernet/realtek}/atp.h (100%)
 rename drivers/net/{ => ethernet/realtek}/r8169.c (100%)
 rename drivers/net/{ => ethernet/realtek}/sc92031.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 39607a9..88ff9ef 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -156,7 +156,7 @@ M:	Realtek linux nic maintainers <nic_swsd@realtek.com>
 M:	Francois Romieu <romieu@fr.zoreil.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/r8169.c
+F:	drivers/net/ethernet/realtek/r8169.c
 
 8250/16?50 (AND CLONE UARTS) SERIAL DRIVER
 M:	Greg Kroah-Hartman <gregkh@suse.de>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8da9f96..42408d7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -594,73 +594,6 @@ config FEALNX
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet 
 	  cards. <http://www.myson.com.tw/>
 
-config 8139CP
-	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
-	depends on NET_PCI && PCI && EXPERIMENTAL
-	select CRC32
-	select MII
-	help
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the RTL8139C+ chips. If you have one of those, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called 8139cp.  This is recommended.
-
-config 8139TOO
-	tristate "RealTek RTL-8129/8130/8139 PCI Fast Ethernet Adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	---help---
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the RTL 8129/8130/8139 chips. If you have one of those, say Y and
-	  read the Ethernet-HOWTO <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called 8139too.  This is recommended.
-
-config 8139TOO_PIO
-	bool "Use PIO instead of MMIO"
-	default y
-	depends on 8139TOO
-	help
-	  This instructs the driver to use programmed I/O ports (PIO) instead
-	  of PCI shared memory (MMIO).  This can possibly solve some problems
-	  in case your mainboard has memory consistency issues.  If unsure,
-	  say N.
-
-config 8139TOO_TUNE_TWISTER
-	bool "Support for uncommon RTL-8139 rev. K (automatic channel equalization)"
-	depends on 8139TOO
-	help
-	  This implements a function which might come in handy in case you
-	  are using low quality on long cabling. It is required for RealTek
-	  RTL-8139 revision K boards, and totally unused otherwise.  It tries
-	  to match the transceiver to the cable characteristics. This is
-	  experimental since hardly documented by the manufacturer.
-	  If unsure, say Y.
-
-config 8139TOO_8129
-	bool "Support for older RTL-8129/8130 boards"
-	depends on 8139TOO
-	help
-	  This enables support for the older and uncommon RTL-8129 and
-	  RTL-8130 chips, which support MII via an external transceiver,
-	  instead of an internal one.  Disabling this option will save some
-	  memory by making the code size smaller.  If unsure, say Y.
-
-config 8139_OLD_RX_RESET
-	bool "Use older RX-reset method"
-	depends on 8139TOO
-	help
-	  The 8139too driver was recently updated to contain a more rapid
-	  reset sequence, in the face of severe receive errors.  This "new"
-	  RX-reset method should be adequate for all boards.  But if you
-	  experience problems, you can enable this option to restore the
-	  old RX-reset behavior.  If unsure, say N.
-
 config R6040
 	tristate "RDC R6040 Fast Ethernet Adapter support"
 	depends on NET_PCI && PCI
@@ -776,18 +709,6 @@ config VIA_RHINE_MMIO
 
 	  If unsure, say Y.
 
-config SC92031
-	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
-	depends on NET_PCI && PCI && EXPERIMENTAL
-	select CRC32
-	---help---
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
-	  have one of these, say Y here.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sc92031.  This is recommended.
-
 config CPMAC
 	tristate "TI AR7 CPMAC Ethernet support (EXPERIMENTAL)"
 	depends on NET_ETHERNET && EXPERIMENTAL && AR7
@@ -819,21 +740,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config ATP
-	tristate "AT-LAN-TEC/RealTek pocket adapter support"
-	depends on NET_POCKET && PARPORT && X86
-	select CRC32
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:drivers/net/atp.c> as well as the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>, if you
-	  want to use this.  If you intend to use this driver, you should have
-	  said N to the "Parallel printer support", because the two drivers
-	  don't like each other.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called atp.
-
 config DE600
 	tristate "D-Link DE600 pocket adapter support"
 	depends on NET_POCKET && PARPORT
@@ -1006,18 +912,6 @@ config YELLOWFIN
 	  To compile this driver as a module, choose M here: the module
 	  will be called yellowfin.  This is recommended.
 
-config R8169
-	tristate "Realtek 8169 gigabit ethernet support"
-	depends on PCI
-	select FW_LOADER
-	select CRC32
-	select MII
-	---help---
-	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called r8169.  This is recommended.
-
 config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0b341dc..d142fc5 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -112,12 +112,8 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_8139CP) += 8139cp.o
-obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
-obj-$(CONFIG_ATP) += atp.o
-obj-$(CONFIG_SC92031) += sc92031.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
@@ -128,7 +124,6 @@ obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
-obj-$(CONFIG_R8169) += r8169.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 110071e..fecac79 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -32,6 +32,7 @@ source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
+source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4a6edf7..0092c30 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
+obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
diff --git a/drivers/net/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
similarity index 100%
rename from drivers/net/8139cp.c
rename to drivers/net/ethernet/realtek/8139cp.c
diff --git a/drivers/net/8139too.c b/drivers/net/ethernet/realtek/8139too.c
similarity index 100%
rename from drivers/net/8139too.c
rename to drivers/net/ethernet/realtek/8139too.c
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
new file mode 100644
index 0000000..a5f67a09
--- /dev/null
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -0,0 +1,126 @@
+#
+# Realtek device configuration
+#
+
+config NET_VENDOR_REALTEK
+	bool "Realtek devices"
+	depends on PCI || (PARPORT && X86)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Realtek devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_REALTEK
+
+config ATP
+	tristate "AT-LAN-TEC/RealTek pocket adapter support"
+	depends on PARPORT && X86
+	select CRC32
+	---help---
+	  This is a network (Ethernet) device which attaches to your parallel
+	  port. Read <file:drivers/net/atp.c> as well as the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>, if you
+	  want to use this.  If you intend to use this driver, you should have
+	  said N to the "Parallel printer support", because the two drivers
+	  don't like each other.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called atp.
+
+config 8139CP
+	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select CRC32
+	select MII
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the RTL8139C+ chips. If you have one of those, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called 8139cp.  This is recommended.
+
+config 8139TOO
+	tristate "RealTek RTL-8129/8130/8139 PCI Fast Ethernet Adapter support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the RTL 8129/8130/8139 chips. If you have one of those, say Y and
+	  read the Ethernet-HOWTO <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called 8139too.  This is recommended.
+
+config 8139TOO_PIO
+	bool "Use PIO instead of MMIO"
+	default y
+	depends on 8139TOO
+	---help---
+	  This instructs the driver to use programmed I/O ports (PIO) instead
+	  of PCI shared memory (MMIO).  This can possibly solve some problems
+	  in case your mainboard has memory consistency issues.  If unsure,
+	  say N.
+
+config 8139TOO_TUNE_TWISTER
+	bool "Support for uncommon RTL-8139 rev. K (automatic channel equalization)"
+	depends on 8139TOO
+	---help---
+	  This implements a function which might come in handy in case you
+	  are using low quality on long cabling. It is required for RealTek
+	  RTL-8139 revision K boards, and totally unused otherwise.  It tries
+	  to match the transceiver to the cable characteristics. This is
+	  experimental since hardly documented by the manufacturer.
+	  If unsure, say Y.
+
+config 8139TOO_8129
+	bool "Support for older RTL-8129/8130 boards"
+	depends on 8139TOO
+	---help---
+	  This enables support for the older and uncommon RTL-8129 and
+	  RTL-8130 chips, which support MII via an external transceiver,
+	  instead of an internal one.  Disabling this option will save some
+	  memory by making the code size smaller.  If unsure, say Y.
+
+config 8139_OLD_RX_RESET
+	bool "Use older RX-reset method"
+	depends on 8139TOO
+	---help---
+	  The 8139too driver was recently updated to contain a more rapid
+	  reset sequence, in the face of severe receive errors.  This "new"
+	  RX-reset method should be adequate for all boards.  But if you
+	  experience problems, you can enable this option to restore the
+	  old RX-reset behavior.  If unsure, say N.
+
+config R8169
+	tristate "Realtek 8169 gigabit ethernet support"
+	depends on PCI
+	select FW_LOADER
+	select CRC32
+	select MII
+	---help---
+	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called r8169.  This is recommended.
+
+config SC92031
+	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select CRC32
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
+	  have one of these, say Y here.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sc92031.  This is recommended.
+
+endif # NET_VENDOR_REALTEK
diff --git a/drivers/net/ethernet/realtek/Makefile b/drivers/net/ethernet/realtek/Makefile
new file mode 100644
index 0000000..e48cfb6
--- /dev/null
+++ b/drivers/net/ethernet/realtek/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the Realtek network device drivers.
+#
+
+obj-$(CONFIG_8139CP) += 8139cp.o
+obj-$(CONFIG_8139TOO) += 8139too.o
+obj-$(CONFIG_ATP) += atp.o
+obj-$(CONFIG_R8169) += r8169.o
+obj-$(CONFIG_SC92031) += sc92031.o
diff --git a/drivers/net/atp.c b/drivers/net/ethernet/realtek/atp.c
similarity index 100%
rename from drivers/net/atp.c
rename to drivers/net/ethernet/realtek/atp.c
diff --git a/drivers/net/atp.h b/drivers/net/ethernet/realtek/atp.h
similarity index 100%
rename from drivers/net/atp.h
rename to drivers/net/ethernet/realtek/atp.h
diff --git a/drivers/net/r8169.c b/drivers/net/ethernet/realtek/r8169.c
similarity index 100%
rename from drivers/net/r8169.c
rename to drivers/net/ethernet/realtek/r8169.c
diff --git a/drivers/net/sc92031.c b/drivers/net/ethernet/realtek/sc92031.c
similarity index 100%
rename from drivers/net/sc92031.c
rename to drivers/net/ethernet/realtek/sc92031.c
-- 
1.7.6

