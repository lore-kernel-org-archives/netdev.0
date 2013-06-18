From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/3] net: Move MII out from under NET_CORE and hide
 it
Date: Tue, 18 Jun 2013 03:24:51 +0100
Message-ID: <1371522291.3495.63.camel@deadeye.wl.decadent.org.uk>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Vf/IdR/ktzGQ6JBrMuCU"
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51461 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753468Ab3FRCYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 22:24:55 -0400
In-Reply-To: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vf/IdR/ktzGQ6JBrMuCU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

All drivers that select MII also need to select NET_CORE because MII
depends on it.  This is a bit ridiculous because NET_CORE is just a
menu option that doesn't enable any code by itself.

There is also no need for it to be a visible option, since its users
all select it.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/cris/arch-v10/drivers/Kconfig             |    1 -
 arch/cris/arch-v32/drivers/Kconfig             |    1 -
 drivers/net/Kconfig                            |   10 +++-------
 drivers/net/ethernet/3com/Kconfig              |    1 -
 drivers/net/ethernet/Kconfig                   |    4 ----
 drivers/net/ethernet/adaptec/Kconfig           |    1 -
 drivers/net/ethernet/adi/Kconfig               |    1 -
 drivers/net/ethernet/allwinner/Kconfig         |    1 -
 drivers/net/ethernet/amd/Kconfig               |    2 --
 drivers/net/ethernet/atheros/Kconfig           |    4 ----
 drivers/net/ethernet/broadcom/Kconfig          |    2 --
 drivers/net/ethernet/cirrus/Kconfig            |    1 -
 drivers/net/ethernet/davicom/Kconfig           |    1 -
 drivers/net/ethernet/dec/tulip/Kconfig         |    1 -
 drivers/net/ethernet/dlink/Kconfig             |    1 -
 drivers/net/ethernet/faraday/Kconfig           |    1 -
 drivers/net/ethernet/freescale/fs_enet/Kconfig |    1 -
 drivers/net/ethernet/icplus/Kconfig            |    1 -
 drivers/net/ethernet/intel/Kconfig             |    1 -
 drivers/net/ethernet/micrel/Kconfig            |    4 ----
 drivers/net/ethernet/nuvoton/Kconfig           |    1 -
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig  |    1 -
 drivers/net/ethernet/packetengines/Kconfig     |    1 -
 drivers/net/ethernet/rdc/Kconfig               |    1 -
 drivers/net/ethernet/realtek/Kconfig           |    3 ---
 drivers/net/ethernet/renesas/Kconfig           |    1 -
 drivers/net/ethernet/sgi/Kconfig               |    1 -
 drivers/net/ethernet/sis/Kconfig               |    2 --
 drivers/net/ethernet/smsc/Kconfig              |    5 -----
 drivers/net/ethernet/stmicro/stmmac/Kconfig    |    1 -
 drivers/net/ethernet/via/Kconfig               |    2 --
 drivers/net/usb/Kconfig                        |    4 ----
 drivers/staging/silicom/Kconfig                |    1 -
 33 files changed, 3 insertions(+), 61 deletions(-)

diff --git a/arch/cris/arch-v10/drivers/Kconfig b/arch/cris/arch-v10/driver=
s/Kconfig
index 5f2cdb3..8eab0c6 100644
--- a/arch/cris/arch-v10/drivers/Kconfig
+++ b/arch/cris/arch-v10/drivers/Kconfig
@@ -4,7 +4,6 @@ config ETRAX_ETHERNET
 	bool "Ethernet support"
 	depends on ETRAX_ARCH_V10
 	select ETHERNET
-	select NET_CORE
 	select MII
 	help
 	  This option enables the ETRAX 100LX built-in 10/100Mbit Ethernet
diff --git a/arch/cris/arch-v32/drivers/Kconfig b/arch/cris/arch-v32/driver=
s/Kconfig
index c55971a..91c4e54 100644
--- a/arch/cris/arch-v32/drivers/Kconfig
+++ b/arch/cris/arch-v32/drivers/Kconfig
@@ -4,7 +4,6 @@ config ETRAX_ETHERNET
 	bool "Ethernet support"
 	depends on ETRAX_ARCH_V32
 	select ETHERNET
