From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Subject: [PATCHv2 0/5] Support for Marvell switches with integrated CPUs
Date: Fri,  6 Jan 2017 17:14:57 +1300
Message-ID: <20170106041517.9589-1-chris.packham@alliedtelesis.co.nz>
References: <20170105033641.6212-1-chris.packham@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Geert Uytterhoeven <geert+renesas@glider.be>,
 Michael Turquette <mturquette@baylibre.com>,
 Laxman Dewangan <ldewangan@nvidia.com>, linux-clk@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Juri Lelli <juri.lelli@arm.com>,
 Russell King <linux@armlinux.org.uk>, Thierry Reding <treding@nvidia.com>,
 Linus Walleij <linus.walleij@linaro.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 devicetree@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
 Arnd Bergmann <arnd@arndb.de>,
 Kalyan Kinthada <kalyan.kinthada@alliedtelesis.co.nz>,
 Rob Herring <robh+dt@kernel.org>, Chris Brand <chris.brand@broadcom.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-gpio@vger.kernel.org, netdev@vger.kernel.org,
 Stephen Boyd <sboyd@c
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170105033641.6212-1-chris.packham@alliedtelesis.co.nz>
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

The 98DX3236, 98DX3336 and 98DX4251 are a set of switch ASICs with
integrated CPUs. They CPU block is common within these product lines and
(as far as I can tell/have been told) is based on the Armada XP. There
are a few differences due to the fact they have to squeeze the CPU into
the same package as the switch.

Chris Packham (4):
  clk: mvebu: support for 98DX3236 SoC
    Changes in v2:
    - Update devicetree binding documentation for new compatible string
    Changes in v3:
    - Add 98dx3236 support to mvebu/clk-corediv.c rather than creating a
      new driver.
    - Document mv98dx3236-corediv-clock binding
  arm: mvebu: support for SMP on 98DX3336 SoC
    Changes in v2:
    - Document new enable-method value
    - Correct some references from 98DX4521 to 98DX3236
    Changes in v3:
    - Simplify mv98dx3236_resume_init by using of_io_request_and_map()
  arm: mvebu: Add device tree for 98DX3236 SoCs
    Changes in v2:
    - Update devicetree binding documentation to reflect that 98DX3336 and
      984251 are supersets of 98DX3236.
    - disable crypto block
    - disable sdio for 98DX3236, enable for 98DX4251
    Changes in v3:
    - fix typo 4521 -> 4251
    - document prestera bindings
    - rework corediv-clock binding
    - add label to packet processor node
    - add new compativle string for DFX server
  arm: mvebu: Add device tree for db-dxbc2 and db-xc3-24g4xg boards
    Changes in v2/v3:
    - none

Kalyan Kinthada (1):
  pinctrl: mvebu: pinctrl driver for 98DX3236 SoC
    Changes in v2:
    - include sdio support for the 98DX4251
    Changes in v3:
    - None


 Documentation/devicetree/bindings/arm/cpus.txt     |   1 +
 .../bindings/arm/marvell/98dx3236-resume-ctrl.txt  |  18 ++
 .../devicetree/bindings/arm/marvell/98dx3236.txt   |  23 ++
 .../bindings/clock/mvebu-corediv-clock.txt         |   1 +
 .../devicetree/bindings/clock/mvebu-cpu-clock.txt  |   1 +
 .../devicetree/bindings/net/marvell,prestera.txt   |  50 ++++
 .../pinctrl/marvell,armada-98dx3236-pinctrl.txt    |  46 ++++
 arch/arm/boot/dts/armada-xp-98dx3236.dtsi          | 254 +++++++++++++++++++++
 arch/arm/boot/dts/armada-xp-98dx3336.dtsi          |  76 ++++++
 arch/arm/boot/dts/armada-xp-98dx4251.dtsi          |  90 ++++++++
 arch/arm/boot/dts/db-dxbc2.dts                     | 159 +++++++++++++
 arch/arm/boot/dts/db-xc3-24g4xg.dts                | 155 +++++++++++++
 arch/arm/mach-mvebu/Makefile                       |   1 +
 arch/arm/mach-mvebu/common.h                       |   1 +
 arch/arm/mach-mvebu/platsmp.c                      |  43 ++++
 arch/arm/mach-mvebu/pmsu-98dx3236.c                |  52 +++++
 drivers/clk/mvebu/armada-xp.c                      |  42 ++++
 drivers/clk/mvebu/clk-corediv.c                    |  23 ++
 drivers/clk/mvebu/clk-cpu.c                        |  31 ++-
 drivers/pinctrl/mvebu/pinctrl-armada-xp.c          | 155 +++++++++++++
 20 files changed, 1220 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/98dx3236-resume-ctrl.txt
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/98dx3236.txt
 create mode 100644 Documentation/devicetree/bindings/net/marvell,prestera.txt
 create mode 100644 Documentation/devicetree/bindings/pinctrl/marvell,armada-98dx3236-pinctrl.txt
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx3236.dtsi
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx3336.dtsi
 create mode 100644 arch/arm/boot/dts/armada-xp-98dx4251.dtsi
 create mode 100644 arch/arm/boot/dts/db-dxbc2.dts
 create mode 100644 arch/arm/boot/dts/db-xc3-24g4xg.dts
 create mode 100644 arch/arm/mach-mvebu/pmsu-98dx3236.c

