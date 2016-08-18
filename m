From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: phy: Sort Makefile and Kconfig
Date: Thu, 18 Aug 2016 23:56:05 +0200
Message-ID: <1471557366-21672-2-git-send-email-andrew@lunn.ch>
References: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38656 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753877AbcHSBzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:05 -0400
In-Reply-To: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sort the files to reduce merge conflicts and to make it easier to find
drivers by name. Also separate the MDIO bus drivers from the PHY
drivers, again to help find what you need.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/Kconfig  | 427 ++++++++++++++++++++++++-----------------------
 drivers/net/phy/Makefile |  76 +++++----
 2 files changed, 253 insertions(+), 250 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d66133bf3eb5..786e8b0b2d06 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -15,85 +15,153 @@ if PHYLIB
 config SWPHY
 	bool
 
-comment "MII PHY device drivers"
+comment "MDIO bus device drivers"
 
-config AQUANTIA_PHY
-        tristate "Drivers for the Aquantia PHYs"
-        ---help---
-          Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
-
-config AT803X_PHY
-	tristate "Drivers for Atheros AT803X PHYs"
-	---help---
-	  Currently supports the AT8030 and AT8035 model
+config MDIO_BCM_IPROC
+	tristate "Broadcom iProc MDIO bus controller"
+	depends on ARCH_BCM_IPROC || COMPILE_TEST
+	depends on HAS_IOMEM && OF_MDIO
+	help
+	  This module provides a driver for the MDIO busses found in the
+	  Broadcom iProc SoC's.
 
-config AMD_PHY
-	tristate "Drivers for the AMD PHYs"
-	---help---
-	  Currently supports the am79c874
+config MDIO_BCM_UNIMAC
+	tristate "Broadcom UniMAC MDIO bus controller"
+	depends on HAS_IOMEM
+	help
+	  This module provides a driver for the Broadcom UniMAC MDIO busses.
+	  This hardware can be found in the Broadcom GENET Ethernet MAC
+	  controllers as well as some Broadcom Ethernet switches such as the
+	  Starfighter 2 switches.
 
-config MARVELL_PHY
-	tristate "Drivers for Marvell PHYs"
-	---help---
-	  Currently has a driver for the 88E1011S
-	
-config DAVICOM_PHY
-	tristate "Drivers for Davicom PHYs"
-	---help---
-	  Currently supports dm9161e and dm9131
+config MDIO_BITBANG
+	tristate "Support for bitbanged MDIO buses"
+	help
+	  This module implements the MDIO bus protocol in software,
+	  for use by low level drivers that export the ability to
+	  drive the relevant pins.
 
-config QSEMI_PHY
-	tristate "Drivers for Quality Semiconductor PHYs"
-	---help---
-	  Currently supports the qs6612
+	  If in doubt, say N.
 
-config LXT_PHY
-	tristate "Drivers for the Intel LXT PHYs"
-	---help---
-	  Currently supports the lxt970, lxt971
+config MDIO_BUS_MUX
+	tristate
+	depends on OF_MDIO
+	help
+	  This module provides a driver framework for MDIO bus
+	  multiplexers which connect one of several child MDIO busses
+	  to a parent bus.  Switching between child busses is done by
+	  device specific drivers.
 
-config CICADA_PHY
-	tristate "Drivers for the Cicada PHYs"
-	---help---
-	  Currently supports the cis8204
+config MDIO_BUS_MUX_BCM_IPROC
+	tristate "Support for iProc based MDIO bus multiplexers"
+	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
+	select MDIO_BUS_MUX
+	default ARCH_BCM_IPROC
+	help
+	  This module provides a driver for MDIO bus multiplexers found in
+	  iProc based Broadcom SoCs. This multiplexer connects one of several
+	  child MDIO bus to a parent bus. Buses could be internal as well as
+	  external and selection logic lies inside the same multiplexer.
 
-config VITESSE_PHY
-        tristate "Drivers for the Vitesse PHYs"
-        ---help---
-          Currently supports the vsc8244
+config MDIO_BUS_MUX_GPIO
+	tristate "Support for GPIO controlled MDIO bus multiplexers"
+	depends on OF_GPIO && OF_MDIO
+	select MDIO_BUS_MUX
+	help
+	  This module provides a driver for MDIO bus multiplexers that
+	  are controlled via GPIO lines.  The multiplexer connects one of
+	  several child MDIO busses to a parent bus.  Child bus
+	  selection is under the control of GPIO lines.
 
