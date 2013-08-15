From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: [PATCH v4 2/5] ARM: davinci: da850: add DT node for mdio device
Date: Thu, 15 Aug 2013 11:31:34 +0530
Message-ID: <1376546497-26931-3-git-send-email-prabhakar.csengg@gmail.com>
References: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376546497-26931-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

Add mdio device tree node information to da850 by
providing register details and bus frequency of mdio.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Changes for v2: none
 
 Changes for v3:
  a> Added pin entries for mdio.
  
 Changes for v4: none
  
 arch/arm/boot/dts/da850-evm.dts |    6 ++++++
 arch/arm/boot/dts/da850.dtsi    |   13 +++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
index 5bce7cc..1f8cfdd 100644
--- a/arch/arm/boot/dts/da850-evm.dts
+++ b/arch/arm/boot/dts/da850-evm.dts
@@ -90,6 +90,12 @@
 				};
 			};
 		};
+		mdio: mdio@1e24000 {
+			status = "okay";
+			pinctrl-names = "default";
+			pinctrl-0 = <&mdio_pins>;
+			bus_freq = <2200000>;
+		};
 	};
 	nand_cs3@62000000 {
 		status = "okay";
diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
index 5f7e79a..d5138b4 100644
--- a/arch/arm/boot/dts/da850.dtsi
+++ b/arch/arm/boot/dts/da850.dtsi
@@ -125,6 +125,13 @@
 					0x14 0x00000010 0x000000f0
 				>;
 			};
+			mdio_pins: pinmux_mdio_pins {
+				pinctrl-single,bits = <
+					/* MDIO_CLK, MDIO_D */
+					0x10 0x00000088 0x000000ff
+				>;
+			};
+
 		};
 		serial0: serial@1c42000 {
 			compatible = "ns16550a";
@@ -213,6 +220,12 @@
 			interrupts = <56>;
 			status = "disabled";
 		};
+		mdio: mdio@1e24000 {
+			compatible = "ti,davinci_mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x224000 0x1000>;
+		};
 	};
 	nand_cs3@62000000 {
 		compatible = "ti,davinci-nand";
-- 
1.7.9.5
