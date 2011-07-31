From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/71] 8390: Move the 8390 related drivers
Date: Sat, 30 Jul 2011 20:26:23 -0700
Message-ID: <1312082850-24914-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Donald Becker <becker@scyld.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alain Malek <alain.malek@cryogen.com>,
	Peter De Schrijver <p2@mind.be>,
	"David Huggins-Daines" <dhd@debian.org>,
	Wim Dumon <wimpie@kotnet.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	David Hinds <dahinds@users.sourceforge.net>,
	Russell King <linux@arm.linux.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752851Ab1GaD1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:39 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the drivers for the National Semi-conductor 8390 chipset into
drivers/net/ethernet/8390/ and the necessary Kconfig and Makefile
changes.

CC: Donald Becker <becker@scyld.com>
CC: Paul Gortmaker <paul.gortmaker@windriver.com>
CC: Alain Malek <alain.malek@cryogen.com>
CC: Peter De Schrijver <p2@mind.be>
CC: "David Huggins-Daines" <dhd@debian.org>
CC: Wim Dumon <wimpie@kotnet.org>
CC: Yoshinori Sato <ysato@users.sourceforge.jp>
CC: David Hinds <dahinds@users.sourceforge.net>
CC: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                      |    5 +-
 drivers/net/Kconfig                              |  283 ------------------
 drivers/net/Makefile                             |   23 --
 drivers/net/arm/Kconfig                          |    8 -
 drivers/net/arm/Makefile                         |    1 -
 drivers/net/ethernet/3com/Kconfig                |   12 -
 drivers/net/{ => ethernet/8390}/3c503.c          |    0
 drivers/net/{ => ethernet/8390}/3c503.h          |    0
 drivers/net/{ => ethernet/8390}/8390.c           |    0
 drivers/net/{ => ethernet/8390}/8390.h           |    0
 drivers/net/{ => ethernet/8390}/8390p.c          |    0
 drivers/net/ethernet/8390/Kconfig                |  344 ++++++++++++++++++++++
 drivers/net/ethernet/8390/Makefile               |   29 ++
 drivers/net/{ => ethernet/8390}/ac3200.c         |    0
 drivers/net/{ => ethernet/8390}/apne.c           |    0
 drivers/net/{ => ethernet/8390}/ax88796.c        |    0
 drivers/net/{pcmcia => ethernet/8390}/axnet_cs.c |    2 +-
 drivers/net/{ => ethernet/8390}/e2100.c          |    0
 drivers/net/{ => ethernet/8390}/es3210.c         |    0
 drivers/net/{arm => ethernet/8390}/etherh.c      |    2 +-
 drivers/net/{ => ethernet/8390}/hp-plus.c        |    0
 drivers/net/{ => ethernet/8390}/hp.c             |    0
 drivers/net/{ => ethernet/8390}/hydra.c          |    0
 drivers/net/{ => ethernet/8390}/lib8390.c        |    0
 drivers/net/{ => ethernet/8390}/lne390.c         |    0
 drivers/net/{ => ethernet/8390}/mac8390.c        |    0
 drivers/net/{ => ethernet/8390}/ne-h8300.c       |    0
 drivers/net/{ => ethernet/8390}/ne.c             |    0
 drivers/net/{ => ethernet/8390}/ne2.c            |    0
 drivers/net/{ => ethernet/8390}/ne2k-pci.c       |    0
 drivers/net/{ => ethernet/8390}/ne3210.c         |    0
 drivers/net/{pcmcia => ethernet/8390}/pcnet_cs.c |    2 +-
 drivers/net/{ => ethernet/8390}/smc-mca.c        |    0
 drivers/net/{ => ethernet/8390}/smc-ultra.c      |    0
 drivers/net/{ => ethernet/8390}/smc-ultra32.c    |    0
 drivers/net/{ => ethernet/8390}/stnic.c          |    0
 drivers/net/{ => ethernet/8390}/wd.c             |    0
 drivers/net/{ => ethernet/8390}/zorro8390.c      |    0
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/pcmcia/Kconfig                       |   21 --
 drivers/net/pcmcia/Makefile                      |    2 -
 42 files changed, 380 insertions(+), 356 deletions(-)
 rename drivers/net/{ => ethernet/8390}/3c503.c (100%)
 rename drivers/net/{ => ethernet/8390}/3c503.h (100%)
 rename drivers/net/{ => ethernet/8390}/8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/8390.h (100%)
 rename drivers/net/{ => ethernet/8390}/8390p.c (100%)
 create mode 100644 drivers/net/ethernet/8390/Kconfig
 create mode 100644 drivers/net/ethernet/8390/Makefile
 rename drivers/net/{ => ethernet/8390}/ac3200.c (100%)
 rename drivers/net/{ => ethernet/8390}/apne.c (100%)
 rename drivers/net/{ => ethernet/8390}/ax88796.c (100%)
 rename drivers/net/{pcmcia => ethernet/8390}/axnet_cs.c (99%)
 rename drivers/net/{ => ethernet/8390}/e2100.c (100%)
 rename drivers/net/{ => ethernet/8390}/es3210.c (100%)
 rename drivers/net/{arm => ethernet/8390}/etherh.c (99%)
 rename drivers/net/{ => ethernet/8390}/hp-plus.c (100%)
 rename drivers/net/{ => ethernet/8390}/hp.c (100%)
 rename drivers/net/{ => ethernet/8390}/hydra.c (100%)
 rename drivers/net/{ => ethernet/8390}/lib8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/lne390.c (100%)
 rename drivers/net/{ => ethernet/8390}/mac8390.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne-h8300.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne2.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne2k-pci.c (100%)
 rename drivers/net/{ => ethernet/8390}/ne3210.c (100%)
 rename drivers/net/{pcmcia => ethernet/8390}/pcnet_cs.c (99%)
 rename drivers/net/{ => ethernet/8390}/smc-mca.c (100%)
 rename drivers/net/{ => ethernet/8390}/smc-ultra.c (100%)
 rename drivers/net/{ => ethernet/8390}/smc-ultra32.c (100%)
 rename drivers/net/{ => ethernet/8390}/stnic.c (100%)
 rename drivers/net/{ => ethernet/8390}/wd.c (100%)
 rename drivers/net/{ => ethernet/8390}/zorro8390.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7a8711d..e7fea16 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -170,8 +170,7 @@ F:	include/linux/serial_8250.h
 8390 NETWORK DRIVERS [WD80x3/SMC-ELITE, SMC-ULTRA, NE2000, 3C503, etc.]
 L:	netdev@vger.kernel.org
 S:	Orphan / Obsolete
