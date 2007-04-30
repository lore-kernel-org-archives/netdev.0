From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 20/36] Use menuconfig objects II - netdev (general+100mbit)
Date: Mon, 30 Apr 2007 13:43:20 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704301341461.29151@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704301225060.29151@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer.gwdg.de ([134.76.10.26]:49578 "EHLO mailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161662AbXD3Lo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 07:44:59 -0400
In-Reply-To: <Pine.LNX.4.61.0704301225060.29151@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CONFIG_NETDEVICES, CONFIG_NET_ETHERNET:
Change Kconfig objects from "menu, config" into "menuconfig" so
that the user can disable the whole feature without having to
enter the menu first.

CONFIG_SMC9194:
Move it so that it appears correctly in menuconfig.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

---
 drivers/net/Kconfig         |  167 +++++++++++++++++++++-----------------------
 drivers/net/arm/Kconfig     |   12 +--
 drivers/net/fec_8xx/Kconfig |    2 
 drivers/net/fs_enet/Kconfig |    2 
 drivers/net/tulip/Kconfig   |   27 +++----
 5 files changed, 102 insertions(+), 108 deletions(-)

--- linux-2.6.21-mm_20070428.orig/drivers/net/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/Kconfig
@@ -3,10 +3,7 @@
 # Network device configuration
 #
 
-menu "Network device support"
-	depends on NET
-
-config NETDEVICES
+menuconfig NETDEVICES
 	default y if UML
 	bool "Network device support"
 	---help---
@@ -151,11 +148,9 @@ source "drivers/net/phy/Kconfig"
 #	Ethernet
 #
 
-menu "Ethernet (10 or 100Mbit)"
-	depends on !UML
-
-config NET_ETHERNET
+menuconfig NET_ETHERNET
 	bool "Ethernet (10 or 100Mbit)"
+	depends on !UML
 	---help---
 	  Ethernet (also called IEEE 802.3 or ISO 8802-2) is the most common
 	  type of Local Area Network (LAN) in universities and companies.
@@ -180,9 +175,10 @@ config NET_ETHERNET
 	  kernel: saying N will just cause the configurator to skip all
 	  the questions about Ethernet network cards. If unsure, say N.
 
+if NET_ETHERNET
+
 config MII
 	tristate "Generic Media Independent Interface device support"
-	depends on NET_ETHERNET
 	help
 	  Most ethernet controllers have MII transceiver either as an external
 	  or internal device.  It is safe to say Y or M here even if your
@@ -190,7 +186,7 @@ config MII
 
 config MACB
 	tristate "Atmel MACB support"
-	depends on NET_ETHERNET && (AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263)
+	depends on AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263
 	select MII
 	help
 	  The Atmel MACB ethernet interface is found on many AT32 and AT91
@@ -203,7 +199,7 @@ source "drivers/net/arm/Kconfig"
 
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC && PPC32
+	depends on PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Power Macintoshes and clones with Ethernet built-in on the
@@ -226,7 +222,7 @@ config MACE_AAUI_PORT
 
 config BMAC
 	tristate "BMAC (G3 ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC && PPC32
+	depends on PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
@@ -237,7 +233,7 @@ config BMAC
 
 config ARIADNE
 	tristate "Ariadne support"
-	depends on NET_ETHERNET && ZORRO
+	depends on ZORRO
 	help
 	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
 	  Otherwise, say N.
@@ -247,7 +243,7 @@ config ARIADNE
 
 config A2065
 	tristate "A2065 support"
-	depends on NET_ETHERNET && ZORRO
+	depends on ZORRO
 	select CRC32
 	help
 	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
@@ -258,7 +254,7 @@ config A2065
 
 config HYDRA
 	tristate "Hydra support"
-	depends on NET_ETHERNET && ZORRO
+	depends on ZORRO
 	select CRC32
 	help
 	  If you have a Hydra Ethernet adapter, say Y. Otherwise, say N.
@@ -268,7 +264,7 @@ config HYDRA
 
 config ZORRO8390
 	tristate "Zorro NS8390-based Ethernet support"
-	depends on NET_ETHERNET && ZORRO
+	depends on ZORRO
 	select CRC32
 	help
 	  This driver is for Zorro Ethernet cards using an NS8390-compatible
@@ -281,7 +277,7 @@ config ZORRO8390
 
 config APNE
 	tristate "PCMCIA NE2000 support"
-	depends on NET_ETHERNET && AMIGA_PCMCIA
+	depends on AMIGA_PCMCIA
 	select CRC32
 	help
 	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
@@ -292,7 +288,7 @@ config APNE
 
 config APOLLO_ELPLUS
 	tristate "Apollo 3c505 support"
-	depends on NET_ETHERNET && APOLLO
+	depends on APOLLO
 	help
 	  Say Y or M here if your Apollo has a 3Com 3c505 ISA Ethernet card.
 	  If you don't have one made for Apollos, you can use one from a PC,
@@ -301,7 +297,7 @@ config APOLLO_ELPLUS
 
 config MAC8390
 	bool "Macintosh NS 8390 based ethernet cards"
-	depends on NET_ETHERNET && MAC
+	depends on MAC
 	select CRC32
 	help
 	  If you want to include a driver to support Nubus or LC-PDS
@@ -311,7 +307,7 @@ config MAC8390
 
 config MAC89x0
 	tristate "Macintosh CS89x0 based ethernet cards"
-	depends on NET_ETHERNET && MAC && BROKEN
+	depends on MAC && BROKEN
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards.  If you have a
 	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
@@ -324,7 +320,7 @@ config MAC89x0
 
 config MACSONIC
 	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
-	depends on NET_ETHERNET && MAC
+	depends on MAC
 	---help---
 	  Support for NatSemi SONIC based Ethernet devices.  This includes
 	  the onboard Ethernet in many Quadras as well as some LC-PDS,
@@ -338,7 +334,7 @@ config MACSONIC
 
 config MACMACE
 	bool "Macintosh (AV) onboard MACE ethernet (EXPERIMENTAL)"
-	depends on NET_ETHERNET && MAC && EXPERIMENTAL
+	depends on MAC && EXPERIMENTAL
 	select CRC32
 	help
 	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
@@ -348,7 +344,7 @@ config MACMACE
 
 config MVME147_NET
 	tristate "MVME147 (Lance) Ethernet support"
-	depends on NET_ETHERNET && MVME147
+	depends on MVME147
 	select CRC32
 	help
 	  Support for the on-board Ethernet interface on the Motorola MVME147
@@ -358,7 +354,7 @@ config MVME147_NET
 
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
-	depends on NET_ETHERNET && MVME16x
+	depends on MVME16x
 	help
 	  This is the driver for the Ethernet interface on the Motorola
 	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
@@ -367,7 +363,7 @@ config MVME16x_NET
 
 config BVME6000_NET
 	tristate "BVME6000 Ethernet support"
-	depends on NET_ETHERNET && BVME6000
+	depends on BVME6000
 	help
 	  This is the driver for the Ethernet interface on BVME4000 and
 	  BVME6000 VME boards.  Say Y here to include the driver for this chip
@@ -376,7 +372,7 @@ config BVME6000_NET
 
 config ATARILANCE
 	tristate "Atari Lance support"
-	depends on NET_ETHERNET && ATARI
+	depends on ATARI
 	help
 	  Say Y to include support for several Atari Ethernet adapters based
 	  on the AMD Lance chipset: RieblCard (with or without battery), or
@@ -384,7 +380,7 @@ config ATARILANCE
 
 config ATARI_BIONET
 	tristate "BioNet-100 support"
-	depends on NET_ETHERNET && ATARI && ATARI_ACSI && BROKEN
+	depends on ATARI && ATARI_ACSI && BROKEN
 	help
 	  Say Y to include support for BioData's BioNet-100 Ethernet adapter
 	  for the ACSI port. The driver works (has to work...) with a polled
@@ -392,7 +388,7 @@ config ATARI_BIONET
 
 config ATARI_PAMSNET
 	tristate "PAMsNet support"
-	depends on NET_ETHERNET && ATARI && ATARI_ACSI && BROKEN
+	depends on ATARI && ATARI_ACSI && BROKEN
 	help
 	  Say Y to include support for the PAMsNet Ethernet adapter for the
 	  ACSI port ("ACSI node"). The driver works (has to work...) with a
@@ -400,7 +396,7 @@ config ATARI_PAMSNET
 
 config SUN3LANCE
 	tristate "Sun3/Sun3x on-board LANCE support"
-	depends on NET_ETHERNET && (SUN3 || SUN3X)
+	depends on SUN3 || SUN3X
 	help
 	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
 	  featured an AMD Lance 10Mbit Ethernet controller on board; say Y
@@ -413,7 +409,7 @@ config SUN3LANCE
 
 config SUN3_82586
 	bool "Sun3 on-board Intel 82586 support"
-	depends on NET_ETHERNET && SUN3
+	depends on SUN3
 	help
 	  This driver enables support for the on-board Intel 82586 based
 	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
@@ -422,7 +418,7 @@ config SUN3_82586
 
 config HPLANCE
 	bool "HP on-board LANCE support"
-	depends on NET_ETHERNET && DIO
+	depends on DIO
 	select CRC32
 	help
 	  If you want to use the builtin "LANCE" Ethernet controller on an
@@ -430,21 +426,21 @@ config HPLANCE
 
 config LASI_82596
 	tristate "Lasi ethernet"
-	depends on NET_ETHERNET && GSC
+	depends on GSC
 	help
 	  Say Y here to support the builtin Intel 82596 ethernet controller
 	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
 
 config MIPS_JAZZ_SONIC
 	tristate "MIPS JAZZ onboard SONIC Ethernet support"
-	depends on NET_ETHERNET && MACH_JAZZ
+	depends on MACH_JAZZ
 	help
 	  This is the driver for the onboard card of MIPS Magnum 4000,
 	  Acer PICA, Olivetti M700-10 and a few other identical OEM systems.
 
 config MIPS_AU1X00_ENET
 	bool "MIPS AU1000 Ethernet support"
-	depends on NET_ETHERNET && SOC_AU1X00
+	depends on SOC_AU1X00
 	select PHYLIB
 	select CRC32
 	help
@@ -453,11 +449,11 @@ config MIPS_AU1X00_ENET
 
 config NET_SB1250_MAC
 	tristate "SB1250 Ethernet support"
-	depends on NET_ETHERNET && SIBYTE_SB1xxx_SOC
+	depends on SIBYTE_SB1xxx_SOC
 
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
-	depends on NET_ETHERNET && PCI && SGI_IP27
+	depends on PCI && SGI_IP27
 	select CRC32
 	select MII
 	help
@@ -487,7 +483,7 @@ config SGI_IOC3_ETH_HW_TX_CSUM
 
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device"
-	depends on NET_ETHERNET && MIPS_SIM
+	depends on MIPS_SIM
 	help
 	  The MIPSNET device is a simple Ethernet network device which is
 	  emulated by the MIPS Simulator.
@@ -495,11 +491,11 @@ config MIPS_SIM_NET
 
 config SGI_O2MACE_ETH
 	tristate "SGI O2 MACE Fast Ethernet support"
-	depends on NET_ETHERNET && SGI_IP32=y
+	depends on SGI_IP32=y
 
 config STNIC
 	tristate "National DP83902AV  support"
-	depends on NET_ETHERNET && SUPERH
+	depends on SUPERH
 	select CRC32
 	help
 	  Support for cards based on the National Semiconductor DP83902AV
@@ -511,7 +507,7 @@ config STNIC
 
 config SUNLANCE
 	tristate "Sun LANCE support"
-	depends on NET_ETHERNET && SBUS
+	depends on SBUS
 	select CRC32
 	help
 	  This driver supports the "le" interface present on all 32-bit Sparc
@@ -524,7 +520,7 @@ config SUNLANCE
 
 config HAPPYMEAL
 	tristate "Sun Happy Meal 10/100baseT support"
-	depends on NET_ETHERNET && (SBUS || PCI)
+	depends on SBUS || PCI
 	select CRC32
 	help
 	  This driver supports the "hme" interface present on most Ultra
@@ -537,7 +533,7 @@ config HAPPYMEAL
 
 config SUNBMAC
 	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
-	depends on NET_ETHERNET && SBUS && EXPERIMENTAL
+	depends on SBUS && EXPERIMENTAL
 	select CRC32
 	help
 	  This driver supports the "be" interface available as an Sbus option.
@@ -548,7 +544,7 @@ config SUNBMAC
 
 config SUNQE
 	tristate "Sun QuadEthernet support"
-	depends on NET_ETHERNET && SBUS
+	depends on SBUS
 	select CRC32
 	help
 	  This driver supports the "qe" 10baseT Ethernet device, available as
@@ -560,7 +556,7 @@ config SUNQE
 
 config SUNGEM
 	tristate "Sun GEM support"
-	depends on NET_ETHERNET && PCI
+	depends on PCI
 	select CRC32
 	help
 	  Support for the Sun GEM chip, aka Sun GigabitEthernet/P 2.0.  See also
@@ -568,7 +564,7 @@ config SUNGEM
 
 config CASSINI
 	tristate "Sun Cassini support"
-	depends on NET_ETHERNET && PCI
+	depends on PCI
 	select CRC32
 	help
 	  Support for the Sun Cassini chip, aka Sun GigaSwift Ethernet. See also
@@ -576,7 +572,7 @@ config CASSINI
 
 config NET_VENDOR_3COM
 	bool "3COM cards"
-	depends on NET_ETHERNET && (ISA || EISA || MCA || PCI)
+	depends on ISA || EISA || MCA || PCI
 	help
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -736,7 +732,7 @@ config TYPHOON
 
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on NET_ETHERNET && ISA && ISA_DMA_API
+	depends on ISA && ISA_DMA_API
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -748,7 +744,7 @@ config LANCE
 
 config NET_VENDOR_SMC
 	bool "Western Digital/SMC cards"
-	depends on NET_ETHERNET && (ISA || MCA || EISA || MAC)
+	depends on ISA || MCA || EISA || MAC
 	help
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -818,11 +814,27 @@ config ULTRA32
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called smc-ultra32.
 
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
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>. The module
+	  will be called smc9194.
+
 config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on NET_ETHERNET && (ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BFIN)
+	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BFIN
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
@@ -838,7 +850,7 @@ config SMC91X
 
 config BFIN_MAC
 	tristate "Blackfin 536/537 on-chip mac support"
-	depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
+	depends on (BF537 || BF536) && !BF537_PORT_H
 	select CRC32
 	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
 	help
@@ -880,26 +892,10 @@ config BFIN_MAC_RMII
 	help
 	  Use Reduced PHY MII Interface
 
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
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
-	  will be called smc9194.
-
 config NET_NETX
 	tristate "NetX Ethernet support"
 	select MII
-	depends on NET_ETHERNET && ARCH_NETX
+	depends on ARCH_NETX
 	help
 	  This is support for the Hilscher netX builtin Ethernet ports
 
@@ -909,7 +905,7 @@ config NET_NETX
 
 config DM9000
 	tristate "DM9000 support"
-	depends on (ARM || MIPS) && NET_ETHERNET
+	depends on ARM || MIPS
 	select CRC32
 	select MII
 	---help---
@@ -923,7 +919,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on NET_ETHERNET && ARCH_PXA
+	depends on ARCH_PXA
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
@@ -937,7 +933,7 @@ config SMC911X
 
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
-	depends on NET_ETHERNET && ISA
+	depends on ISA
 	help
 	  If you have a network (Ethernet) card belonging to this class, such
 	  as the NI5010, NI5210 or NI6210, say Y and read the Ethernet-HOWTO,
@@ -989,7 +985,7 @@ source "drivers/net/tulip/Kconfig"
 
 config AT1700
 	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on NET_ETHERNET && (ISA || MCA_LEGACY) && EXPERIMENTAL
+	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -1002,7 +998,7 @@ config AT1700
 
 config DEPCA
 	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
-	depends on NET_ETHERNET && (ISA || EISA || MCA)
+	depends on ISA || EISA || MCA
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -1016,7 +1012,7 @@ config DEPCA
 
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
-	depends on NET_ETHERNET && (ISA || EISA || PCI)
+	depends on ISA || EISA || PCI
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -1028,7 +1024,7 @@ config HP100
 
 config NET_ISA
 	bool "Other ISA cards"
-	depends on NET_ETHERNET && ISA
+	depends on ISA
 	---help---
 	  If your network (Ethernet) card hasn't been mentioned yet and its
 	  bus system (that's the way the cards talks to the other components
@@ -1191,7 +1187,7 @@ config SEEQ8005
 
 config NE2_MCA
 	tristate "NE/2 (ne2000 MCA version) support"
-	depends on NET_ETHERNET && MCA_LEGACY
+	depends on MCA_LEGACY
 	select CRC32
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -1204,7 +1200,7 @@ config NE2_MCA
 
 config IBMLANA
 	tristate "IBM LAN Adapter/A support"
-	depends on NET_ETHERNET && MCA && MCA_LEGACY
+	depends on MCA && MCA_LEGACY
 	---help---
 	  This is a Micro Channel Ethernet adapter.  You need to set
 	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
@@ -1220,7 +1216,7 @@ config IBMLANA
 
 config IBMVETH
 	tristate "IBM LAN Virtual Ethernet support"
-	depends on NET_ETHERNET && PPC_PSERIES
+	depends on PPC_PSERIES
 	---help---
 	  This driver supports virtual ethernet adapters on newer IBM iSeries
 	  and pSeries systems.
@@ -1301,7 +1297,7 @@ config IBM_EMAC_TAH
 
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
-	depends on NET_ETHERNET && (ISA || EISA || PCI)
+	depends on ISA || EISA || PCI
 	help
 	  This is another class of network cards which attach directly to the
 	  bus. If you have one of those, say Y and read the Ethernet-HOWTO,
@@ -1357,6 +1353,7 @@ config AMD8111_ETH
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called amd8111e.
+
 config AMD8111E_NAPI
 	bool "Enable NAPI support"
 	depends on AMD8111_ETH
@@ -1822,7 +1819,7 @@ config SC92031
 
 config NET_POCKET
 	bool "Pocket and portable adapters"
-	depends on NET_ETHERNET && PARPORT
+	depends on PARPORT
 	---help---
 	  Cute little network (Ethernet) devices which attach to the parallel
 	  port ("pocket adapters"), commonly used with laptops. If you have
@@ -1891,14 +1888,14 @@ config DE620
 
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
-	depends on NET_ETHERNET && SGI_IP22
+	depends on SGI_IP22
 	help
 	  Say Y here if you have an Seeq based Ethernet network card. This is
 	  used in many Silicon Graphics machines.
 
 config DECLANCE
 	tristate "DEC LANCE ethernet controller support"
-	depends on NET_ETHERNET && MACH_DECSTATION
+	depends on MACH_DECSTATION
 	select CRC32
 	help
 	  This driver is for the series of Ethernet controllers produced by
@@ -1928,7 +1925,7 @@ config FEC2
 
 config NE_H8300
 	tristate "NE2000 compatible support for H8/300"
-	depends on H8300 && NET_ETHERNET
+	depends on H8300
 	help
 	  Say Y here if you want to use the NE2000 compatible
 	  controller on the Renesas H8/300 processor.
@@ -1936,7 +1933,7 @@ config NE_H8300
 source "drivers/net/fec_8xx/Kconfig"
 source "drivers/net/fs_enet/Kconfig"
 
-endmenu
+endif # NET_ETHERNET
 
 #
 #	Gigabit Ethernet
@@ -3009,8 +3006,6 @@ config NETCONSOLE
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
-endif #NETDEVICES
-
 config NETPOLL
 	def_bool NETCONSOLE
 
@@ -3027,4 +3022,4 @@ config NETPOLL_TRAP
 config NET_POLL_CONTROLLER
 	def_bool NETPOLL
 
-endmenu
+endif # NETDEVICES
--- linux-2.6.21-mm_20070428.orig/drivers/net/arm/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/arm/Kconfig
@@ -4,7 +4,7 @@
 #
 config ARM_AM79C961A
 	bool "ARM EBSA110 AM79C961A support"
-	depends on NET_ETHERNET && ARM && ARCH_EBSA110
+	depends on ARM && ARCH_EBSA110
 	select CRC32
 	help
 	  If you wish to compile a kernel for the EBSA-110, then you should
@@ -12,21 +12,21 @@ config ARM_AM79C961A
 
 config ARM_ETHER1
 	tristate "Acorn Ether1 support"
-	depends on NET_ETHERNET && ARM && ARCH_ACORN
+	depends on ARM && ARCH_ACORN
 	help
 	  If you have an Acorn system with one of these (AKA25) network cards,
 	  you should say Y to this option if you wish to use it with Linux.
 
 config ARM_ETHER3
 	tristate "Acorn/ANT Ether3 support"
-	depends on NET_ETHERNET && ARM && ARCH_ACORN
+	depends on ARM && ARCH_ACORN
 	help
 	  If you have an Acorn system with one of these network cards, you
 	  should say Y to this option if you wish to use it with Linux.
 
 config ARM_ETHERH
 	tristate "I-cubed EtherH/ANT EtherM support"
-	depends on NET_ETHERNET && ARM && ARCH_ACORN
+	depends on ARM && ARCH_ACORN
 	select CRC32
 	help
 	  If you have an Acorn system with one of these network cards, you
@@ -34,7 +34,7 @@ config ARM_ETHERH
 
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
-	depends on NET_ETHERNET && ARM && ARCH_AT91RM9200
+	depends on ARM && ARCH_AT91RM9200
 	select MII
 	help
 	  If you wish to compile a kernel for the AT91RM9200 and enable
@@ -42,7 +42,7 @@ config ARM_AT91_ETHER
 
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
-	depends on NET_ETHERNET && ARM && ARCH_EP93XX
+	depends on ARM && ARCH_EP93XX
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
--- linux-2.6.21-mm_20070428.orig/drivers/net/fec_8xx/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/fec_8xx/Kconfig
@@ -1,6 +1,6 @@
 config FEC_8XX
 	tristate "Motorola 8xx FEC driver"
-	depends on NET_ETHERNET && 8xx
+	depends on 8XX
 	select MII
 
 config FEC_8XX_GENERIC_PHY
--- linux-2.6.21-mm_20070428.orig/drivers/net/fs_enet/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/fs_enet/Kconfig
@@ -1,6 +1,6 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on NET_ETHERNET && (CPM1 || CPM2)
+       depends on CPM1 || CPM2
        select MII
 
 config FS_ENET_HAS_SCC
--- linux-2.6.21-mm_20070428.orig/drivers/net/tulip/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/tulip/Kconfig
@@ -2,17 +2,17 @@
 # Tulip family network device configuration
 #
 
-menu "Tulip family network device support"
-	depends on NET_ETHERNET && (PCI || EISA || CARDBUS)
-
-config NET_TULIP
+menuconfig NET_TULIP
 	bool "\"Tulip\" family network device support"
+	depends on PCI || EISA || CARDBUS
 	help
 	  This selects the "Tulip" family of EISA/PCI network cards.
 
+if NET_TULIP
+
 config DE2104X
 	tristate "Early DECchip Tulip (dc2104x) PCI support (EXPERIMENTAL)"
-	depends on NET_TULIP && PCI && EXPERIMENTAL
+	depends on PCI && EXPERIMENTAL
 	select CRC32
 	---help---
 	  This driver is developed for the SMC EtherPower series Ethernet
@@ -30,7 +30,7 @@ config DE2104X
 
 config TULIP
 	tristate "DECchip Tulip (dc2114x) PCI support"
-	depends on NET_TULIP && PCI
+	depends on PCI
 	select CRC32
 	---help---
 	  This driver is developed for the SMC EtherPower series Ethernet
@@ -95,7 +95,7 @@ config TULIP_NAPI_HW_MITIGATION
 
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
-	depends on NET_TULIP && (PCI || EISA)
+	depends on PCI || EISA
 	select CRC32
 	---help---
 	  This is support for the DIGITAL series of PCI/EISA Ethernet cards.
@@ -112,7 +112,7 @@ config DE4X5
 
 config WINBOND_840
 	tristate "Winbond W89c840 Ethernet support"
-	depends on NET_TULIP && PCI
+	depends on PCI
 	select CRC32
 	select MII
 	help
@@ -123,7 +123,7 @@ config WINBOND_840
 
 config DM9102
 	tristate "Davicom DM910x/DM980x support"
-	depends on NET_TULIP && PCI
+	depends on PCI
 	select CRC32
 	---help---
 	  This driver is for DM9102(A)/DM9132/DM9801 compatible PCI cards from
@@ -137,7 +137,7 @@ config DM9102
 
 config ULI526X
 	tristate "ULi M526x controller support"
-	depends on NET_TULIP && PCI
+	depends on PCI
 	select CRC32
 	---help---
 	  This driver is for ULi M5261/M5263 10/100M Ethernet Controller
@@ -149,7 +149,7 @@ config ULI526X
 	  
 config PCMCIA_XIRCOM
 	tristate "Xircom CardBus support (new driver)"
-	depends on NET_TULIP && CARDBUS
+	depends on CARDBUS
 	---help---
 	  This driver is for the Digital "Tulip" Ethernet CardBus adapters.
 	  It should work with most DEC 21*4*-based chips/ethercards, as well
@@ -162,7 +162,7 @@ config PCMCIA_XIRCOM
 
 config PCMCIA_XIRTULIP
 	tristate "Xircom Tulip-like CardBus support (old driver)"
-	depends on NET_TULIP && CARDBUS && BROKEN_ON_SMP
+	depends on CARDBUS && BROKEN_ON_SMP
 	select CRC32
 	---help---
 	  This driver is for the Digital "Tulip" Ethernet CardBus adapters.
@@ -174,5 +174,4 @@ config PCMCIA_XIRTULIP
 	  <file:Documentation/networking/net-modules.txt>.  The module will
 	  be called xircom_tulip_cb.  If unsure, say N.
 
-endmenu
-
+endif # NET_TULIP
