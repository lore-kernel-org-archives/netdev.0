From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 1/4] dt-bindings: net: mediatek: add support for MediaTek MT7623 and MT7622 SoC
Date: Mon, 31 Jul 2017 18:05:08 +0800
Message-ID: <f19ecd28bb71a0b991d7325b0562295bcac15861.1501494522.git.sean.wang@mediatek.com>
References: <cover.1501494522.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1501494522.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

The patch adds the supplements in the dt-binding document for MediaTek
MT7622 SoC with extra SGMII system controller and relevant clock consumers
listed as the requirements for those SoCs equipped with the SGMII circuit.
Also, add the missing binding information for MT7623 SoC here which relies
on the fallback binding of MT2701.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index c7194e8..1d1168b 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -7,24 +7,30 @@ have dual GMAC each represented by a child node..
 * Ethernet controller node
 
 Required properties:
-- compatible: Should be "mediatek,mt2701-eth"
+- compatible: Should be
+		"mediatek,mt2701-eth": for MT2701 SoC
+		"mediatek,mt7623-eth", "mediatek,mt2701-eth": for MT7623 SoC
+		"mediatek,mt7622-eth": for MT7622 SoC
 - reg: Address and length of the register set for the device
 - interrupts: Should contain the three frame engines interrupts in numeric
 	order. These are fe_int0, fe_int1 and fe_int2.
 - clocks: the clock used by the core
 - clock-names: the names of the clock listed in the clocks property. These are
-	"ethif", "esw", "gp2", "gp1"
+	"ethif", "esw", "gp2", "gp1" : For MT2701 and MT7623 SoC
+        "ethif", "esw", "gp0", "gp1", "gp2", "sgmii_tx250m", "sgmii_rx250m",
+	"sgmii_cdr_ref", "sgmii_cdr_fb", "sgmii_ck", "eth2pll" : For MT7622 SoC
 - power-domains: phandle to the power domain that the ethernet is part of
 - resets: Should contain a phandle to the ethsys reset signal
 - reset-names: Should contain the reset signal name "eth"
 - mediatek,ethsys: phandle to the syscon node that handles the port setup
+- mediatek,sgmiisys: phandle to the syscon node that handles the SGMII setup
+	which is required for those SoCs equipped with SGMII such as MT7622 SoC.
 - mediatek,pctl: phandle to the syscon node that handles the ports slew rate
 	and driver current
 
 Optional properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
-
 * Ethernet MAC node
 
 Required properties:
-- 
2.7.4