-config TERANETICS_PHY
-        tristate "Drivers for the Teranetics PHYs"
-        ---help---
-          Currently supports the Teranetics TN2020
+config MDIO_BUS_MUX_MMIOREG
+	tristate "Support for MMIO device-controlled MDIO bus multiplexers"
+	depends on OF_MDIO && HAS_IOMEM
+	select MDIO_BUS_MUX
+	help
+	  This module provides a driver for MDIO bus multiplexers that
+	  are controlled via a simple memory-mapped device, like an FPGA.
+	  The multiplexer connects one of several child MDIO busses to a
+	  parent bus.  Child bus selection is under the control of one of
+	  the FPGA's registers.
 
-config SMSC_PHY
-	tristate "Drivers for SMSC PHYs"
-	---help---
-	  Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
+	  Currently, only 8-bit registers are supported.
 
-config BCM_NET_PHYLIB
+config MDIO_CAVIUM
 	tristate
 
-config BROADCOM_PHY
-	tristate "Drivers for Broadcom PHYs"
-	select BCM_NET_PHYLIB
+config MDIO_GPIO
+	tristate "Support for GPIO lib-based bitbanged MDIO buses"
+	depends on MDIO_BITBANG && GPIOLIB
 	---help---
-	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
-	  BCM5481 and BCM5482 PHYs.
+	  Supports GPIO lib-based MDIO busses.
 
-config BCM_CYGNUS_PHY
-	tristate "Drivers for Broadcom Cygnus SoC internal PHY"
-	depends on ARCH_BCM_CYGNUS || COMPILE_TEST
-	depends on MDIO_BCM_IPROC
-	select BCM_NET_PHYLIB
+	  To compile this driver as a module, choose M here: the module
+	  will be called mdio-gpio.
+
+config MDIO_HISI_FEMAC
+	tristate "Hisilicon FEMAC MDIO bus controller"
+	depends on HAS_IOMEM && OF_MDIO
+	help
+	  This module provides a driver for the MDIO busses found in the
+	  Hisilicon SoC that have an Fast Ethernet MAC.
+
+config MDIO_MOXART
+        tristate "MOXA ART MDIO interface support"
+        depends on ARCH_MOXART
+        help
+          This driver supports the MDIO interface found in the network
+          interface units of the MOXA ART SoC
+
+config MDIO_OCTEON
+	tristate "Support for MDIO buses on Octeon and some ThunderX SOCs"
+	depends on 64BIT
+	depends on HAS_IOMEM
+	select MDIO_CAVIUM
+	help
+	  This module provides a driver for the Octeon and ThunderX MDIO
+	  buses. It is required by the Octeon and ThunderX ethernet device
+	  drivers on some systems.
+
+config MDIO_SUN4I
+	tristate "Allwinner sun4i MDIO interface support"
+	depends on ARCH_SUNXI
+	help
+	  This driver supports the MDIO interface found in the network
+	  interface units of the Allwinner SoC that have an EMAC (A10,
+	  A12, A10s, etc.)
+
+config MDIO_THUNDER
+	tristate "Support for MDIO buses on ThunderX SOCs"
+	depends on 64BIT
+	depends on PCI
+	select MDIO_CAVIUM
+	help
+	  This driver supports the MDIO interfaces found on Cavium
+	  ThunderX SoCs when the MDIO bus device appears as a PCI
+	  device.
+
+config MDIO_XGENE
+	tristate "APM X-Gene SoC MDIO bus controller"
+	help
+	  This module provides a driver for the MDIO busses found in the
+	  APM X-Gene SoC's.
+
+comment "MII PHY device drivers"
+
+config AMD_PHY
+	tristate "Drivers for the AMD PHYs"
 	---help---
-	  This PHY driver is for the 1G internal PHYs of the Broadcom
-	  Cygnus Family SoC.
+	  Currently supports the am79c874
 
-	  Currently supports internal PHY's used in the BCM11300,
-	  BCM11320, BCM11350, BCM11360, BCM58300, BCM58302,
-	  BCM58303 & BCM58305 Broadcom Cygnus SoCs.
+config AQUANTIA_PHY
+        tristate "Drivers for the Aquantia PHYs"
+        ---help---
+          Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
+
+config AT803X_PHY
+	tristate "Drivers for Atheros AT803X PHYs"
+	---help---
+	  Currently supports the AT8030 and AT8035 model
 
 config BCM63XX_PHY
 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
@@ -114,35 +182,38 @@ config BCM87XX_PHY
 	help
 	  Currently supports the BCM8706 and BCM8727 10G Ethernet PHYs.
 
-config ICPLUS_PHY
-	tristate "Drivers for ICPlus PHYs"
+config BCM_CYGNUS_PHY
+	tristate "Drivers for Broadcom Cygnus SoC internal PHY"
+	depends on ARCH_BCM_CYGNUS || COMPILE_TEST
+	depends on MDIO_BCM_IPROC
+	select BCM_NET_PHYLIB
 	---help---