-	select NET_CORE
 	select MII
 	help
 	  This option enables the ETRAX FS built-in 10/100Mbit Ethernet
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3835321..00aba08 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -25,6 +25,9 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
=20
+config MII
+	tristate
+
 config NET_CORE
 	default y
 	bool "Network core driver support"
@@ -100,13 +103,6 @@ config NET_FC
 	  adaptor below. You also should have said Y to "SCSI support" and
 	  "SCSI generic support".
=20
-config MII
-	tristate "Generic Media Independent Interface device support"
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lacks MII.
-
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/=
Kconfig
index 1c71c76..f00c763 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -67,7 +67,6 @@ config PCMCIA_3C589
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
 	depends on (PCI || EISA) && HAS_IOPORT
-	select NET_CORE
 	select MII
 	---help---
 	  This option enables driver support for a large number of 10Mbps and
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 18fd6fb..a989669 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -64,7 +64,6 @@ config JME
 	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the PCI-Express gigabit ethernet adapters
@@ -96,7 +95,6 @@ config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet
@@ -107,7 +105,6 @@ source "drivers/net/ethernet/8390/Kconfig"
=20
 config NET_NETX
 	tristate "NetX Ethernet support"
-	select NET_CORE
 	select MII
 	depends on ARCH_NETX
 	---help---
@@ -125,7 +122,6 @@ source "drivers/net/ethernet/oki-semi/Kconfig"
 config ETHOC
 	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
 	depends on HAS_IOMEM && HAS_DMA
-	select NET_CORE
 	select MII
 	select PHYLIB
 	select CRC32
