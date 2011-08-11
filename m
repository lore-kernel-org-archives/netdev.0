From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] *sonic/natsemi/ns83829: Move the National Semi-conductor drivers
Date: Thu, 11 Aug 2011 16:39:53 -0700
Message-ID: <1313105998-2859-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Harald Welte <laforge@gnumonks.org>,
	Tim Hockin <thockin@hockin.org>, <linux-ns83820@kvack.org>,
	Kevin Chea <kchea@yahoo.com>,
	Marc Gauthier <marc@linux-xtensa.org>,
	Chris Zankel <chris@zankel.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab1HKXkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 19:40:04 -0400
In-Reply-To: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the National Semi-conductor drivers into drivers/net/ethernet/natsemi/
and make the necessary Kconfig and Makefile changes.  Also moved the 8390
(National Semi-conductor) devices as a sub-menu of National Semi-conductor
devices.

- moved the ibmlana driver as well into this directory since it is a
  "SONIC" driver

CC: Alfred Arnold <alfred.arnold@lancom.de>
CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
CC: Harald Welte <laforge@gnumonks.org>
CC: Tim Hockin <thockin@hockin.org>
CC: <linux-ns83820@kvack.org>
CC: Kevin Chea <kchea@yahoo.com>
CC: Marc Gauthier <marc@linux-xtensa.org>
CC: Chris Zankel <chris@zankel.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Marc Gauthier <marc@tensilica.com>
---
 MAINTAINERS                                    |    4 +-
 drivers/net/Kconfig                            |   62 ------------------
 drivers/net/Makefile                           |    7 --
 drivers/net/ethernet/8390/Kconfig              |    7 +-
 drivers/net/ethernet/Kconfig                   |    3 +-
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/natsemi/Kconfig           |   82 ++++++++++++++++++++++++
 drivers/net/ethernet/natsemi/Makefile          |   10 +++
 drivers/net/{ => ethernet/natsemi}/ibmlana.c   |    0
 drivers/net/{ => ethernet/natsemi}/ibmlana.h   |    0
 drivers/net/{ => ethernet/natsemi}/jazzsonic.c |    0
 drivers/net/{ => ethernet/natsemi}/macsonic.c  |    0
 drivers/net/{ => ethernet/natsemi}/natsemi.c   |    0
 drivers/net/{ => ethernet/natsemi}/ns83820.c   |    0
 drivers/net/{ => ethernet/natsemi}/sonic.c     |    0
 drivers/net/{ => ethernet/natsemi}/sonic.h     |    0
 drivers/net/{ => ethernet/natsemi}/xtsonic.c   |    0
 17 files changed, 101 insertions(+), 75 deletions(-)
 create mode 100644 drivers/net/ethernet/natsemi/Kconfig
 create mode 100644 drivers/net/ethernet/natsemi/Makefile
 rename drivers/net/{ => ethernet/natsemi}/ibmlana.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/ibmlana.h (100%)
 rename drivers/net/{ => ethernet/natsemi}/jazzsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/macsonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/natsemi.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/ns83820.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.c (100%)
 rename drivers/net/{ => ethernet/natsemi}/sonic.h (100%)
 rename drivers/net/{ => ethernet/natsemi}/xtsonic.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5dffc8e..554529d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4340,7 +4340,7 @@ F:	drivers/net/ethernet/myricom/myri10ge/
 NATSEMI ETHERNET DRIVER (DP8381x)
 M:	Tim Hockin <thockin@hockin.org>
 S:	Maintained
-F:	drivers/net/natsemi.c
+F:	drivers/net/ethernet/natsemi/natsemi.c
 
 NATIVE INSTRUMENTS USB SOUND INTERFACE DRIVER
 M:	Daniel Mack <zonque@gmail.com>
@@ -5943,7 +5943,7 @@ SONIC NETWORK DRIVER
 M:	Thomas Bogendoerfer <tsbogend@alpha.franken.de>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/sonic.*
+F:	drivers/net/ethernet/natsemi/sonic.*
 
 SONICS SILICON BACKPLANE DRIVER (SSB)
 M:	Michael Buesch <m@bues.ch>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d81f8f9..8b1fae8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,19 +237,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config MACSONIC
-	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
-	depends on MAC
-	---help---
-	  Support for NatSemi SONIC based Ethernet devices.  This includes
-	  the onboard Ethernet in many Quadras as well as some LC-PDS,
-	  a few Nubus and all known Comm Slot Ethernet cards.  If you have
-	  one of these say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. This module will
-	  be called macsonic.
-
 config KORINA
 	tristate "Korina (IDT RC32434) Ethernet support"
 	depends on NET_ETHERNET && MIKROTIK_RB532
