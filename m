From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 2/5] ARM: dts: sunxi: h3/h5: represent the mdio switch used
 by sun8i-h3-emac
Date: Sat, 26 Aug 2017 09:33:08 +0200
Message-ID: <20170826073311.25612-3-clabbe.montjoie@gmail.com>
References: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>,
 linux-arm-kernel@lists.infradead.org, icenowy@aosc.io
To: robh+dt@kernel.org, mark.rutland@arm.com, maxime.ripard@free-electrons.com,
 wens@csie.org, linux@armlinux.org.uk, peppe.cavallaro@st.com,
 alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Since dwmac-sun8i could use either an integrated PHY or an external PHY
(which could be at same MDIO address), we need to represent this selection
by a MDIO switch.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 4b599b5d26f6..5ffb940a44bb 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -417,7 +417,22 @@
 			#size-cells = <0>;
 			status = "disabled";
 
-			mdio: mdio {
+			mdio0: mdio {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				compatible = "snps,dwmac-mdio";
+			};
+
+		};
+
+		eth-phy-mux {
+			compatible = "mdio-mux";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			mdio-parent-bus = <&mdio0>;
+
+			/* Only one MDIO is usable at the time */
+			internal_mdio: mdio@1 {
 				#address-cells = <1>;
 				#size-cells = <0>;
 				int_mii_phy: ethernet-phy@1 {
@@ -425,8 +440,13 @@
 					reg = <1>;
 					clocks = <&ccu CLK_BUS_EPHY>;
 					resets = <&ccu RST_BUS_EPHY>;
+					phy-is-integrated;
 				};
 			};
+			mdio: mdio@0 {
+				#address-cells = <1>;
+				#size-cells = <0>;
+			};
 		};
 
 		spi0: spi@01c68000 {
-- 
2.13.5
