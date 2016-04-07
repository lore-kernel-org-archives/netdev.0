From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 1/9] net: mediatek: update the IRQ part of the binding document
Date: Thu,  7 Apr 2016 19:57:48 +0200
Message-ID: <1460051876-53135-1-git-send-email-blogic@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
	<sean.wang@mediatek.com>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <blogic@openwrt.org>, devicetree@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caladan.dune.hu ([78.24.191.180]:38736 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932386AbcDGR6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 13:58:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current binding document only describes a single interrupt. Update the
document by adding the 2 other interrupts.

The driver currently only uses a single interrupt. The HW is however able
to using IRQ grouping to split TX and RX onto separate GIC irqs.

Signed-off-by: John Crispin <blogic@openwrt.org>
Cc: devicetree@vger.kernel.org
---
 Documentation/devicetree/bindings/net/mediatek-net.txt |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index 5ca7929..2f142be 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -9,7 +9,7 @@ have dual GMAC each represented by a child node..
 Required properties:
 - compatible: Should be "mediatek,mt7623-eth"
 - reg: Address and length of the register set for the device
-- interrupts: Should contain the frame engines interrupt
+- interrupts: Should contain the three frame engines interrupts
 - clocks: the clock used by the core
 - clock-names: the names of the clock listed in the clocks property. These are
 	"ethif", "esw", "gp2", "gp1"
@@ -42,7 +42,9 @@ eth: ethernet@1b100000 {
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
