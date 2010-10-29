From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 08/15] netdev: relocate toplevel 8390 based drivers to legacy dir
Date: Thu, 28 Oct 2010 21:19:12 -0400
Message-ID: <1288315159-1350-9-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33980 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772Ab0J2BTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:30 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the original 8 bit ISA ne1000 card being over 20 years old,
it only makes sense to relocate ne.c and all the other toplevel
8390 based driver files to the legacy dir.  Largely the most recent
thing made in large quantities that was 8390 based was those
crazy PCI ne2k clones - and even they are now 10 years old.

The couple other non-toplevel drivers (arm, pcmcia), which
source 8390.h or lib8390.c are just updated in place to have
the legacy part added to their path.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                    |  226 --------------------------------
 drivers/net/Makefile                   |   23 ----
 drivers/net/arm/etherh.c               |    2 +-
 drivers/net/{ => legacy}/3c503.c       |    0
 drivers/net/{ => legacy}/3c503.h       |    0
 drivers/net/{ => legacy}/8390.c        |    0
 drivers/net/{ => legacy}/8390.h        |    0
 drivers/net/{ => legacy}/8390p.c       |    0
 drivers/net/legacy/Kconfig             |  226 ++++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile            |   29 ++++
 drivers/net/{ => legacy}/ac3200.c      |    0
 drivers/net/{ => legacy}/apne.c        |    0
 drivers/net/{ => legacy}/ax88796.c     |    0
 drivers/net/{ => legacy}/e2100.c       |    0
 drivers/net/{ => legacy}/es3210.c      |    0
 drivers/net/{ => legacy}/hp-plus.c     |    0
 drivers/net/{ => legacy}/hp.c          |    0
 drivers/net/{ => legacy}/hydra.c       |    0
 drivers/net/{ => legacy}/lib8390.c     |    0
 drivers/net/{ => legacy}/lne390.c      |    0
 drivers/net/{ => legacy}/mac8390.c     |    0
 drivers/net/{ => legacy}/ne-h8300.c    |    0
 drivers/net/{ => legacy}/ne.c          |    0
 drivers/net/{ => legacy}/ne2.c         |    0
 drivers/net/{ => legacy}/ne2k-pci.c    |    0
 drivers/net/{ => legacy}/ne3210.c      |    0
 drivers/net/{ => legacy}/smc-mca.c     |    0
 drivers/net/{ => legacy}/smc-ultra.c   |    0
 drivers/net/{ => legacy}/smc-ultra32.c |    0
 drivers/net/{ => legacy}/stnic.c       |    0
 drivers/net/{ => legacy}/wd.c          |    0
 drivers/net/{ => legacy}/zorro8390.c   |    0
 drivers/net/pcmcia/axnet_cs.c          |    2 +-
 drivers/net/pcmcia/pcnet_cs.c          |    2 +-
 34 files changed, 258 insertions(+), 252 deletions(-)
 rename drivers/net/{ => legacy}/3c503.c (100%)
 rename drivers/net/{ => legacy}/3c503.h (100%)
 rename drivers/net/{ => legacy}/8390.c (100%)
 rename drivers/net/{ => legacy}/8390.h (100%)
 rename drivers/net/{ => legacy}/8390p.c (100%)
 rename drivers/net/{ => legacy}/ac3200.c (100%)
 rename drivers/net/{ => legacy}/apne.c (100%)
 rename drivers/net/{ => legacy}/ax88796.c (100%)
 rename drivers/net/{ => legacy}/e2100.c (100%)
 rename drivers/net/{ => legacy}/es3210.c (100%)
 rename drivers/net/{ => legacy}/hp-plus.c (100%)
 rename drivers/net/{ => legacy}/hp.c (100%)
 rename drivers/net/{ => legacy}/hydra.c (100%)
 rename drivers/net/{ => legacy}/lib8390.c (100%)
 rename drivers/net/{ => legacy}/lne390.c (100%)
 rename drivers/net/{ => legacy}/mac8390.c (100%)
 rename drivers/net/{ => legacy}/ne-h8300.c (100%)
 rename drivers/net/{ => legacy}/ne.c (100%)
 rename drivers/net/{ => legacy}/ne2.c (100%)
 rename drivers/net/{ => legacy}/ne2k-pci.c (100%)
 rename drivers/net/{ => legacy}/ne3210.c (100%)
 rename drivers/net/{ => legacy}/smc-mca.c (100%)
 rename drivers/net/{ => legacy}/smc-ultra.c (100%)
 rename drivers/net/{ => legacy}/smc-ultra32.c (100%)
 rename drivers/net/{ => legacy}/stnic.c (100%)
 rename drivers/net/{ => legacy}/wd.c (100%)
 rename drivers/net/{ => legacy}/zorro8390.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6ef5848..9f6315c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -249,22 +249,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config AX88796
