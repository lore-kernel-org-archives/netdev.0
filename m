From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 10/10] arm: orion5x: Configure Netgear WNR854T network port
 LEDs
Date: Sat, 16 Jul 2016 15:29:08 +0100
Message-ID: <1468679348-10522-11-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
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

The default bootloader leaves the LEDs orange, and the 88E1121R driver
applies it's own inappropriate configuration. Configure as per manual,
i.e. orange = 100 / green = 1000 / blink = activity

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts | 45 +++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
index a8e89d8..635b396 100644
--- a/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
+++ b/arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
@@ -81,16 +81,19 @@
 			port@0 {
 				reg = <0>;
 				label = "lan3";
+				phy-handle = <&lan3phy>;
 			};
 
 			port@1 {
 				reg = <1>;
 				label = "lan4";
+				phy-handle = <&lan4phy>;
 			};
 
 			port@2 {
 				reg = <2>;
 				label = "wan";
+				phy-handle = <&wanphy>;
 			};
 
 			port@3 {
@@ -101,11 +104,13 @@
 			port@5 {
 				reg = <5>;
 				label = "lan1";
+				phy-handle = <&lan1phy>;
 			};
 
 			port@7 {
 				reg = <7>;
 				label = "lan2";
+				phy-handle = <&lan2phy>;
 			};
 		};
 	};
@@ -148,6 +153,46 @@
 
 &mdio {
 	status = "okay";
+
+	lan3phy: ethernet-phy@0 {
+		/* Marvell 88E1121R (port 1) */
+		compatible = "ethernet-phy-id0141.0cb0",
+			     "ethernet-phy-ieee802.3-c22";
+		reg = <0>;
+		marvell,reg-init = <3 16 0 0x1777 3 17 0 0x15>;
+	};
+
+	lan4phy: ethernet-phy@1 {
+		/* Marvell 88E1121R (port 2) */
+		compatible = "ethernet-phy-id0141.0cb0",
+			     "ethernet-phy-ieee802.3-c22";
+		reg = <1>;
+		marvell,reg-init = <3 16 0 0x1777 3 17 0 0x15>;
+	};
+
+	wanphy: ethernet-phy@2 {
+		/* Marvell 88E1121R (port 1) */
+		compatible = "ethernet-phy-id0141.0cb0",
+			     "ethernet-phy-ieee802.3-c22";
+		reg = <2>;
+		marvell,reg-init = <3 16 0 0x1777 3 17 0 0x15>;
+	};
+
+	lan1phy: ethernet-phy@5 {
+		/* Marvell 88E1112 */
+		compatible = "ethernet-phy-id0141.0cb0",
+			     "ethernet-phy-ieee802.3-c22";
+		reg = <5>;
+		marvell,reg-init = <3 16 0 0x1777 3 17 0 0x15>;
+	};
+
+	lan2phy: ethernet-phy@7 {
+		/* Marvell 88E1112 */
+		compatible = "ethernet-phy-id0141.0cb0",
+			     "ethernet-phy-ieee802.3-c22";
+		reg = <7>;
+		marvell,reg-init = <3 16 0 0x1777 3 17 0 0x15>;
+	};
 };
 
 &eth {
-- 
2.8.1
