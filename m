From: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] ARM: mx5: add basic device tree support for imx51 babbage
Date: Sat, 18 Jun 2011 23:19:14 +0800
Message-ID: <1308410354-21387-4-git-send-email-shawn.guo@linaro.org>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1308410354-21387-1-git-send-email-shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the i.mx51 dt platform with uart and fec support.
It also adds the dts file imx51 babbage, so that we can have a dt
kernel on babbage booting into console with nfs root.

Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 arch/arm/boot/dts/imx51-babbage.dts |   89 +++++++++++++++++++++++++++++++++++
 arch/arm/mach-mx5/Kconfig           |    8 +++
 arch/arm/mach-mx5/Makefile          |    1 +
 arch/arm/mach-mx5/imx51-dt.c        |   70 +++++++++++++++++++++++++++
 4 files changed, 168 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/boot/dts/imx51-babbage.dts
 create mode 100644 arch/arm/mach-mx5/imx51-dt.c

diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/imx51-babbage.dts
new file mode 100644
index 0000000..7976932
--- /dev/null
+++ b/arch/arm/boot/dts/imx51-babbage.dts
@@ -0,0 +1,89 @@
+/*
+ * Copyright 2011 Freescale Semiconductor, Inc.
+ * Copyright 2011 Linaro Ltd.
+ *
+ * The code contained herein is licensed under the GNU General Public
+ * License. You may obtain a copy of the GNU General Public License
+ * Version 2 or later at the following locations:
+ *
+ * http://www.opensource.org/licenses/gpl-license.html
+ * http://www.gnu.org/copyleft/gpl.html
+ */
+
+/dts-v1/;
+/include/ "skeleton.dtsi"
+
+/ {
+	model = "Freescale i.MX51 Babbage";
+	compatible = "fsl,imx51-babbage", "fsl,imx51";
+	interrupt-parent = <&tzic>;
+
+	chosen {
+		bootargs = "console=ttymxc0,115200 root=/dev/mmcblk0p3 rootwait";
+	};
+
+	memory {
+		reg = <0x90000000 0x20000000>;
+	};
+
+	tzic: tz-interrupt-controller@e0000000 {
+		compatible = "fsl,imx51-tzic", "fsl,tzic";
+		interrupt-controller;
+		#interrupt-cells = <1>;
+		reg = <0xe0000000 0x4000>;
+	};
+
+	aips@70000000 { /* aips-1 */
+		compatible = "fsl,aips-bus", "simple-bus";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		reg = <0x70000000 0x10000000>;
+		ranges;
+
+		spba {
+			compatible = "fsl,spba-bus", "simple-bus";
+			#address-cells = <1>;
+			#size-cells = <1>;
+			reg = <0x70000000 0x40000>;
+			ranges;
+
+			uart@7000c000 {
+				compatible = "fsl,imx51-uart", "fsl,imx-uart";
+				reg = <0x7000c000 0x4000>;
+				interrupts = <33>;
+				id = <3>;
+				fsl,has-rts-cts;
+			};
+		};
+
+		uart@73fbc000 {
+			compatible = "fsl,imx51-uart", "fsl,imx-uart";
+			reg = <0x73fbc000 0x4000>;
+			interrupts = <31>;
+			id = <1>;
+			fsl,has-rts-cts;
+		};
+
+		uart@73fc0000 {
+			compatible = "fsl,imx51-uart", "fsl,imx-uart";
+			reg = <0x73fc0000 0x4000>;
+			interrupts = <32>;
+			id = <2>;
+			fsl,has-rts-cts;
+		};
+	};
+
+	aips@80000000 {	/* aips-2 */
+		compatible = "fsl,aips-bus", "simple-bus";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		reg = <0x80000000 0x10000000>;
+		ranges;
+
+		fec@83fec000 {
+			compatible = "fsl,imx51-fec", "fsl,fec";
+			reg = <0x83fec000 0x4000>;
+			interrupts = <87>;
+		};
+	};
+};
diff --git a/arch/arm/mach-mx5/Kconfig b/arch/arm/mach-mx5/Kconfig
index 799fbc4..8bdd0c4 100644
--- a/arch/arm/mach-mx5/Kconfig
+++ b/arch/arm/mach-mx5/Kconfig
@@ -62,6 +62,14 @@ endif # ARCH_MX50_SUPPORTED
 if ARCH_MX51
 comment "i.MX51 machines:"
 
