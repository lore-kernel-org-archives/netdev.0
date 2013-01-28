From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 4/6] ARM: davinci: da850: add DT node for eth0.
Date: Mon, 28 Jan 2013 19:17:57 +0530
Message-ID: <1359380879-26306-5-git-send-email-prabhakar.lad@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Heiko Schocher <hs@denx.de>,
	"Lad, Prabhakar" <prabhakar.lad@ti.com>
To: Sekhar Nori <nsekhar@ti.com>, linux-arm-kernel@lists.infradead.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.lad@ti.com>

Add eth0 device tree node information and pinmux for mii to da850 by
providing interrupt details and local mac address of eth0.

Signed-off-by: Lad, Prabhakar <prabhakar.lad@ti.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 arch/arm/boot/dts/da850-evm.dts |    5 +++++
 arch/arm/boot/dts/da850.dtsi    |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
index a319491..19aa2b3 100644
--- a/arch/arm/boot/dts/da850-evm.dts
+++ b/arch/arm/boot/dts/da850-evm.dts
@@ -30,6 +30,11 @@
 		mdio: davinci_mdio@1e24000 {
 			status = "okay";
 		};
+		eth0: emac@1e20000 {
+			status = "okay";
+			pinctrl-names = "default";
+			pinctrl-0 = <&mii_pins>;
+		};
 	};
 	nand_cs3@62000000 {
 		status = "okay";
diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
index ba28f2d..76905f3 100644
--- a/arch/arm/boot/dts/da850.dtsi
+++ b/arch/arm/boot/dts/da850.dtsi
@@ -56,6 +56,26 @@
 					0x30 0x01100000  0x0ff00000
 				>;
 			};
+			mii_pins: pinmux_mii_pins {
+				pinctrl-single,bits = <
+					/*
+					 * MII_TXEN, MII_TXCLK, MII_COL
+					 * MII_TXD_3, MII_TXD_2, MII_TXD_1
+					 * MII_TXD_0
+					 */
+					0x8 0x88888880 0xfffffff0
+					/*
+					 * MII_RXER, MII_CRS, MII_RXCLK
+					 * MII_RXDV, MII_RXD_3, MII_RXD_2
+					 * MII_RXD_1, MII_RXD_0
+					 */
+					0xc 0x88888888 0xffffffff
+					/* MDIO_CLK, MDIO_D */
+					0x10 0x00222288 0x00ffffff
+					/* GPIO2_6 */
+					0x18 0x00000080 0x000000f0
+				>;
+			};
 		};
 		serial0: serial@1c42000 {
 			compatible = "ns16550a";
@@ -88,6 +108,21 @@
 			reg = <0x224000 0x1000>;
 			bus_freq = <2200000>;
 		};
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
+			phy-handle = <&mdio>;
+		};
 	};
 	nand_cs3@62000000 {
 		compatible = "ti,davinci-nand";
-- 
1.7.4.1
