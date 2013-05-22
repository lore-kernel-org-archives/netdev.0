From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2] MIPS: OCTEON: Rename Kconfig CAVIUM_OCTEON_REFERENCE_BOARD to CAVIUM_OCTEON_SOC
Date: Wed, 22 May 2013 09:10:46 -0700
Message-ID: <1369239046-7603-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>, linux-ide@vger.kernel.org,
	linux-edac@vger.kernel.org, linux-i2c@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org
To: linux-mips@linux-mips.org, ralf@linux-mips.org
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

CAVIUM_OCTEON_SOC most place we used to use CPU_CAVIUM_OCTEON.  This
allows us to CPU_CAVIUM_OCTEON in places where we have no OCTEON SOC.

Remove CAVIUM_OCTEON_SIMULATOR as it doesn't really do anything, we can
get the same configuration with CAVIUM_OCTEON_SOC.

Signed-off-by: David Daney <david.daney@cavium.com>
Cc: linux-ide@vger.kernel.org
Cc: linux-edac@vger.kernel.org
Cc: linux-i2c@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: spi-devel-general@lists.sourceforge.net
Cc: devel@driverdev.osuosl.org
Cc: linux-usb@vger.kernel.org
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: Wolfram Sang <wsa@the-dreams.de>
Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>
---
It may make sense to merge this before 3.10 as it touches a ton of
Kconfigs that are more likely to experiance merge problems in a full
merge window.  Also it is only Kconfigery and no 'real' code, so there
are fewer chances of really screwing things up.

Changes from v1: White space fixes and missed conversion of
                 drivers/watchdog/Kconfig as noted by Aaro Koskinen.


 arch/mips/Kconfig                         | 19 ++-----------------
 arch/mips/cavium-octeon/Kconfig           |  6 +++++-
 arch/mips/cavium-octeon/Platform          |  8 ++++----
 arch/mips/configs/cavium_octeon_defconfig |  2 +-
 arch/mips/pci/Makefile                    |  4 ++--
 drivers/ata/Kconfig                       |  2 +-
 drivers/char/hw_random/Kconfig            |  2 +-
 drivers/edac/Kconfig                      |  6 +++---
 drivers/i2c/busses/Kconfig                |  2 +-
 drivers/net/ethernet/octeon/Kconfig       |  2 +-
 drivers/net/phy/Kconfig                   |  2 +-
 drivers/spi/Kconfig                       |  2 +-
 drivers/staging/octeon/Kconfig            |  2 +-
 drivers/usb/host/Kconfig                  |  4 ++--
 drivers/watchdog/Kconfig                  |  2 +-
 15 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 2ae8e1d..baa3fa0 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -737,23 +737,8 @@ config WR_PPMC
 	  This enables support for the Wind River MIPS32 4KC PPMC evaluation
 	  board, which is based on GT64120 bridge chip.
 
-config CAVIUM_OCTEON_SIMULATOR
-	bool "Cavium Networks Octeon Simulator"
-	select CEVT_R4K
-	select 64BIT_PHYS_ADDR
-	select DMA_COHERENT
-	select SYS_SUPPORTS_64BIT_KERNEL
-	select SYS_SUPPORTS_BIG_ENDIAN
-	select SYS_SUPPORTS_HOTPLUG_CPU
-	select SYS_HAS_CPU_CAVIUM_OCTEON
-	select HOLES_IN_ZONE
-	help
-	  The Octeon simulator is software performance model of the Cavium
-	  Octeon Processor. It supports simulating Octeon processors on x86
-	  hardware.
-
-config CAVIUM_OCTEON_REFERENCE_BOARD
-	bool "Cavium Networks Octeon reference board"
+config CAVIUM_OCTEON_SOC
+	bool "Cavium Networks Octeon SoC based boards"
 	select CEVT_R4K
 	select 64BIT_PHYS_ADDR
 	select DMA_COHERENT
diff --git a/arch/mips/cavium-octeon/Kconfig b/arch/mips/cavium-octeon/Kconfig
index 75a6df7..a12444a 100644
--- a/arch/mips/cavium-octeon/Kconfig
+++ b/arch/mips/cavium-octeon/Kconfig
@@ -10,6 +10,10 @@ config CAVIUM_CN63XXP1
 	  non-CN63XXP1 hardware, so it is recommended to select "n"
 	  unless it is known the workarounds are needed.
 
+endif # CPU_CAVIUM_OCTEON
+
+if CAVIUM_OCTEON_SOC
+
 config CAVIUM_OCTEON_2ND_KERNEL
 	bool "Build the kernel to be used as a 2nd kernel on the same chip"
 	default "n"
@@ -103,4 +107,4 @@ config OCTEON_ILM
 	  To compile this driver as a module, choose M here.  The module
 	  will be called octeon-ilm
 