Interdiff to v2:

diff --git
a/Documentation/devicetree/bindings/clock/mvebu-corediv-clock.txt
b/Documentation/devicetree/bindings/clock/mvebu-corediv-clock.txt
index 520562a7dc2a..c7b4e3a6b2c6 100644
--- a/Documentation/devicetree/bindings/clock/mvebu-corediv-clock.txt
+++ b/Documentation/devicetree/bindings/clock/mvebu-corediv-clock.txt
@@ -7,6 +7,7 @@ Required properties:
 - compatible : must be "marvell,armada-370-corediv-clock",
                       "marvell,armada-375-corediv-clock",
                       "marvell,armada-380-corediv-clock",
+                       "marvell,mv98dx3236-corediv-clock",
 
 - reg : must be the register address of Core Divider control register
 - #clock-cells : from common clock binding; shall be set to 1
diff --git a/Documentation/devicetree/bindings/net/marvell,prestera.txt
b/Documentation/devicetree/bindings/net/marvell,prestera.txt
new file mode 100644
index 000000000000..5fbab29718e8
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/marvell,prestera.txt
@@ -0,0 +1,50 @@
+Marvell Prestera Switch Chip bindings
+-------------------------------------
+
+Required properties:
+- compatible: one of the following
+       "marvell,prestera-98dx3236",
+       "marvell,prestera-98dx3336",
+       "marvell,prestera-98dx4251",
+- reg: address and length of the register set for the device.
+- interrupts: interrupt for the device
+
+Optional properties:
+- dfx: phandle reference to the "DFX Server" node
+
+Example:
+
+switch {
+       compatible = "simple-bus";
+       #address-cells = <1>;
+       #size-cells = <1>;
+       ranges = <0 MBUS_ID(0x03, 0x00) 0 0x100000>;
+
+       packet-processor@0 {
+               compatible = "marvell,prestera-98dx3236";
+               reg = <0 0x4000000>;
+               interrupts = <33>, <34>, <35>;
+               dfx = <&dfx>;
+       };
+};
+
+DFX Server bindings
+-------------------
+
+Required properties:
+- compatible: must be "marvell,dfx-server"
+- reg: address and length of the register set for the device.
+
+Example:
+
+dfx-registers {
+       compatible = "simple-bus";
+       #address-cells = <1>;
+       #size-cells = <1>;
+       ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
+
+       dfx: dfx@0 {
+               compatible = "marvell,dfx-server";
+               reg = <0 0x100000>;
+       };
+};
diff --git a/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
index 61bd3acc5cfe..4b7b2fe3b682 100644
--- a/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
+++ b/arch/arm/boot/dts/armada-xp-98dx3236.dtsi
@@ -126,12 +126,7 @@
                        };
 
                        corediv-clock@18740 {
-                               compatible =
                                "marvell,mv98dx3236-corediv-clock";
-                               reg = <0xf8268 0xc>;
-                               base = <&dfx>;
-                               #clock-cells = <1>;
-                               clocks = <&mainpll>;
-                               clock-output-names = "nand";
+                               status = "disabled";
                        };
 
                        xor@60900 {
@@ -194,6 +189,10 @@
                                #interrupt-cells = <2>;
                                interrupts = <87>;
                        };
