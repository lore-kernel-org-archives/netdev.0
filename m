From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v3 4/6] ARM: davinci: da850: add DT node for eth0.
Date: Sun, 23 Jun 2013 20:30:05 +0530
Message-ID: <1371999607-6483-5-git-send-email-prabhakar.csengg@gmail.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Heiko Schocher <hs@denx.de>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	devicetree-discuss@lists.ozlabs.org, Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

Add eth0 device tree node information and pinmux for mii to da850 by
providing interrupt details and local mac address of eth0.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: davinci-linux-open-source@linux.davincidsp.com
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: Heiko Schocher <hs@denx.de>
---
 Changes for v2: None
 Changes for v3:
  a> Split the pinmux for mdio and mii.
  
 arch/arm/boot/dts/da850-evm.dts |    5 +++++
 arch/arm/boot/dts/da850.dtsi    |   30 ++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
index 661219e..590d884 100644
--- a/arch/arm/boot/dts/da850-evm.dts
+++ b/arch/arm/boot/dts/da850-evm.dts
@@ -96,6 +96,11 @@
 			pinctrl-0 = <&mdio_pins>;
 			bus_freq = <2200000>;
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
index bcef5a9..0109b65 100644
--- a/arch/arm/boot/dts/da850.dtsi
+++ b/arch/arm/boot/dts/da850.dtsi
@@ -131,6 +131,22 @@
 					0x10 0x00000088 0x000000ff
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
+				>;
+			};
 
 		};
 		serial0: serial@1c42000 {
@@ -229,6 +245,20 @@
 			#size-cells = <0>;
 			reg = <0x224000 0x1000>;
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
+		};
 	};
 	nand_cs3@62000000 {
 		compatible = "ti,davinci-nand";
-- 
1.7.9.5
