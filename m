From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v2 9/9] ARM: dts: rockchip: add support emac for RK3036
Date: Sun, 13 Mar 2016 17:07:42 +0800
Message-ID: <1457860062-5514-10-git-send-email-wxt@rock-chips.com>
References: <1457860062-5514-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
 zhengxing <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1457860062-5514-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: zhengxing <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

This patch adds the emac device node for rk3036.
We need to let mac clock under the DPLL which is able to provide
the accurate 50MHz what mac_ref need, since that will cause some
unstable things if the cpufreq is working.

Signed-off-by: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

---

Changes in v2: None

 arch/arm/boot/dts/rk3036-evb.dts   | 23 ++++++++++++++++++++++
 arch/arm/boot/dts/rk3036-kylin.dts | 20 +++++++++++++++++++
 arch/arm/boot/dts/rk3036.dtsi      | 39 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+)

diff --git a/arch/arm/boot/dts/rk3036-evb.dts b/arch/arm/boot/dts/rk3036-evb.dts
index 28a0336..d7d3719 100644
--- a/arch/arm/boot/dts/rk3036-evb.dts
+++ b/arch/arm/boot/dts/rk3036-evb.dts
@@ -47,6 +47,17 @@
 	compatible = "rockchip,rk3036-evb", "rockchip,rk3036";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&rmii_rst>;
+	phy = <&phy0>;
+	status = "okay";
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
+
 &i2c1 {
 	status = "okay";
 
@@ -62,3 +73,15 @@
 &uart2 {
 	status = "okay";
 };
+
+&pinctrl {
+	pcfg_output_high: pcfg-output-high {
+		output-high;
+	};
+
+	emac {
+		rmii_rst: rmii-rst {
+			rockchip,pins = <2 22 RK_FUNC_GPIO &pcfg_output_high>;
+		};
+	};
+};
diff --git a/arch/arm/boot/dts/rk3036-kylin.dts b/arch/arm/boot/dts/rk3036-kylin.dts
index eb9c979..8b1d681 100644
--- a/arch/arm/boot/dts/rk3036-kylin.dts
+++ b/arch/arm/boot/dts/rk3036-kylin.dts
@@ -112,6 +112,20 @@
 	status = "okay";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&rmii_rst>;
+	phy = <&phy0>;
+	reset-gpios = <&gpio2 22 GPIO_ACTIVE_LOW>; /* PHY_RST */
+	phy-reset-duration = <10>; /* millisecond */
+
+	status = "okay";
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
+
 &emmc {
 	status = "okay";
 };
@@ -383,6 +397,12 @@
 };
 
 &pinctrl {
+	emac {
+		rmii_rst: rmii-rst {
+			rockchip,pins = <2 22 RK_FUNC_GPIO &pcfg_pull_default>;
+		};
+	};
+
 	leds {
 		led_ctl: led-ctl {
 			rockchip,pins = <2 30 RK_FUNC_GPIO &pcfg_pull_none>;
diff --git a/arch/arm/boot/dts/rk3036.dtsi b/arch/arm/boot/dts/rk3036.dtsi
index 90faa86..5175a2a 100644
--- a/arch/arm/boot/dts/rk3036.dtsi
+++ b/arch/arm/boot/dts/rk3036.dtsi
@@ -223,6 +223,27 @@
 		status = "disabled";
 	};
 
+	emac: ethernet@10200000 {
+		compatible = "rockchip,rk3036-emac", "snps,arc-emac";
+		reg = <0x10200000 0x4000>;
+		interrupts = <GIC_SPI 8 IRQ_TYPE_LEVEL_HIGH>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		rockchip,grf = <&grf>;
+		clocks = <&cru HCLK_MAC>, <&cru SCLK_MACREF>, <&cru SCLK_MAC>;
+		clock-names = "hclk", "macref", "macclk";
+		/*
+		 * Fix the emac parent clock is DPLL instead of APLL.
+		 * since that will cause some unstable things if the cpufreq
+		 * is working. (e.g: the accurate 50MHz what mac_ref need)
+		 */
+		assigned-clocks = <&cru SCLK_MACPLL>;
+		assigned-clock-parents = <&cru PLL_DPLL>;
+		max-speed = <100>;
+		phy-mode = "rmii";
+		status = "disabled";
+	};
+
 	sdmmc: dwmmc@10214000 {
 		compatible = "rockchip,rk3036-dw-mshc", "rockchip,rk3288-dw-mshc";
 		reg = <0x10214000 0x4000>;
@@ -628,6 +649,24 @@
 			};
 		};
 
+		emac {
+			emac_xfer: emac-xfer {
+				rockchip,pins = <2 10 RK_FUNC_1 &pcfg_pull_default>, /* crs_dvalid */
+						<2 13 RK_FUNC_1 &pcfg_pull_default>, /* tx_en */
+						<2 14 RK_FUNC_1 &pcfg_pull_default>, /* mac_clk */
+						<2 15 RK_FUNC_1 &pcfg_pull_default>, /* rx_err */
+						<2 16 RK_FUNC_1 &pcfg_pull_default>, /* rxd1 */
+						<2 17 RK_FUNC_1 &pcfg_pull_default>, /* rxd0 */
+						<2 18 RK_FUNC_1 &pcfg_pull_default>, /* txd1 */
+						<2 19 RK_FUNC_1 &pcfg_pull_default>; /* txd0 */
+			};
+
+			emac_mdio: emac-mdio {
+				rockchip,pins = <2 12 RK_FUNC_1 &pcfg_pull_default>, /* mac_md */
+						<2 25 RK_FUNC_1 &pcfg_pull_default>; /* mac_mdclk */
+			};
+		};
+
 		i2c0 {
 			i2c0_xfer: i2c0-xfer {
 				rockchip,pins = <0 0 RK_FUNC_1 &pcfg_pull_none>,
-- 
1.9.1