+
+                       nand: nand@d0000 {
+                               clocks = <&dfx_coredivclk 0>;
+                       };
                };
 
                dfx-registers {
@@ -202,8 +201,16 @@
                        #size-cells = <1>;
                        ranges = <0 MBUS_ID(0x08, 0x00) 0 0x100000>;
 
+                        dfx_coredivclk: corediv-clock@f8268 {
+                                compatible =
"marvell,mv98dx3236-corediv-clock";
+                                reg = <0xf8268 0xc>;
+                                #clock-cells = <1>;
+                                clocks = <&mainpll>;
+                                clock-output-names = "nand";
+                        };
+
                        dfx: dfx@0 {
-                               compatible = "simple-bus";
+                               compatible = "marvell,dfx-server";
                                reg = <0 0x100000>;
                        };
                };
@@ -214,7 +221,7 @@
                        #size-cells = <1>;
                        ranges = <0 MBUS_ID(0x03, 0x00) 0 0x100000>;
 
-                       packet-processor@0 {
+                       pp0: packet-processor@0 {
                                compatible =
"marvell,prestera-98dx3236";
                                reg = <0 0x4000000>;
                                interrupts = <33>, <34>, <35>;
diff --git a/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
b/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
index 9c9aa565fd82..a9b0f47f8df9 100644
--- a/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
+++ b/arch/arm/boot/dts/armada-xp-98dx3336.dtsi
@@ -68,11 +68,9 @@
                                reg = <0x20980 0x10>;
                        };
                };
-
-               switch {
-                       packet-processor@0 {
-                               compatible =
                                "marvell,prestera-98dx3336";
-                       };
-               };
        };
 };
+
+&pp0 {
+       compatible = "marvell,prestera-98dx3336";
+};
diff --git a/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
b/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
index 5f7edc23d5ae..446e6e65ec59 100644
--- a/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
+++ b/arch/arm/boot/dts/armada-xp-98dx4251.dtsi
@@ -68,12 +68,6 @@
                                reg = <0x20980 0x10>;
                        };
                };
-
-               switch {
-                       packet-processor@0 {
-                               compatible =
                                "marvell,prestera-98dx4521";
-                       };
-               };
        };
 };
 
@@ -90,3 +84,7 @@
                marvell,function = "sd0";
        };
 };
+
+&pp0 {
+       compatible = "marvell,prestera-98dx4251";
+};
diff --git a/arch/arm/mach-mvebu/pmsu-98dx3236.c
b/arch/arm/mach-mvebu/pmsu-98dx3236.c
index 87ca42ef40c7..1052674dd439 100644
--- a/arch/arm/mach-mvebu/pmsu-98dx3236.c
+++ b/arch/arm/mach-mvebu/pmsu-98dx3236.c
@@ -31,39 +31,22 @@ void mv98dx3236_resume_set_cpu_boot_addr(int hw_cpu,
void *boot_addr)
 static int __init mv98dx3236_resume_init(void)
 {
        struct device_node *np;
-       struct resource res;
-       int ret = 0;
+       void __iomem *base;
 
        np = of_find_matching_node(NULL, of_mv98dx3236_resume_table);
        if (!np)
                return 0;
 
-       pr_info("Initializing 98DX3236 Resume\n");
-
-       if (of_address_to_resource(np, 0, &res)) {
-               pr_err("unable to get resource\n");
-               ret = -ENOENT;
-               goto out;
-       }
-
-       if (!request_mem_region(res.start, resource_size(&res),
-                               np->full_name)) {
-               pr_err("unable to request region\n");
-               ret = -EBUSY;
-               goto out;
-       }
-
-       mv98dx3236_resume_base = ioremap(res.start,
        resource_size(&res));
-       if (!mv98dx3236_resume_base) {
+       base = of_io_request_and_map(np, 0, of_node_full_name(np));
+       if (IS_ERR(base)) {
                pr_err("unable to map registers\n");
-               release_mem_region(res.start, resource_size(&res));
-               ret = -ENOMEM;
-               goto out;
+               of_node_put(np);
+               return PTR_ERR(mv98dx3236_resume_base);
        }
 
-out:
+       mv98dx3236_resume_base = base;
        of_node_put(np);
-       return ret;
+       return 0;
 }
 
 early_initcall(mv98dx3236_resume_init);
diff --git a/drivers/clk/mvebu/Makefile b/drivers/clk/mvebu/Makefile
index 6a3681e3d6db..d9ae97fb43c4 100644
--- a/drivers/clk/mvebu/Makefile
+++ b/drivers/clk/mvebu/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_ARMADA_39X_CLK)    += armada-39x.o
 obj-$(CONFIG_ARMADA_37XX_CLK)  += armada-37xx-xtal.o
 obj-$(CONFIG_ARMADA_37XX_CLK)  += armada-37xx-tbg.o
 obj-$(CONFIG_ARMADA_37XX_CLK)  += armada-37xx-periph.o