-	  Currently supports the IP175C and IP1001 PHYs.
+	  This PHY driver is for the 1G internal PHYs of the Broadcom
+	  Cygnus Family SoC.
 
-config REALTEK_PHY
-	tristate "Drivers for Realtek PHYs"
-	---help---
-	  Supports the Realtek 821x PHY.
+	  Currently supports internal PHY's used in the BCM11300,
+	  BCM11320, BCM11350, BCM11360, BCM58300, BCM58302,
+	  BCM58303 & BCM58305 Broadcom Cygnus SoCs.
 
-config NATIONAL_PHY
-	tristate "Drivers for National Semiconductor PHYs"
-	---help---
-	  Currently supports the DP83865 PHY.
+config BCM_NET_PHYLIB
+	tristate
 
-config STE10XP
-	tristate "Driver for STMicroelectronics STe10Xp PHYs"
+config BROADCOM_PHY
+	tristate "Drivers for Broadcom PHYs"
+	select BCM_NET_PHYLIB
 	---help---
-	  This is the driver for the STe100p and STe101p PHYs.
+	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
+	  BCM5481 and BCM5482 PHYs.
 
-config LSI_ET1011C_PHY
-	tristate "Driver for LSI ET1011C PHY"
+config CICADA_PHY
+	tristate "Drivers for the Cicada PHYs"
 	---help---
-	  Supports the LSI ET1011C PHY.
+	  Currently supports the cis8204
 
-config MICREL_PHY
-	tristate "Driver for Micrel PHYs"
+config DAVICOM_PHY
+	tristate "Drivers for Davicom PHYs"
 	---help---
-	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
+	  Currently supports dm9161e and dm9131
 
 config DP83848_PHY
 	tristate "Driver for Texas Instruments DP83848 PHY"
@@ -154,11 +225,6 @@ config DP83867_PHY
 	---help---
 	  Currently supports the DP83867 PHY.
 
-config MICROCHIP_PHY
-	tristate "Drivers for Microchip PHYs"
-	help
-	  Supports the LAN88XX PHYs.
-
 config FIXED_PHY
 	tristate "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB
@@ -169,122 +235,10 @@ config FIXED_PHY
 
 	  Currently tested with mpc866ads and mpc8349e-mitx.
 
-config MDIO_BITBANG
-	tristate "Support for bitbanged MDIO buses"
-	help
-	  This module implements the MDIO bus protocol in software,
-	  for use by low level drivers that export the ability to
-	  drive the relevant pins.
-
-	  If in doubt, say N.
-
-config MDIO_GPIO
-	tristate "Support for GPIO lib-based bitbanged MDIO buses"
-	depends on MDIO_BITBANG && GPIOLIB
+config ICPLUS_PHY
+	tristate "Drivers for ICPlus PHYs"
 	---help---
