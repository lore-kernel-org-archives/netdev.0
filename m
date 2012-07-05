From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH v6 7/7] ARM: davinci: add support for the am1808 based enbw_cmc board
Date: Thu,  5 Jul 2012 14:50:08 +0200
Message-ID: <1341492608-20597-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>,
	Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Sylwester Nawrocki <s.nawrocki-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

- AM1808 based board
- 64 MiB DDR ram
- 2 MiB Nor flash
- 128 MiB NAND flash
- use internal RTC
- I2C support
- hwmon lm75 support
- UBI/UBIFS support
- MMC support
- USB OTG support

Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
Cc: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Cc: Kevin Hilman <khilman-l0cyMroinI0@public.gmane.org>
Cc: Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>
Cc: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: Sylwester Nawrocki <s.nawrocki-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

---
- post this board support with USB support, even though
  USB is only working with the 10 ms "workaround", posted here:
  http://comments.gmane.org/gmane.linux.usb.general/54505
  I see this issue also on the AM1808 TMDXEXP1808L evalboard.
- MMC and USB are not using OF support yet, ideas how to port
  this are welcome. I need for USB and MMC boards board
  specific callbacks, how to solve this with OF support?

- changes for v2:
  - changes in the nand node due to comments from Scott Wood:
    - add "ti,davinci-" prefix
    - Dashes are preferred to underscores
    - rename "nandflash" to "nand"
    - introduce new "ti,davinci" specific properties for setting
      up ecc_mode, ecc_bits, options and bbt options, instead
      using linux defines
  - changes for i2c due to comments from Sylwester Nawrocki:
    - use "cell-index" instead "id"
    - OF_DEV_AUXDATA in the machine code, instead pre-define
      platform device name
  - add comment from Grant Likely for i2c:
    - removed "id" resp. "cell-index" completely
    - fixed documentation
    - use of_match_ptr()
    - use devm_kzalloc() for allocating plattform data mem
    - fixed a whitespace issue
  - add net comments from Grant Likely:
    - add prefix "ti,davinci-" to davinci specific property names
    - remove version property
    - use compatible name "ti,davinci-dm6460-emac"
  - add comment from Grant Likely:
    - rename compatible node
    - do not use cell-index
    - CONFIG_OF required for this board
    TODO:
    - create a generic board support file, as I got no
      answer to my ping to grant, maybe this could be done
      in a second step?
- changes for v3:
  - add comments from Sergei Shtylyov:
    - rename compatible" prop to "ti,cp_intc"
    - cp_intc_init now used for Interrupt controller init
- changes for v4:
  add comment from Nori Sekhar:
  - rename davinci emac compatible property to "ti,davinci-dm6467-emac"
  - remove "pinmux-handle" property as discussed here:
    http://www.spinics.net/lists/arm-kernel/msg175701.html
    with Nori Sekhar

- changes for v5:
  add comments from Grant Likely:
  - rename compatible" prop to "ti,cp-intc"

- changes for v6:
  rework this patch, as patch
  ARM: davinci: cp_intc: Add OF support for TI interrupt controller
  was changed from Nori Sekhar on Jul 03, 2012; 9:16pm
  Changes therefore in this patch:

  Call of_irq_init() in the generic DT board file and not in the
  interrupt controller code. See arch/arm/mach-at91/board-dt.c or
  arch/arm/mach-omap2/board-generic.c for examples.

  At this point the question raises, if we should rename this
  board port from arch/arm/mach-davinci/enbw_cmc.c to
  arch/arm/mach-davinci/board-dt.c ? Also the defconfig to
  davinci_of_defconfig ... ? The USB and MMC callbacks are
  currently board specific, but if other boards come in,
  that could be easily adapted for their needs ...

 arch/arm/boot/dts/enbw_cmc.dts                  |  183 +++++++++++
 arch/arm/configs/enbw_cmc_defconfig             |  126 ++++++++
 arch/arm/mach-davinci/Kconfig                   |    9 +
 arch/arm/mach-davinci/Makefile                  |    1 +
 arch/arm/mach-davinci/board-enbw-cmc.c          |  385 +++++++++++++++++++++++
 arch/arm/mach-davinci/include/mach/uncompress.h |    1 +
 6 files changed, 705 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/boot/dts/enbw_cmc.dts
 create mode 100644 arch/arm/configs/enbw_cmc_defconfig
 create mode 100644 arch/arm/mach-davinci/board-enbw-cmc.c