-obj-$(CONFIG_ARMADA_XP_CLK)    += armada-xp.o mv98dx3236-corediv.o
+obj-$(CONFIG_ARMADA_XP_CLK)    += armada-xp.o
 obj-$(CONFIG_ARMADA_AP806_SYSCON) += ap806-system-controller.o
 obj-$(CONFIG_ARMADA_CP110_SYSCON) += cp110-system-controller.o
 obj-$(CONFIG_DOVE_CLK)         += dove.o dove-divider.o
diff --git a/drivers/clk/mvebu/clk-corediv.c
b/drivers/clk/mvebu/clk-corediv.c
index d1e5863d3375..8491979f4096 100644
--- a/drivers/clk/mvebu/clk-corediv.c
+++ b/drivers/clk/mvebu/clk-corediv.c
@@ -71,6 +71,10 @@ static const struct clk_corediv_desc
mvebu_corediv_desc[] = {
        { .mask = 0x3f, .offset = 8, .fieldbit = 1 }, /* NAND clock */
 };
 
+static const struct clk_corediv_desc mv98dx3236_corediv_desc[] = {
+       { .mask = 0x0f, .offset = 6, .fieldbit = 26 }, /* NAND clock */
+};
+
 #define to_corediv_clk(p) container_of(p, struct clk_corediv, hw)
 
 static int clk_corediv_is_enabled(struct clk_hw *hwclk)
@@ -232,6 +236,18 @@ static const struct clk_corediv_soc_desc
armada375_corediv_soc = {
        .ratio_offset = 0x4,
 };
 
+static const struct clk_corediv_soc_desc mv98dx3236_corediv_soc = {
+       .descs = mv98dx3236_corediv_desc,
+       .ndescs = ARRAY_SIZE(mv98dx3236_corediv_desc),
+       .ops = {
+               .recalc_rate = clk_corediv_recalc_rate,
+               .round_rate = clk_corediv_round_rate,
+               .set_rate = clk_corediv_set_rate,
+       },
+       .ratio_reload = BIT(10),
+       .ratio_offset = 0x8,
+};
+
 static void __init
 mvebu_corediv_clk_init(struct device_node *node,
                       const struct clk_corediv_soc_desc *soc_desc)
@@ -313,3 +329,10 @@ static void __init
armada380_corediv_clk_init(struct device_node *node)
 }
 CLK_OF_DECLARE(armada380_corediv_clk,
"marvell,armada-380-corediv-clock",
               armada380_corediv_clk_init);
