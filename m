From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH v2 4/4] arm: dts: nsp: Add USB nodes to device tree
Date: Tue, 17 Jan 2017 11:14:30 -0500
Message-ID: <1484669670-4201-5-git-send-email-yendapally.reddy@broadcom.com>
References: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484669670-4201-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add USB nodes to the Northstar plus device tree file

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 arch/arm/boot/dts/bcm-nsp.dtsi   | 56 ++++++++++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/bcm958625k.dts | 16 ++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
index b6142bd..94b3231 100644
--- a/arch/arm/boot/dts/bcm-nsp.dtsi
+++ b/arch/arm/boot/dts/bcm-nsp.dtsi
@@ -259,6 +259,34 @@
 			status = "disabled";
 		};
 
+		xhci: usb@29000 {
+			compatible = "generic-xhci";
+			reg = <0x29000 0x1000>;
+			interrupts = <GIC_SPI 80 IRQ_TYPE_LEVEL_HIGH>;
+			phys = <&usb3_phy>;
+			phy-names = "usb";
+			status = "disabled";
+		};
+
+		ehci0: usb@2a000 {
+			compatible = "generic-ehci";
+			reg = <0x2a000 0x100>;
+			interrupts = <GIC_SPI 79 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
+		ohci0: usb@2b000 {
+			compatible = "generic-ohci";
+			reg = <0x2b000 0x100>;
+			interrupts = <GIC_SPI 79 IRQ_TYPE_LEVEL_HIGH>;
+			status = "disabled";
+		};
+
+		mdio: mdio@32000 {
+			compatible = "brcm,iproc-mdio";
+			reg = <0x32000 0x8>;
+		};
+
 		rng: rng@33000 {
 			compatible = "brcm,bcm-nsp-rng";
 			reg = <0x33000 0x14>;
@@ -358,6 +386,29 @@
 					     "sata2";
 		};
 
+		mdio-mux {
+			compatible = "mdio-mux-mmioreg";
+			mdio-parent-bus = <&mdio>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x32000 0x4>;
+			mux-mask = <0x200>;
+
+			mdio@0 {
+				reg = <0x00>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				usb3_phy: usb-phy@10 {
+					compatible = "brcm,nsp-usb3-phy";
+					reg = <0x10>;
+					usb3-ctrl-syscon = <&usb3_ctrl>;
+					#phy-cells = <0>;
+					status = "disabled";
+				};
+			};
+		};
+
 		pinctrl: pinctrl@3f1c0 {
 			compatible = "brcm,nsp-pinmux";
 			reg = <0x3f1c0 0x04>,
@@ -406,6 +457,11 @@
 				phy-names = "sata-phy";
 			};
 		};
+
+		usb3_ctrl: syscon@104408 {
+			compatible = "brcm,nsp-usb3-ctrl", "syscon";
+			reg = <0x104408 0x3fc>;
+		};
 	};
 
 	pcie0: pcie@18012000 {
diff --git a/arch/arm/boot/dts/bcm958625k.dts b/arch/arm/boot/dts/bcm958625k.dts
index 59d96fb..1da22dc 100644
--- a/arch/arm/boot/dts/bcm958625k.dts
+++ b/arch/arm/boot/dts/bcm958625k.dts
@@ -53,6 +53,22 @@
 	};
 };
 
+&ehci0 {
+	status = "okay";
+};
+
+&ohci0 {
+	status = "okay";
+};
+
+&usb3_phy {
+	status = "okay";
+};
+
+&xhci {
+	status = "okay";
+};
+
 &uart0 {
 	status = "okay";
 };
-- 
2.1.0
