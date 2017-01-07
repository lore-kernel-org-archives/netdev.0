From: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH RFC 3/4] dt-bindings: correct marvell orion MDIO binding
 document
Date: Sat, 07 Jan 2017 11:28:30 +0000
Message-ID: <E1cPpAk-0005uJ-TM@rmk-PC.armlinux.org.uk>
References: <20170107112656.GL14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170107112656.GL14217-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Correct the Marvell Orion MDIO binding document to properly reflect the
cases where an interrupt is present.  Augment the examples to show this.

Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
---
 .../devicetree/bindings/net/marvell-orion-mdio.txt      | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
index 9417e54c26c0..ca733ff68ab9 100644
--- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
+++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
@@ -7,7 +7,10 @@ interface.
 
 Required properties:
 - compatible: "marvell,orion-mdio"
-- reg: address and length of the SMI register
+- reg: address and length of the MDIO registers.  When an interrupt is
+  not present, the length is the size of the SMI register (4 bytes)
+  otherwise it must be 0x84 bytes to cover the interrupt control
+  registers.
 
 Optional properties:
 - interrupts: interrupt line number for the SMI error/done interrupt
@@ -17,7 +20,7 @@ The child nodes of the MDIO driver are the individual PHY devices
 connected to this MDIO bus. They must have a "reg" property given the
 PHY address on the MDIO bus.
 
-Example at the SoC level:
+Example at the SoC level without an interrupt property:
 
 mdio {
 	#address-cells = <1>;
@@ -26,6 +29,16 @@ mdio {
 	reg = <0xd0072004 0x4>;
 };
 
+Example with an interrupt property:
+
+mdio {
+	#address-cells = <1>;
+	#size-cells = <0>;
+	compatible = "marvell,orion-mdio";
+	reg = <0xd0072004 0x84>;
+	interrupts = <30>;
+};
+
 And at the board level:
 
 mdio {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
