From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: [PATCH 4/4] ARM: shmobile: ape6evm-reference: add smsc911x ethernet support
Date: Tue, 23 Jul 2013 18:12:04 +0200
Message-ID: <1374595924-12338-5-git-send-email-g.liakhovetski@gmx.de>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
To: linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the SMSC9220 ethernet chip on the board.

Signed-off-by: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
---
 arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts |   25 ++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts b/arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts
index 3bcbc9f..4215ebc 100644
--- a/arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts
+++ b/arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts
@@ -8,6 +8,8 @@
  * kind, whether express or implied.
  */
 
+#include <dt-bindings/gpio/gpio.h>
+
 /dts-v1/;
 /include/ "r8a73a4.dtsi"
 
@@ -16,7 +18,7 @@
 	compatible = "renesas,ape6evm-reference", "renesas,r8a73a4";
 
 	chosen {
-		bootargs = "console=ttySC0,115200 ignore_loglevel";
+		bootargs = "console=ttySC0,115200 debug ip=dhcp root=/dev/nfs";
 	};
 
 	memory@40000000 {
@@ -37,6 +39,22 @@
 		#address-cells = <1>;
 		#size-cells = <1>;
 		ranges = <0 0 0 0x80000000>;
+
+		ethernet@8000000 {
+			compatible = "smsc,lan9118", "smsc,lan9115";
+			reg = <0x08000000 0x1000>;
+			interrupt-parent = <&irqc1>;
+			interrupts = <8 0x4>;
+			phy-mode = "mii";
+			reg-io-width = <4>;
+			smsc,irq-active-high;
+			smsc,irq-push-pull;
+			smsc,reset-gpios = <&pfc 270 GPIO_ACTIVE_LOW>;
+			pinctrl-names = "default";
+			pinctrl-0 = <&smsc_pins>;
+			vdd33a-supply = <&ape6evm_fixed_3v3>;
+			vddvario-supply = <&ape6evm_fixed_3v3>;
+		};
 	};
 };
 
@@ -85,6 +103,11 @@
 		renesas,groups = "sdhi1_data4", "sdhi1_ctrl";
 		renesas,function = "sdhi1";
 	};
+
+	smsc_pins: eth0 {
+		renesas,groups = "irqc_irq40";
+		renesas,function = "irqc";
+	};
 };
 
 &mmcif0 {
-- 
1.7.2.5

