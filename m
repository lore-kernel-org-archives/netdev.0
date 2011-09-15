From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] MII: fix Kconfig dependencies for MII
Date: Thu, 15 Sep 2011 00:23:14 -0700
Message-ID: <1316071394-18195-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46891 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761Ab1IOHXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 03:23:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MII Kconfig option is apart of the core networking drivers and
by default NET_CORE is enabled so drivers selecting MII will
have MII enabled as well.  It was found using the randconfig
option during testing, MII would be selected but NET_CORE
could be disabled.  This caused a dependency error.

Resolved the dependency by selecting NET_CORE when MII is
selected.

Reported-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 arch/cris/arch-v10/drivers/Kconfig             |    1 +
 arch/cris/arch-v32/drivers/Kconfig             |    1 +
 drivers/net/ethernet/3com/Kconfig              |    1 +
 drivers/net/ethernet/Kconfig                   |    4 ++++
 drivers/net/ethernet/adaptec/Kconfig           |    1 +
 drivers/net/ethernet/adi/Kconfig               |    1 +
 drivers/net/ethernet/amd/Kconfig               |    2 ++
 drivers/net/ethernet/atheros/Kconfig           |    4 ++++
 drivers/net/ethernet/broadcom/Kconfig          |    2 ++
 drivers/net/ethernet/cadence/Kconfig           |    1 +
 drivers/net/ethernet/cirrus/Kconfig            |    1 +
 drivers/net/ethernet/davicom/Kconfig           |    1 +
 drivers/net/ethernet/dec/tulip/Kconfig         |    1 +
 drivers/net/ethernet/dlink/Kconfig             |    1 +
 drivers/net/ethernet/faraday/Kconfig           |    1 +
 drivers/net/ethernet/freescale/fs_enet/Kconfig |    1 +
 drivers/net/ethernet/icplus/Kconfig            |    1 +
 drivers/net/ethernet/intel/Kconfig             |    1 +
 drivers/net/ethernet/micrel/Kconfig            |    4 ++++
 drivers/net/ethernet/nuvoton/Kconfig           |    1 +
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig  |    1 +
 drivers/net/ethernet/packetengines/Kconfig     |    1 +
 drivers/net/ethernet/rdc/Kconfig               |    1 +
 drivers/net/ethernet/realtek/Kconfig           |    3 +++
 drivers/net/ethernet/renesas/Kconfig           |    1 +
 drivers/net/ethernet/sgi/Kconfig               |    1 +
 drivers/net/ethernet/sis/Kconfig               |    2 ++
 drivers/net/ethernet/smsc/Kconfig              |    5 +++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig    |    1 +
 drivers/net/ethernet/via/Kconfig               |    2 ++
 drivers/net/usb/Kconfig                        |    3 +++
 31 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/arch/cris/arch-v10/drivers/Kconfig b/arch/cris/arch-v10/drivers/Kconfig
index 0d72217..32d9086 100644
--- a/arch/cris/arch-v10/drivers/Kconfig
+++ b/arch/cris/arch-v10/drivers/Kconfig
@@ -4,6 +4,7 @@ config ETRAX_ETHERNET
 	bool "Ethernet support"
 	depends on ETRAX_ARCH_V10
 	select NET_ETHERNET
+	select NET_CORE
 	select MII
 	help
 	  This option enables the ETRAX 100LX built-in 10/100Mbit Ethernet
diff --git a/arch/cris/arch-v32/drivers/Kconfig b/arch/cris/arch-v32/drivers/Kconfig
index 41a2732..e47e9c3 100644
--- a/arch/cris/arch-v32/drivers/Kconfig
+++ b/arch/cris/arch-v32/drivers/Kconfig
@@ -4,6 +4,7 @@ config ETRAX_ETHERNET
 	bool "Ethernet support"
 	depends on ETRAX_ARCH_V32
 	select NET_ETHERNET
+	select NET_CORE
 	select MII
 	help
 	  This option enables the ETRAX FS built-in 10/100Mbit Ethernet
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index a439cbd..a8bb30c 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -81,6 +81,7 @@ config PCMCIA_3C589
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
 	depends on (PCI || EISA)
