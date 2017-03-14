From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 08/20] ARM: dts: sun8i: Enable dwmac-sun8i on the Banana Pi
 M2+
Date: Tue, 14 Mar 2017 15:18:44 +0100
Message-ID: <20170314141856.24560-9-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, LABBE Corentin <clabbe.montjoie@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: robh+dt@kernel.org, mark.rutland@arm.com, maxime.ripard@free-electrons.com,
 wens@csie.org, linux@armlinux.org.uk, catalin.marinas@arm.com,
 will.deacon@arm.com, peppe.cavallaro@st.com, alexandre.torgue@st.com,
 davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
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

From: LABBE Corentin <clabbe.montjoie@gmail.com>

The dwmac-sun8i hardware is present on the Banana Pi M2+
It uses an external PHY rtl8211e via RGMII.

This patch create the needed regulator, emac and phy nodes.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts | 37 +++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
index 52acbe1..30b0a41 100644
--- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
@@ -90,6 +90,18 @@
 		pinctrl-0 = <&wifi_en_bpi_m2p>;
 		reset-gpios = <&r_pio 0 7 GPIO_ACTIVE_LOW>; /* PL7 */
 	};
+
+	reg_gmac_3v3: gmac-3v3 {
+		      compatible = "regulator-fixed";
+		      pinctrl-names = "default";
+		      pinctrl-0 = <&gmac_power_pin_orangepi>;
+		      regulator-name = "gmac-3v3";
+		      regulator-min-microvolt = <3300000>;
+		      regulator-max-microvolt = <3300000>;
+		      startup-delay-us = <100000>;
+		      enable-active-high;
+		      gpio = <&pio 3 6 GPIO_ACTIVE_HIGH>;
+	      };
 };
 
 &ehci1 {
@@ -186,3 +198,28 @@
 	/* USB VBUS is on as long as VCC-IO is on */
 	status = "okay";
 };
+
+&pio {
+	gmac_power_pin_orangepi: gmac_power_pin@0 {
+		 pins = "PD6";
+		 function = "gpio_out";
+		 drive-strength = <10>;
+	 };
+};
+
+&mdio {
+	ext_rgmii_phy: ethernet-phy@1 {
+		reg = <0>;
+	};
+};
+
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_rgmii_pins>;
+	phy-supply = <&reg_gmac_3v3>;
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+
+	allwinner,leds-active-low;
+	status = "okay";
+};
-- 
2.10.2
