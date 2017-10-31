From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v10 4/8] ARM: dts: sunxi: h3/h5: represent the mdio switch used by sun8i-h3-emac
Date: Tue, 31 Oct 2017 09:19:11 +0100
Message-ID: <20171031081915.18960-5-clabbe.montjoie@gmail.com>
References: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:53159 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752823AbdJaIV1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 04:21:27 -0400
In-Reply-To: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dwmac-sun8i could use either an integrated PHY or an external PHY
(which could be at same MDIO address), we need to represent this selection
by a MDIO switch.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index d762098fc589..408df33e947b 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -425,11 +425,34 @@
 			mdio: mdio {
 				#address-cells = <1>;
 				#size-cells = <0>;
-				int_mii_phy: ethernet-phy@1 {
-					compatible = "ethernet-phy-ieee802.3-c22";
+				compatible = "snps,dwmac-mdio";
+			};
+
+			mdio-mux {
+				compatible = "allwinner,sun8i-h3-mdio-mux";
+				#address-cells = <1>;
+				#size-cells = <0>;
+
+				mdio-parent-bus = <&mdio>;
+				/* Only one MDIO is usable at the time */
+				internal_mdio: mdio@1 {
+					compatible = "allwinner,sun8i-h3-mdio-internal";
 					reg = <1>;
-					clocks = <&ccu CLK_BUS_EPHY>;
-					resets = <&ccu RST_BUS_EPHY>;
+					#address-cells = <1>;
+					#size-cells = <0>;
+
+					int_mii_phy: ethernet-phy@1 {
+						compatible = "ethernet-phy-ieee802.3-c22";
+						reg = <1>;
+						clocks = <&ccu CLK_BUS_EPHY>;
+						resets = <&ccu RST_BUS_EPHY>;
+					};
+				};
+
+				external_mdio: mdio@2 {
+					reg = <2>;
+					#address-cells = <1>;
+					#size-cells = <0>;
 				};
 			};
 		};
-- 
2.13.6