-	  Supports GPIO lib-based MDIO busses.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called mdio-gpio.
-
-config MDIO_CAVIUM
-	tristate
-
-config MDIO_OCTEON
-	tristate "Support for MDIO buses on Octeon and some ThunderX SOCs"
-	depends on 64BIT
-	depends on HAS_IOMEM
-	select MDIO_CAVIUM
-	help
-	  This module provides a driver for the Octeon and ThunderX MDIO
-	  buses. It is required by the Octeon and ThunderX ethernet device
-	  drivers on some systems.
-
-config MDIO_THUNDER
-	tristate "Support for MDIO buses on ThunderX SOCs"
-	depends on 64BIT
-	depends on PCI
-	select MDIO_CAVIUM
-	help
-	  This driver supports the MDIO interfaces found on Cavium
-	  ThunderX SoCs when the MDIO bus device appears as a PCI
-	  device.
-
-
-config MDIO_SUN4I
-	tristate "Allwinner sun4i MDIO interface support"
-	depends on ARCH_SUNXI
-	help
-	  This driver supports the MDIO interface found in the network
-	  interface units of the Allwinner SoC that have an EMAC (A10,
-	  A12, A10s, etc.)
-
-config MDIO_MOXART
-        tristate "MOXA ART MDIO interface support"
-        depends on ARCH_MOXART
-        help
-          This driver supports the MDIO interface found in the network
-          interface units of the MOXA ART SoC
-
-config MDIO_BUS_MUX
-	tristate
-	depends on OF_MDIO
-	help
-	  This module provides a driver framework for MDIO bus
-	  multiplexers which connect one of several child MDIO busses
-	  to a parent bus.  Switching between child busses is done by
-	  device specific drivers.
-
-config MDIO_BUS_MUX_GPIO
-	tristate "Support for GPIO controlled MDIO bus multiplexers"
-	depends on OF_GPIO && OF_MDIO
-	select MDIO_BUS_MUX
-	help
-	  This module provides a driver for MDIO bus multiplexers that
-	  are controlled via GPIO lines.  The multiplexer connects one of
-	  several child MDIO busses to a parent bus.  Child bus
-	  selection is under the control of GPIO lines.
-
-config MDIO_BUS_MUX_MMIOREG
-	tristate "Support for MMIO device-controlled MDIO bus multiplexers"
-	depends on OF_MDIO && HAS_IOMEM
-	select MDIO_BUS_MUX
-	help
-	  This module provides a driver for MDIO bus multiplexers that
-	  are controlled via a simple memory-mapped device, like an FPGA.
-	  The multiplexer connects one of several child MDIO busses to a
-	  parent bus.  Child bus selection is under the control of one of
-	  the FPGA's registers.
-
-	  Currently, only 8-bit registers are supported.
-
-config MDIO_BUS_MUX_BCM_IPROC
-	tristate "Support for iProc based MDIO bus multiplexers"
-	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
-	select MDIO_BUS_MUX
-	default ARCH_BCM_IPROC
-	help
-	  This module provides a driver for MDIO bus multiplexers found in
-	  iProc based Broadcom SoCs. This multiplexer connects one of several
-	  child MDIO bus to a parent bus. Buses could be internal as well as
-	  external and selection logic lies inside the same multiplexer.
-
-config MDIO_BCM_UNIMAC
-	tristate "Broadcom UniMAC MDIO bus controller"
-	depends on HAS_IOMEM
-	help
-	  This module provides a driver for the Broadcom UniMAC MDIO busses.
-	  This hardware can be found in the Broadcom GENET Ethernet MAC
-	  controllers as well as some Broadcom Ethernet switches such as the
-	  Starfighter 2 switches.
-
-config MDIO_BCM_IPROC
-	tristate "Broadcom iProc MDIO bus controller"
-	depends on ARCH_BCM_IPROC || COMPILE_TEST
-	depends on HAS_IOMEM && OF_MDIO
-	help
-	  This module provides a driver for the MDIO busses found in the
-	  Broadcom iProc SoC's.
+	  Currently supports the IP175C and IP1001 PHYs.
 
 config INTEL_XWAY_PHY
 	tristate "Driver for Intel XWAY PHYs"
@@ -294,24 +248,71 @@ config INTEL_XWAY_PHY
 	  PEF 7061, PEF 7071 and PEF 7072 or integrated into the Intel
 	  SoCs xRX200, xRX300, xRX330, xRX350 and xRX550.
 
-config MDIO_HISI_FEMAC
-	tristate "Hisilicon FEMAC MDIO bus controller"
-	depends on HAS_IOMEM && OF_MDIO
-	help
-	  This module provides a driver for the MDIO busses found in the
-	  Hisilicon SoC that have an Fast Ethernet MAC.
+config LSI_ET1011C_PHY
+	tristate "Driver for LSI ET1011C PHY"
+	---help---
+	  Supports the LSI ET1011C PHY.
 
-config MDIO_XGENE
-	tristate "APM X-Gene SoC MDIO bus controller"
+config LXT_PHY
+	tristate "Drivers for the Intel LXT PHYs"
+	---help---
+	  Currently supports the lxt970, lxt971
+
+config MARVELL_PHY
+	tristate "Drivers for Marvell PHYs"
+	---help---
+	  Currently has a driver for the 88E1011S
+
+config MICREL_PHY
+	tristate "Driver for Micrel PHYs"
+	---help---
+	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
+
+config MICROCHIP_PHY
+	tristate "Drivers for Microchip PHYs"
 	help
-	  This module provides a driver for the MDIO busses found in the
-	  APM X-Gene SoC's.
+	  Supports the LAN88XX PHYs.
 
 config MICROSEMI_PHY
     tristate "Drivers for the Microsemi PHYs"
     ---help---
       Currently supports the VSC8531 and VSC8541 PHYs
 