+
+static void __init mv98dx3236_corediv_clk_init(struct device_node
*node)
+{
+       return mvebu_corediv_clk_init(node, &mv98dx3236_corediv_soc);
+}
+CLK_OF_DECLARE(mv98dx3236_corediv_clk,
"marvell,mv98dx3236-corediv-clock",
+              mv98dx3236_corediv_clk_init);
diff --git a/drivers/clk/mvebu/clk-cpu.c b/drivers/clk/mvebu/clk-cpu.c
index 29f295e7a36b..3b8f0e14fa01 100644
--- a/drivers/clk/mvebu/clk-cpu.c
+++ b/drivers/clk/mvebu/clk-cpu.c
@@ -254,7 +254,7 @@ static void __init of_cpu_clk_setup(struct
device_node *node)
 }
 
 CLK_OF_DECLARE(armada_xp_cpu_clock, "marvell,armada-xp-cpu-clock",
-                                       of_cpu_clk_setup);
+                                        of_cpu_clk_setup);
 
 /* Define the clock and operations for the mv98dx3236 - it cannot
 * perform
  * any operations.
diff --git a/drivers/clk/mvebu/mv98dx3236-corediv.c
b/drivers/clk/mvebu/mv98dx3236-corediv.c
deleted file mode 100644
index 3060764a8e5d..000000000000
--- a/drivers/clk/mvebu/mv98dx3236-corediv.c
+++ /dev/null
@@ -1,207 +0,0 @@
-/*
- * MV98DX3236 Core divider clock
- *
- * Copyright (C) 2015 Allied Telesis Labs
- *
- * Based on armada-xp-corediv.c
- * Copyright (C) 2015 Marvell
- *
- * John Thompson <john.thompson@alliedtelesis.co.nz>
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-#include <linux/kernel.h>
-#include <linux/clk-provider.h>
-#include <linux/of_address.h>
-#include <linux/slab.h>
-#include <linux/delay.h>
-#include "common.h"
-
-#define CORE_CLK_DIV_RATIO_MASK                0xff
-
-#define CLK_DIV_RATIO_NAND_MASK 0x0f
-#define CLK_DIV_RATIO_NAND_OFFSET 6
-#define CLK_DIV_RATIO_NAND_FORCE_RELOAD_BIT 26
-
-#define RATIO_RELOAD_BIT BIT(10)
-#define RATIO_REG_OFFSET 0x08
-
-/*
- * This structure represents one core divider clock for the clock
- * framework, and is dynamically allocated for each core divider clock
- * existing in the current SoC.
- */
-struct clk_corediv {
-       struct clk_hw hw;
-       void __iomem *reg;
-       spinlock_t lock;
-};
-
-static struct clk_onecell_data clk_data;
-
-
-#define to_corediv_clk(p) container_of(p, struct clk_corediv, hw)
-
-static int mv98dx3236_corediv_is_enabled(struct clk_hw *hwclk)
-{
-       /* Core divider is always active */
-       return 1;
-}
-
-static int mv98dx3236_corediv_enable(struct clk_hw *hwclk)
-{
-       /* always succeeds */
-       return 0;
-}
-
-static void mv98dx3236_corediv_disable(struct clk_hw *hwclk)
-{
-       /* can't be disabled so is left alone */
-}
-
-static unsigned long mv98dx3236_corediv_recalc_rate(struct clk_hw
*hwclk,
-                                        unsigned long parent_rate)
-{
-       struct clk_corediv *corediv = to_corediv_clk(hwclk);
-       u32 reg, div;
-
-       reg = readl(corediv->reg + RATIO_REG_OFFSET);
-       div = (reg >> CLK_DIV_RATIO_NAND_OFFSET) &
        CLK_DIV_RATIO_NAND_MASK;
-       return parent_rate / div;
-}
-
-static long mv98dx3236_corediv_round_rate(struct clk_hw *hwclk,
-                              unsigned long rate, unsigned long
                               *parent_rate)