diff --git a/drivers/net/ethernet/adaptec/Kconfig b/drivers/net/ethernet/ad=
aptec/Kconfig
index 0bff571..5c804bb 100644
--- a/drivers/net/ethernet/adaptec/Kconfig
+++ b/drivers/net/ethernet/adaptec/Kconfig
@@ -22,7 +22,6 @@ config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kc=
onfig
index a948160..f952fff 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -23,7 +23,6 @@ config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
 	depends on (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
 	select CRC32
-	select NET_CORE
 	select MII
 	select PHYLIB
 	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/=
allwinner/Kconfig
index 66d3532..53ad213 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -24,7 +24,6 @@ config SUN4I_EMAC
 	depends on ARCH_SUNXI
 	depends on OF
 	select CRC32
-	select NET_CORE
 	select MII
 	select PHYLIB
         ---help---
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kc=
onfig
index 13d74aa..562df46 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -34,7 +34,6 @@ config AMD8111_ETH
 	tristate "AMD 8111 (new PCI LANCE) support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  If you have an AMD 8111-based PCI LANCE ethernet card,
@@ -60,7 +59,6 @@ config PCNET32
 	tristate "AMD PCnet32 PCI support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/at=
heros/Kconfig
index 36d6abd..55e3d7e 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -22,7 +22,6 @@ config ATL2
 	tristate "Atheros L2 Fast Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L2 fast ethernet adapter.
@@ -34,7 +33,6 @@ config ATL1
 	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros/Attansic L1 gigabit ethernet
@@ -47,7 +45,6 @@ config ATL1E
 	tristate "Atheros L1E Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L1E gigabit ethernet adapter.
@@ -59,7 +56,6 @@ config ATL1C
 	tristate "Atheros L1C Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L1C gigabit ethernet adapter.
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/b=
roadcom/Kconfig
index 3e69b3f..1d680ba 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -22,7 +22,6 @@ config B44
 	tristate "Broadcom 440x/47xx ethernet support"
 	depends on SSB_POSSIBLE && HAS_DMA
 	select SSB
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y
@@ -54,7 +53,6 @@ config B44_PCI
 config BCM63XX_ENET
 	tristate "Broadcom 63xx internal mac support"
 	depends on BCM63XX
-	select NET_CORE
 	select MII
 	select PHYLIB
 	help
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cir=
rus/Kconfig
index 8388e36..7403dff 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -44,7 +44,6 @@ config CS89x0_PLATFORM
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
-	select NET_CORE
 	select MII
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/da=
vicom/Kconfig
index 9745fe5..316c5e5 100644
--- a/drivers/net/ethernet/davicom/Kconfig
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -6,7 +6,6 @@ config DM9000
 	tristate "DM9000 support"
 	depends on ARM || BLACKFIN || MIPS || COLDFIRE
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Support for DM9000 chipset.
diff --git a/drivers/net/ethernet/dec/tulip/Kconfig b/drivers/net/ethernet/=
dec/tulip/Kconfig
index 1df33c7..eb9ba6e 100644
--- a/drivers/net/ethernet/dec/tulip/Kconfig
+++ b/drivers/net/ethernet/dec/tulip/Kconfig
@@ -126,7 +126,6 @@ config WINBOND_840
 	tristate "Winbond W89c840 Ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the Winbond W89c840 chip.  It also works with=20
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlin=
k/Kconfig
index ee26ce7..c543ac1 100644
--- a/drivers/net/ethernet/dlink/Kconfig
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -36,7 +36,6 @@ config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the Sundance "Alta" chip.
diff --git a/drivers/net/ethernet/faraday/Kconfig b/drivers/net/ethernet/fa=
raday/Kconfig
index b8974b9..5918c689 100644
--- a/drivers/net/ethernet/faraday/Kconfig
+++ b/drivers/net/ethernet/faraday/Kconfig
@@ -21,7 +21,6 @@ if NET_VENDOR_FARADAY
 config FTMAC100
 	tristate "Faraday FTMAC100 10/100 Ethernet support"
 	depends on ARM
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the FTMAC100 10/100 Ethernet controller
diff --git a/drivers/net/ethernet/freescale/fs_enet/Kconfig b/drivers/net/e=
thernet/freescale/fs_enet/Kconfig
index 268414d..be92229 100644
--- a/drivers/net/ethernet/freescale/fs_enet/Kconfig
+++ b/drivers/net/ethernet/freescale/fs_enet/Kconfig
@@ -1,7 +1,6 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
        depends on NET_VENDOR_FREESCALE && (CPM1 || CPM2 || PPC_MPC512x)
-       select NET_CORE
        select MII
        select PHYLIB
=20
diff --git a/drivers/net/ethernet/icplus/Kconfig b/drivers/net/ethernet/icp=
lus/Kconfig
index 5119ef1..14a66e9 100644
--- a/drivers/net/ethernet/icplus/Kconfig
+++ b/drivers/net/ethernet/icplus/Kconfig
@@ -5,7 +5,6 @@
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports IP1000 gigabit Ethernet cards.
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/inte=
l/Kconfig
index 05f7264..f0e7ed2 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -20,7 +20,6 @@ if NET_VENDOR_INTEL
 config E100
 	tristate "Intel(R) PRO/100+ support"
 	depends on PCI
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports Intel(R) PRO/100 family of adapters.
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/mic=
rel/Kconfig
index fe42fc0..d16b11e 100644
--- a/drivers/net/ethernet/micrel/Kconfig
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -22,7 +22,6 @@ if NET_VENDOR_MICREL
 config ARM_KS8695_ETHER
 	tristate "KS8695 Ethernet support"
 	depends on ARM && ARCH_KS8695
-	select NET_CORE
 	select MII
 	---help---
 	  If you wish to compile a kernel for the KS8695 and want to
@@ -39,7 +38,6 @@ config KS8842
 config KS8851
 	tristate "Micrel KS8851 SPI"
 	depends on SPI
-	select NET_CORE
 	select MII
 	select CRC32
 	select EEPROM_93CX6
@@ -49,7 +47,6 @@ config KS8851
 config KS8851_MLL
 	tristate "Micrel KS8851 MLL"
 	depends on HAS_IOMEM
-	select NET_CORE
 	select MII
 	---help---
 	  This platform driver is for Micrel KS8851 Address/data bus
@@ -58,7 +55,6 @@ config KS8851_MLL
 config KSZ884X_PCI
 	tristate "Micrel KSZ8841/2 PCI"
 	depends on PCI
-	select NET_CORE
 	select MII
 	select CRC32
 	---help---
diff --git a/drivers/net/ethernet/nuvoton/Kconfig b/drivers/net/ethernet/nu=
voton/Kconfig
index 334c171..01182b5 100644
--- a/drivers/net/ethernet/nuvoton/Kconfig
+++ b/drivers/net/ethernet/nuvoton/Kconfig
@@ -22,7 +22,6 @@ config W90P910_ETH
 	tristate "Nuvoton w90p910 Ethernet support"
 	depends on ARM && ARCH_W90X900
 	select PHYLIB
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you want to use built-in Ethernet ports
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/et=
hernet/oki-semi/pch_gbe/Kconfig
index 34d05bf..cb22341 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -5,7 +5,6 @@
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
 	depends on PCI
-	select NET_CORE
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---
diff --git a/drivers/net/ethernet/packetengines/Kconfig b/drivers/net/ether=
net/packetengines/Kconfig
index cbbeca3..8d51800 100644
--- a/drivers/net/ethernet/packetengines/Kconfig
+++ b/drivers/net/ethernet/packetengines/Kconfig
@@ -21,7 +21,6 @@ if NET_PACKET_ENGINE
 config HAMACHI
 	tristate "Packet Engines Hamachi GNIC-II support"
 	depends on PCI
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a Gigabit Ethernet card of this type, say Y and read
diff --git a/drivers/net/ethernet/rdc/Kconfig b/drivers/net/ethernet/rdc/Kc=
onfig
index c8ba4b3..2055f7e 100644
--- a/drivers/net/ethernet/rdc/Kconfig
+++ b/drivers/net/ethernet/rdc/Kconfig
@@ -22,7 +22,6 @@ config R6040
 	tristate "RDC R6040 Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/re=
altek/Kconfig
index 783fa8b..ae5d027 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -37,7 +37,6 @@ config 8139CP
 	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -52,7 +51,6 @@ config 8139TOO
 	tristate "RealTek RTL-8129/8130/8139 PCI Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -107,7 +105,6 @@ config R8169
 	depends on PCI
 	select FW_LOADER
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/re=
nesas/Kconfig
index 267eac0..544514e 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -5,7 +5,6 @@
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	select CRC32
-	select NET_CORE
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kc=
onfig
index c1c4bb8..e832f46 100644
--- a/drivers/net/ethernet/sgi/Kconfig
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -22,7 +22,6 @@ config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
 	depends on PCI && SGI_IP27
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ethernet/sis/Kconfig b/drivers/net/ethernet/sis/Kc=
onfig
index f1135cc..68d052b 100644
--- a/drivers/net/ethernet/sis/Kconfig
+++ b/drivers/net/ethernet/sis/Kconfig
@@ -22,7 +22,6 @@ config SIS900
 	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -39,7 +38,6 @@ config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have a SiS 190 PCI Fast Ethernet adapter or
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/=
Kconfig
index ff9e994..068fc44 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -37,7 +37,6 @@ config SMC9194
 config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
-	select NET_CORE
 	select MII
 	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
 		    MN10300 || COLDFIRE || ARM64)
