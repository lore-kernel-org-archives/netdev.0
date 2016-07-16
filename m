From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 06/10] arm: orion5x: Add DT-based support for Netgear
 WNR854T
Date: Sat, 16 Jul 2016 15:29:04 +0100
Message-ID: <1468679348-10522-7-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This is a router based on the mv88f5181 chipset.

http://www.netgear.com/support/product/WNR854T.aspx
http://wiki.openwrt.org/toh/netgear/wnr854t

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 .../bindings/arm/marvell/marvell,orion5x.txt       |   1 +
 arch/arm/boot/dts/Makefile                         |   1 +
 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts      | 200 +++++++++++++++++++++
 arch/arm/mach-orion5x/Kconfig                      |   6 +
 arch/arm/mach-orion5x/Makefile                     |   1 +
 arch/arm/mach-orion5x/board-wnr854t.c              |  78 ++++++++
 6 files changed, 287 insertions(+)
 create mode 100644 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
 create mode 100644 arch/arm/mach-orion5x/board-wnr854t.c

diff --git a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
index ff3c120..748a8f2 100644
--- a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
+++ b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
@@ -22,3 +22,4 @@ board. Currently known boards are:
 "lacie,d2-network"
 "marvell,rd-88f5182-nas"
 "maxtor,shared-storage-2"
+"netgear,wnr854t"
diff --git a/arch/arm/boot/dts/Makefile b/arch/arm/boot/dts/Makefile
index 95c1923..63b9202 100644
--- a/arch/arm/boot/dts/Makefile
+++ b/arch/arm/boot/dts/Makefile
@@ -535,6 +535,7 @@ dtb-$(CONFIG_ARCH_ORION5X) += \
 	orion5x-linkstation-lswtgl.dtb \
 	orion5x-lswsgl.dtb \
 	orion5x-maxtor-shared-storage-2.dtb \
+	orion5x-netgear-wnr854t.dtb \
 	orion5x-rd88f5182-nas.dtb
 dtb-$(CONFIG_ARCH_PRIMA2) += \
 	prima2-evb.dtb
diff --git a/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
new file mode 100644
index 0000000..a8e89d8
--- /dev/null
+++ b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
@@ -0,0 +1,200 @@
+/*
+ * Copyright (C) 2014 Jamie Lentin <jm@lentin.co.uk>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+/dts-v1/;
+
+#include <dt-bindings/gpio/gpio.h>
+#include <dt-bindings/input/input.h>
+#include "orion5x-mv88f5181.dtsi"
+
+/ {
+	model = "Netgear WNR854-t";
+	compatible = "netgear,wnr854t", "marvell,orion5x-88f5181",
+			"marvell,orion5x";
+
+	memory {
+		reg = <0x00000000 0x2000000>; /* 32 MB */
+	};
+
+	chosen {
+		bootargs = "console=ttyS0,115200n8 earlyprintk";
+		linux,stdout-path = &uart0;
+	};
+
+	soc {
+		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000>,
+			<MBUS_ID(0x09, 0x00) 0 0xf2200000 0x800>,
+			<MBUS_ID(0x01, 0x0f) 0 0xf4000000 0x800000>;
+	};
+
+	gpio-keys {
+		compatible = "gpio-keys";
+		pinctrl-0 = <&pmx_reset_switch>;
+		pinctrl-names = "default";
+
+		reset {
+			label = "Reset Button";
+			linux,code = <KEY_RESTART>;
+			gpios = <&gpio0 1 GPIO_ACTIVE_LOW>;
+		};
+	};
+
+	gpio-leds {
+		compatible = "gpio-leds";
+		pinctrl-0 = <&pmx_power_led &pmx_power_led_blink &pmx_wan_led>;
+		pinctrl-names = "default";
+
+		led@0 {
+			label = "power:green";
+			gpios = <&gpio0 0 GPIO_ACTIVE_LOW>;
+		};
+
+		led@1 {
+			label = "power:blink";
+			gpios = <&gpio0 2 GPIO_ACTIVE_LOW>;
+		};
+
+		led@2 {
+			label = "wan:green";
+			gpios = <&gpio0 3 GPIO_ACTIVE_LOW>;
+		};
+	};
+
+	dsa@0 {
+		compatible = "marvell,dsa";
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		dsa,ethernet = <&ethport>;
+		dsa,mii-bus = <&mdio>;
+
+		switch@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
+
+			port@0 {
+				reg = <0>;
+				label = "lan3";
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan4";
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "wan";
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "cpu";
+			};
+
+			port@5 {
+				reg = <5>;
+				label = "lan1";
+			};
+
+			port@7 {
+				reg = <7>;
+				label = "lan2";
+			};
+		};
+	};
+};
+
+&devbus_bootcs {
+	status = "okay";
+
+	devbus,keep-config;
+
+	flash@0 {
+		compatible = "cfi-flash";
+		reg = <0 0x800000>;
+		bank-width = <1>;
+		#address-cells = <1>;
+		#size-cells = <1>;
+
+		partition@0 {
+			label = "kernel";
+			reg = <0x0 0x100000>;
+		};
+
+		partition@100000 {
+			label = "rootfs";
+			reg = <0x100000 0x660000>;
+		};
+
+		partition@760000 {
+			label = "uboot_env";
+			reg = <0x760000 0x20000>;
+		};
+
+		partition@780000 {
+			label = "uboot";
+			reg = <0x780000 0x80000>;
+			read-only;
+		};
+	};
+};
+
+&mdio {
+	status = "okay";
+};
+
+&eth {
+	status = "okay";
+	ethernet-port@0 {
+		speed = <1000>;
+		duplex = <1>;
+	};
+};
+
+&pinctrl {
+	pinctrl-0 = <&pmx_pci_gpios &pmx_ge>;
+	pinctrl-names = "default";
+
+	pmx_power_led: pmx-power-led {
+		marvell,pins = "mpp0";
+		marvell,function = "gpio";
+	};
+
+	pmx_reset_switch: pmx-reset-switch {
+		marvell,pins = "mpp1";
+		marvell,function = "gpio";
+	};
+
+	pmx_power_led_blink: pmx-power-led-blink {
+		marvell,pins = "mpp2";
+		marvell,function = "gpio";
+	};
+
+	pmx_wan_led: pmx-wan-led {
+		marvell,pins = "mpp3";
+		marvell,function = "gpio";
+	};
+
+	pmx_pci_gpios: pmx-pci-gpios {
+		marvell,pins = "mpp4";
+		marvell,function = "gpio";
+	};
+
+	pmx_ge: pmx-ge {
+		marvell,pins = "mpp9", "mpp12",	"mpp13", "mpp14", "mpp15",
+				"mpp16", "mpp17", "mpp18", "mpp19";
+		marvell,function = "ge";
+	};
+};
+
+&uart0 {
+	/* Pin 1: Tx, Pin 7: Rx, Pin 8: Gnd */
+	status = "okay";
+};
diff --git a/arch/arm/mach-orion5x/Kconfig b/arch/arm/mach-orion5x/Kconfig
index a2af158..1fdb95d 100644
--- a/arch/arm/mach-orion5x/Kconfig
+++ b/arch/arm/mach-orion5x/Kconfig
@@ -151,6 +151,12 @@ config MACH_MSS2_DT
 	  Say 'Y' here if you want your kernel to support the
 	  Maxtor Shared Storage II platform.
 