-{
-       /* Valid ratio are 1:4, 1:5, 1:6 and 1:8 */
-       u32 div;
-
-       div = *parent_rate / rate;
-       if (div < 4)
-               div = 4;
-       else if (div > 6)
-               div = 8;
-
-       return *parent_rate / div;
-}
-
-static int mv98dx3236_corediv_set_rate(struct clk_hw *hwclk, unsigned
long rate,
-                           unsigned long parent_rate)
-{
-       struct clk_corediv *corediv = to_corediv_clk(hwclk);
-       unsigned long flags = 0;
-       u32 reg, div;
-
-       div = parent_rate / rate;
-
-       spin_lock_irqsave(&corediv->lock, flags);
-
-       /* Write new divider to the divider ratio register */
-       reg = readl(corediv->reg + RATIO_REG_OFFSET);
-       reg &= ~(CLK_DIV_RATIO_NAND_MASK << CLK_DIV_RATIO_NAND_OFFSET);
-       reg |= (div & CLK_DIV_RATIO_NAND_MASK) <<
        CLK_DIV_RATIO_NAND_OFFSET;
-       writel(reg, corediv->reg + RATIO_REG_OFFSET);
-
-       /* Set reload-force for this clock */
-       reg = readl(corediv->reg) |
        BIT(CLK_DIV_RATIO_NAND_FORCE_RELOAD_BIT);
-       writel(reg, corediv->reg);
-
-       /* Now trigger the clock update */
-       reg = readl(corediv->reg + RATIO_REG_OFFSET) | RATIO_RELOAD_BIT;
-       writel(reg, corediv->reg + RATIO_REG_OFFSET);
-
-       /*
-        * Wait for clocks to settle down, and then clear all the
-        * ratios request and the reload request.
-        */
-       udelay(1000);
-       reg &= ~(CORE_CLK_DIV_RATIO_MASK | RATIO_RELOAD_BIT);
-       writel(reg, corediv->reg + RATIO_REG_OFFSET);
-       udelay(1000);
-
-       spin_unlock_irqrestore(&corediv->lock, flags);
-
-       return 0;
-}
-
-static const struct clk_ops ops = {
-       .enable = mv98dx3236_corediv_enable,
-       .disable = mv98dx3236_corediv_disable,
-       .is_enabled = mv98dx3236_corediv_is_enabled,
-       .recalc_rate = mv98dx3236_corediv_recalc_rate,
-       .round_rate = mv98dx3236_corediv_round_rate,
-       .set_rate = mv98dx3236_corediv_set_rate,
-};
-
-static void __init mv98dx3236_corediv_clk_init(struct device_node
*node)
-{
-       struct clk_init_data init;
-       struct clk_corediv *corediv;
-       struct clk **clks;
-       void __iomem *base;
-       const __be32 *off;
-       const char *parent_name;
-       const char *clk_name;
-       int len;
-       struct device_node *dfx_node;
-
-       dfx_node = of_parse_phandle(node, "base", 0);
-       if (WARN_ON(!dfx_node))
-               return;
-
-       off = of_get_property(node, "reg", &len);
-       if (WARN_ON(!off))
-               return;
-
-       base = of_iomap(dfx_node, 0);
-       if (WARN_ON(!base))
-               return;
-
-       of_node_put(dfx_node);
-
-       parent_name = of_clk_get_parent_name(node, 0);
-
-       clk_data.clk_num = 1;
-
-       /* clks holds the clock array */
-       clks = kcalloc(clk_data.clk_num, sizeof(struct clk *),
-                               GFP_KERNEL);
-       if (WARN_ON(!clks))
-               goto err_unmap;
-       /* corediv holds the clock specific array */
-       corediv = kcalloc(clk_data.clk_num, sizeof(struct clk_corediv),
-                               GFP_KERNEL);
-       if (WARN_ON(!corediv))
-               goto err_free_clks;
-
-       spin_lock_init(&corediv->lock);
-
-       of_property_read_string_index(node, "clock-output-names",
-                                         0, &clk_name);
-
-       init.num_parents = 1;
-       init.parent_names = &parent_name;
-       init.name = clk_name;
-       init.ops = &ops;
-       init.flags = 0;
-
-       corediv[0].reg = (void *)((int)base + be32_to_cpu(*off));
-       corediv[0].hw.init = &init;
-
-       clks[0] = clk_register(NULL, &corediv[0].hw);
-       WARN_ON(IS_ERR(clks[0]));
-
-       clk_data.clks = clks;
-       of_clk_add_provider(node, of_clk_src_onecell_get, &clk_data);
-       return;
-
-err_free_clks:
-       kfree(clks);
-err_unmap:
-       iounmap(base);
-}
-
-CLK_OF_DECLARE(mv98dx3236_corediv_clk,
"marvell,mv98dx3236-corediv-clock",
-              mv98dx3236_corediv_clk_init);


-- 
2.11.0.24.ge6920cf