+	select NET_CORE
 	select MII
 	---help---
 	  This option enables driver support for a large number of 10Mbps and
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 1f64747..6dff5a0 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -62,6 +62,7 @@ config JME
 	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the PCI-Express gigabit ethernet adapters
@@ -102,6 +103,7 @@ config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet
@@ -112,6 +114,7 @@ source "drivers/net/ethernet/8390/Kconfig"
 
 config NET_NETX
 	tristate "NetX Ethernet support"
+	select NET_CORE
 	select MII
 	depends on ARCH_NETX
 	---help---
@@ -128,6 +131,7 @@ source "drivers/net/ethernet/oki-semi/Kconfig"
 config ETHOC
 	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
 	depends on HAS_IOMEM && HAS_DMA
+	select NET_CORE
 	select MII
 	select PHYLIB
 	select CRC32
diff --git a/drivers/net/ethernet/adaptec/Kconfig b/drivers/net/ethernet/adaptec/Kconfig
index 5c804bb..0bff571 100644
--- a/drivers/net/ethernet/adaptec/Kconfig
+++ b/drivers/net/ethernet/adaptec/Kconfig
@@ -22,6 +22,7 @@ config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index 6de9851..49a30d3 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -23,6 +23,7 @@ config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
 	depends on (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
 	select CRC32
+	select NET_CORE
 	select MII
 	select PHYLIB
 	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 8af1c93..238b537 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -34,6 +34,7 @@ config AMD8111_ETH
 	tristate "AMD 8111 (new PCI LANCE) support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  If you have an AMD 8111-based PCI LANCE ethernet card,
@@ -59,6 +60,7 @@ config PCNET32
 	tristate "AMD PCnet32 PCI support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index 26ab8ca..1ed886d 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -22,6 +22,7 @@ config ATL2
 	tristate "Atheros L2 Fast Ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L2 fast ethernet adapter.
@@ -33,6 +34,7 @@ config ATL1
 	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros/Attansic L1 gigabit ethernet
@@ -45,6 +47,7 @@ config ATL1E
 	tristate "Atheros L1E Gigabit Ethernet support (EXPERIMENTAL)"
 	depends on PCI && EXPERIMENTAL
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L1E gigabit ethernet adapter.
@@ -56,6 +59,7 @@ config ATL1C
 	tristate "Atheros L1C Gigabit Ethernet support (EXPERIMENTAL)"
 	depends on PCI && EXPERIMENTAL
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the Atheros L1C gigabit ethernet adapter.
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index d82ad22..f15e72e 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -22,6 +22,7 @@ config B44
 	tristate "Broadcom 440x/47xx ethernet support"
 	depends on SSB_POSSIBLE && HAS_DMA
 	select SSB
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y
@@ -53,6 +54,7 @@ config B44_PCI
 config BCM63XX_ENET
 	tristate "Broadcom 63xx internal mac support"
 	depends on BCM63XX
+	select NET_CORE
 	select MII
 	select PHYLIB
 	help
diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index c00e706..98849a1 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -25,6 +25,7 @@ if NET_ATMEL
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
 	depends on ARM && ARCH_AT91RM9200
+	select NET_CORE
 	select MII
 	---help---
 	  If you wish to compile a kernel for the AT91RM9200 and enable
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index e0cacf6..e9386ef 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -21,6 +21,7 @@ if NET_VENDOR_CIRRUS
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
+	select NET_CORE
 	select MII
 	help
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
index 73c5d20..972b62b 100644
--- a/drivers/net/ethernet/davicom/Kconfig
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -6,6 +6,7 @@ config DM9000
 	tristate "DM9000 support"
 	depends on ARM || BLACKFIN || MIPS
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Support for DM9000 chipset.
diff --git a/drivers/net/ethernet/dec/tulip/Kconfig b/drivers/net/ethernet/dec/tulip/Kconfig
index f6af772..1203be0 100644
--- a/drivers/net/ethernet/dec/tulip/Kconfig
+++ b/drivers/net/ethernet/dec/tulip/Kconfig
@@ -125,6 +125,7 @@ config WINBOND_840
 	tristate "Winbond W89c840 Ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the Winbond W89c840 chip.  It also works with 
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlink/Kconfig
index 84a28a6..b5afe21 100644
--- a/drivers/net/ethernet/dlink/Kconfig
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -66,6 +66,7 @@ config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the Sundance "Alta" chip.
diff --git a/drivers/net/ethernet/faraday/Kconfig b/drivers/net/ethernet/faraday/Kconfig
index 5918c68..b8974b9 100644
--- a/drivers/net/ethernet/faraday/Kconfig
+++ b/drivers/net/ethernet/faraday/Kconfig
@@ -21,6 +21,7 @@ if NET_VENDOR_FARADAY
 config FTMAC100
 	tristate "Faraday FTMAC100 10/100 Ethernet support"
 	depends on ARM
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports the FTMAC100 10/100 Ethernet controller
diff --git a/drivers/net/ethernet/freescale/fs_enet/Kconfig b/drivers/net/ethernet/freescale/fs_enet/Kconfig
index be92229..268414d 100644
--- a/drivers/net/ethernet/freescale/fs_enet/Kconfig
+++ b/drivers/net/ethernet/freescale/fs_enet/Kconfig
@@ -1,6 +1,7 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
        depends on NET_VENDOR_FREESCALE && (CPM1 || CPM2 || PPC_MPC512x)
+       select NET_CORE
        select MII
        select PHYLIB
 
diff --git a/drivers/net/ethernet/icplus/Kconfig b/drivers/net/ethernet/icplus/Kconfig
index e888222..3aff81d 100644
--- a/drivers/net/ethernet/icplus/Kconfig
+++ b/drivers/net/ethernet/icplus/Kconfig
@@ -5,6 +5,7 @@
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports IP1000 gigabit Ethernet cards.
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 4a98e83..61029dc 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -21,6 +21,7 @@ if NET_VENDOR_INTEL
 config E100
 	tristate "Intel(R) PRO/100+ support"
 	depends on PCI
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports Intel(R) PRO/100 family of adapters.
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
index bd090db..d10c2e1 100644
--- a/drivers/net/ethernet/micrel/Kconfig
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -22,6 +22,7 @@ if NET_VENDOR_MICREL
 config ARM_KS8695_ETHER
 	tristate "KS8695 Ethernet support"
 	depends on ARM && ARCH_KS8695
+	select NET_CORE
 	select MII
 	---help---
 	  If you wish to compile a kernel for the KS8695 and want to
@@ -38,6 +39,7 @@ config KS8842
 config KS8851
 	tristate "Micrel KS8851 SPI"
 	depends on SPI
+	select NET_CORE
 	select MII
 	select CRC32
 	---help---
@@ -46,6 +48,7 @@ config KS8851
 config KS8851_MLL
 	tristate "Micrel KS8851 MLL"
 	depends on HAS_IOMEM
+	select NET_CORE
 	select MII
 	---help---
 	  This platform driver is for Micrel KS8851 Address/data bus
@@ -54,6 +57,7 @@ config KS8851_MLL
 config KSZ884X_PCI
 	tristate "Micrel KSZ8841/2 PCI"
 	depends on PCI
+	select NET_CORE
 	select MII
 	select CRC32
 	---help---
diff --git a/drivers/net/ethernet/nuvoton/Kconfig b/drivers/net/ethernet/nuvoton/Kconfig
index 01182b5..334c171 100644
--- a/drivers/net/ethernet/nuvoton/Kconfig
+++ b/drivers/net/ethernet/nuvoton/Kconfig
@@ -22,6 +22,7 @@ config W90P910_ETH
 	tristate "Nuvoton w90p910 Ethernet support"
 	depends on ARM && ARCH_W90X900
 	select PHYLIB
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you want to use built-in Ethernet ports
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index c85709d..7efa624 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -5,6 +5,7 @@
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR ML7223 IOH GbE (Intel EG20T PCH)"
 	depends on PCI
+	select NET_CORE
 	select MII
 	---help---
 	  This is a gigabit ethernet driver for EG20T PCH.
diff --git a/drivers/net/ethernet/packetengines/Kconfig b/drivers/net/ethernet/packetengines/Kconfig
index 4add1db..b97132d 100644
--- a/drivers/net/ethernet/packetengines/Kconfig
+++ b/drivers/net/ethernet/packetengines/Kconfig
@@ -20,6 +20,7 @@ if NET_PACKET_ENGINE
 config HAMACHI
 	tristate "Packet Engines Hamachi GNIC-II support"
 	depends on PCI
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a Gigabit Ethernet card of this type, say Y and read
diff --git a/drivers/net/ethernet/rdc/Kconfig b/drivers/net/ethernet/rdc/Kconfig
index 2055f7e..c8ba4b3 100644
--- a/drivers/net/ethernet/rdc/Kconfig
+++ b/drivers/net/ethernet/rdc/Kconfig
@@ -22,6 +22,7 @@ config R6040
 	tristate "RDC R6040 Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index d8df67a..84083ec 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -37,6 +37,7 @@ config 8139CP
 	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
 	depends on PCI && EXPERIMENTAL
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -51,6 +52,7 @@ config 8139TOO
 	tristate "RealTek RTL-8129/8130/8139 PCI Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -105,6 +107,7 @@ config R8169
 	depends on PCI
 	select FW_LOADER
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index f57ae23..9755b49 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -9,6 +9,7 @@ config SH_ETH
 		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
 		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7757)
 	select CRC32