-endif # CPU_CAVIUM_OCTEON
+endif # CAVIUM_OCTEON_SOC
diff --git a/arch/mips/cavium-octeon/Platform b/arch/mips/cavium-octeon/Platform
index 1e43ccf..8a301cb 100644
--- a/arch/mips/cavium-octeon/Platform
+++ b/arch/mips/cavium-octeon/Platform
@@ -1,11 +1,11 @@
 #
 # Cavium Octeon
 #
-platform-$(CONFIG_CPU_CAVIUM_OCTEON)	+= cavium-octeon/
-cflags-$(CONFIG_CPU_CAVIUM_OCTEON)	+=				\
+platform-$(CONFIG_CAVIUM_OCTEON_SOC)	+= cavium-octeon/
+cflags-$(CONFIG_CAVIUM_OCTEON_SOC)	+=				\
 		-I$(srctree)/arch/mips/include/asm/mach-cavium-octeon
 ifdef CONFIG_CAVIUM_OCTEON_2ND_KERNEL
-load-$(CONFIG_CPU_CAVIUM_OCTEON)	+= 0xffffffff84100000
+load-$(CONFIG_CAVIUM_OCTEON_SOC)	+= 0xffffffff84100000
 else
-load-$(CONFIG_CPU_CAVIUM_OCTEON)	+= 0xffffffff81100000
+load-$(CONFIG_CAVIUM_OCTEON_SOC)	+= 0xffffffff81100000
 endif
diff --git a/arch/mips/configs/cavium_octeon_defconfig b/arch/mips/configs/cavium_octeon_defconfig
index 014ba4b..1888e5f 100644
--- a/arch/mips/configs/cavium_octeon_defconfig
+++ b/arch/mips/configs/cavium_octeon_defconfig
@@ -1,4 +1,4 @@
-CONFIG_CAVIUM_OCTEON_REFERENCE_BOARD=y
+CONFIG_CAVIUM_OCTEON_SOC=y
 CONFIG_CAVIUM_CN63XXP1=y
 CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE=2
 CONFIG_SPARSEMEM_MANUAL=y
diff --git a/arch/mips/pci/Makefile b/arch/mips/pci/Makefile
index 2cb1d31..fa3bcd2 100644
--- a/arch/mips/pci/Makefile
+++ b/arch/mips/pci/Makefile
@@ -54,10 +54,10 @@ obj-$(CONFIG_VICTOR_MPC30X)	+= fixup-mpc30x.o
 obj-$(CONFIG_ZAO_CAPCELLA)	+= fixup-capcella.o
 obj-$(CONFIG_WR_PPMC)		+= fixup-wrppmc.o
 obj-$(CONFIG_MIKROTIK_RB532)	+= pci-rc32434.o ops-rc32434.o fixup-rc32434.o
-obj-$(CONFIG_CPU_CAVIUM_OCTEON) += pci-octeon.o pcie-octeon.o
+obj-$(CONFIG_CAVIUM_OCTEON_SOC) += pci-octeon.o pcie-octeon.o
 obj-$(CONFIG_CPU_XLR)		+= pci-xlr.o
 obj-$(CONFIG_CPU_XLP)		+= pci-xlp.o
 
 ifdef CONFIG_PCI_MSI
-obj-$(CONFIG_CPU_CAVIUM_OCTEON) += msi-octeon.o
+obj-$(CONFIG_CAVIUM_OCTEON_SOC) += msi-octeon.o
 endif
diff --git a/drivers/ata/Kconfig b/drivers/ata/Kconfig
index a5a3ebc..dc20774 100644
--- a/drivers/ata/Kconfig
+++ b/drivers/ata/Kconfig
@@ -160,7 +160,7 @@ config PDC_ADMA
 
 config PATA_OCTEON_CF
 	tristate "OCTEON Boot Bus Compact Flash support"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	help
 	  This option enables a polled compact flash driver for use with
 	  compact flash cards attached to the OCTEON boot bus.
diff --git a/drivers/char/hw_random/Kconfig b/drivers/char/hw_random/Kconfig
index 2f9dbf7..40a8654 100644
--- a/drivers/char/hw_random/Kconfig
+++ b/drivers/char/hw_random/Kconfig
@@ -167,7 +167,7 @@ config HW_RANDOM_OMAP
 
 config HW_RANDOM_OCTEON
 	tristate "Octeon Random Number Generator support"
-	depends on HW_RANDOM && CPU_CAVIUM_OCTEON
+	depends on HW_RANDOM && CAVIUM_OCTEON_SOC
 	default HW_RANDOM
 	---help---
 	  This driver provides kernel-side support for the Random Number
diff --git a/drivers/edac/Kconfig b/drivers/edac/Kconfig
index e443f2c1..923d2e8 100644
--- a/drivers/edac/Kconfig
+++ b/drivers/edac/Kconfig
@@ -349,21 +349,21 @@ config EDAC_OCTEON_PC
 
 config EDAC_OCTEON_L2C
 	tristate "Cavium Octeon Secondary Caches (L2C)"