@@ -257,19 +244,6 @@ config KORINA
 	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
 	  based system say Y. Otherwise say N.
 
-config MIPS_JAZZ_SONIC
-	tristate "MIPS JAZZ onboard SONIC Ethernet support"
-	depends on MACH_JAZZ
-	help
-	  This is the driver for the onboard card of MIPS Magnum 4000,
-	  Acer PICA, Olivetti M700-10 and a few other identical OEM systems.
-
-config XTENSA_XT2000_SONIC
-	tristate "Xtensa XT2000 onboard SONIC Ethernet support"
-	depends on XTENSA_PLATFORM_XT2000
-	help
-	  This is the driver for the onboard card of the Xtensa XT2000 board.
-
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
 	depends on PCI && SGI_IP27
@@ -556,21 +530,6 @@ config SEEQ8005
 	  To compile this driver as a module, choose M here. The module
 	  will be called seeq8005.
 
-config IBMLANA
-	tristate "IBM LAN Adapter/A support"
-	depends on MCA
-	---help---
-	  This is a Micro Channel Ethernet adapter.  You need to set
-	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
-	  driver and as a module.
-
-	  To compile this driver as a module, choose M here. The only
-	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
-	  will both support 16K and 32K memory windows, however a 32K window
-	  gives a better security against packet losses.  Usage of multiple
-	  boards with this driver should be possible, but has not been tested
-	  up to now due to lack of hardware.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
@@ -635,17 +594,6 @@ config FEALNX
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet 
 	  cards. <http://www.myson.com.tw/>
 
-config NATSEMI
-	tristate "National Semiconductor DP8381x series PCI Ethernet support"
-	depends on NET_PCI && PCI
-	select CRC32
-	help
-	  This driver is for the National Semiconductor DP83810 series,
-	  which is used in cards from PureData, NetGear, Linksys
-	  and others, including the 83815 chip.
-	  More specific information and updates are available from
-	  <http://www.scyld.com/network/natsemi.html>.
-
 config 8139CP
 	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
@@ -1043,16 +991,6 @@ config IP1000
 
 source "drivers/net/ixp2000/Kconfig"
 
-config NS83820
-	tristate "National Semiconductor DP83820 support"
-	depends on PCI
-	help
-	  This is a driver for the National Semiconductor DP83820 series
-	  of gigabit ethernet MACs.  Cards using this chipset include
-	  the D-Link DGE-500T, PureData's PDP8023Z-TG, SMC's SMC9462TX,
-	  SOHO-GA2000T, SOHO-GA2500T.  The driver supports the use of
-	  zero copy.
-
 config HAMACHI
 	tristate "Packet Engines Hamachi GNIC-II support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 79f93f0..843edb3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -43,8 +43,6 @@ obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
-obj-$(CONFIG_NATSEMI) += natsemi.o
-obj-$(CONFIG_NS83820) += ns83820.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
@@ -116,7 +114,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
@@ -127,10 +124,8 @@ obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
-obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
@@ -144,8 +139,6 @@ obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
-obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
-
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_S6GMAC) += s6gmac.o
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index f1b9bdd..5d21698 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -4,9 +4,10 @@
 
 config NET_VENDOR_8390
 	bool "National Semi-conductor 8390 devices"
