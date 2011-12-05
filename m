From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v3 2/2] ARM: at91/net: add macb ethernet controller in 9g45 DT
Date: Mon,  5 Dec 2011 12:59:53 +0100
Message-ID: <1ec7a786c94564a9b15a61239f41a2a3fba8578a.1323086095.git.nicolas.ferre@atmel.com>
References: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
 <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
Cc: linux-arm-kernel@lists.infradead.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, jamie@jamieiles.com,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: robherring2@gmail.com, devicetree-discuss@lists.ozlabs.org,
	netdev@vger.kernel.org, plagnioj@jcrosoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
In-Reply-To: <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
References: <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the Cadence macb ethernet controller in at91sam9g45 .dtsi and
enable it in at91sam9m10g45ek board device tree file.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
v3: - form a thread with "macb DT support" patch
    - remove "local-mac-address" from 9m10g45ek.dts file but use it in
      documentation example.

 Documentation/devicetree/bindings/net/macb.txt |    1 +
 arch/arm/boot/dts/at91sam9g45.dtsi             |    7 +++++++
 arch/arm/boot/dts/at91sam9m10g45ek.dts         |    5 +++++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 2e24f05..44afa0e 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -21,4 +21,5 @@ Examples:
 		reg = <0xfffc4000 0x4000>;
 		interrupts = <21>;
 		phy-mode = "rmii";
+		local-mac-address = [3a 0e 03 04 05 06];
 	};
diff --git a/arch/arm/boot/dts/at91sam9g45.dtsi b/arch/arm/boot/dts/at91sam9g45.dtsi
index e89b1d7..67f94d3 100644
--- a/arch/arm/boot/dts/at91sam9g45.dtsi
+++ b/arch/arm/boot/dts/at91sam9g45.dtsi
@@ -101,6 +101,13 @@
 				atmel,use-dma-tx;
 				status = "disabled";
 			};
+
+			macb0: ethernet@fffbc000 {
+				compatible = "cdns,at32ap7000-macb", "cdns,macb";
+				reg = <0xfffbc000 0x100>;
+				interrupts = <25 4>;
+				status = "disabled";
+			};
 		};
 	};
 };
diff --git a/arch/arm/boot/dts/at91sam9m10g45ek.dts b/arch/arm/boot/dts/at91sam9m10g45ek.dts
index 85b34f5..a387e77 100644
--- a/arch/arm/boot/dts/at91sam9m10g45ek.dts
+++ b/arch/arm/boot/dts/at91sam9m10g45ek.dts
@@ -30,6 +30,11 @@
 			usart1: serial@fff90000 {
 				status = "okay";
 			};
+
+			macb0: ethernet@fffbc000 {
+				phy-mode = "rmii";
+				status = "okay";
+			};
 		};
 	};
 };
-- 
1.7.5.4