@@ -57,7 +56,6 @@ config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
 	depends on PCMCIA
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you intend to attach an SMC 91Cxx compatible PCMCIA
@@ -70,7 +68,6 @@ config EPIC100
 	tristate "SMC EtherPower II"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
@@ -81,7 +78,6 @@ config EPIC100
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
-	select NET_CORE
 	select MII
 	depends on (ARM || SUPERH || MN10300)
 	---help---
@@ -99,7 +95,6 @@ config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
 	depends on HAS_IOMEM
 	select CRC32
-	select NET_CORE
 	select MII
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethe=
rnet/stmicro/stmmac/Kconfig
index 43c1f32..6e52c0f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -1,7 +1,6 @@
 config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
 	depends on HAS_IOMEM && HAS_DMA
-	select NET_CORE
 	select MII
 	select PHYLIB
 	select CRC32
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kc=
onfig
index 6a87097..8a049a2 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -21,7 +21,6 @@ config VIA_RHINE
 	tristate "VIA Rhine support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a VIA "Rhine" based network card (Rhine-I (VT86C100A),
@@ -47,7 +46,6 @@ config VIA_VELOCITY
 	depends on (PCI || USE_OF)
 	select CRC32
 	select CRC_CCITT
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a VIA "Velocity" based network card say Y here.
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 287cc62..d84bfd4 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -67,7 +67,6 @@ config USB_KAWETH
=20
 config USB_PEGASUS
 	tristate "USB Pegasus/Pegasus-II based ethernet device support"
