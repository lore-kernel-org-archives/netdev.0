From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 12 Sep 2016 10:49:08 +1000
Message-ID: <20160912104908.08c5db80@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jean Delvare <jdelvare@suse.de>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:46794 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755329AbcILAtL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Sep 2016 20:49:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/phy/Kconfig

between commit:

  c2f57fb97da5 ("drivers: net: phy: mdio-xgene: Add hardware dependency")

from the net tree and commit:

  d75b4a22b255 ("net: phy: Sort Makefile and Kconfig")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

These "sort the Kconfig/Makefile" patches are much better done just
before or after -rc1 so that the conflicting changes are already merged
and new development can be based on top of them.
-- 
Cheers,
Stephen Rothwell

138c337cf0c2436790877f87e91154b3c3294346
diff --cc drivers/net/phy/Kconfig
index b4863e4e522b,87b566f54cc1..2651c8d8de2f
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@@ -15,88 -15,156 +15,157 @@@ if PHYLI
  config SWPHY
  	bool
  
- comment "MII PHY device drivers"
- 
- config AQUANTIA_PHY
-         tristate "Drivers for the Aquantia PHYs"
-         ---help---
-           Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
+ comment "MDIO bus device drivers"
  
- config AT803X_PHY
- 	tristate "Drivers for Atheros AT803X PHYs"
- 	---help---
- 	  Currently supports the AT8030 and AT8035 model
+ config MDIO_BCM_IPROC
+ 	tristate "Broadcom iProc MDIO bus controller"
+ 	depends on ARCH_BCM_IPROC || COMPILE_TEST
+ 	depends on HAS_IOMEM && OF_MDIO
+ 	help
+ 	  This module provides a driver for the MDIO busses found in the
+ 	  Broadcom iProc SoC's.
  
- config AMD_PHY
- 	tristate "Drivers for the AMD PHYs"
- 	---help---
- 	  Currently supports the am79c874
+ config MDIO_BCM_UNIMAC
+ 	tristate "Broadcom UniMAC MDIO bus controller"
+ 	depends on HAS_IOMEM
+ 	help
+ 	  This module provides a driver for the Broadcom UniMAC MDIO busses.
+ 	  This hardware can be found in the Broadcom GENET Ethernet MAC
+ 	  controllers as well as some Broadcom Ethernet switches such as the
+ 	  Starfighter 2 switches.
  
- config MARVELL_PHY
- 	tristate "Drivers for Marvell PHYs"
- 	---help---
- 	  Currently has a driver for the 88E1011S
- 	
- config DAVICOM_PHY
- 	tristate "Drivers for Davicom PHYs"
- 	---help---
- 	  Currently supports dm9161e and dm9131
+ config MDIO_BITBANG
+ 	tristate "Bitbanged MDIO buses"
+ 	help
+ 	  This module implements the MDIO bus protocol in software,
+ 	  for use by low level drivers that export the ability to
+ 	  drive the relevant pins.
  
- config QSEMI_PHY
- 	tristate "Drivers for Quality Semiconductor PHYs"
- 	---help---
- 	  Currently supports the qs6612
+ 	  If in doubt, say N.
  
- config LXT_PHY
- 	tristate "Drivers for the Intel LXT PHYs"
- 	---help---
- 	  Currently supports the lxt970, lxt971
+ config MDIO_BUS_MUX
+ 	tristate
+ 	depends on OF_MDIO
+ 	help
+ 	  This module provides a driver framework for MDIO bus
+ 	  multiplexers which connect one of several child MDIO busses
+ 	  to a parent bus.  Switching between child busses is done by
+ 	  device specific drivers.
  
- config CICADA_PHY
- 	tristate "Drivers for the Cicada PHYs"
- 	---help---
- 	  Currently supports the cis8204
+ config MDIO_BUS_MUX_BCM_IPROC
+ 	tristate "Broadcom iProc based MDIO bus multiplexers"
+ 	depends on OF && OF_MDIO && (ARCH_BCM_IPROC || COMPILE_TEST)
+ 	select MDIO_BUS_MUX
+ 	default ARCH_BCM_IPROC
+ 	help
+ 	  This module provides a driver for MDIO bus multiplexers found in
+ 	  iProc based Broadcom SoCs. This multiplexer connects one of several
+ 	  child MDIO bus to a parent bus. Buses could be internal as well as
+ 	  external and selection logic lies inside the same multiplexer.
  
- config VITESSE_PHY
-         tristate "Drivers for the Vitesse PHYs"
-         ---help---
-           Currently supports the vsc8244
+ config MDIO_BUS_MUX_GPIO
+ 	tristate "GPIO controlled MDIO bus multiplexers"
+ 	depends on OF_GPIO && OF_MDIO
+ 	select MDIO_BUS_MUX
+ 	help
+ 	  This module provides a driver for MDIO bus multiplexers that
+ 	  are controlled via GPIO lines.  The multiplexer connects one of
+ 	  several child MDIO busses to a parent bus.  Child bus
+ 	  selection is under the control of GPIO lines.
  
