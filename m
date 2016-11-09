From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 6/6] arm: dts: nsp: Add USB nodes to device tree
Date: Wed,  9 Nov 2016 04:33:14 -0500
Message-ID: <1478683994-12008-7-git-send-email-yendapally.reddy@broadcom.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
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
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add USB nodes to the Northstar plus device tree file

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 arch/arm/boot/dts/bcm-nsp.dtsi   | 57 ++++++++++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/bcm958625k.dts | 16 +++++++++++
 2 files changed, 73 insertions(+)

diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
index 7c9e0fa..acdb576 100644
--- a/arch/arm/boot/dts/bcm-nsp.dtsi
+++ b/arch/arm/boot/dts/bcm-nsp.dtsi
@@ -249,6 +249,34 @@
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
@@ -319,6 +347,30 @@
 					     "sata2";
 		};
 
+		mdio_mux: mdio-mux@3f190 {
+			compatible = "brcm,mdio-mux-nsp";
+			reg = <0x3f190 0x4>,
+			      <0x32000 0x4>;
+			reg-names = "bus-ctrl", "mgmt-ctrl";
+			mdio-parent-bus = <&mdio>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			mdio@0 {
+				reg = <0x0>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				usb3_phy: usb3-phy@10 {
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
@@ -367,6 +419,11 @@
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
index 05c5f98..c7303fa 100644
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
