From: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [patch v1 1/2] dt-bindings: net: add binding documentation for mlxsw thermal control
Date: Tue, 29 Aug 2017 18:45:10 +0000
Message-ID: <1504032311-195988-2-git-send-email-vadimp@mellanox.com>
References: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
Cc: jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1504032311-195988-1-git-send-email-vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add binding document for Mellanox switch devices.

Signed-off-by: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 .../devicetree/bindings/net/mellanox,mlxsw.txt     | 46 ++++++++++++++++++++++
 1 file changed, 46 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mellanox,mlxsw.txt

diff --git a/Documentation/devicetree/bindings/net/mellanox,mlxsw.txt b/Documentation/devicetree/bindings/net/mellanox,mlxsw.txt
new file mode 100644
index 0000000..55de5ff
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mellanox,mlxsw.txt
@@ -0,0 +1,46 @@
+Mellanox Technologies Switch ASICs
+
+This file provides information, what the device node
+for the Switch ASIC interface contains.
+
+Required properties:
+- compatible		: "mellanox,mlxsw_minimal"
+- reg			: The I2C address of the device.
+
+Optional properties:
+- cooling-phandle	: phandle of the cooling device, which is to be used
+			  for the zone thermal control.
+			  If absent, cooling device controlled internally by
+			  the ASIC may be used.
+
+- trips			: the nodes to describe a point in the temperature
+			  domain with key temperatures at which cooling is
+			  recommended. Each node must contain the next values:
+			  - type: the trip type. Expected values are:
+			    0 - a trip point to enable active cooling;
+			    1 - a trip point to enable passive cooling;
+			    2 - a trip point to notify emergency;
+			  - temperature: unsigned integer indicating the trip
+			    temperature level in millicelsius;
+			  - minimum cooling state allowed within the trip node;
+			  - maximum cooling state allowed within the trip node;
+
+Example:
+	asic_thermal: mlxsw_minimal@48 {
+		compatible = "mlxsw_minimal";
+		reg = <0x48>;
+		status = "disabled";
+		cooling-phandle = <&cooling>;
+
+		trips {
+			trip@0 {
+				trip = <0 75000 0 0>;
+			};
+			trip@1 {
+				trip = <2 85000 1 5>;
+			};
+			trip@3 {
+				trip = <2 105000 5 5>;
+			};
+		};
+	};
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
