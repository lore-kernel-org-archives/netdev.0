From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] dt-bindings: mdio: Clarify binding document
Date: Tue, 25 Apr 2017 11:33:03 -0700
Message-ID: <20170425183308.26107-1-f.fainelli@gmail.com>
Cc: rogerq-l0cyMroinI0@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, nsekhar-l0cyMroinI0@public.gmane.org, jsarha-l0cyMroinI0@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The described GPIO reset property is applicable to *all* child PHYs. If
we have one reset line per PHY present on the MDIO bus, these
automatically become properties of the child PHY nodes.

Finally, indicate how the RESET pulse width must be defined, which is
the maximum value of all individual PHYs RESET pulse widths determined
by reading their datasheets.

Fixes: 69226896ad63 ("mdio_bus: Issue GPIO RESET to PHYs.")
Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/devicetree/bindings/net/mdio.txt | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
index 4ffbbacebda1..96a53f89aa6e 100644
--- a/Documentation/devicetree/bindings/net/mdio.txt
+++ b/Documentation/devicetree/bindings/net/mdio.txt
@@ -3,13 +3,17 @@ Common MDIO bus properties.
 These are generic properties that can apply to any MDIO bus.
 
 Optional properties:
-- reset-gpios: List of one or more GPIOs that control the RESET lines
-  of the PHYs on that MDIO bus.
-- reset-delay-us: RESET pulse width in microseconds as per PHY datasheet.
+- reset-gpios: One GPIO that control the RESET lines of all PHYs on that MDIO
+  bus.
+- reset-delay-us: RESET pulse width in microseconds.
 
 A list of child nodes, one per device on the bus is expected. These
 should follow the generic phy.txt, or a device specific binding document.
 
+The 'reset-delay-us' indicates the RESET signal pulse width in microseconds and
+applies to all PHY devices. It must therefore be appropriately determined based
+on all PHY requirements (maximum value of all per-PHY RESET pulse widths).
+
 Example :
 This example shows these optional properties, plus other properties
 required for the TI Davinci MDIO driver.
@@ -21,7 +25,7 @@ required for the TI Davinci MDIO driver.
 		#size-cells = <0>;
 
 		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
-		reset-delay-us = <2>;   /* PHY datasheet states 1us min */
+		reset-delay-us = <2>;
 
 		ethphy0: ethernet-phy@1 {
 			reg = <1>;
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