-	depends on AMIGA_PCMCIA || PCI || SUPERH || ISA || MCA || EISA ||  \
-		   MAC || M32R || MACH_TX49XX || MCA_LEGACY || H8300 ||  \
-		   ARM || MIPS || ZORRO || PCMCIA || EXPERIMENTAL
+	depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH || \
+		   ISA || MCA || EISA || MAC || M32R || MACH_TX49XX || \
+		   MCA_LEGACY || H8300 || ARM || MIPS || ZORRO || PCMCIA || \
+		   EXPERIMENTAL)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c3c415d..efc3665 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,7 +12,6 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
-source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
@@ -26,6 +25,8 @@ source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
+source "drivers/net/ethernet/natsemi/Kconfig"
+source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index b67b88d..668ca92 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -17,6 +17,7 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
+obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
diff --git a/drivers/net/ethernet/natsemi/Kconfig b/drivers/net/ethernet/natsemi/Kconfig
new file mode 100644
index 0000000..1e5c1e1
--- /dev/null
+++ b/drivers/net/ethernet/natsemi/Kconfig
@@ -0,0 +1,82 @@
+#
+# National Semi-conductor device configuration
+#
+
+config NET_VENDOR_NATSEMI
+	bool "National Semi-conductor devices"
+	depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT2000
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about National Semi-conductor devices. If you say Y,
+	  you will be asked for your specific card in the following questions.
+
+if NET_VENDOR_NATSEMI
+
+config IBMLANA
+	tristate "IBM LAN Adapter/A support"
+	depends on MCA
+	---help---
+	  This is a Micro Channel Ethernet adapter.  You need to set
+	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
+	  driver and as a module.
+
+	  To compile this driver as a module, choose M here. The only
+	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
+	  will both support 16K and 32K memory windows, however a 32K window
+	  gives a better security against packet losses.  Usage of multiple
+	  boards with this driver should be possible, but has not been tested
+	  up to now due to lack of hardware.
+
+config MACSONIC
+	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
+	depends on MAC
+	---help---
+	  Support for NatSemi SONIC based Ethernet devices.  This includes
+	  the onboard Ethernet in many Quadras as well as some LC-PDS,
+	  a few Nubus and all known Comm Slot Ethernet cards.  If you have
+	  one of these say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called macsonic.
+
+config MIPS_JAZZ_SONIC
+	tristate "MIPS JAZZ onboard SONIC Ethernet support"
+	depends on MACH_JAZZ
+	---help---
+	  This is the driver for the onboard card of MIPS Magnum 4000,
+	  Acer PICA, Olivetti M700-10 and a few other identical OEM systems.
+
+config NATSEMI
+	tristate "National Semiconductor DP8381x series PCI Ethernet support"
+	depends on PCI
+	select CRC32
+	---help---
+	  This driver is for the National Semiconductor DP83810 series,
+	  which is used in cards from PureData, NetGear, Linksys
+	  and others, including the 83815 chip.
+	  More specific information and updates are available from
+	  <http://www.scyld.com/network/natsemi.html>.
+
+config NS83820
+	tristate "National Semiconductor DP83820 support"
+	depends on PCI
+	---help---
+	  This is a driver for the National Semiconductor DP83820 series
+	  of gigabit ethernet MACs.  Cards using this chipset include
+	  the D-Link DGE-500T, PureData's PDP8023Z-TG, SMC's SMC9462TX,
+	  SOHO-GA2000T, SOHO-GA2500T.  The driver supports the use of
+	  zero copy.
+
+config XTENSA_XT2000_SONIC
+	tristate "Xtensa XT2000 onboard SONIC Ethernet support"
+	depends on XTENSA_PLATFORM_XT2000
+	---help---
+	  This is the driver for the onboard card of the Xtensa XT2000 board.
+
+endif # NET_VENDOR_NATSEMI
diff --git a/drivers/net/ethernet/natsemi/Makefile b/drivers/net/ethernet/natsemi/Makefile
new file mode 100644
index 0000000..9aa5dea
--- /dev/null
+++ b/drivers/net/ethernet/natsemi/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for the National Semi-conductor Sonic devices.
+#
+
+obj-$(CONFIG_IBMLANA) += ibmlana.o
+obj-$(CONFIG_MACSONIC) += macsonic.o
+obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
+obj-$(CONFIG_NATSEMI) += natsemi.o
+obj-$(CONFIG_NS83820) += ns83820.o
+obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
diff --git a/drivers/net/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
similarity index 100%
rename from drivers/net/ibmlana.c
rename to drivers/net/ethernet/natsemi/ibmlana.c
diff --git a/drivers/net/ibmlana.h b/drivers/net/ethernet/natsemi/ibmlana.h
similarity index 100%
rename from drivers/net/ibmlana.h
rename to drivers/net/ethernet/natsemi/ibmlana.h
diff --git a/drivers/net/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
similarity index 100%
rename from drivers/net/jazzsonic.c
rename to drivers/net/ethernet/natsemi/jazzsonic.c
diff --git a/drivers/net/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
similarity index 100%
rename from drivers/net/macsonic.c
rename to drivers/net/ethernet/natsemi/macsonic.c
diff --git a/drivers/net/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
similarity index 100%
rename from drivers/net/natsemi.c
rename to drivers/net/ethernet/natsemi/natsemi.c
diff --git a/drivers/net/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
similarity index 100%
rename from drivers/net/ns83820.c
rename to drivers/net/ethernet/natsemi/ns83820.c
diff --git a/drivers/net/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
similarity index 100%
rename from drivers/net/sonic.c
rename to drivers/net/ethernet/natsemi/sonic.c
diff --git a/drivers/net/sonic.h b/drivers/net/ethernet/natsemi/sonic.h
similarity index 100%
rename from drivers/net/sonic.h
rename to drivers/net/ethernet/natsemi/sonic.h
diff --git a/drivers/net/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
similarity index 100%
rename from drivers/net/xtsonic.c
rename to drivers/net/ethernet/natsemi/xtsonic.c
-- 
1.7.6