+config MACH_WNR854T_DT
+	bool "Netgear WNR854T (Flattened Device Tree)"
+	help
+	  Say 'Y' here if you want your kernel to support the
+	  Netgear WNR854T platform.
+
 config MACH_WNR854T
 	bool "Netgear WNR854T"
 	help
diff --git a/arch/arm/mach-orion5x/Makefile b/arch/arm/mach-orion5x/Makefile
index 4b2502b..9dff2d3 100644
--- a/arch/arm/mach-orion5x/Makefile
+++ b/arch/arm/mach-orion5x/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_ARCH_ORION5X_DT)		+= board-dt.o
 obj-$(CONFIG_MACH_D2NET_DT)	+= board-d2net.o
 obj-$(CONFIG_MACH_MSS2_DT)	+= board-mss2.o
 obj-$(CONFIG_MACH_RD88F5182_DT)	+= board-rd88f5182.o
+obj-$(CONFIG_MACH_WNR854T_DT)	+= board-wnr854t.o
diff --git a/arch/arm/mach-orion5x/board-wnr854t.c b/arch/arm/mach-orion5x/board-wnr854t.c
new file mode 100644
index 0000000..c506e33
--- /dev/null
+++ b/arch/arm/mach-orion5x/board-wnr854t.c
@@ -0,0 +1,78 @@
+/*
+ * Netgear WNR854T PCI setup
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2.  This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+#include <linux/gpio.h>
+#include <linux/platform_device.h>
+#include <linux/pci.h>
+#include <asm/mach/pci.h>
+#include "common.h"
+#include "orion5x.h"
+
+#define WNR854T_PCI_SLOT0_OFFS	7
+#define WNR854T_PCI_SLOT0_IRQ_PIN	4
+
+static void __init wnr854t_pci_preinit(void)
+{
+	int pin;
+
+	/*
+	 * Configure PCI GPIO IRQ pins
+	 */
+	pin = WNR854T_PCI_SLOT0_IRQ_PIN;
+	if (gpio_request(pin, "PCI Int") == 0) {
+		if (gpio_direction_input(pin) == 0) {
+			irq_set_irq_type(gpio_to_irq(pin), IRQ_TYPE_LEVEL_LOW);
+		} else {
+			pr_err("wnr854t_pci_preinit failed to set_irq_type pin %d\n",
+				pin);
+			gpio_free(pin);
+		}
+	} else {
+		pr_err("wnr854t_pci_preinit failed to request gpio %d\n", pin);
+	}
+}
+
+static int __init wnr854t_pci_map_irq(const struct pci_dev *dev, u8 slot,
+	u8 pin)
+{
+	int irq;
+
+	/*
+	 * Check for devices with hard-wired IRQs.
+	 */
+	irq = orion5x_pci_map_irq(dev, slot, pin);
+	if (irq != -1)
+		return irq;
+
+	/*
+	 * PCI IRQs are connected via GPIOs
+	 */
+	switch (slot - WNR854T_PCI_SLOT0_OFFS) {
+	case 0:
+		return gpio_to_irq(WNR854T_PCI_SLOT0_IRQ_PIN);
+	default:
+		return -1;
+	}
+}
+
+static struct hw_pci wnr854t_pci __initdata = {
+	.nr_controllers	= 2,
+	.preinit	= wnr854t_pci_preinit,
+	.setup		= orion5x_pci_sys_setup,
+	.scan		= orion5x_pci_sys_scan_bus,
+	.map_irq	= wnr854t_pci_map_irq,
+};
+
+static int __init wnr854t_pci_init(void)
+{
+	if (of_machine_is_compatible("netgear,wnr854t"))
+		pci_common_init(&wnr854t_pci);
+
+	return 0;
+}
+/* NB: Use late_initcall so we can gpio_request() without being deferred */
+late_initcall(wnr854t_pci_init);
-- 
2.8.1