- config TERANETICS_PHY
-         tristate "Drivers for the Teranetics PHYs"
-         ---help---
-           Currently supports the Teranetics TN2020
+ config MDIO_BUS_MUX_MMIOREG
+ 	tristate "MMIO device-controlled MDIO bus multiplexers"
+ 	depends on OF_MDIO && HAS_IOMEM
+ 	select MDIO_BUS_MUX
+ 	help
+ 	  This module provides a driver for MDIO bus multiplexers that
+ 	  are controlled via a simple memory-mapped device, like an FPGA.
+ 	  The multiplexer connects one of several child MDIO busses to a
+ 	  parent bus.  Child bus selection is under the control of one of
+ 	  the FPGA's registers.
  
- config SMSC_PHY
- 	tristate "Drivers for SMSC PHYs"
- 	---help---
- 	  Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
+ 	  Currently, only 8-bit registers are supported.
  
- config BCM_NET_PHYLIB
+ config MDIO_CAVIUM
  	tristate
  
- config BROADCOM_PHY
- 	tristate "Drivers for Broadcom PHYs"
- 	select BCM_NET_PHYLIB
+ config MDIO_GPIO
+ 	tristate "GPIO lib-based bitbanged MDIO buses"
+ 	depends on MDIO_BITBANG && GPIOLIB
  	---help---
- 	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
- 	  BCM5481 and BCM5482 PHYs.
+ 	  Supports GPIO lib-based MDIO busses.
  
- config BCM_CYGNUS_PHY
- 	tristate "Drivers for Broadcom Cygnus SoC internal PHY"
- 	depends on ARCH_BCM_CYGNUS || COMPILE_TEST
- 	depends on MDIO_BCM_IPROC
- 	select BCM_NET_PHYLIB
+ 	  To compile this driver as a module, choose M here: the module
+ 	  will be called mdio-gpio.
+ 
+ config MDIO_HISI_FEMAC
+ 	tristate "Hisilicon FEMAC MDIO bus controller"
+ 	depends on HAS_IOMEM && OF_MDIO
+ 	help
+ 	  This module provides a driver for the MDIO busses found in the
+ 	  Hisilicon SoC that have an Fast Ethernet MAC.
+ 
+ config MDIO_MOXART
+         tristate "MOXA ART MDIO interface support"
+         depends on ARCH_MOXART
+         help
+           This driver supports the MDIO interface found in the network
+           interface units of the MOXA ART SoC
+ 
+ config MDIO_OCTEON
+ 	tristate "Octeon and some ThunderX SOCs MDIO buses"
+ 	depends on 64BIT
+ 	depends on HAS_IOMEM
+ 	select MDIO_CAVIUM
+ 	help
+ 	  This module provides a driver for the Octeon and ThunderX MDIO
+ 	  buses. It is required by the Octeon and ThunderX ethernet device
+ 	  drivers on some systems.
+ 
+ config MDIO_SUN4I
+ 	tristate "Allwinner sun4i MDIO interface support"
+ 	depends on ARCH_SUNXI
+ 	help
+ 	  This driver supports the MDIO interface found in the network
+ 	  interface units of the Allwinner SoC that have an EMAC (A10,
+ 	  A12, A10s, etc.)
+ 
+ config MDIO_THUNDER
+ 	tristate "ThunderX SOCs MDIO buses"
+ 	depends on 64BIT
+ 	depends on PCI
+ 	select MDIO_CAVIUM
+ 	help
+ 	  This driver supports the MDIO interfaces found on Cavium
+ 	  ThunderX SoCs when the MDIO bus device appears as a PCI
+ 	  device.
+ 
+ config MDIO_XGENE
+ 	tristate "APM X-Gene SoC MDIO bus controller"
++	depends on ARCH_XGENE || COMPILE_TEST
+ 	help
+ 	  This module provides a driver for the MDIO busses found in the
+ 	  APM X-Gene SoC's.
+ 
+ comment "MII PHY device drivers"
+ 
+ config AMD_PHY
+ 	tristate "AMD PHYs"
  	---help---
- 	  This PHY driver is for the 1G internal PHYs of the Broadcom
- 	  Cygnus Family SoC.
+ 	  Currently supports the am79c874
  
- 	  Currently supports internal PHY's used in the BCM11300,
- 	  BCM11320, BCM11350, BCM11360, BCM58300, BCM58302,
- 	  BCM58303 & BCM58305 Broadcom Cygnus SoCs.
+ config AQUANTIA_PHY
+         tristate "Aquantia PHYs"
+         ---help---
+           Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
+ 
+ config AT803X_PHY
+ 	tristate "AT803X PHYs"
+ 	---help---
+ 	  Currently supports the AT8030 and AT8035 model
  
  config BCM63XX_PHY
- 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
+ 	tristate "Broadcom 63xx SOCs internal PHY"
  	depends on BCM63XX
  	select BCM_NET_PHYLIB
  	---help---
