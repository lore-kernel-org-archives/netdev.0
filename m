From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 15/20] ARM64: dts: sun50i-a64: add dwmac-sun8i Ethernet driver
Date: Tue, 14 Mar 2017 15:18:51 +0100
Message-ID: <20170314141856.24560-16-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dwmac-sun8i is an Ethernet MAC that supports 10/100/1000 Mbit
connections. It is very similar to the device found in the Allwinner
H3, but lacks the internal 100 Mbit PHY and its associated control
bits.
This adds the necessary bits to the Allwinner A64 SoC .dtsi, but keeps
it disabled at this level.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi | 37 +++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
index 3b09af2..57d69e5 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
@@ -277,6 +277,23 @@
 				bias-pull-up;
 			};
 
+			rmii_pins: rmii_pins {
+				pins = "PD10", "PD11", "PD13", "PD14",
+						"PD17", "PD18", "PD19", "PD20",
+						"PD22", "PD23";
+				function = "emac";
+				drive-strength = <40>;
+			};
+
+			rgmii_pins: rgmii_pins {
+				pins = "PD8", "PD9", "PD10", "PD11",
+						"PD12", "PD13", "PD15",
+						"PD16", "PD17", "PD18", "PD19",
+						"PD20", "PD21", "PD22", "PD23";
+				function = "emac";
+				drive-strength = <40>;
+			};
+
 			uart0_pins_a: uart0@0 {
 				pins = "PB8", "PB9";
 				function = "uart0";
@@ -381,6 +398,26 @@
 			#size-cells = <0>;
 		};
 
+		emac: ethernet@1c30000 {
+			compatible = "allwinner,sun50i-a64-emac";
+			syscon = <&syscon>;
+			reg = <0x01c30000 0x100>;
+			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+			interrupt-names = "macirq";
+			resets = <&ccu RST_BUS_EMAC>;
+			reset-names = "stmmaceth";
+			clocks = <&ccu CLK_BUS_EMAC>;
+			clock-names = "stmmaceth";
+			status = "disabled";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			mdio: mdio {
+				#address-cells = <1>;
+				#size-cells = <0>;
+			};
+		};
+
 		gic: interrupt-controller@1c81000 {
 			compatible = "arm,gic-400";
 			reg = <0x01c81000 0x1000>,
-- 
2.10.2
