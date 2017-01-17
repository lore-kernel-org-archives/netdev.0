From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH v2 1/4] dt-bindings: phy: Add documentation for NSP USB3 PHY
Date: Tue, 17 Jan 2017 11:14:27 -0500
Message-ID: <1484669670-4201-2-git-send-email-yendapally.reddy@broadcom.com>
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

Add documentation for USB3 PHY available in Northstar plus SoC

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 .../devicetree/bindings/phy/brcm,nsp-usb3-phy.txt  | 39 ++++++++++++++++++++++
 1 file changed, 39 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt

diff --git a/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt b/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
new file mode 100644
index 0000000..e68ae5d
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/brcm,nsp-usb3-phy.txt
@@ -0,0 +1,39 @@
+Broadcom USB3 phy binding for northstar plus SoC
+The USB3 phy is internal to the SoC and is accessed using mdio interface.
+
+Required mdio bus properties:
+- reg: Should be 0x0 for SoC internal USB3 phy
+- #address-cells: must be 1
+- #size-cells: must be 0
+
+Required USB3 PHY properties:
+- compatible: should be "brcm,nsp-usb3-phy"
+- reg: USB3 Phy address on SoC internal MDIO bus and it should be 0x10.
+- usb3-ctrl-syscon: handler of syscon node defining physical address
+  of usb3 control register.
+- #phy-cells: must be 0
+
+Required usb3 control properties:
+- compatible: should be "brcm,nsp-usb3-ctrl"
+- reg: offset and length of the control registers
+
+Example:
+
+	mdio@0 {
+		reg = <0x0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		usb3_phy: usb-phy@10 {
+			compatible = "brcm,nsp-usb3-phy";
+			reg = <0x10>;
+			usb3-ctrl-syscon = <&usb3_ctrl>;
+			#phy-cells = <0>;
+			status = "disabled";
+		};
+	};
+
+	usb3_ctrl: syscon@104408 {
+		compatible = "brcm,nsp-usb3-ctrl", "syscon";
+		reg = <0x104408 0x3fc>;
+	};
-- 
2.1.0
