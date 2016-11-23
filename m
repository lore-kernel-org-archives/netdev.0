From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
Subject: [PATCH 1/4] bindings: net: stmmac: correct note about TSO
Date: Wed, 23 Nov 2016 15:24:25 +0100
Message-ID: <1479911066-19752-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>,
        Niklas Cassel <niklass-VrBV9hrLPhE@public.gmane.org>,
        Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>

snps,tso was previously placed under AXI BUS Mode parameters,
suggesting that the property should be in the stmmac-axi-config node.

TSO (TCP Segmentation Offloading) has nothing to do with AXI BUS Mode
parameters, and the parser actually expects it to be in the root node,
not in the stmmac-axi-config.

Also added a note about snps,tso only being available on GMAC4 and newer.

Signed-off-by: Niklas Cassel <niklas.cassel-VrBV9hrLPhE@public.gmane.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 41b49e6075f5..b95ff998ba73 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -1,7 +1,7 @@
 * STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
 
 Required properties:
-- compatible: Should be "snps,dwmac-<ip_version>" "snps,dwmac"
+- compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
 	For backwards compatibility: "st,spear600-gmac" is also supported.
 - reg: Address and length of the register set for the device
 - interrupt-parent: Should be the phandle for the interrupt controller
@@ -50,6 +50,8 @@ Optional properties:
 - snps,ps-speed: port selection speed that can be passed to the core when
 		 PCS is supported. For example, this is used in case of SGMII
 		 and MAC2MAC connection.
+- snps,tso: this enables the TSO feature otherwise it will be managed by
+		 MAC HW capability register. Only for GMAC4 and newer.
 - AXI BUS Mode parameters: below the list of all the parameters to program the
 			   AXI register inside the DMA module:
 	- snps,lpi_en: enable Low Power Interface
@@ -62,8 +64,6 @@ Optional properties:
 	- snps,fb: fixed-burst
 	- snps,mb: mixed-burst
 	- snps,rb: rebuild INCRx Burst
-	- snps,tso: this enables the TSO feature otherwise it will be managed by
-	    MAC HW capability register.
 - mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
 
 Examples:
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