-	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS || SUPERH
-	select CRC32
-	select MII
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
@@ -310,50 +294,6 @@ config A2065
 	  To compile this driver as a module, choose M here: the module
 	  will be called a2065.
 
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
@@ -440,18 +380,6 @@ config SGI_O2MACE_ETH
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
@@ -551,18 +479,6 @@ config NET_VENDOR_3COM
 	  the questions about 3COM cards. If you say Y, you will be asked for
 	  your specific card in the following questions.
 
-config EL2
-	tristate "3c503 \"EtherLink II\" support"
-	depends on NET_VENDOR_3COM && ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c503.
-
 config EL3
 	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
 	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
@@ -642,61 +558,6 @@ config NET_VENDOR_SMC
 	  the questions about Western Digital cards. If you say Y, you will be
 	  asked for your specific card in the following questions.
 
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
@@ -985,42 +846,6 @@ config NET_ISA
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
 config ETH16I
 	tristate "ICL EtherTeam 16i/32 support"
 	depends on NET_ISA
@@ -1032,26 +857,6 @@ config ETH16I
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
 config SEEQ8005
 	tristate "SEEQ8005 support (EXPERIMENTAL)"
 	depends on NET_ISA && EXPERIMENTAL
@@ -1063,18 +868,6 @@ config SEEQ8005
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
@@ -1283,18 +1076,6 @@ config E100
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
@@ -1679,13 +1460,6 @@ config FEC_MPC52xx_MDIO
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
index 68c1eb9..e5015c6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -66,7 +66,6 @@ obj-$(CONFIG_BMAC) += bmac.o
 
 obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
-obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
 obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
@@ -80,7 +79,6 @@ obj-$(CONFIG_ACENIC) += acenic.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
-obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
@@ -115,9 +113,6 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_MAC8390) += mac8390.o
-obj-$(CONFIG_APNE) += apne.o 8390.o
-obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
@@ -126,24 +121,9 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
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
-obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
-obj-$(CONFIG_AX88796) += ax88796.o
 obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
@@ -185,11 +165,9 @@ obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
-obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_SC92031) += sc92031.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
-obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
@@ -197,7 +175,6 @@ obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_A2065) += a2065.o
-obj-$(CONFIG_HYDRA) += hydra.o 8390.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 4af235d..0e60f86 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -65,7 +65,7 @@
 static char version[] __initdata =
 	"EtherH/EtherM Driver (c) 2002-2004 Russell King " DRV_VERSION "\n";
 
-#include "../lib8390.c"
+#include "../legacy/lib8390.c"
 
 static unsigned int net_debug = NET_DEBUG;
 
