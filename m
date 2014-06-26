From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: [PATCH v2 1/2] ARM: at91/dt: describe rgmii ethernet phy connected to sama5d3xek boards
Date: Thu, 26 Jun 2014 12:13:34 +0200
Message-ID: <1403777615-25685-2-git-send-email-boris.brezillon@free-electrons.com>
References: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42708 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752833AbaFZKNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 06:13:40 -0400
In-Reply-To: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethernet-phy node and specify phy interrupt (connected to pin PB25).

The PHY address is not specified here because atmel have 2 different
designs
for its CPU modules: one is connecting PHYAD[0-2] pins to pull up resistors
(Embest design) and the other one is connection PHYAD0 to a pull up
resistor and PHYAD[1-2] to pull down resistors (Ronetix design).
As a result, Ronetix design will have its PHY available at address 0x1 and
Embest design at 0x7.
Let the net PHY core automatically detect the PHY address by scanning the
MDIO bus.

Define board specific delays to apply to RGMII signals.

Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
---
 arch/arm/boot/dts/sama5d3xcm.dtsi | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/arch/arm/boot/dts/sama5d3xcm.dtsi b/arch/arm/boot/dts/sama5d3xcm.dtsi
index b0b1331..fc68bae 100644
--- a/arch/arm/boot/dts/sama5d3xcm.dtsi
+++ b/arch/arm/boot/dts/sama5d3xcm.dtsi
@@ -34,6 +34,21 @@
 
 			macb0: ethernet@f0028000 {
 				phy-mode = "rgmii";
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				ethernet-phy {
+					interrupt-parent = <&pioB>;
+					interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
+					txen-skew-ps = <800>;
+					txc-skew-ps = <3000>;
+					rxdv-skew-ps = <400>;
+					rxc-skew-ps = <3000>;
+					rxd0-skew-ps = <400>;
+					rxd1-skew-ps = <400>;
+					rxd2-skew-ps = <400>;
+					rxd3-skew-ps = <400>;
+				};
 			};
 
 			pmc: pmc@fffffc00 {
-- 
1.8.3.2
