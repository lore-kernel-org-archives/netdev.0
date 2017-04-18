From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Subject: [PATCH net-next v3] bindings: net: stmmac: add missing note about LPI interrupt
Date: Tue, 18 Apr 2017 14:39:53 +0200
Message-ID: <20170418123955.21335-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>

The hardware has a LPI interrupt.
There is already code in the stmmac driver to parse and handle the
interrupt. However, this information was missing from the DT binding.

At the same time, improve the description of the existing interrupts.

Signed-off-by: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index f652b0c384ce..c3a7be6615c5 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -7,9 +7,12 @@ Required properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
 - interrupts: Should contain the STMMAC interrupts
-- interrupt-names: Should contain the interrupt names "macirq"
-  "eth_wake_irq" if this interrupt is supported in the "interrupts"
-  property
+- interrupt-names: Should contain a list of interrupt names corresponding to
+	the interrupts in the interrupts property, if available.
+	Valid interrupt names are:
+  - "macirq" (combined signal for various interrupt events)
+  - "eth_wake_irq" (the interrupt to manage the remote wake-up packet detection)
+  - "eth_lpi" (the interrupt that occurs when Tx or Rx enters/exits LPI state)
 - phy-mode: See ethernet.txt file in the same directory.
 - snps,reset-gpio 	gpio number for phy reset.
 - snps,reset-active-low boolean flag to indicate if phy reset is active low.
@@ -152,8 +155,8 @@ Examples:
 		compatible = "st,spear600-gmac";
 		reg = <0xe0800000 0x8000>;
 		interrupt-parent = <&vic1>;
-		interrupts = <24 23>;
-		interrupt-names = "macirq", "eth_wake_irq";
+		interrupts = <24 23 22>;
+		interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
