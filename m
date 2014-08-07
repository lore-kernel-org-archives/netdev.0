From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v10 2/4] Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Thu,  7 Aug 2014 15:14:26 -0700
Message-ID: <1407449668-13520-3-git-send-email-isubramanian@apm.com>
References: <1407449668-13520-1-git-send-email-isubramanian@apm.com>
Cc: dnelson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1407449668-13520-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
---
 .../devicetree/bindings/net/apm-xgene-enet.txt     | 66 ++++++++++++++++++++++
 1 file changed, 66 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
new file mode 100644
index 0000000..ebcad25
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -0,0 +1,66 @@
+APM X-Gene SoC Ethernet nodes
+
+Ethernet nodes are defined to describe on-chip ethernet interfaces in
+APM X-Gene SoC.
+
+Required properties:
+- compatible: Should be "apm,xgene-enet"
+- reg: Address and length of the register set for the device. It contains the
+  information of registers in the same order as described by reg-names
+- reg-names: Should contain the register set names
+  - "enet_csr": Ethernet control and status register address space
+  - "ring_csr": Descriptor ring control and status register address space
+  - "ring_cmd": Descriptor ring command register address space
+- interrupts: Ethernet main interrupt
+- clocks: Reference to the clock entry.
+- local-mac-address: MAC address assigned to this device
+- phy-connection-type: Interface type between ethernet device and PHY device
+- phy-handle: Reference to a PHY node connected to this device
+
+- mdio: Device tree subnode with the following required properties:
+  - compatible: Must be "apm,xgene-mdio".
+  - #address-cells: Must be <1>.
+  - #size-cells: Must be <0>.
+
+  For the phy on the mdio bus, there must be a node with the following fields:
+  - compatible: PHY identifier.  Please refer ./phy.txt for the format.
+  - reg: The ID number for the phy.
+
+Optional properties:
+- status: Should be "ok" or "disabled" for enabled/disabled. Default is "ok".
+
+Example:
+	menetclk: menetclk {
+		compatible = "apm,xgene-device-clock";
+		clock-output-names = "menetclk";
+		status = "ok";
+	};
+
+	menet: ethernet@17020000 {
+		compatible = "apm,xgene-enet";
+		status = "disabled";
+		reg = <0x0 0x17020000 0x0 0xd100>,
+		      <0x0 0X17030000 0x0 0X400>,
+		      <0x0 0X10000000 0x0 0X200>;
+		reg-names = "enet_csr", "ring_csr", "ring_cmd";
+		interrupts = <0x0 0x3c 0x4>;
+		clocks = <&menetclk 0>;
+		local-mac-address = [00 01 73 00 00 01];
+		phy-connection-type = "rgmii";
+		phy-handle = <&menetphy>;
+		mdio {
+			compatible = "apm,xgene-mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			menetphy: menetphy@3 {
+				compatible = "ethernet-phy-id001c.c915";
+				reg = <0x3>;
+			};
+
+		};
+	};
+
+/* Board-specific peripheral configurations */
+&menet {
+        status = "ok";
+};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
