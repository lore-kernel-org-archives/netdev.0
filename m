From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 06:58:37 -0700
Message-ID: <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sriram <srk@ti.com>, Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188Ab1FYOAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:20 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make the
necessary Kconfig and Makefile changes.
There were 4 drivers (TI Davinci & ftmac100) not in the
drivers/net/arm/ which should have been since they are only supported
under ARM, so they were added to the new directory structure.

NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
CC'ing the last 3 major contributors from TI.

CC: Sriram <srk@ti.com>
CC: Vinay Hegde <vinay.hegde@ti.com>
CC: Cyril Chemparathy <cyril@ti.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Wan ZongShun <mcuos.com@gmail.com>
CC: Lennert Buytenhek <kernel@wantstofly.org>
CC: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                    |   10 +-
 drivers/net/Kconfig                            |   33 -------
 drivers/net/Makefile                           |    5 -
 drivers/net/arm/Kconfig                        |   74 ---------------
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/arm/Kconfig               |  120 ++++++++++++++++++++++++
 drivers/net/{ => ethernet}/arm/Makefile        |    4 +-
 drivers/net/{ => ethernet}/arm/am79c961a.c     |    0
 drivers/net/{ => ethernet}/arm/am79c961a.h     |    0
 drivers/net/{ => ethernet}/arm/at91_ether.c    |    0
 drivers/net/{ => ethernet}/arm/at91_ether.h    |    0
 drivers/net/{ => ethernet/arm}/davinci_cpdma.c |    0
 drivers/net/{ => ethernet/arm}/davinci_cpdma.h |    0
 drivers/net/{ => ethernet/arm}/davinci_emac.c  |    0
 drivers/net/{ => ethernet/arm}/davinci_mdio.c  |    0
 drivers/net/{ => ethernet}/arm/ep93xx_eth.c    |    0
 drivers/net/{ => ethernet}/arm/ether1.c        |    0
 drivers/net/{ => ethernet}/arm/ether1.h        |    0
 drivers/net/{ => ethernet}/arm/ether3.c        |    0
 drivers/net/{ => ethernet}/arm/ether3.h        |    0
 drivers/net/{ => ethernet}/arm/etherh.c        |    0
 drivers/net/{ => ethernet}/arm/ixp4xx_eth.c    |    0
 drivers/net/{ => ethernet}/arm/ks8695net.c     |    0
 drivers/net/{ => ethernet}/arm/ks8695net.h     |    0
 drivers/net/{ => ethernet}/arm/w90p910_ether.c |    0
 26 files changed, 130 insertions(+), 118 deletions(-)
 delete mode 100644 drivers/net/arm/Kconfig
 create mode 100644 drivers/net/ethernet/arm/Kconfig
 rename drivers/net/{ => ethernet}/arm/Makefile (74%)
 rename drivers/net/{ => ethernet}/arm/am79c961a.c (100%)
 rename drivers/net/{ => ethernet}/arm/am79c961a.h (100%)
 rename drivers/net/{ => ethernet}/arm/at91_ether.c (100%)
 rename drivers/net/{ => ethernet}/arm/at91_ether.h (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_cpdma.c (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_cpdma.h (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_emac.c (100%)
 rename drivers/net/{ => ethernet/arm}/davinci_mdio.c (100%)
 rename drivers/net/{ => ethernet}/arm/ep93xx_eth.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether1.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether1.h (100%)
 rename drivers/net/{ => ethernet}/arm/ether3.c (100%)
 rename drivers/net/{ => ethernet}/arm/ether3.h (100%)
 rename drivers/net/{ => ethernet}/arm/etherh.c (100%)
 rename drivers/net/{ => ethernet}/arm/ixp4xx_eth.c (100%)
 rename drivers/net/{ => ethernet}/arm/ks8695net.c (100%)
 rename drivers/net/{ => ethernet}/arm/ks8695net.h (100%)
 rename drivers/net/{ => ethernet}/arm/w90p910_ether.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 90925d9..7469e6c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -726,7 +726,7 @@ L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 W:	http://www.arm.linux.org.uk/
 S:	Maintained
 F:	arch/arm/mach-ebsa110/
-F:	drivers/net/arm/am79c961a.*
+F:	drivers/net/ethernet/arm/am79c961a.*
 
 ARM/EZX SMARTPHONES (A780, A910, A1200, E680, ROKR E2 and ROKR E6)
 M:	Daniel Ribeiro <drwyrm@gmail.com>
@@ -995,7 +995,7 @@ F:	arch/arm/include/asm/hardware/ioc.h
 F:	arch/arm/include/asm/hardware/iomd.h
 F:	arch/arm/include/asm/hardware/memc.h
 F:	arch/arm/mach-rpc/
-F:	drivers/net/arm/ether*
+F:	drivers/net/ethernet/arm/ether*
 F:	drivers/scsi/arm/
 
 ARM/SHARK MACHINE SUPPORT
@@ -1107,7 +1107,7 @@ F:	arch/arm/mach-nuc93x/
 F:	drivers/input/keyboard/w90p910_keypad.c
 F:	drivers/input/touchscreen/w90p910_ts.c
 F:	drivers/watchdog/nuc900_wdt.c
-F:	drivers/net/arm/w90p910_ether.c
+F:	drivers/net/ethernet/arm/w90p910_ether.c
 F:	drivers/mtd/nand/nuc900_nand.c
 F:	drivers/rtc/rtc-nuc900.c
 F:	drivers/spi/spi_nuc900.c
@@ -1741,7 +1741,7 @@ CIRRUS LOGIC EP93XX ETHERNET DRIVER
 M:	Hartley Sweeten <hsweeten@visionengravers.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/arm/ep93xx_eth.c
+F:	drivers/net/ethernet/arm/ep93xx_eth.c
 
 CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
 M:	Lennert Buytenhek <kernel@wantstofly.org>
@@ -3287,7 +3287,7 @@ F:	arch/arm/mach-ixp4xx/include/mach/qmgr.h
 F:	arch/arm/mach-ixp4xx/include/mach/npe.h
 F:	arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
 F:	arch/arm/mach-ixp4xx/ixp4xx_npe.c
-F:	drivers/net/arm/ixp4xx_eth.c
+F:	drivers/net/ethernet/arm/ixp4xx_eth.c
 F:	drivers/net/wan/ixp4xx_hss.c
 
 INTEL IXP4XX RANDOM NUMBER GENERATOR SUPPORT
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a2c032c..3568fc2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -235,8 +235,6 @@ config MACB
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
 
-source "drivers/net/arm/Kconfig"
-
 config ARIADNE
 	tristate "Ariadne support"
 	depends on ZORRO
@@ -409,37 +407,6 @@ config NET_NETX
 	  To compile this driver as a module, choose M here. The module
 	  will be called netx-eth.
 
-config TI_DAVINCI_EMAC
-	tristate "TI DaVinci EMAC Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	select TI_DAVINCI_MDIO
-	select TI_DAVINCI_CPDMA
-	select PHYLIB
-	help
-	  This driver supports TI's DaVinci Ethernet .
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_emac_driver.  This is recommended.
-
-config TI_DAVINCI_MDIO
-	tristate "TI DaVinci MDIO Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	select PHYLIB
-	help
-	  This driver supports TI's DaVinci MDIO module.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_mdio.  This is recommended.
-
-config TI_DAVINCI_CPDMA
-	tristate "TI DaVinci CPDMA Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
-	help
-	  This driver supports TI's DaVinci CPDMA dma engine.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called davinci_cpdma.  This is recommended.
-
 config DM9000
 	tristate "DM9000 support"
 	depends on ARM || BLACKFIN || MIPS
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0d016c1..d3eb443 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -6,10 +6,6 @@ obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
 
-obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
-obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
-obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
-
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
@@ -160,7 +156,6 @@ obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 
-obj-$(CONFIG_ARM) += arm/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_TR) += tokenring/
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
deleted file mode 100644
index 39e1c0d..0000000
--- a/drivers/net/arm/Kconfig
+++ /dev/null
@@ -1,74 +0,0 @@
-#
-# Acorn Network device configuration
-#  These are for Acorn's Expansion card network interfaces
-#
-config ARM_AM79C961A
-	bool "ARM EBSA110 AM79C961A support"
-	depends on ARM && ARCH_EBSA110
-	select CRC32
-	help
-	  If you wish to compile a kernel for the EBSA-110, then you should
-	  always answer Y to this.
-
-config ARM_ETHER1
-	tristate "Acorn Ether1 support"
-	depends on ARM && ARCH_ACORN
-	help
-	  If you have an Acorn system with one of these (AKA25) network cards,
-	  you should say Y to this option if you wish to use it with Linux.
-
-config ARM_ETHER3
-	tristate "Acorn/ANT Ether3 support"
-	depends on ARM && ARCH_ACORN
-	help
-	  If you have an Acorn system with one of these network cards, you
-	  should say Y to this option if you wish to use it with Linux.
-
-config ARM_ETHERH
-	tristate "I-cubed EtherH/ANT EtherM support"
-	depends on ARM && ARCH_ACORN
-	select CRC32
-	help
-	  If you have an Acorn system with one of these network cards, you
-	  should say Y to this option if you wish to use it with Linux.
-
-config ARM_AT91_ETHER
-	tristate "AT91RM9200 Ethernet support"
-	depends on ARM && ARCH_AT91RM9200
-	select MII
-	help
-	  If you wish to compile a kernel for the AT91RM9200 and enable
-	  ethernet support, then you should always answer Y to this.
-
-config ARM_KS8695_ETHER
-	tristate "KS8695 Ethernet support"
-	depends on ARM && ARCH_KS8695
-	select MII
-	help
-	  If you wish to compile a kernel for the KS8695 and want to
-	  use the internal ethernet then you should answer Y to this.
-
-config EP93XX_ETH
-	tristate "EP93xx Ethernet support"
-	depends on ARM && ARCH_EP93XX
-	select MII
-	help
-	  This is a driver for the ethernet hardware included in EP93xx CPUs.
-	  Say Y if you are building a kernel for EP93xx based devices.
-
-config IXP4XX_ETH
-	tristate "Intel IXP4xx Ethernet support"
-	depends on ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR
-	select PHYLIB
-	help
-	  Say Y here if you want to use built-in Ethernet ports
-	  on IXP4xx processor.
-
-config W90P910_ETH
-	tristate "Nuvoton w90p910 Ethernet support"
-	depends on ARM && ARCH_W90X900
-	select PHYLIB
-	select MII
-	help
-	  Say Y here if you want to use built-in Ethernet ports
-	  on w90p910 processor.
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 4daf50d..76fcaae 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -14,6 +14,7 @@ if ETHERNET
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
+source "drivers/net/ethernet/arm/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 2bce3e6..0bdb3ed 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
+obj-$(CONFIG_NET_ARM) += arm/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
diff --git a/drivers/net/ethernet/arm/Kconfig b/drivers/net/ethernet/arm/Kconfig
new file mode 100644
index 0000000..73e66b7
--- /dev/null
+++ b/drivers/net/ethernet/arm/Kconfig
@@ -0,0 +1,120 @@
+#
+# ARM/Acorn Network device configuration
+#
+
+config NET_ARM
+	bool "ARM devices"
+	depends on ARM
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  If unsure, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the remaining ARM network card questions. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config ARM_AM79C961A
+	bool "ARM EBSA110 AM79C961A support"
+	depends on NET_ARM && ARM && ARCH_EBSA110
+	select CRC32
+	---help---
+	  If you wish to compile a kernel for the EBSA-110, then you should
+	  always answer Y to this.
+
+config ARM_ETHER1
+	tristate "Acorn Ether1 support"
+	depends on NET_ARM && ARM && ARCH_ACORN
+	---help---
+	  If you have an Acorn system with one of these (AKA25) network cards,
+	  you should say Y to this option if you wish to use it with Linux.
+
+config ARM_ETHER3
+	tristate "Acorn/ANT Ether3 support"
+	depends on NET_ARM && ARM && ARCH_ACORN
+	---help---
+	  If you have an Acorn system with one of these network cards, you
+	  should say Y to this option if you wish to use it with Linux.
+
+config ARM_AT91_ETHER
+	tristate "AT91RM9200 Ethernet support"
+	depends on NET_ARM && ARM && ARCH_AT91RM9200
+	select MII
+	---help---
+	  If you wish to compile a kernel for the AT91RM9200 and enable
+	  ethernet support, then you should always answer Y to this.
+
+config EP93XX_ETH
+	tristate "EP93xx Ethernet support"
+	depends on NET_ARM && ARM && ARCH_EP93XX
+	select MII
+	---help---
+	  This is a driver for the ethernet hardware included in EP93xx CPUs.
+	  Say Y if you are building a kernel for EP93xx based devices.
+
+config ARM_ETHERH
+	tristate "I-cubed EtherH/ANT EtherM support"
+	depends on NET_ARM && ARM && ARCH_ACORN
+	select CRC32
+	---help---
+	  If you have an Acorn system with one of these network cards, you
+	  should say Y to this option if you wish to use it with Linux.
+
+config IXP4XX_ETH
+	tristate "Intel IXP4xx Ethernet support"
+	depends on NET_ARM && ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR
+	select PHYLIB
+	---help---
+	  Say Y here if you want to use built-in Ethernet ports
+	  on IXP4xx processor.
+
+config ARM_KS8695_ETHER
+	tristate "KS8695 Ethernet support"
+	depends on NET_ARM && ARM && ARCH_KS8695
+	select MII
+	---help---
+	  If you wish to compile a kernel for the KS8695 and want to
+	  use the internal ethernet then you should answer Y to this.
+
+config W90P910_ETH
+	tristate "Nuvoton w90p910 Ethernet support"
+	depends on NET_ARM && ARM && ARCH_W90X900
+	select PHYLIB
+	select MII
+	---help---
+	  Say Y here if you want to use built-in Ethernet ports
+	  on w90p910 processor.
+
+config TI_DAVINCI_EMAC
+	tristate "TI DaVinci EMAC Support"
+	depends on NET_ARM && ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	select TI_DAVINCI_MDIO
+	select TI_DAVINCI_CPDMA
+	select PHYLIB
+	---help---
+	  This driver supports TI's DaVinci Ethernet .
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_emac_driver.  This is recommended.
+
+config TI_DAVINCI_MDIO
+	tristate "TI DaVinci MDIO Support"
+	depends on NET_ARM && ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	select PHYLIB
+	---help---
+	  This driver supports TI's DaVinci MDIO module.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_mdio.  This is recommended.
+
+config TI_DAVINCI_CPDMA
+	tristate "TI DaVinci CPDMA Support"
+	depends on NET_ARM && ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	---help---
+	  This driver supports TI's DaVinci CPDMA dma engine.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called davinci_cpdma.  This is recommended.
diff --git a/drivers/net/arm/Makefile b/drivers/net/ethernet/arm/Makefile
similarity index 74%
rename from drivers/net/arm/Makefile
rename to drivers/net/ethernet/arm/Makefile
index 303171f..f2fb6ad 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/ethernet/arm/Makefile
@@ -1,4 +1,3 @@
-# File: drivers/net/arm/Makefile
 #
 # Makefile for the ARM network device drivers
 #
@@ -12,3 +11,6 @@ obj-$(CONFIG_ARM_KS8695_ETHER)	+= ks8695net.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
 obj-$(CONFIG_IXP4XX_ETH)	+= ixp4xx_eth.o
 obj-$(CONFIG_W90P910_ETH)	+= w90p910_ether.o
+obj-$(CONFIG_TI_DAVINCI_EMAC)	+= davinci_emac.o
+obj-$(CONFIG_TI_DAVINCI_MDIO)	+= davinci_mdio.o
+obj-$(CONFIG_TI_DAVINCI_CPDMA)	+= davinci_cpdma.o
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/ethernet/arm/am79c961a.c
similarity index 100%
rename from drivers/net/arm/am79c961a.c
rename to drivers/net/ethernet/arm/am79c961a.c
diff --git a/drivers/net/arm/am79c961a.h b/drivers/net/ethernet/arm/am79c961a.h
similarity index 100%
rename from drivers/net/arm/am79c961a.h
rename to drivers/net/ethernet/arm/am79c961a.h
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/ethernet/arm/at91_ether.c
similarity index 100%
rename from drivers/net/arm/at91_ether.c
rename to drivers/net/ethernet/arm/at91_ether.c
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/ethernet/arm/at91_ether.h
similarity index 100%
rename from drivers/net/arm/at91_ether.h
rename to drivers/net/ethernet/arm/at91_ether.h
diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/ethernet/arm/davinci_cpdma.c
similarity index 100%
rename from drivers/net/davinci_cpdma.c
rename to drivers/net/ethernet/arm/davinci_cpdma.c
diff --git a/drivers/net/davinci_cpdma.h b/drivers/net/ethernet/arm/davinci_cpdma.h
similarity index 100%
rename from drivers/net/davinci_cpdma.h
rename to drivers/net/ethernet/arm/davinci_cpdma.h
diff --git a/drivers/net/davinci_emac.c b/drivers/net/ethernet/arm/davinci_emac.c
similarity index 100%
rename from drivers/net/davinci_emac.c
rename to drivers/net/ethernet/arm/davinci_emac.c
diff --git a/drivers/net/davinci_mdio.c b/drivers/net/ethernet/arm/davinci_mdio.c
similarity index 100%
rename from drivers/net/davinci_mdio.c
rename to drivers/net/ethernet/arm/davinci_mdio.c
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/ethernet/arm/ep93xx_eth.c
similarity index 100%
rename from drivers/net/arm/ep93xx_eth.c
rename to drivers/net/ethernet/arm/ep93xx_eth.c
diff --git a/drivers/net/arm/ether1.c b/drivers/net/ethernet/arm/ether1.c
similarity index 100%
rename from drivers/net/arm/ether1.c
rename to drivers/net/ethernet/arm/ether1.c
diff --git a/drivers/net/arm/ether1.h b/drivers/net/ethernet/arm/ether1.h
similarity index 100%
rename from drivers/net/arm/ether1.h
rename to drivers/net/ethernet/arm/ether1.h
diff --git a/drivers/net/arm/ether3.c b/drivers/net/ethernet/arm/ether3.c
similarity index 100%
rename from drivers/net/arm/ether3.c
rename to drivers/net/ethernet/arm/ether3.c
diff --git a/drivers/net/arm/ether3.h b/drivers/net/ethernet/arm/ether3.h
similarity index 100%
rename from drivers/net/arm/ether3.h
rename to drivers/net/ethernet/arm/ether3.h
diff --git a/drivers/net/arm/etherh.c b/drivers/net/ethernet/arm/etherh.c
similarity index 100%
rename from drivers/net/arm/etherh.c
rename to drivers/net/ethernet/arm/etherh.c
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/ethernet/arm/ixp4xx_eth.c
similarity index 100%
rename from drivers/net/arm/ixp4xx_eth.c
rename to drivers/net/ethernet/arm/ixp4xx_eth.c
diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/ethernet/arm/ks8695net.c
similarity index 100%
rename from drivers/net/arm/ks8695net.c
rename to drivers/net/ethernet/arm/ks8695net.c
diff --git a/drivers/net/arm/ks8695net.h b/drivers/net/ethernet/arm/ks8695net.h
similarity index 100%
rename from drivers/net/arm/ks8695net.h
rename to drivers/net/ethernet/arm/ks8695net.h
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/ethernet/arm/w90p910_ether.c
similarity index 100%
rename from drivers/net/arm/w90p910_ether.c
rename to drivers/net/ethernet/arm/w90p910_ether.c
-- 
1.7.5.4