+config MACH_IMX51_DT
+	bool "Support i.MX51 platforms from device tree"
+	select SOC_IMX51
+	select USE_OF
+	help
+	  Include support for Freescale i.MX51 based platforms
+	  using the device tree for discovery
+
 config MACH_MX51_BABBAGE
 	bool "Support MX51 BABBAGE platforms"
 	select SOC_IMX51
diff --git a/arch/arm/mach-mx5/Makefile b/arch/arm/mach-mx5/Makefile
index 0b9338c..47b483f 100644
--- a/arch/arm/mach-mx5/Makefile
+++ b/arch/arm/mach-mx5/Makefile
@@ -7,6 +7,7 @@ obj-y   := cpu.o mm.o clock-mx51-mx53.o devices.o ehci.o system.o
 obj-$(CONFIG_SOC_IMX50) += mm-mx50.o
 
 obj-$(CONFIG_CPU_FREQ_IMX)    += cpu_op-mx51.o
+obj-$(CONFIG_MACH_IMX51_DT) += imx51-dt.o
 obj-$(CONFIG_MACH_MX51_BABBAGE) += board-mx51_babbage.o
 obj-$(CONFIG_MACH_MX51_3DS) += board-mx51_3ds.o
 obj-$(CONFIG_MACH_MX53_EVK) += board-mx53_evk.o
diff --git a/arch/arm/mach-mx5/imx51-dt.c b/arch/arm/mach-mx5/imx51-dt.c
new file mode 100644
index 0000000..8bfdb91
--- /dev/null
+++ b/arch/arm/mach-mx5/imx51-dt.c
@@ -0,0 +1,70 @@
+/*
+ * Copyright 2011 Freescale Semiconductor, Inc. All Rights Reserved.
+ * Copyright 2011 Linaro Ltd.
+ *
+ * The code contained herein is licensed under the GNU General Public
+ * License. You may obtain a copy of the GNU General Public License
+ * Version 2 or later at the following locations:
+ *
+ * http://www.opensource.org/licenses/gpl-license.html
+ * http://www.gnu.org/copyleft/gpl.html
+ */
+
+#include <linux/irq.h>
+#include <linux/of_platform.h>
+
+#include <asm/mach/arch.h>
+#include <asm/mach/time.h>
+
+#include <mach/common.h>
+#include <mach/mx51.h>
+
+/*
+ * Lookup table for attaching a specific name and platform_data pointer to
+ * devices as they get created by of_platform_populate().  Ideally this table
+ * would not exist, but the current clock implementation depends on some devices
+ * having a specific name.
+ */
+static const struct of_dev_auxdata imx51_auxdata_lookup[] __initconst = {
+	OF_DEV_AUXDATA("fsl,imx51-uart", MX51_UART1_BASE_ADDR, "imx-uart.0", NULL),
+	OF_DEV_AUXDATA("fsl,imx51-uart", MX51_UART2_BASE_ADDR, "imx-uart.1", NULL),
+	OF_DEV_AUXDATA("fsl,imx51-uart", MX51_UART3_BASE_ADDR, "imx-uart.2", NULL),
+	OF_DEV_AUXDATA("fsl,imx51-fec", MX51_FEC_BASE_ADDR, "fec.0", NULL),
+	{}
+};
+
+static const struct of_device_id tzic_of_match[] __initconst = {
+	{ .compatible = "fsl,imx51-tzic", },
+	{}
+};
+
+static void __init imx51_dt_init(void)
+{
+	irq_domain_generate_simple(tzic_of_match, MX51_TZIC_BASE_ADDR, 0);
+
+	of_platform_populate(NULL, of_default_bus_match_table,
+			     imx51_auxdata_lookup, NULL);
+}
+
+static void __init imx51_timer_init(void)
+{
+	mx51_clocks_init(32768, 24000000, 22579200, 0);
+}
+
+static struct sys_timer imx51_timer = {
+	.init = imx51_timer_init,
+};
+
+static const char *imx51_dt_board_compat[] __initdata = {
+	"fsl,imx51-babbage",
+	NULL
+};
+
+DT_MACHINE_START(IMX51_DT, "Freescale i.MX51 (Device Tree Support)")
+	.map_io		= mx51_map_io,
+	.init_early	= imx51_init_early,
+	.init_irq	= mx51_init_irq,
+	.timer		= &imx51_timer,
+	.init_machine	= imx51_dt_init,
+	.dt_compat	= imx51_dt_board_compat,
+MACHINE_END
-- 
1.7.4.1