diff --git a/arch/arm/boot/dts/enbw_cmc.dts b/arch/arm/boot/dts/enbw_cmc.dts
new file mode 100644
index 0000000..32dc7a9
--- /dev/null
+++ b/arch/arm/boot/dts/enbw_cmc.dts
@@ -0,0 +1,183 @@
+/*
+ * Device Tree for the EnBW CMC plattform
+ *
+ * Copyright 2011 DENX Software Engineering GmbH
+ * Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+/dts-v1/;
+/include/ "skeleton.dtsi"
+
+/ {
+	model = "EnBW CMC";
+	compatible = "enbw,cmc";
+
+	aliases {
+		ethernet0 = &eth0;
+	};
+
+	arm {
+		#address-cells = <1>;
+		#size-cells = <1>;
+		ranges = <0 0xfffee000 0x00020000>;
+		intc: interrupt-controller@1 {
+			compatible = "ti,cp-intc";
+			interrupt-controller;
+			#interrupt-cells = <1>;
+			ti,intc-size = <101>;
+			reg = <0x0 0x2000>;
+		};
+	};
+	soc@1c00000 {
+		compatible = "ti,da850";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		ranges = <0x0 0x01c00000 0x400000>;
+
+		serial0: serial@1c42000 {
+			compatible = "ti,da850", "ns16550a";
+			reg = <0x42000 0x100>;
+			clock-frequency = <150000000>;
+			reg-shift = <2>;
+			interrupts = <25>;
+			interrupt-parent = <&intc>;
+		};
+		serial1: serial@1d0c000 {
+			compatible = "ti,da850", "ns16550a";
+			reg = <0x10c000 0x100>;
+			clock-frequency = <150000000>;
+			reg-shift = <2>;
+			interrupts = <53>;
+			interrupt-parent = <&intc>;
+		};
+		serial2: serial@1d0d000 {
+			compatible = "ti,da850", "ns16550a";
+			reg = <0x10d000 0x100>;
+			clock-frequency = <150000000>;
+			reg-shift = <2>;
+			interrupts = <61>;
+			interrupt-parent = <&intc>;
+		};
+
+		eth0: emac@1e20000 {
+			compatible = "ti,davinci-dm6467-emac";
+			reg = <0x220000 0x4000>;
+			ti,davinci-ctrl-reg-offset = <0x3000>;
+			ti,davinci-ctrl-mod-reg-offset = <0x2000>;
+			ti,davinci-ctrl-ram-offset = <0>;
+			ti,davinci-ctrl-ram-size = <0x2000>;
+			local-mac-address = [ 00 00 00 00 00 00 ];
+			interrupts = <33
+					34
+					35
+					36
+					>;
+			interrupt-parent = <&intc>;
+		};
+
+		i2c@1c22000 {
+			compatible = "ti,davinci-i2c";
+			reg = <0x22000 0x1000>;
+			clock-frequency = <100000>;
+			interrupts = <15>;
+			interrupt-parent = <&intc>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			dtt@48 {
+				compatible = "national,lm75";
+				reg = <0x48>;
+			};
+		};
+
+		wdt@1c21000 {
+			compatible = "ti,davinci-wdt";
+			reg = <0x00021000 0x1000>;
+			period = <100>;
+		};
+		bootcount@1c23000 {
+			compatible = "uboot,bootcount";
+			reg = <0x23060 0x20>;
+		};
+
+	};
+	onchipram@8000000 {
+		compatible = "ti,davinci-onchipram";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		ranges = <0x0 0x80000000 0x20000>;
+	};
+	aemif@60000000 {
+		compatible = "ti,davinci-aemif";
+		#address-cells = <2>;
+		#size-cells = <1>;
+		reg = <0x68000000 0x80000>;
+		ranges = <2 0 0x60000000 0x02000000
+			  3 0 0x62000000 0x02000000
+			  4 0 0x64000000 0x02000000
+			  5 0 0x66000000 0x02000000
+			  6 0 0x68000000 0x02000000>;
+		cs2@68000000 {
+			compatible = "ti,davinci-cs";
+			#address-cells = <1>;
+			#size-cells = <1>;
+			/* all timings in nanoseconds */
+			cs = <2>;
+			asize = <1>;
+			ta = <0>;
+			rhold = <7>;
+			rstrobe = <42>;
+			rsetup = <14>;
+			whold = <7>;
+			wstrobe = <42>;
+			wsetup = <14>;
+			ew = <0>;
+			ss = <0>;
+		};
+		flash@2,0 {
+			compatible = "cfi-flash";
+			reg = <2 0x0 0x400000>;
+			#address-cells = <1>;
+			#size-cells = <1>;
+			bank-width = <2>;
+			device-width = <2>;
+		};
+		nand_cs: cs3@68000000 {
+			compatible = "ti,davinci-cs";
+			#address-cells = <1>;
+			#size-cells = <1>;
+			/* all timings in nanoseconds */
+			cs = <3>;
+			asize = <0>;
+			ta = <0>;
+			rhold = <7>;
+			rstrobe = <42>;
+			rsetup = <7>;
+			whold = <7>;
+			wstrobe = <14>;
+			wsetup = <7>;
+			ew = <0>;
+			ss = <0>;
+		};
+		nand@3,0 {
+			compatible = "ti,davinci-nand";
+			reg = <3 0x0 0x807ff
+				6 0x0 0x8000>;
+			#address-cells = <1>;
+			#size-cells = <1>;
+			ti,davinci-chipselect = <1>;
+			ti,davinci-mask-ale = <0>;
+			ti,davinci-mask-cle = <0>;
+			ti,davinci-mask-chipsel = <0>;
+			ti,davinci-ecc-mode = "hw";
+			ti,davinci-ecc-bits = <4>;
+			ti,davinci-nand-use-bbt;
+			timing-handle = <&nand_cs>;
+		};
+
+	};
+};
diff --git a/arch/arm/configs/enbw_cmc_defconfig b/arch/arm/configs/enbw_cmc_defconfig
new file mode 100644
index 0000000..b6b01c2
--- /dev/null
+++ b/arch/arm/configs/enbw_cmc_defconfig
@@ -0,0 +1,126 @@
+CONFIG_EXPERIMENTAL=y
+# CONFIG_SWAP is not set
+CONFIG_SYSVIPC=y
+CONFIG_POSIX_MQUEUE=y
+CONFIG_IKCONFIG=y
+CONFIG_IKCONFIG_PROC=y
+CONFIG_LOG_BUF_SHIFT=14
+CONFIG_BLK_DEV_INITRD=y
+CONFIG_EXPERT=y
+CONFIG_LOGBUFFER=y
+CONFIG_MODULES=y
+CONFIG_MODULE_UNLOAD=y
+CONFIG_MODULE_FORCE_UNLOAD=y
+CONFIG_MODVERSIONS=y
+# CONFIG_BLK_DEV_BSG is not set
+CONFIG_PARTITION_ADVANCED=y
+# CONFIG_IOSCHED_DEADLINE is not set
+# CONFIG_IOSCHED_CFQ is not set
+CONFIG_ARCH_DAVINCI=y
+CONFIG_ARCH_DAVINCI_DA850=y
+# CONFIG_MACH_DAVINCI_DA850_EVM is not set
+CONFIG_GPIO_PCA953X=y
+CONFIG_NO_HZ=y
+CONFIG_HIGH_RES_TIMERS=y
+CONFIG_PREEMPT=y
+CONFIG_AEABI=y
+# CONFIG_OABI_COMPAT is not set
+CONFIG_USE_OF=y
+CONFIG_NET=y
+CONFIG_PACKET=y
+CONFIG_UNIX=y
+CONFIG_INET=y
+CONFIG_IP_PNP=y
+CONFIG_IP_PNP_DHCP=y
+# CONFIG_INET_LRO is not set
+CONFIG_IPV6=y
+CONFIG_NETFILTER=y
+# CONFIG_WIRELESS is not set
+CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
+# CONFIG_FW_LOADER is not set
+CONFIG_MTD=y
+CONFIG_MTD_CMDLINE_PARTS=y
+CONFIG_MTD_CHAR=y
+CONFIG_MTD_BLKDEVS=y
+CONFIG_MTD_CFI=y
+CONFIG_MTD_CFI_INTELEXT=y
+CONFIG_MTD_CFI_AMDSTD=y
+CONFIG_MTD_PHYSMAP=y
+CONFIG_MTD_PHYSMAP_OF=y
+CONFIG_MTD_NAND=y
+CONFIG_MTD_NAND_DAVINCI=y
+CONFIG_MTD_UBI=y
+CONFIG_BLK_DEV_LOOP=y
+CONFIG_BLK_DEV_RAM=y
+CONFIG_BLK_DEV_RAM_COUNT=1
+CONFIG_BLK_DEV_RAM_SIZE=32768
+CONFIG_UBOOT_BOOTCOUNT=y
+CONFIG_EEPROM_AT24=y
+CONFIG_SCSI=y
+CONFIG_BLK_DEV_SD=y
+CONFIG_NETDEVICES=y
+CONFIG_MII=y
+CONFIG_TI_DAVINCI_EMAC=y
+# CONFIG_WLAN is not set
+CONFIG_INPUT_POLLDEV=y
+# CONFIG_INPUT_MOUSEDEV is not set
+CONFIG_INPUT_EVDEV=y
+CONFIG_INPUT_EVBUG=y
+# CONFIG_INPUT_KEYBOARD is not set
+# CONFIG_INPUT_MOUSE is not set
+# CONFIG_SERIO is not set
+# CONFIG_VT is not set
+CONFIG_SERIAL_8250=y
+CONFIG_SERIAL_8250_CONSOLE=y
+CONFIG_SERIAL_8250_NR_UARTS=3
+CONFIG_SERIAL_8250_RUNTIME_UARTS=3
+CONFIG_SERIAL_OF_PLATFORM=y
+CONFIG_HW_RANDOM=y
+CONFIG_I2C=y
+CONFIG_I2C_CHARDEV=y
+CONFIG_I2C_DAVINCI=y
+CONFIG_GPIO_SYSFS=y
+CONFIG_GPIO_PCF857X=y
+CONFIG_SENSORS_LM75=y
+CONFIG_WATCHDOG=y
+CONFIG_WATCHDOG_CORE=y
+CONFIG_WD=y
+CONFIG_DAVINCI_WATCHDOG=y
+# CONFIG_HID_SUPPORT is not set
+CONFIG_USB=y
+CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
+CONFIG_USB_MUSB_HDRC=y
+CONFIG_USB_MUSB_DA8XX=y
+CONFIG_USB_STORAGE=y
+CONFIG_USB_UAS=y
+CONFIG_USB_LIBUSUAL=y
+CONFIG_USB_GADGET=y
+CONFIG_USB_FUSB300=y
+CONFIG_USB_ETH=y
+CONFIG_MMC=y
+CONFIG_MMC_DAVINCI=y
+CONFIG_RTC_CLASS=y
+CONFIG_RTC_DRV_OMAP=y
+CONFIG_EXT2_FS=y
+CONFIG_EXT3_FS=y
+CONFIG_AUTOFS4_FS=y
+CONFIG_MSDOS_FS=y
+CONFIG_VFAT_FS=y
+CONFIG_TMPFS=y
+CONFIG_UBIFS_FS=y
+CONFIG_CRAMFS=y
+CONFIG_NFS_FS=y
+CONFIG_NFS_V3=y
+CONFIG_ROOT_NFS=y
+CONFIG_NLS_CODEPAGE_437=y
+CONFIG_NLS_ASCII=y
+CONFIG_NLS_ISO8859_1=y
+CONFIG_NLS_UTF8=y
+CONFIG_DEBUG_FS=y
+CONFIG_TIMER_STATS=y
+CONFIG_DEBUG_RT_MUTEXES=y
+CONFIG_DEBUG_MUTEXES=y
+# CONFIG_CRYPTO_ANSI_CPRNG is not set
+# CONFIG_CRYPTO_HW is not set
+CONFIG_CRC_CCITT=m
+CONFIG_CRC_T10DIF=m
diff --git a/arch/arm/mach-davinci/Kconfig b/arch/arm/mach-davinci/Kconfig
index 32d837d..4cb0469 100644
--- a/arch/arm/mach-davinci/Kconfig
+++ b/arch/arm/mach-davinci/Kconfig
@@ -202,6 +202,15 @@ config DA850_WL12XX
 	  Say Y if you want to use a wl1271 expansion card connected to the
 	  AM18x EVM.
 
