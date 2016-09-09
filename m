From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 5/9] ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
Date: Fri,  9 Sep 2016 14:45:13 +0200
Message-ID: <1473425117-18645-6-git-send-email-clabbe.montjoie@gmail.com>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sun8i-emac is an ethernet MAC hardware that support 10/100/1000
speed.

This patch enable the sun8i-emac on the Allwinner H3 SoC Device-tree.
The SoC H3 have an internal PHY, so optionals syscon and ephy are set.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sun8i-h3.dtsi | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
index a39da6f..a3ac476 100644
--- a/arch/arm/boot/dts/sun8i-h3.dtsi
+++ b/arch/arm/boot/dts/sun8i-h3.dtsi
@@ -50,6 +50,10 @@
 / {
 	interrupt-parent = <&gic>;
 
+	aliases {
+		ethernet0 = &emac;
+	};
+
 	cpus {
 		#address-cells = <1>;
 		#size-cells = <0>;
@@ -446,6 +450,21 @@
 			status = "disabled";
 		};
 
+		emac: ethernet@1c30000 {
+			compatible = "allwinner,sun8i-h3-emac";
+			syscon = <&syscon>;
+			reg = <0x01c30000 0x104>;
+			reg-names = "emac";
+			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+			resets = <&ccu RST_BUS_EMAC>, <&ccu RST_BUS_EPHY>;
+			reset-names = "ahb", "ephy";
+			clocks = <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
+			clock-names = "ahb", "ephy";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			status = "disabled";
+		};
+
 		gic: interrupt-controller@01c81000 {
 			compatible = "arm,cortex-a7-gic", "arm,cortex-a15-gic";
 			reg = <0x01c81000 0x1000>,
-- 
2.7.3