-	depends on EDAC_MM_EDAC && CPU_CAVIUM_OCTEON
+	depends on EDAC_MM_EDAC && CAVIUM_OCTEON_SOC
 	help
 	  Support for error detection and correction on the
 	  Cavium Octeon family of SOCs.
 
 config EDAC_OCTEON_LMC
 	tristate "Cavium Octeon DRAM Memory Controller (LMC)"
-	depends on EDAC_MM_EDAC && CPU_CAVIUM_OCTEON
+	depends on EDAC_MM_EDAC && CAVIUM_OCTEON_SOC
 	help
 	  Support for error detection and correction on the
 	  Cavium Octeon family of SOCs.
 
 config EDAC_OCTEON_PCI
 	tristate "Cavium Octeon PCI Controller"
-	depends on EDAC_MM_EDAC && PCI && CPU_CAVIUM_OCTEON
+	depends on EDAC_MM_EDAC && PCI && CAVIUM_OCTEON_SOC
 	help
 	  Support for error detection and correction on the
 	  Cavium Octeon family of SOCs.
diff --git a/drivers/i2c/busses/Kconfig b/drivers/i2c/busses/Kconfig
index 631736e..a8fff77 100644
--- a/drivers/i2c/busses/Kconfig
+++ b/drivers/i2c/busses/Kconfig
@@ -726,7 +726,7 @@ config I2C_VERSATILE
 
 config I2C_OCTEON
 	tristate "Cavium OCTEON I2C bus support"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	help
 	  Say yes if you want to support the I2C serial bus on Cavium
 	  OCTEON SOC.
diff --git a/drivers/net/ethernet/octeon/Kconfig b/drivers/net/ethernet/octeon/Kconfig
index 3de52ff..a7aa280 100644
--- a/drivers/net/ethernet/octeon/Kconfig
+++ b/drivers/net/ethernet/octeon/Kconfig
@@ -4,7 +4,7 @@
 
 config OCTEON_MGMT_ETHERNET
 	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
-	depends on  CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	select PHYLIB
 	select MDIO_OCTEON
 	default y
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 1e11f2b..84461e8 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -135,7 +135,7 @@ config MDIO_GPIO
 
 config MDIO_OCTEON
 	tristate "Support for MDIO buses on Octeon SOCs"
-	depends on  CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	default y
 	help
 
diff --git a/drivers/spi/Kconfig b/drivers/spi/Kconfig
index 92a9345..2015897 100644
--- a/drivers/spi/Kconfig
+++ b/drivers/spi/Kconfig
@@ -266,7 +266,7 @@ config SPI_OC_TINY
 
 config SPI_OCTEON
 	tristate "Cavium OCTEON SPI controller"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	help
 	  SPI host driver for the hardware found on some Cavium OCTEON
 	  SOCs.
diff --git a/drivers/staging/octeon/Kconfig b/drivers/staging/octeon/Kconfig
index 9493128..6e1d5f8 100644
--- a/drivers/staging/octeon/Kconfig
+++ b/drivers/staging/octeon/Kconfig
@@ -1,6 +1,6 @@
 config OCTEON_ETHERNET
 	tristate "Cavium Networks Octeon Ethernet support"
-	depends on CPU_CAVIUM_OCTEON && NETDEVICES
+	depends on CAVIUM_OCTEON_SOC && NETDEVICES
 	select PHYLIB
 	select MDIO_OCTEON
 	help
diff --git a/drivers/usb/host/Kconfig b/drivers/usb/host/Kconfig
index de94f26..00861ba 100644
--- a/drivers/usb/host/Kconfig
+++ b/drivers/usb/host/Kconfig
@@ -285,7 +285,7 @@ config USB_EHCI_HCD_PLATFORM
 
 config USB_OCTEON_EHCI
 	bool "Octeon on-chip EHCI support"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	default n
 	select USB_EHCI_BIG_ENDIAN_MMIO
 	help
@@ -480,7 +480,7 @@ config USB_OHCI_HCD_PLATFORM
 
 config USB_OCTEON_OHCI
 	bool "Octeon on-chip OHCI support"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	default USB_OCTEON_EHCI
 	select USB_OHCI_BIG_ENDIAN_MMIO
 	select USB_OHCI_LITTLE_ENDIAN
diff --git a/drivers/watchdog/Kconfig b/drivers/watchdog/Kconfig
index e89fc31..9d03af1 100644
--- a/drivers/watchdog/Kconfig
+++ b/drivers/watchdog/Kconfig
@@ -1072,7 +1072,7 @@ config TXX9_WDT
 
 config OCTEON_WDT
 	tristate "Cavium OCTEON SOC family Watchdog Timer"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CAVIUM_OCTEON_SOC
 	default y
 	select EXPORT_UASM if OCTEON_WDT = m
 	help
-- 
1.7.11.7