diff --git a/drivers/net/3c503.c b/drivers/net/legacy/3c503.c
similarity index 100%
rename from drivers/net/3c503.c
rename to drivers/net/legacy/3c503.c
diff --git a/drivers/net/3c503.h b/drivers/net/legacy/3c503.h
similarity index 100%
rename from drivers/net/3c503.h
rename to drivers/net/legacy/3c503.h
diff --git a/drivers/net/8390.c b/drivers/net/legacy/8390.c
similarity index 100%
rename from drivers/net/8390.c
rename to drivers/net/legacy/8390.c
diff --git a/drivers/net/8390.h b/drivers/net/legacy/8390.h
similarity index 100%
rename from drivers/net/8390.h
rename to drivers/net/legacy/8390.h
diff --git a/drivers/net/8390p.c b/drivers/net/legacy/8390p.c
similarity index 100%
rename from drivers/net/8390p.c
rename to drivers/net/legacy/8390p.c
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 32bd91a..74644b8 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -321,3 +321,229 @@ config LANCE
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called lance.  This is recommended.
+
+config AX88796
+	tristate "ASIX AX88796 NE2000 clone support"
+	depends on ARM || MIPS || SUPERH
+	select CRC32
+	select MII
+	help
+	  AX88796 driver, using platform bus to provide
+	  chip detection and resources
+
+config AX88796_93CX6
+	bool "ASIX AX88796 external 93CX6 eeprom support"
+	depends on AX88796
+	select EEPROM_93CX6
+	help
+	  Select this if your platform comes with an external 93CX6 eeprom.
+
+config HYDRA
+	tristate "Hydra support"
+	depends on ZORRO
+	select CRC32
+	help
+	  If you have a Hydra Ethernet adapter, say Y. Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called hydra.
+
+config ZORRO8390
+	tristate "Zorro NS8390-based Ethernet support"
+	depends on ZORRO
+	select CRC32
+	help
+	  This driver is for Zorro Ethernet cards using an NS8390-compatible
+	  chipset, like the Village Tronic Ariadne II and the Individual
+	  Computers X-Surf Ethernet cards. If you have such a card, say Y.
+	  Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called zorro8390.
+
+config APNE
+	tristate "PCMCIA NE2000 support"
+	depends on AMIGA_PCMCIA
+	select CRC32
+	help
+	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
+	  say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called apne.
+
+config MAC8390
+	bool "Macintosh NS 8390 based ethernet cards"
+	depends on MAC
+	select CRC32
+	help
+	  If you want to include a driver to support Nubus or LC-PDS
+	  Ethernet cards using an NS8390 chipset or its equivalent, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+config STNIC
+	tristate "National DP83902AV  support"
+	depends on SUPERH
+	select CRC32
+	help
+	  Support for cards based on the National Semiconductor DP83902AV
+	  ST-NIC Serial Network Interface Controller for Twisted Pair.  This
+	  is a 10Mbit/sec Ethernet controller.  Product overview and specs at
+	  <http://www.national.com/pf/DP/DP83902A.html>.
+
+	  If unsure, say N.
+
+config EL2
+	tristate "3c503 \"EtherLink II\" support"
+	depends on NET_VENDOR_3COM && ISA
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c503.
+
+config WD80x3
+	tristate "WD80*3 support"
+	depends on NET_VENDOR_SMC && ISA
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called wd.
+
+config ULTRAMCA
+	tristate "SMC Ultra MCA support"
+	depends on NET_VENDOR_SMC && MCA
+	select CRC32
+	help
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
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc-ultra32.
+
+config E2100
+	tristate "Cabletron E21xx support"
+	depends on NET_ISA
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e2100.
+
+config HPLAN_PLUS
+	tristate "HP PCLAN+ (27247B and 27252A) support"
+	depends on NET_ISA
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp-plus.
+
+config HPLAN
+	tristate "HP PCLAN (27245 and other 27xxx series) support"
+	depends on NET_ISA
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp.
+
+config NE2000
+	tristate "NE2000/NE1000 support"
+	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
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
+	depends on MCA_LEGACY
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ne2.
+
+config LNE390
+	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
+	depends on NET_PCI && EISA && EXPERIMENTAL
+	select CRC32
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called lne390.
+ 
+config NE_H8300
+	tristate "NE2000 compatible support for H8/300"
+	depends on H8300
+	help
+	  Say Y here if you want to use the NE2000 compatible
+	  controller on the Renesas H8/300 processor.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index 0eb679c..eefacda 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -37,3 +37,32 @@ obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_NI65) += ni65.o
+
+# ISA 8390 based
+obj-$(CONFIG_E2100) += e2100.o 8390.o
+obj-$(CONFIG_EL2) += 3c503.o 8390p.o
+obj-$(CONFIG_HPLAN) += hp.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
+obj-$(CONFIG_NE2000) += ne.o 8390p.o
+obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
+obj-$(CONFIG_WD80x3) += wd.o 8390.o
+
+# EISA 8390 based
+obj-$(CONFIG_AC3200) += ac3200.o 8390.o
+obj-$(CONFIG_ES3210) += es3210.o 8390.o
+obj-$(CONFIG_LNE390) += lne390.o 8390.o
+obj-$(CONFIG_NE3210) += ne3210.o 8390.o
+obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
+
+# Other 8390 based hardware.
+obj-$(CONFIG_APNE) += apne.o 8390.o
+obj-$(CONFIG_AX88796) += ax88796.o
+obj-$(CONFIG_HYDRA) += hydra.o 8390.o
+obj-$(CONFIG_MAC8390) += mac8390.o
+obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
+obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
+obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
+obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
+obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
+obj-$(CONFIG_STNIC) += stnic.o 8390.o
+obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
diff --git a/drivers/net/ac3200.c b/drivers/net/legacy/ac3200.c
similarity index 100%
rename from drivers/net/ac3200.c
rename to drivers/net/legacy/ac3200.c
diff --git a/drivers/net/apne.c b/drivers/net/legacy/apne.c
similarity index 100%
rename from drivers/net/apne.c
rename to drivers/net/legacy/apne.c
diff --git a/drivers/net/ax88796.c b/drivers/net/legacy/ax88796.c
similarity index 100%
rename from drivers/net/ax88796.c
rename to drivers/net/legacy/ax88796.c
diff --git a/drivers/net/e2100.c b/drivers/net/legacy/e2100.c
similarity index 100%
rename from drivers/net/e2100.c
rename to drivers/net/legacy/e2100.c
diff --git a/drivers/net/es3210.c b/drivers/net/legacy/es3210.c
similarity index 100%
rename from drivers/net/es3210.c
rename to drivers/net/legacy/es3210.c
diff --git a/drivers/net/hp-plus.c b/drivers/net/legacy/hp-plus.c
similarity index 100%
rename from drivers/net/hp-plus.c
rename to drivers/net/legacy/hp-plus.c
diff --git a/drivers/net/hp.c b/drivers/net/legacy/hp.c
similarity index 100%
rename from drivers/net/hp.c
rename to drivers/net/legacy/hp.c
diff --git a/drivers/net/hydra.c b/drivers/net/legacy/hydra.c
similarity index 100%
rename from drivers/net/hydra.c
rename to drivers/net/legacy/hydra.c
diff --git a/drivers/net/lib8390.c b/drivers/net/legacy/lib8390.c
similarity index 100%
rename from drivers/net/lib8390.c
rename to drivers/net/legacy/lib8390.c
diff --git a/drivers/net/lne390.c b/drivers/net/legacy/lne390.c
similarity index 100%
rename from drivers/net/lne390.c
rename to drivers/net/legacy/lne390.c
diff --git a/drivers/net/mac8390.c b/drivers/net/legacy/mac8390.c
similarity index 100%
rename from drivers/net/mac8390.c
rename to drivers/net/legacy/mac8390.c
diff --git a/drivers/net/ne-h8300.c b/drivers/net/legacy/ne-h8300.c
similarity index 100%
rename from drivers/net/ne-h8300.c
rename to drivers/net/legacy/ne-h8300.c
diff --git a/drivers/net/ne.c b/drivers/net/legacy/ne.c
similarity index 100%
rename from drivers/net/ne.c
rename to drivers/net/legacy/ne.c
diff --git a/drivers/net/ne2.c b/drivers/net/legacy/ne2.c
similarity index 100%
rename from drivers/net/ne2.c
rename to drivers/net/legacy/ne2.c
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/legacy/ne2k-pci.c
similarity index 100%
rename from drivers/net/ne2k-pci.c
rename to drivers/net/legacy/ne2k-pci.c
diff --git a/drivers/net/ne3210.c b/drivers/net/legacy/ne3210.c
similarity index 100%
rename from drivers/net/ne3210.c
rename to drivers/net/legacy/ne3210.c
diff --git a/drivers/net/smc-mca.c b/drivers/net/legacy/smc-mca.c
similarity index 100%
rename from drivers/net/smc-mca.c
rename to drivers/net/legacy/smc-mca.c
diff --git a/drivers/net/smc-ultra.c b/drivers/net/legacy/smc-ultra.c
similarity index 100%
rename from drivers/net/smc-ultra.c
rename to drivers/net/legacy/smc-ultra.c
diff --git a/drivers/net/smc-ultra32.c b/drivers/net/legacy/smc-ultra32.c
similarity index 100%
rename from drivers/net/smc-ultra32.c
rename to drivers/net/legacy/smc-ultra32.c
diff --git a/drivers/net/stnic.c b/drivers/net/legacy/stnic.c
similarity index 100%
rename from drivers/net/stnic.c
rename to drivers/net/legacy/stnic.c
diff --git a/drivers/net/wd.c b/drivers/net/legacy/wd.c
similarity index 100%
rename from drivers/net/wd.c
rename to drivers/net/legacy/wd.c
diff --git a/drivers/net/zorro8390.c b/drivers/net/legacy/zorro8390.c
similarity index 100%
rename from drivers/net/zorro8390.c
rename to drivers/net/legacy/zorro8390.c
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index d2e166e..65314e8 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -38,7 +38,7 @@
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
-#include "../8390.h"
+#include "../legacy/8390.h"
 
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 03096c8..6e7731e 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -41,7 +41,7 @@
 #include <linux/log2.h>
 #include <linux/etherdevice.h>
 #include <linux/mii.h>
-#include "../8390.h"
+#include "../legacy/8390.h"
 
 #include <pcmcia/cistpl.h>
 #include <pcmcia/ciscode.h>
-- 
1.7.3.2.146.g2d444