-	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you know you have Pegasus or Pegasus-II based adapter.
@@ -83,7 +82,6 @@ config USB_PEGASUS
=20
 config USB_RTL8150
 	tristate "USB RTL8150 based ethernet device support"
-	select NET_CORE
 	select MII
 	help
 	  Say Y here if you have RTL8150 based usb-ethernet adapter.
@@ -95,7 +93,6 @@ config USB_RTL8150
=20
 config USB_RTL8152
 	tristate "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
-	select NET_CORE
 	select MII
 	help
 	  This option adds support for Realtek RTL8152 based USB 2.0
@@ -106,7 +103,6 @@ config USB_RTL8152
=20
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
-	select NET_CORE
 	select MII
 	---help---
 	  This driver supports several kinds of network links over USB,
diff --git a/drivers/staging/silicom/Kconfig b/drivers/staging/silicom/Kcon=
fig
index eda2e7d..fc082db 100644
--- a/drivers/staging/silicom/Kconfig
+++ b/drivers/staging/silicom/Kconfig
@@ -32,7 +32,6 @@ config BPCTL
 	depends on PCI && NET
 	depends on m
 	select SBYPASS
-	select NET_CORE
 	select MII
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y



--=-Vf/IdR/ktzGQ6JBrMuCU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb/E8+e/yOyVhhEJAQogTRAAz+itE9VRSrq9Sz6UgRpksBVP/9x0ElaJ
rgyOufCwE2+S4R+JZtJUGmDH0puYHhH4hoPcpFlYCtqK2DmYChm7IrQB7KbN9Ly2
jd9kS/bnYRu8qHb1jwXo2FfqQivvGSMhLqzXMrG/ZyrIobH1xWtBRHQgqDuRdAzQ
/lKjE90Ju03ivssUzNUDNz4yQG1zfge7WwuUQ7FZJPiMEABgAcd3LwwPsG0tRRZ1
nA5FbZ2n7EI+K8ANlywKwK8qEj/D7e9PBzS/w9t7hxadMtiSk/ERwxXDPd1y+wdt
7/oSIOkm4wIPyOsZP91gf257Qae5dWXayYFxamrmu7cVL0bFrJdaAGkP+GaBfu46
6C9bVw7FEsOympsprfaPr4zYpo93jpHpM7GS6C1WWp7EVWJSUOQMcT/WGxhomPta
AT3Kr7a4P1COqawVSULCRuWgL/j2LySxFBrzp+0RALxgg4HX+V97a+4IpyO+apcb
e9pk1AeeuH6tV4ISZZRe8MreYglOk2YdllNQY03X+3isvjT+RnNSmAb6ofUKBn4b
cCI4wbHQD01YbwcKP2qLkCAwqRpjxndCvGOsGwpF/uFP0VtURsNOo0S6a0a5cMMr
RxUVG55EylqPghefSluTINFGv+OLUkVKXwXXdLItD8NDpAfLPB05T+MyenDZ0brE
63OIFi5iatI=
=Of6I
-----END PGP SIGNATURE-----

--=-Vf/IdR/ktzGQ6JBrMuCU--