-F:	drivers/net/*8390*
-F:	drivers/net/ax88796.c
+F:	drivers/net/ethernet/8390/
 
 9P FILE SYSTEM
 M:	Eric Van Hensbergen <ericvh@gmail.com>
@@ -6390,7 +6389,7 @@ W:	http://uclinux-h8.sourceforge.jp/
 S:	Supported
 F:	arch/h8300/
 F:	drivers/ide/ide-h8300.c
-F:	drivers/net/ne-h8300.c
+F:	drivers/net/ethernet/8390/ne-h8300.c
 
 UDF FILESYSTEM
 M:	Jan Kara <jack@suse.cz>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e446460..077085d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,22 +237,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config AX88796
-	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS || SUPERH
-	select PHYLIB
-	select MDIO_BITBANG
-	help
-	  AX88796 driver, using platform bus to provide
-	  chip detection and resources
-
-config AX88796_93CX6
-	bool "ASIX AX88796 external 93CX6 eeprom support"
-	depends on AX88796
-	select EEPROM_93CX6
-	help
-	  Select this if your platform comes with an external 93CX6 eeprom.
-
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on PPC_PMAC && PPC32
@@ -287,50 +271,6 @@ config BMAC
 	  To compile this driver as a module, choose M here: the module
 	  will be called bmac.
 
-config HYDRA
-	tristate "Hydra support"
-	depends on ZORRO
-	select CRC32
-	help
-	  If you have a Hydra Ethernet adapter, say Y. Otherwise, say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called hydra.
-
-config ZORRO8390
-	tristate "Zorro NS8390-based Ethernet support"
-	depends on ZORRO
-	select CRC32
-	help
-	  This driver is for Zorro Ethernet cards using an NS8390-compatible
-	  chipset, like the Village Tronic Ariadne II and the Individual
-	  Computers X-Surf Ethernet cards. If you have such a card, say Y.
-	  Otherwise, say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called zorro8390.
-
-config APNE
-	tristate "PCMCIA NE2000 support"
-	depends on AMIGA_PCMCIA
-	select CRC32
-	help
-	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
-	  say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called apne.
-
-config MAC8390
-	bool "Macintosh NS 8390 based ethernet cards"
-	depends on MAC
-	select CRC32
-	help
-	  If you want to include a driver to support Nubus or LC-PDS
-	  Ethernet cards using an NS8390 chipset or its equivalent, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
 config MAC89x0
 	tristate "Macintosh CS89x0 based ethernet cards"
 	depends on MAC
@@ -449,18 +389,6 @@ config SGI_O2MACE_ETH
 	tristate "SGI O2 MACE Fast Ethernet support"
 	depends on SGI_IP32=y
 
-config STNIC
-	tristate "National DP83902AV  support"
-	depends on SUPERH
-	select CRC32
-	help
-	  Support for cards based on the National Semiconductor DP83902AV
-	  ST-NIC Serial Network Interface Controller for Twisted Pair.  This
-	  is a 10Mbit/sec Ethernet controller.  Product overview and specs at
-	  <http://www.national.com/pf/DP/DP83902A.html>.
-
-	  If unsure, say N.
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
@@ -534,74 +462,6 @@ config SUNVNET
 	help
 	  Support for virtual network devices under Sun Logical Domains.
 
-config NET_VENDOR_SMC
-	bool "Western Digital/SMC cards"
-	depends on ISA || MCA || EISA || MAC
-	help
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Western Digital cards. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
-config WD80x3
-	tristate "WD80*3 support"
-	depends on NET_VENDOR_SMC && ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called wd.
-
-config ULTRAMCA
-	tristate "SMC Ultra MCA support"
-	depends on NET_VENDOR_SMC && MCA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type and are running
-	  an MCA based system (PS/2), say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc-mca.
-
-config ULTRA
-	tristate "SMC Ultra support"
-	depends on NET_VENDOR_SMC && ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Important: There have been many reports that, with some motherboards
-	  mixing an SMC Ultra and an Adaptec AHA154x SCSI card (or compatible,
-	  such as some BusLogic models) causes corruption problems with many
-	  operating systems. The Linux smc-ultra driver has a work-around for
-	  this but keep it in mind if you have such a SCSI card and have
-	  problems.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc-ultra.
-
-config ULTRA32
-	tristate "SMC Ultra32 EISA support"
-	depends on NET_VENDOR_SMC && EISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc-ultra32.
-
 config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
 	depends on NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
@@ -922,18 +782,6 @@ config NET_ISA
 	  the remaining ISA network card questions. If you say Y, you will be
 	  asked for your specific card in the following questions.
 
-config E2100
-	tristate "Cabletron E21xx support"
-	depends on NET_ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e2100.
-
 config EWRK3
 	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
 	depends on NET_ISA
@@ -975,30 +823,6 @@ config EEXPRESS_PRO
 	  To compile this driver as a module, choose M here. The module
 	  will be called eepro.
 
-config HPLAN_PLUS
-	tristate "HP PCLAN+ (27247B and 27252A) support"
-	depends on NET_ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called hp-plus.
-
-config HPLAN
-	tristate "HP PCLAN (27245 and other 27xxx series) support"
-	depends on NET_ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called hp.
-
 config LP486E
 	tristate "LP486E on board Ethernet"
 	depends on NET_ISA
@@ -1018,26 +842,6 @@ config ETH16I
 	  To compile this driver as a module, choose M here. The module
 	  will be called eth16i.
 
-config NE2000
-	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Many Ethernet cards
-	  without a specific driver are compatible with NE2000.
-
-	  If you have a PCI NE2000 card however, say N here and Y to "PCI
-	  NE2000 and clone support" under "EISA, VLB, PCI and on board
-	  controllers" below. If you have a NE2000 card and are running on
-	  an MCA system (a bus system used on some IBM PS/2 computers and
-	  laptops), say N here and Y to "NE/2 (ne2000 MCA version) support",
-	  below.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne.
-
 config ZNET
 	tristate "Zenith Z-Note support (EXPERIMENTAL)"
 	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
@@ -1059,18 +863,6 @@ config SEEQ8005
 	  To compile this driver as a module, choose M here. The module
 	  will be called seeq8005.
 
-config NE2_MCA
-	tristate "NE/2 (ne2000 MCA version) support"
-	depends on MCA_LEGACY
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne2.
-
 config IBMLANA
 	tristate "IBM LAN Adapter/A support"
 	depends on MCA
@@ -1126,18 +918,6 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
-config AC3200
-	tristate "Ansel Communications EISA 3200 support (EXPERIMENTAL)"
-	depends on NET_PCI && (ISA || EISA) && EXPERIMENTAL
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ac3200.
-
 config KSZ884X_PCI
 	tristate "Micrel KSZ8841/2 PCI"
 	depends on NET_PCI && PCI
@@ -1253,18 +1033,6 @@ config E100
 	  To compile this driver as a module, choose M here. The module
 	  will be called e100.
 
-config LNE390
-	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
-	depends on NET_PCI && EISA && EXPERIMENTAL
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called lne390.
-
 config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on NET_PCI && PCI
@@ -1285,50 +1053,6 @@ config NATSEMI
 	  More specific information and updates are available from
 	  <http://www.scyld.com/network/natsemi.html>.
 
-config NE2K_PCI
-	tristate "PCI NE2000 and clones support (see help)"
-	depends on NET_PCI && PCI
-	select CRC32
-	---help---
-	  This driver is for NE2000 compatible PCI cards. It will not work
-	  with ISA NE2000 cards (they have their own driver, "NE2000/NE1000
-	  support" below). If you have a PCI NE2000 network (Ethernet) card,
-	  say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  This driver also works for the following NE2000 clone cards:
-	  RealTek RTL-8029  Winbond 89C940  Compex RL2000  KTI ET32P2
-	  NetVin NV5000SC   Via 86C926      SureCom NE34   Winbond
-	  Holtek HT80232    Holtek HT80229
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne2k-pci.
-
-config NE3210
-	tristate "Novell/Eagle/Microdyne NE3210 EISA support (EXPERIMENTAL)"
-	depends on NET_PCI && EISA && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that this driver
-	  will NOT WORK for NE3200 cards as they are completely different.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne3210.
-
-config ES3210
-	tristate "Racal-Interlan EISA ES3210 support (EXPERIMENTAL)"
-	depends on NET_PCI && EISA && EXPERIMENTAL
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called es3210.
-
 config 8139CP
 	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
@@ -1666,13 +1390,6 @@ config FEC_MPC52xx_MDIO
 	  If not sure, enable.
 	  If compiled as module, it will be called fec_mpc52xx_phy.
 
-config NE_H8300
-	tristate "NE2000 compatible support for H8/300"
-	depends on H8300
-	help
-	  Say Y here if you want to use the NE2000 compatible
-	  controller on the Renesas H8/300 processor.
-
 config ATL2
 	tristate "Atheros L2 Fast Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e06b05..9861f6f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -65,7 +65,6 @@ obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
-obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
 obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
@@ -77,7 +76,6 @@ obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
-obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
@@ -112,9 +110,6 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_MAC8390) += mac8390.o
-obj-$(CONFIG_APNE) += apne.o 8390.o
-obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
@@ -122,24 +117,9 @@ obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
 endif
-obj-$(CONFIG_WD80x3) += wd.o 8390.o
-obj-$(CONFIG_EL2) += 3c503.o 8390p.o
-obj-$(CONFIG_NE2000) += ne.o 8390p.o
-obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
-obj-$(CONFIG_HPLAN) += hp.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
-obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
-obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
-obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
-obj-$(CONFIG_E2100) += e2100.o 8390.o
-obj-$(CONFIG_ES3210) += es3210.o 8390.o
-obj-$(CONFIG_LNE390) += lne390.o 8390.o
-obj-$(CONFIG_NE3210) += ne3210.o 8390.o
 obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
-obj-$(CONFIG_NE_H8300) += ne-h8300.o
-obj-$(CONFIG_AX88796) += ax88796.o
 obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
 obj-$(CONFIG_FTGMAC100) += ftgmac100.o
 obj-$(CONFIG_FTMAC100) += ftmac100.o
@@ -191,7 +171,6 @@ obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_NI52) += ni52.o
-obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
@@ -203,13 +182,11 @@ obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
-obj-$(CONFIG_ZORRO8390) += zorro8390.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_HYDRA) += hydra.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index d0c8cf2..715bf2a 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -17,14 +17,6 @@ config ARM_ETHER3
 	  If you have an Acorn system with one of these network cards, you
 	  should say Y to this option if you wish to use it with Linux.
 
-config ARM_ETHERH
-	tristate "I-cubed EtherH/ANT EtherM support"
-	depends on ARM && ARCH_ACORN
-	select CRC32
-	help
-	  If you have an Acorn system with one of these network cards, you
-	  should say Y to this option if you wish to use it with Linux.
-
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
 	depends on ARM && ARCH_AT91RM9200
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index 63c57be..f1e6150 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -3,7 +3,6 @@
 # Makefile for the ARM network device drivers
 #
 
-obj-$(CONFIG_ARM_ETHERH)	+= etherh.o
 obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index 9b343d9..7cbeae7 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -29,18 +29,6 @@ config EL1
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c501.
 
-config EL2
-	tristate "3c503 \"EtherLink II\" support"
-	depends on NET_VENDOR_3COM && ISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c503.
-
 config ELPLUS
 	tristate "3c505 \"EtherLink Plus\" support"
 	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
diff --git a/drivers/net/3c503.c b/drivers/net/ethernet/8390/3c503.c
similarity index 100%
rename from drivers/net/3c503.c
rename to drivers/net/ethernet/8390/3c503.c
diff --git a/drivers/net/3c503.h b/drivers/net/ethernet/8390/3c503.h
similarity index 100%
rename from drivers/net/3c503.h
rename to drivers/net/ethernet/8390/3c503.h
diff --git a/drivers/net/8390.c b/drivers/net/ethernet/8390/8390.c
similarity index 100%
rename from drivers/net/8390.c
rename to drivers/net/ethernet/8390/8390.c
diff --git a/drivers/net/8390.h b/drivers/net/ethernet/8390/8390.h
similarity index 100%
rename from drivers/net/8390.h
rename to drivers/net/ethernet/8390/8390.h
diff --git a/drivers/net/8390p.c b/drivers/net/ethernet/8390/8390p.c
similarity index 100%
rename from drivers/net/8390p.c
rename to drivers/net/ethernet/8390/8390p.c
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
new file mode 100644
index 0000000..072c641
--- /dev/null
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -0,0 +1,344 @@
+#
+# 8390 device configuration
+#
+
+config NET_VENDOR_8390
+	bool "National Semi-conductor 8390 devices"
+	depends on AMIGA_PCMCIA || PCI || SUPERH || ISA || MCA || EISA ||  \
+		   MAC || M32R || MACH_TX49XX || MCA_LEGACY || H8300 ||  \
+		   ARM || MIPS || ZORRO || PCMCIA || EXPERIMENTAL
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
+config EL2
+	tristate "3c503 \"EtherLink II\" support"
+	depends on NET_VENDOR_8390 && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c503.
+
+config AC3200
+	tristate "Ansel Communications EISA 3200 support (EXPERIMENTAL)"
+	depends on NET_VENDOR_8390 && PCI && (ISA || EISA) && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ac3200.
+
+config PCMCIA_AXNET
+	tristate "Asix AX88190 PCMCIA support"
+	depends on NET_VENDOR_8390 && PCMCIA
+	---help---
+	  Say Y here if you intend to attach an Asix AX88190-based PCMCIA
+	  (PC-card) Fast Ethernet card to your computer.  These cards are
+	  nearly NE2000 compatible but need a separate driver due to a few
+	  misfeatures.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called axnet_cs.  If unsure, say N.
+
+config AX88796
+	tristate "ASIX AX88796 NE2000 clone support"
+	depends on NET_VENDOR_8390 && (ARM || MIPS || SUPERH)
+	select PHYLIB
+	select MDIO_BITBANG
+	---help---
+	  AX88796 driver, using platform bus to provide
+	  chip detection and resources
+
+config AX88796_93CX6
+	bool "ASIX AX88796 external 93CX6 eeprom support"
+	depends on AX88796
+	select EEPROM_93CX6
+	---help---
+	  Select this if your platform comes with an external 93CX6 eeprom.
+
+config E2100
+	tristate "Cabletron E21xx support"
+	depends on NET_VENDOR_8390 && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e2100.
+
+config ES3210
+	tristate "Racal-Interlan EISA ES3210 support (EXPERIMENTAL)"
+	depends on NET_VENDOR_8390 && PCI && EISA && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called es3210.
+
+config HPLAN_PLUS
+	tristate "HP PCLAN+ (27247B and 27252A) support"
+	depends on NET_VENDOR_8390 && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp-plus.
+
+config HPLAN
+	tristate "HP PCLAN (27245 and other 27xxx series) support"
+	depends on NET_VENDOR_8390 && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp.
+
+config HYDRA
+	tristate "Hydra support"
+	depends on NET_VENDOR_8390 && ZORRO
+	select CRC32
+	---help---
+	  If you have a Hydra Ethernet adapter, say Y. Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called hydra.
+
+config ARM_ETHERH
+	tristate "I-cubed EtherH/ANT EtherM support"
+	depends on NET_VENDOR_8390 && ARM && ARCH_ACORN
+	select CRC32
+	---help---
+	  If you have an Acorn system with one of these network cards, you
+	  should say Y to this option if you wish to use it with Linux.
+
+config LNE390
+	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
+	depends on NET_VENDOR_8390 && PCI && EISA && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called lne390.
+
+config MAC8390
+	bool "Macintosh NS 8390 based ethernet cards"
+	depends on NET_VENDOR_8390 && MAC
+	select CRC32
+	---help---
+	  If you want to include a driver to support Nubus or LC-PDS
+	  Ethernet cards using an NS8390 chipset or its equivalent, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+config NE2000
+	tristate "NE2000/NE1000 support"
+	depends on NET_VENDOR_8390 && (ISA || (Q40 && m) || M32R || MACH_TX49XX)
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.  Many Ethernet cards
+	  without a specific driver are compatible with NE2000.
+
+	  If you have a PCI NE2000 card however, say N here and Y to "PCI
+	  NE2000 and clone support" under "EISA, VLB, PCI and on board
+	  controllers" below. If you have a NE2000 card and are running on
+	  an MCA system (a bus system used on some IBM PS/2 computers and
+	  laptops), say N here and Y to "NE/2 (ne2000 MCA version) support",
+	  below.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ne.
+
+config NE2_MCA
+	tristate "NE/2 (ne2000 MCA version) support"
+	depends on NET_VENDOR_8390 && MCA_LEGACY
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ne2.
+
+config NE2K_PCI
+	tristate "PCI NE2000 and clones support (see help)"
+	depends on NET_VENDOR_8390 && PCI
+	select CRC32
+	---help---
+	  This driver is for NE2000 compatible PCI cards. It will not work
+	  with ISA NE2000 cards (they have their own driver, "NE2000/NE1000
+	  support" below). If you have a PCI NE2000 network (Ethernet) card,
+	  say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  This driver also works for the following NE2000 clone cards:
+	  RealTek RTL-8029  Winbond 89C940  Compex RL2000  KTI ET32P2
+	  NetVin NV5000SC   Via 86C926      SureCom NE34   Winbond
+	  Holtek HT80232    Holtek HT80229
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ne2k-pci.
+
+config APNE
+	tristate "PCMCIA NE2000 support"
+	depends on NET_VENDOR_8390 && AMIGA_PCMCIA
+	select CRC32
+	---help---
+	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
+	  say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called apne.
+
+config NE3210
+	tristate "Novell/Eagle/Microdyne NE3210 EISA support (EXPERIMENTAL)"
+	depends on NET_VENDOR_8390 && PCI && EISA && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.  Note that this driver
+	  will NOT WORK for NE3200 cards as they are completely different.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ne3210.
+
+config PCMCIA_PCNET
+	tristate "NE2000 compatible PCMCIA support"
+	depends on NET_VENDOR_8390 && PCMCIA
+	select CRC32
+	---help---
+	  Say Y here if you intend to attach an NE2000 compatible PCMCIA
+	  (PC-card) Ethernet or Fast Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called pcnet_cs.  If unsure, say N.
+
+config NE_H8300
+	tristate "NE2000 compatible support for H8/300"
+	depends on NET_VENDOR_8390 && H8300
+	---help---
+	  Say Y here if you want to use the NE2000 compatible
+	  controller on the Renesas H8/300 processor.
+
+config STNIC
+	tristate "National DP83902AV  support"
+	depends on NET_VENDOR_8390 && SUPERH
+	select CRC32
+	---help---
+	  Support for cards based on the National Semiconductor DP83902AV
+	  ST-NIC Serial Network Interface Controller for Twisted Pair.  This
+	  is a 10Mbit/sec Ethernet controller.  Product overview and specs at
+	  <http://www.national.com/pf/DP/DP83902A.html>.
+
+	  If unsure, say N.
+
+config NET_VENDOR_SMC
+	bool "Western Digital/SMC cards"
+	depends on NET_VENDOR_8390 && (ISA || MCA || EISA || MAC)
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
+config ULTRAMCA
+	tristate "SMC Ultra MCA support"
+	depends on NET_VENDOR_SMC && MCA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type and are running
+	  an MCA based system (PS/2), say Y and read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc-mca.
+
+config ULTRA
+	tristate "SMC Ultra support"
+	depends on NET_VENDOR_SMC && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Important: There have been many reports that, with some motherboards
+	  mixing an SMC Ultra and an Adaptec AHA154x SCSI card (or compatible,
+	  such as some BusLogic models) causes corruption problems with many
+	  operating systems. The Linux smc-ultra driver has a work-around for
+	  this but keep it in mind if you have such a SCSI card and have
+	  problems.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc-ultra.
+
+config ULTRA32
+	tristate "SMC Ultra32 EISA support"
+	depends on NET_VENDOR_SMC && EISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc-ultra32.
+
+config WD80x3
+	tristate "WD80*3 support"
+	depends on NET_VENDOR_SMC && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called wd.
+
+config ZORRO8390
+	tristate "Zorro NS8390-based Ethernet support"
+	depends on NET_VENDOR_8390 && ZORRO
+	select CRC32
+	---help---
+	  This driver is for Zorro Ethernet cards using an NS8390-compatible
+	  chipset, like the Village Tronic Ariadne II and the Individual
+	  Computers X-Surf Ethernet cards. If you have such a card, say Y.
+	  Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called zorro8390.
diff --git a/drivers/net/ethernet/8390/Makefile b/drivers/net/ethernet/8390/Makefile
new file mode 100644
index 0000000..3337d7f
--- /dev/null
+++ b/drivers/net/ethernet/8390/Makefile
@@ -0,0 +1,29 @@
+#
+# Makefile for the 8390 network device drivers.
+#
+
+obj-$(CONFIG_MAC8390) += mac8390.o
+obj-$(CONFIG_AC3200) += ac3200.o 8390.o
+obj-$(CONFIG_APNE) += apne.o 8390.o
+obj-$(CONFIG_ARM_ETHERH) += etherh.o
+obj-$(CONFIG_AX88796) += ax88796.o
+obj-$(CONFIG_E2100) += e2100.o 8390.o
+obj-$(CONFIG_EL2) += 3c503.o 8390p.o
+obj-$(CONFIG_ES3210) += es3210.o 8390.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
+obj-$(CONFIG_HPLAN) += hp.o 8390p.o
+obj-$(CONFIG_HYDRA) += hydra.o 8390.o
+obj-$(CONFIG_LNE390) += lne390.o 8390.o
+obj-$(CONFIG_NE2000) += ne.o 8390p.o
+obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
+obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
+obj-$(CONFIG_NE3210) += ne3210.o 8390.o
+obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
+obj-$(CONFIG_PCMCIA_AXNET) += axnet_cs.o 8390.o
+obj-$(CONFIG_PCMCIA_PCNET) += pcnet_cs.o 8390.o
+obj-$(CONFIG_STNIC) += stnic.o 8390.o
+obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
+obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
+obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
+obj-$(CONFIG_WD80x3) += wd.o 8390.o
+obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
diff --git a/drivers/net/ac3200.c b/drivers/net/ethernet/8390/ac3200.c
similarity index 100%
rename from drivers/net/ac3200.c
rename to drivers/net/ethernet/8390/ac3200.c
diff --git a/drivers/net/apne.c b/drivers/net/ethernet/8390/apne.c
similarity index 100%
rename from drivers/net/apne.c
rename to drivers/net/ethernet/8390/apne.c
diff --git a/drivers/net/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
similarity index 100%
rename from drivers/net/ax88796.c
rename to drivers/net/ethernet/8390/ax88796.c
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
similarity index 99%
rename from drivers/net/pcmcia/axnet_cs.c
rename to drivers/net/ethernet/8390/axnet_cs.c
index 9953db7..3e4b926 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -38,7 +38,7 @@
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
-#include "../8390.h"
+#include "8390.h"
 
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/e2100.c b/drivers/net/ethernet/8390/e2100.c
similarity index 100%
rename from drivers/net/e2100.c
rename to drivers/net/ethernet/8390/e2100.c
diff --git a/drivers/net/es3210.c b/drivers/net/ethernet/8390/es3210.c
similarity index 100%
rename from drivers/net/es3210.c
rename to drivers/net/ethernet/8390/es3210.c
diff --git a/drivers/net/arm/etherh.c b/drivers/net/ethernet/8390/etherh.c
similarity index 99%
rename from drivers/net/arm/etherh.c
rename to drivers/net/ethernet/8390/etherh.c
index 03e217a..cf851fa 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -65,7 +65,7 @@
 static char version[] __initdata =
 	"EtherH/EtherM Driver (c) 2002-2004 Russell King " DRV_VERSION "\n";
 
-#include "../lib8390.c"
+#include "lib8390.c"
 
 static unsigned int net_debug = NET_DEBUG;
 
diff --git a/drivers/net/hp-plus.c b/drivers/net/ethernet/8390/hp-plus.c
similarity index 100%
rename from drivers/net/hp-plus.c
rename to drivers/net/ethernet/8390/hp-plus.c
diff --git a/drivers/net/hp.c b/drivers/net/ethernet/8390/hp.c
similarity index 100%
rename from drivers/net/hp.c
rename to drivers/net/ethernet/8390/hp.c
diff --git a/drivers/net/hydra.c b/drivers/net/ethernet/8390/hydra.c
similarity index 100%
rename from drivers/net/hydra.c
rename to drivers/net/ethernet/8390/hydra.c
diff --git a/drivers/net/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
similarity index 100%
rename from drivers/net/lib8390.c
rename to drivers/net/ethernet/8390/lib8390.c
diff --git a/drivers/net/lne390.c b/drivers/net/ethernet/8390/lne390.c
similarity index 100%
rename from drivers/net/lne390.c
rename to drivers/net/ethernet/8390/lne390.c
diff --git a/drivers/net/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
similarity index 100%
rename from drivers/net/mac8390.c
rename to drivers/net/ethernet/8390/mac8390.c
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ethernet/8390/ne-h8300.c
similarity index 100%
rename from drivers/net/ne-h8300.c
rename to drivers/net/ethernet/8390/ne-h8300.c
diff --git a/drivers/net/ne.c b/drivers/net/ethernet/8390/ne.c
similarity index 100%
rename from drivers/net/ne.c
rename to drivers/net/ethernet/8390/ne.c
diff --git a/drivers/net/ne2.c b/drivers/net/ethernet/8390/ne2.c
similarity index 100%
rename from drivers/net/ne2.c
rename to drivers/net/ethernet/8390/ne2.c
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
similarity index 100%
rename from drivers/net/ne2k-pci.c
rename to drivers/net/ethernet/8390/ne2k-pci.c
diff --git a/drivers/net/ne3210.c b/drivers/net/ethernet/8390/ne3210.c
similarity index 100%
rename from drivers/net/ne3210.c
rename to drivers/net/ethernet/8390/ne3210.c
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
similarity index 99%
rename from drivers/net/pcmcia/pcnet_cs.c
rename to drivers/net/ethernet/8390/pcnet_cs.c
index b4fd7c3..4010761 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -41,7 +41,7 @@
 #include <linux/log2.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
-#include "../8390.h"
+#include "8390.h"
 
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/smc-mca.c b/drivers/net/ethernet/8390/smc-mca.c
similarity index 100%
rename from drivers/net/smc-mca.c
rename to drivers/net/ethernet/8390/smc-mca.c
diff --git a/drivers/net/smc-ultra.c b/drivers/net/ethernet/8390/smc-ultra.c
similarity index 100%
rename from drivers/net/smc-ultra.c
rename to drivers/net/ethernet/8390/smc-ultra.c
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/ethernet/8390/smc-ultra32.c
similarity index 100%
rename from drivers/net/smc-ultra32.c
rename to drivers/net/ethernet/8390/smc-ultra32.c
diff --git a/drivers/net/stnic.c b/drivers/net/ethernet/8390/stnic.c
similarity index 100%
rename from drivers/net/stnic.c
rename to drivers/net/ethernet/8390/stnic.c
diff --git a/drivers/net/wd.c b/drivers/net/ethernet/8390/wd.c
similarity index 100%
rename from drivers/net/wd.c
rename to drivers/net/ethernet/8390/wd.c
diff --git a/drivers/net/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
similarity index 100%
rename from drivers/net/zorro8390.c
rename to drivers/net/ethernet/8390/zorro8390.c
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 5e62efd..56ed5ec 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,6 +12,7 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
+source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1bc2ac2..fc82588 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -3,4 +3,5 @@
 #
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
+obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index e17ad95..72aa257 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -31,16 +31,6 @@ config PCMCIA_FMVJ18X
 	  To compile this driver as a module, choose M here: the module will be
 	  called fmvj18x_cs.  If unsure, say N.
 
-config PCMCIA_PCNET
-	tristate "NE2000 compatible PCMCIA support"
-	select CRC32
-	help
-	  Say Y here if you intend to attach an NE2000 compatible PCMCIA
-	  (PC-card) Ethernet or Fast Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called pcnet_cs.  If unsure, say N.
-
 config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
 	select CRC32
@@ -61,17 +51,6 @@ config PCMCIA_XIRC2PS
 	  To compile this driver as a module, choose M here: the module will be
 	  called xirc2ps_cs.  If unsure, say N.
 
-config PCMCIA_AXNET
-	tristate "Asix AX88190 PCMCIA support"
-	---help---
-	  Say Y here if you intend to attach an Asix AX88190-based PCMCIA
-	  (PC-card) Fast Ethernet card to your computer.  These cards are
-	  nearly NE2000 compatible but need a separate driver due to a few
-	  misfeatures.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called axnet_cs.  If unsure, say N.
-
 config ARCNET_COM20020_CS
 	tristate "COM20020 ARCnet PCMCIA support"
 	depends on ARCNET_COM20020
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index 985f0ae..c2b8b44 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -4,10 +4,8 @@
 
 # 16-bit client drivers
 obj-$(CONFIG_PCMCIA_FMVJ18X)	+= fmvj18x_cs.o
-obj-$(CONFIG_PCMCIA_PCNET)	+= pcnet_cs.o
 obj-$(CONFIG_PCMCIA_SMC91C92)	+= smc91c92_cs.o
 obj-$(CONFIG_PCMCIA_XIRC2PS)	+= xirc2ps_cs.o
 obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
-obj-$(CONFIG_PCMCIA_AXNET)	+= axnet_cs.o
 
 obj-$(CONFIG_PCMCIA_IBMTR)	+= ibmtr_cs.o
-- 
1.7.6

