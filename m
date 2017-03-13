From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/4] dt-bindings: net: dsa: add Mediatek MT7530
 binding
Date: Tue, 14 Mar 2017 00:11:25 +0800
Message-ID: <1489421488-300-2-git-send-email-sean.wang@mediatek.com>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <andrew-g2DYL2Zd6BY@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>, <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1489421488-300-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

Add device-tree binding for Mediatek MT7530 switch.

Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 .../devicetree/bindings/net/dsa/mt7530.txt         | 94 ++++++++++++++++++++++
 1 file changed, 94 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/mt7530.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/mt7530.txt b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
new file mode 100644
index 0000000..0e50dbf
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
@@ -0,0 +1,94 @@
+Mediatek MT7530 Ethernet switch
+================================
+
+Required properties:
+
+- compatible: Must be compatible = "mediatek,mt7530";
+- #address-cells: Must be 1
+- #size-cells: Must be 0
+- mediatek,ethsys: Phandle to the syscon node that handles the reset.
+- mediatek,ethernet: Phandle to the syscon node that Mediatek ethernet driver
+	provides that handles the TRGMII setup used by the switch.
+	See
+	Documentation/devicetree/bindings/net/mediatek-net.txt for the detailed
+	setup on mediatek ethernet.
+- mediatek,mcm: String, should be "enabled" or "disabled" to indicate that
+	either MT7530 is the part on multi-chip module belong to MT7623A has
+	or the remotely standalone chip as the function MT7623N reference board
+	provided for.
+- core-supply: Phandle to the regulator node necessary for the core power.
+- io-supply: Phandle to the regulator node necessary for the I/O power
+	See Documentation/devicetree/bindings/regulator/mt6323-regulator.txt
+	for details for the regulator setup on these boards.
+- mediatek,reset-pin: Phandle to the pinctrl node used for the reset. Which
+	must be required if the property mediatek,mcm of specified as
+	"disabled". See
+	Documentation/devicetree/bindings/pinctrl/pinctrl-mt65xx.txt for
+	the mediatek pintcrl setting for the details.
+
+Each port children node within ports container must have the following
+mandatory properties:
+- reg			: Port address described must be 6 for CPU port
+			and from 0 to 5 for user ports.
+
+See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
+required, optional properties and how the integrated switch subnodes must
+be specified.
+
+Example:
+
+	&mdio0 {
+		switch@0 {
+			compatible = "mediatek,mt7530";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0>;
+
+			mediatek,ethsys = <&ethsys>;
+			mediatek,ethernet = <&eth>;
+			mediatek,mcm = "enabled";
+			core-supply = <&mt6323_vpa_reg>;
+			io-supply = <&mt6323_vemc3v3_reg>;
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				reg = <0>;
+				port@0 {
+					reg = <0>;
+					label = "lan0";
+				};
+
+				port@1 {
+					reg = <1>;
+					label = "lan1";
+				};
+
+				port@2 {
+					reg = <2>;
+					label = "lan2";
+				};
+
+				port@3 {
+					reg = <3>;
+					label = "lan3";
+				};
+
+				port@4 {
+					reg = <4>;
+					label = "wan";
+				};
+
+				port@6 {
+					reg = <6>;
+					label = "cpu";
+					ethernet = <&eth>;
+					phy-mode = "trgmii";
+					fixed-link {
+						speed = <1000>;
+						full-duplex;
+					};
+				};
+			};
+		};
+	};
-- 
1.9.1