+	select NET_CORE
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
index e832f46..c1c4bb8 100644
--- a/drivers/net/ethernet/sgi/Kconfig
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -22,6 +22,7 @@ config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
 	depends on PCI && SGI_IP27
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ethernet/sis/Kconfig b/drivers/net/ethernet/sis/Kconfig
index 68d052b..f1135cc 100644
--- a/drivers/net/ethernet/sis/Kconfig
+++ b/drivers/net/ethernet/sis/Kconfig
@@ -22,6 +22,7 @@ config SIS900
 	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
@@ -38,6 +39,7 @@ config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you have a SiS 190 PCI Fast Ethernet adapter or
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index f961928..1854c88 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -37,6 +37,7 @@ config SMC9194
 config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
+	select NET_CORE
 	select MII
 	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
 		    MN10300 || COLDFIRE)
@@ -56,6 +57,7 @@ config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
 	depends on PCMCIA
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you intend to attach an SMC 91Cxx compatible PCMCIA
@@ -68,6 +70,7 @@ config EPIC100
 	tristate "SMC EtherPower II"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  This driver is for the SMC EtherPower II 9432 PCI Ethernet NIC,
@@ -78,6 +81,7 @@ config EPIC100
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
+	select NET_CORE
 	select MII
 	depends on (ARM || SUPERH || MN10300)
 	---help---