+config MACH_ENBW_CMC
+	bool "EnBW Communication Module Compact"
+	default ARCH_DAVINCI_DA850
+	depends on ARCH_DAVINCI_DA850
+	select OF
+	help
+	  Say Y here to select the EnBW Communication Module Compact
+	  board.
+
 config GPIO_PCA953X
 	default MACH_DAVINCI_DA850_EVM
 
diff --git a/arch/arm/mach-davinci/Makefile b/arch/arm/mach-davinci/Makefile
index 2db78bd..12f3166 100644
--- a/arch/arm/mach-davinci/Makefile
+++ b/arch/arm/mach-davinci/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_MACH_DAVINCI_DA850_EVM)	+= board-da850-evm.o
 obj-$(CONFIG_MACH_TNETV107X)		+= board-tnetv107x-evm.o
 obj-$(CONFIG_MACH_MITYOMAPL138)		+= board-mityomapl138.o
 obj-$(CONFIG_MACH_OMAPL138_HAWKBOARD)	+= board-omapl138-hawk.o
+obj-$(CONFIG_MACH_ENBW_CMC)		+= board-enbw-cmc.o
 
 # Power Management
 obj-$(CONFIG_CPU_FREQ)			+= cpufreq.o
diff --git a/arch/arm/mach-davinci/board-enbw-cmc.c b/arch/arm/mach-davinci/board-enbw-cmc.c
new file mode 100644
index 0000000..b475d6d
--- /dev/null
+++ b/arch/arm/mach-davinci/board-enbw-cmc.c
@@ -0,0 +1,385 @@
+/*
+ * EnBW Communication Module Compact board
+ * Copyright 2011 DENX Software Engineering GmbH
+ * Author: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
+ *
+ * based on:
+ * TI DA850/OMAP-L138 EVM board
+ *
+ * Copyright (C) 2009 Texas Instruments Incorporated - http://www.ti.com/
+ *
+ * Derived from: arch/arm/mach-davinci/board-da850-evm.c
+ * Original Copyrights follow:
+ *
+ * 2007, 2009 (c) MontaVista Software, Inc. This file is licensed under
+ * the terms of the GNU General Public License version 2. This program
+ * is licensed "as is" without any warranty of any kind, whether express
+ * or implied.
+ */
+#include <linux/console.h>
+#include <linux/gpio.h>
+#include <linux/gpio_keys.h>
+#include <linux/i2c.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mtd/mtd.h>
+#include <linux/mtd/nand.h>
+#include <linux/mtd/partitions.h>
+#include <linux/mtd/physmap.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/of_platform.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
+#include <linux/platform_device.h>
+#include <linux/spi/spi.h>
+#include <linux/spi/flash.h>
+#include <asm/mach-types.h>
+#include <asm/mach/arch.h>
+#include <mach/aemif.h>
+#include <mach/cp_intc.h>
+#include <mach/da8xx.h>
+#include <mach/mux.h>
+#include <mach/nand.h>
+#include <mach/spi.h>
+
+#define ENBW_CMC_MMCSD_CD_PIN          GPIO_TO_PIN(3, 13)
+
+/*
+ * USB1 VBUS is controlled by GPIO7[12], over-current is reported on GPIO7[8].
+ */
+#define DA850_USB_VBUS_PIN	GPIO_TO_PIN(7, 12)
+#define ON_BD_USB_OVC		GPIO_TO_PIN(7, 8)
+
+#if defined(CONFIG_USB_OHCI_HCD)
+static irqreturn_t enbw_cmc_usb_ocic_irq(int irq, void *dev_id);
+static da8xx_ocic_handler_t enbw_cmc_usb_ocic_handler;
+
+static int enbw_cmc_usb_set_power(unsigned port, int on)
+{
+	gpio_set_value(DA850_USB_VBUS_PIN, on);
+	return 0;
+}
+
+static int enbw_cmc_usb_get_power(unsigned port)
+{
+	return gpio_get_value(DA850_USB_VBUS_PIN);
+}
+
+static int enbw_cmc_usb_get_oci(unsigned port)
+{
+	return !gpio_get_value(ON_BD_USB_OVC);
+}
+
+static irqreturn_t enbw_cmc_usb_ocic_irq(int, void *);
+
+static int enbw_cmc_usb_ocic_notify(da8xx_ocic_handler_t handler)
+{
+	int irq         = gpio_to_irq(ON_BD_USB_OVC);
+	int error       = 0;
+
+	if (handler != NULL) {
+		enbw_cmc_usb_ocic_handler = handler;
+
+		error = request_irq(irq, enbw_cmc_usb_ocic_irq,
+					IRQF_DISABLED | IRQF_TRIGGER_RISING |
+					IRQF_TRIGGER_FALLING,
+					"OHCI over-current indicator", NULL);
+		if (error)
+			pr_err("%s: could not request IRQ to watch "
+				"over-current indicator changes\n", __func__);
+	} else {
+		free_irq(irq, NULL);
+	}
+	return error;
+}
+
+static struct da8xx_ohci_root_hub enbw_cmc_usb11_pdata = {
+	.set_power      = enbw_cmc_usb_set_power,
+	.get_power      = enbw_cmc_usb_get_power,
+	.get_oci        = enbw_cmc_usb_get_oci,
+	.ocic_notify    = enbw_cmc_usb_ocic_notify,
+	.potpgt         = (10 + 1) / 2,  /* 10 ms max */
+};
+
+static irqreturn_t enbw_cmc_usb_ocic_irq(int irq, void *dev_id)
+{
+	enbw_cmc_usb_ocic_handler(&enbw_cmc_usb11_pdata, 1);
+	return IRQ_HANDLED;
+}
+#endif
+
+static __init void enbw_cmc_usb_init(void)
+{
+	int ret;
+	u32 cfgchip2;
+
+	/* Set up USB clock/mode in the CFGCHIP2 register. */
+	cfgchip2 = __raw_readl(DA8XX_SYSCFG0_VIRT(DA8XX_CFGCHIP2_REG));
+
+	/* USB2.0 PHY reference clock is AUXCLK with 24MHz */
+	cfgchip2 &= ~CFGCHIP2_REFFREQ;
+	cfgchip2 |=  CFGCHIP2_REFFREQ_24MHZ;
+
+	/*
+	 * Select internal reference clock for USB 2.0 PHY
+	 * and use it as a clock source for USB 1.1 PHY
+	 * (this is the default setting anyway).
+	 */
+	cfgchip2 &= ~CFGCHIP2_USB1PHYCLKMUX;
+	cfgchip2 |=  CFGCHIP2_USB2PHYCLKMUX;
+
+	cfgchip2 &= ~CFGCHIP2_OTGMODE;
+	cfgchip2 |=  CFGCHIP2_SESENDEN | CFGCHIP2_VBDTCTEN;
+
+	__raw_writel(cfgchip2, DA8XX_SYSCFG0_VIRT(DA8XX_CFGCHIP2_REG));
+
+	/*
+	 * SP2525A @ 5V supplies 500mA,
+	 * with the power on to power good time of 10 ms.
+	 */
+	ret = da8xx_register_usb20(500, 10);
+	if (ret)
+		pr_warning("%s: USB 2.0 registration failed: %d\n",
+			   __func__, ret);
+
+#if defined(CONFIG_USB_OHCI_HCD)
+	ret = gpio_request_one(DA850_USB_VBUS_PIN,
+			GPIOF_DIR_OUT, "USB 1.1 VBUS");
+	if (ret < 0) {
+		pr_err("%s: failed to request GPIO for USB 1.1 port "
+			"power control: %d\n", __func__, ret);
+		return;
+	}
+	gpio_direction_input(DA850_USB_VBUS_PIN);
+
+	ret = gpio_request(ON_BD_USB_OVC, "ON_BD_USB_OVC");
+	if (ret) {
+		printk(KERN_ERR "%s: failed to request GPIO for USB 1.1 port "
+		       "over-current indicator: %d\n", __func__, ret);
+		gpio_free(DA850_USB_VBUS_PIN);
+		return;
+	}
+	gpio_direction_input(ON_BD_USB_OVC);
+
+	ret = da8xx_register_usb11(&enbw_cmc_usb11_pdata);
+	if (ret) {
+		pr_warning("%s: USB 1.1 registration failed: %d\n",
+			   __func__, ret);
+		gpio_free(ON_BD_USB_OVC);
+		gpio_free(DA850_USB_VBUS_PIN);
+	}
+#endif
+
+	return;
+}
+
+static int enbw_cmc_mmc_get_ro(int index)
+{
+	return 0;
+}
+
+static int enbw_cmc_mmc_get_cd(int index)
+{
+	return gpio_get_value(ENBW_CMC_MMCSD_CD_PIN) ? 1 : 0;
+}
+
+static struct davinci_mmc_config enbw_cmc_mmc_config = {
+	.get_ro		= enbw_cmc_mmc_get_ro,
+	.get_cd		= enbw_cmc_mmc_get_cd,
+	.wires		= 4,
+	.max_freq	= 50000000,
+	.caps		= MMC_CAP_MMC_HIGHSPEED | MMC_CAP_SD_HIGHSPEED,
+	.version	= MMC_CTLR_VERSION_2,
+};
+
+static int __init enbw_cmc_config_emac(void)
+{
+	void __iomem *cfg_chip3_base;
+	u32 val;
+	struct davinci_soc_info *soc_info = &davinci_soc_info;
+
+	if (!machine_is_enbw_cmc())
+		return 0;
+
+	cfg_chip3_base = DA8XX_SYSCFG0_VIRT(DA8XX_CFGCHIP3_REG);
+	val = __raw_readl(cfg_chip3_base);
+	val &= ~BIT(8);
+	pr_info("EMAC: MII PHY configured, RMII PHY will not be"
+						" functional\n");
+
+	/* configure the CFGCHIP3 register for MII */
+	__raw_writel(val, cfg_chip3_base);
+
+	/* use complete info from OF */
+	soc_info->emac_pdata = NULL;
+
+	return 0;
+}
+device_initcall(enbw_cmc_config_emac);
+
+static const s16 da850_dma0_rsv_chans[][2] = {
+	/* (offset, number) */
+	{-1, -1}
+};
+
+static const s16 da850_dma0_rsv_slots[][2] = {
+	/* (offset, number) */
+	{-1, -1}
+};
+
+static const s16 da850_dma1_rsv_chans[][2] = {
+	/* (offset, number) */
+	{-1, -1}
+};
+
+static const s16 da850_dma1_rsv_slots[][2] = {
+	/* (offset, number) */
+	{-1, -1}
+};
+
+static struct edma_rsv_info da850_edma_cc0_rsv = {
+	.rsv_chans	= da850_dma0_rsv_chans,
+	.rsv_slots	= da850_dma0_rsv_slots,
+};
+
+static struct edma_rsv_info da850_edma_cc1_rsv = {
+	.rsv_chans	= da850_dma1_rsv_chans,
+	.rsv_slots	= da850_dma1_rsv_slots,
+};
+
+static struct edma_rsv_info *da850_edma_rsv[2] = {
+	&da850_edma_cc0_rsv,
+	&da850_edma_cc1_rsv,
+};
+
+#ifdef CONFIG_CPU_FREQ
+static __init int da850_evm_init_cpufreq(void)
+{
+	switch (system_rev & 0xF) {
+	case 3:
+		da850_max_speed = 456000;
+		break;
+	case 2:
+		da850_max_speed = 408000;
+		break;
+	case 1:
+		da850_max_speed = 372000;
+		break;
+	}
+
+	return da850_register_cpufreq("pll0_sysclk3");
+}
+#else
+static __init int da850_evm_init_cpufreq(void) { return 0; }
+#endif
+
+struct of_dev_auxdata enbw_cmc_auxdata_lookup[] __initdata = {
+	OF_DEV_AUXDATA("ti,davinci-wdt", 0x01c21000, "ti,davinci-wdt", NULL),
+	OF_DEV_AUXDATA("ti,davinci-i2c", 0x01c22000, "i2c_davinci.1", NULL),
+	OF_DEV_AUXDATA("ti,davinci-i2c", 0x01e28000, "i2c_davinci.2", NULL),
+	OF_DEV_AUXDATA("ti,davinci-dm6467-emac", 0x01e20000, "davinci_emac.1",
+			NULL),
+	{}
+};
+
+const struct of_device_id enbw_cmc_bus_match_table[] = {
+	{ .compatible = "simple-bus", },
+	{ .compatible = "ti,da850", },
+	{ .compatible = "ti,davinci-onchipram", },
+	{ .compatible = "ti,davinci-aemif", },
+	{} /* Empty terminated list */
+};
+
+static __init void enbw_cmc_init(void)
+{
+	int ret;
+
+	of_platform_populate(NULL, enbw_cmc_bus_match_table,
+		enbw_cmc_auxdata_lookup, NULL);
+
+	ret = da8xx_register_watchdog();
+	if (ret)
+		pr_warning("enbw_cmc_init: watchdog registration failed: %d\n",
+				ret);
+
+	ret = da850_register_edma(da850_edma_rsv);
+	if (ret)
+		pr_warning("enbw_cmc_init: edma registration failed: %d\n",
+				ret);
+
+	/*
+	 * shut down uart 0 this port is not used on the board
+	 */
+	__raw_writel(0, IO_ADDRESS(DA8XX_UART0_BASE) + 0x30);
+
+	ret = da8xx_register_rtc();
+	if (ret)
+		pr_warning("enbw_cmc_init: rtc setup failed: %d\n", ret);
+
+	ret = da850_evm_init_cpufreq();
+	if (ret)
+		pr_warning("enbw_cmc_init: cpufreq registration failed: %d\n",
+				ret);
+
+	ret = da8xx_register_cpuidle();
+	if (ret)
+		pr_warning("enbw_cmc_init: cpuidle registration failed: %d\n",
+				ret);
+
+	ret = gpio_request(ENBW_CMC_MMCSD_CD_PIN, "MMC CD\n");
+	if (ret)
+		pr_warning("enbw_cmc_init: can not open GPIO %d\n",
+				ENBW_CMC_MMCSD_CD_PIN);
+	gpio_direction_input(ENBW_CMC_MMCSD_CD_PIN);
+
+	ret = da850_register_mmcsd1(&enbw_cmc_mmc_config);
+	if (ret)
+		pr_warning("enbw_cmc_init: mmcsd1 registration failed:"
+				" %d\n", ret);
+
+	enbw_cmc_usb_init();
+}
+
+#ifdef CONFIG_SERIAL_8250_CONSOLE
+static int __init enbw_cmc_console_init(void)
+{
+	if (!machine_is_enbw_cmc())
+		return 0;
+
+	return add_preferred_console("ttyS", 2, "115200");
+}
+console_initcall(enbw_cmc_console_init);
+#endif
+
+static void __init enbw_cmc_map_io(void)
+{
+	da850_init();
+}
+
+static const char *enbw_cmc_board_compat[] __initconst = {
+	"enbw,cmc",
+	NULL
+};
+
+static struct of_device_id irq_of_match[] __initdata = {
+	{ .compatible = "ti,cp-intc", .data = cp_intc_of_init, },
+	{ }
+};
+
+static void __init cp_dt_init_irq(void)
+{
+	of_irq_init(irq_of_match);
+}
+
+MACHINE_START(ENBW_CMC, "EnBW CMC")
+	.map_io		= enbw_cmc_map_io,
+	.init_irq	= cp_dt_init_irq,
+	.timer		= &davinci_timer,
+	.init_machine	= enbw_cmc_init,
+	.dt_compat	= enbw_cmc_board_compat,
+	.dma_zone_size	= SZ_128M,
+	.restart	= da8xx_restart,
+MACHINE_END
diff --git a/arch/arm/mach-davinci/include/mach/uncompress.h b/arch/arm/mach-davinci/include/mach/uncompress.h
index da2fb2c..6119543 100644
--- a/arch/arm/mach-davinci/include/mach/uncompress.h
+++ b/arch/arm/mach-davinci/include/mach/uncompress.h
@@ -98,6 +98,7 @@ static inline void __arch_decomp_setup(unsigned long arch_id)
 		DEBUG_LL_DA8XX(davinci_da850_evm,	2);
 		DEBUG_LL_DA8XX(mityomapl138,		1);
 		DEBUG_LL_DA8XX(omapl138_hawkboard,	2);
+		DEBUG_LL_DA8XX(enbw_cmc,		2);
 
 		/* TNETV107x boards */
 		DEBUG_LL_TNETV107X(tnetv107x,		1);
-- 
1.7.7.6