+config NATIONAL_PHY
+	tristate "Drivers for National Semiconductor PHYs"
+	---help---
+	  Currently supports the DP83865 PHY.
+
+config QSEMI_PHY
+	tristate "Drivers for Quality Semiconductor PHYs"
+	---help---
+	  Currently supports the qs6612
+
+config REALTEK_PHY
+	tristate "Drivers for Realtek PHYs"
+	---help---
+	  Supports the Realtek 821x PHY.
+
+config SMSC_PHY
+	tristate "Drivers for SMSC PHYs"
+	---help---
+	  Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
+
+config STE10XP
+	tristate "Driver for STMicroelectronics STe10Xp PHYs"
+	---help---
+	  This is the driver for the STe100p and STe101p PHYs.
+
+config TERANETICS_PHY
+        tristate "Drivers for the Teranetics PHYs"
+        ---help---
+          Currently supports the Teranetics TN2020
+
+config VITESSE_PHY
+        tristate "Drivers for the Vitesse PHYs"
+        ---help---
+          Currently supports the vsc8244
+
 config XILINX_GMII2RGMII
        tristate "Xilinx GMII2RGMII converter driver"
        ---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 73d65ce04454..e58667d111e7 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,53 +1,55 @@
-# Makefile for Linux PHY drivers
+# Makefile for Linux PHY drivers and MDIO bus drivers
 
 libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o
 libphy-$(CONFIG_SWPHY)		+= swphy.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
+
+obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
+obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
+obj-$(CONFIG_MDIO_BUS_MUX)	+= mdio-mux.o
+obj-$(CONFIG_MDIO_BUS_MUX_BCM_IPROC)	+= mdio-mux-bcm-iproc.o
+obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
+obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
+obj-$(CONFIG_MDIO_CAVIUM)	+= mdio-cavium.o
+obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
+obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
+obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
+obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
+obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
+obj-$(CONFIG_MDIO_THUNDER)	+= mdio-thunder.o
+obj-$(CONFIG_MDIO_XGENE)	+= mdio-xgene.o
+
+obj-$(CONFIG_AMD_PHY)		+= amd.o
 obj-$(CONFIG_AQUANTIA_PHY)	+= aquantia.o
-obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
-obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
-obj-$(CONFIG_CICADA_PHY)	+= cicada.o
-obj-$(CONFIG_LXT_PHY)		+= lxt.o
-obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
-obj-$(CONFIG_SMSC_PHY)		+= smsc.o
-obj-$(CONFIG_MICROSEMI_PHY) += mscc.o
-obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
-obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
-obj-$(CONFIG_BCM_NET_PHYLIB)	+= bcm-phy-lib.o
-obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
+obj-$(CONFIG_AT803X_PHY)	+= at803x.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
 obj-$(CONFIG_BCM7XXX_PHY)	+= bcm7xxx.o
 obj-$(CONFIG_BCM87XX_PHY)	+= bcm87xx.o
 obj-$(CONFIG_BCM_CYGNUS_PHY)	+= bcm-cygnus.o
-obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
-obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
-obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
-obj-$(CONFIG_FIXED_PHY)		+= fixed_phy.o
-obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
-obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
-obj-$(CONFIG_NATIONAL_PHY)	+= national.o
+obj-$(CONFIG_BCM_NET_PHYLIB)	+= bcm-phy-lib.o
+obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
+obj-$(CONFIG_CICADA_PHY)	+= cicada.o
+obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
 obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
 obj-$(CONFIG_DP83867_PHY)	+= dp83867.o
-obj-$(CONFIG_STE10XP)		+= ste10Xp.o
-obj-$(CONFIG_MICREL_PHY)	+= micrel.o
-obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
-obj-$(CONFIG_MDIO_THUNDER)	+= mdio-thunder.o
-obj-$(CONFIG_MDIO_CAVIUM)	+= mdio-cavium.o
+obj-$(CONFIG_FIXED_PHY)		+= fixed_phy.o
+obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
+obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
+obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
+obj-$(CONFIG_LXT_PHY)		+= lxt.o
+obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
 obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
-obj-$(CONFIG_AT803X_PHY)	+= at803x.o
-obj-$(CONFIG_AMD_PHY)		+= amd.o
-obj-$(CONFIG_MDIO_BUS_MUX)	+= mdio-mux.o
-obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
-obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
-obj-$(CONFIG_MDIO_BUS_MUX_BCM_IPROC)	+= mdio-mux-bcm-iproc.o
-obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
-obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
-obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
+obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
-obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
-obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
-obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
-obj-$(CONFIG_MDIO_XGENE)	+= mdio-xgene.o
+obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
+obj-$(CONFIG_NATIONAL_PHY)	+= national.o
+obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
+obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
+obj-$(CONFIG_SMSC_PHY)		+= smsc.o
+obj-$(CONFIG_STE10XP)		+= ste10Xp.o
+obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
+obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_XILINX_GMII2RGMII) += xilinx_gmii2rgmii.o
-- 
2.8.1
