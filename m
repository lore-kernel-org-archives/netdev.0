From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 1/6] dt-bindings: mdio-mux: Add documentation for mdio mux for NSP SoC
Date: Wed,  9 Nov 2016 04:33:09 -0500
Message-ID: <1478683994-12008-2-git-send-email-yendapally.reddy@broadcom.com>
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

Add documentation for mdio mux available in Broadcom NSP SoC

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 .../devicetree/bindings/net/brcm,mdio-mux-nsp.txt  | 57 ++++++++++++++++++++++
 1 file changed, 57 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt b/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
new file mode 100644
index 0000000..b749a2b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-nsp.txt
@@ -0,0 +1,57 @@
+Properties for an MDIO bus multiplexer available in Broadcom NSP SoC.
+
+This MDIO bus multiplexer defines buses that could access the internal
+phys as well as external to SoCs. When child bus is selected, one needs
+to select the below properties to generate desired MDIO transaction on
+appropriate bus.
+
+Required properties in addition to the generic multiplexer properties:
+
+MDIO multiplexer node:
+- compatible: brcm,mdio-mux-iproc.
+- reg: Should contain registers location and length.
+- reg-names: Should contain the resource reg names.
+	- bus-ctrl: mdio bus control register address space required to
+	  select the bus master. This property is not required for SoC's
+	  that doesn't provide master selection.
+	- mgmt-ctrl: mdio management control register address space
+
+Sub-nodes:
+   Each bus master should be represented as a sub-node.
+
+Sub-nodes required properties:
+- reg: Bus master number. Should be 0x10 to access the external mdio devices.
+- address-cells: should be 1
+- size-cells: should be 0
+
+Every non-ethernet PHY requires a compatible property so that it could be
+probed based on this compatible string.
+
+Additional information regarding generic multiplexer properties can be found
+at- Documentation/devicetree/bindings/net/mdio-mux.txt
+
+example:
+
+	mdio_mux: mdio-mux@3f190 {
+		compatible = "brcm,mdio-mux-nsp";
+		reg = <0x3f190 0x4>,
+		      <0x32000 0x4>;
+		reg-names = "bus-ctrl", "mgmt-ctrl";
+		mdio-parent-bus = <&mdio>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		mdio@0 {
+			reg = <0x0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			usb3_phy: usb3-phy@10 {
+				compatible = "brcm,nsp-usb3-phy";
+				reg = <0x10>;
+				usb3-ctrl-syscon = <&usb3_ctrl>;
+				#phy-cells = <0>;
+				status = "disabled";
+			};
+		};
+	};
-- 
2.1.0
