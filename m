From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [RESEND PATCH 1/3] bindings: net: stmmac: correct note about TSO
Date: Wed, 7 Dec 2016 13:41:06 +0100
Message-ID: <1481114469-4788-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Phil Reid <preid@electromag.com.au>,
        Eric Engestrom <eric@engestrom.ch>,
        Niklas Cassel <niklass@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

snps,tso was previously placed under AXI BUS Mode parameters,
suggesting that the property should be in the stmmac-axi-config node.

TSO (TCP Segmentation Offloading) has nothing to do with AXI BUS Mode
parameters, and the parser actually expects it to be in the root node,
not in the stmmac-axi-config.

Also added a note about snps,tso only being available on GMAC4 and newer.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
Acked-by: Alexandre TORGUE <alexandre.torgue@st.com>
Acked-by: Rob Herring <robh@kernel.org>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
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
