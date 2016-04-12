From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V3] net: mediatek: update the IRQ part of the binding document
Date: Tue, 12 Apr 2016 08:35:18 +0200
Message-ID: <1460442918-6070-1-git-send-email-blogic@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <blogic@openwrt.org>,
	devicetree@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caladan.dune.hu ([78.24.191.180]:44668 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752087AbcDLGf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 02:35:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current binding document only describes a single interrupt. Update the
document by adding the 2 other interrupts.

The driver currently only uses a single interrupt. The HW is however able
to using IRQ grouping to split TX and RX onto separate GIC irqs.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: devicetree@vger.kernel.org
---
This binding doc was merged in 4.6-rc1 and there are no users yet. The
current driver only uses 1 irq but will work fine with all 3 listed in
the devicetree. This patch should be merged before v4.6 is final such
that listing all 3 irqs becomes part of the ABI. I have already posted
a patch that utilizes all 3 irqs for next-next for v4.7 inclusion.

Changes in V3:
* be verbose about the 3 irqs and their ordering

Changes in V2:
* split this patch out of the series that fixes tx stalls in the driver

 Documentation/devicetree/bindings/net/mediatek-net.txt |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 5ca7929..32eaaca 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -9,7 +9,8 @@ have dual GMAC each represented by a child node..
 Required properties:
 - compatible: Should be "mediatek,mt7623-eth"
 - reg: Address and length of the register set for the device
-- interrupts: Should contain the frame engines interrupt
+- interrupts: Should contain the three frame engines interrupts in numeric
+	order. These are fe_int0, fe_int1 and fe_int2.
 - clocks: the clock used by the core
 - clock-names: the names of the clock listed in the clocks property. These are
 	"ethif", "esw", "gp2", "gp1"
@@ -42,7 +43,9 @@ eth: ethernet@1b100000 {
 		 <&ethsys CLK_ETHSYS_GP2>,
 		 <&ethsys CLK_ETHSYS_GP1>;
 	clock-names = "ethif", "esw", "gp2", "gp1";
-	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW>;
+	interrupts = <GIC_SPI 200 IRQ_TYPE_LEVEL_LOW
+		      GIC_SPI 199 IRQ_TYPE_LEVEL_LOW
+		      GIC_SPI 198 IRQ_TYPE_LEVEL_LOW>;
 	power-domains = <&scpsys MT2701_POWER_DOMAIN_ETH>;
 	resets = <&ethsys MT2701_ETHSYS_ETH_RST>;
 	reset-names = "eth";
-- 
1.7.10.4
