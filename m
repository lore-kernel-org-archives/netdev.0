From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH v3 1/5] net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
Date: Sun, 28 Aug 2016 18:16:33 +0200
Message-ID: <20160828161637.9941-2-martin.blumenstingl@googlemail.com>
References: <20160820093538.9707-1-martin.blumenstingl@googlemail.com>
 <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160828161637.9941-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the documentation for the DWMAC ethernet controller
found in Amlogic Meson 8b (S805) and GXBB (S905) SoCs.
The main difference between the Meson6 glue is that different registers
(with different layout) are used.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 .../devicetree/bindings/net/meson-dwmac.txt        | 45 ++++++++++++++++++----
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/meson-dwmac.txt b/Documentation/devicetree/bindings/net/meson-dwmac.txt
index ec633d7..89e62dd 100644
--- a/Documentation/devicetree/bindings/net/meson-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/meson-dwmac.txt
@@ -1,18 +1,32 @@
 * Amlogic Meson DWMAC Ethernet controller
 
 The device inherits all the properties of the dwmac/stmmac devices
-described in the file net/stmmac.txt with the following changes.
+described in the file stmmac.txt in the current directory with the
+following changes.
 
-Required properties:
+Required properties on all platforms:
 
-- compatible: should be "amlogic,meson6-dwmac" along with "snps,dwmac"
-	      and any applicable more detailed version number
-	      described in net/stmmac.txt
+- compatible:	Depending on the platform this should be one of:
+			- "amlogic,meson6-dwmac"
+			- "amlogic,meson8b-dwmac"
+			- "amlogic,meson-gxbb-dwmac"
+		Additionally "snps,dwmac" and any applicable more
+		detailed version number described in net/stmmac.txt
+		should be used.
 
-- reg: should contain a register range for the dwmac controller and
-       another one for the Amlogic specific configuration
+- reg:	The first register range should be the one of the DWMAC
+	controller. The second range is is for the Amlogic specific
+	configuration (for example the PRG_ETHERNET register range
+	on Meson8b and newer)
 
-Example:
+Required properties on Meson8b and newer:
+- clock-names:	Should contain the following:
+		- "stmmaceth" - see stmmac.txt
+		- "clkin0" - first parent clock of the internal mux
+		- "clkin1" - second parent clock of the internal mux
+
+
+Example for Meson6:
 
 	ethmac: ethernet@c9410000 {
 		compatible = "amlogic,meson6-dwmac", "snps,dwmac";
@@ -23,3 +37,18 @@ Example:
 		clocks = <&clk81>;
 		clock-names = "stmmaceth";
 	}
+
+Example for GXBB:
+	ethmac: ethernet@c9410000 {
+		compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
+		reg = <0x0 0xc9410000 0x0 0x10000>,
+			<0x0 0xc8834540 0x0 0x8>;
+		interrupts = <0 8 1>;
+		interrupt-names = "macirq";
+		clocks = <&clkc CLKID_ETH>,
+				<&clkc CLKID_FCLK_DIV2>,
+				<&clkc CLKID_MPLL2>;
+		clock-names = "stmmaceth", "clkin0", "clkin1";
+		phy-mode = "rgmii";
+		status = "disabled";
+	};
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