@@ -95,6 +99,7 @@ config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
 	depends on (ARM || SUPERH || BLACKFIN || MIPS || MN10300)
 	select CRC32
+	select NET_CORE
 	select MII
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index cda61e3..2346ba0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -1,6 +1,7 @@
 config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
 	depends on HAS_IOMEM
+	select NET_CORE
 	select MII
 	select PHYLIB
 	select CRC32
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index e5d82a5..68a9ba6 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -22,6 +22,7 @@ config VIA_RHINE
 	tristate "VIA Rhine support"
 	depends on PCI
 	select CRC32
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a VIA "Rhine" based network card (Rhine-I (VT86C100A),
@@ -47,6 +48,7 @@ config VIA_VELOCITY
 	depends on PCI
 	select CRC32
 	select CRC_CCITT
+	select NET_CORE
 	select MII
 	---help---
 	  If you have a VIA "Velocity" based network card say Y here.
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 84d4608..2335761 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -68,6 +68,7 @@ config USB_KAWETH
 
 config USB_PEGASUS
 	tristate "USB Pegasus/Pegasus-II based ethernet device support"
+	select NET_CORE
 	select MII
 	---help---
 	  Say Y here if you know you have Pegasus or Pegasus-II based adapter.
@@ -84,6 +85,7 @@ config USB_PEGASUS
 config USB_RTL8150
 	tristate "USB RTL8150 based ethernet device support (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
+	select NET_CORE
 	select MII
 	help
 	  Say Y here if you have RTL8150 based usb-ethernet adapter.
@@ -95,6 +97,7 @@ config USB_RTL8150
 
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
+	select NET_CORE
 	select MII
 	---help---
 	  This driver supports several kinds of network links over USB,
-- 
1.7.6
