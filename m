From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 07/12] ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
Date: Tue, 21 May 2013 18:41:45 +0200
Message-ID: <1369154510-4927-8-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds mv643xx_eth and mvmdio device tree nodes for DT enabled
Kirkwood boards. Phy nodes are also added with reg property set on a
per-board basis.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v3->v4:
- convert to new device tree binding
- fix phy addr of kirkwood-ts219-6282.dts (Reported by Andrew Lunn)
- fix mvmdio interrupt (Reported by Simon Baatz)

Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   16 ++++++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   16 ++++++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   17 +++++++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   28 +++++++++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   16 ++++++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   30 +++++++++++
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |   16 ++++++
 arch/arm/boot/dts/kirkwood-iconnect.dts            |   16 ++++++
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |   24 +++++++++
 arch/arm/boot/dts/kirkwood-is2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |   16 ++++++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi               |   28 +++++++++++
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |   27 ++++++++++
 .../boot/dts/kirkwood-netgear_readynas_duo_v2.dts  |   16 ++++++
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |   16 ++++++
 arch/arm/boot/dts/kirkwood-ns2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-ns2lite.dts             |    2 +
 arch/arm/boot/dts/kirkwood-ns2max.dts              |    2 +
 arch/arm/boot/dts/kirkwood-ns2mini.dts             |    2 +
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |   16 ++++++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   16 ++++++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   16 ++++++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 ++++++++++++++++++++
 25 files changed, 398 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood-cloudbox.dts b/arch/arm/boot/dts/kirkwood-cloudbox.dts
index 5f21d4e..03e1b68 100644
--- a/arch/arm/boot/dts/kirkwood-cloudbox.dts
+++ b/arch/arm/boot/dts/kirkwood-cloudbox.dts
@@ -87,3 +87,19 @@
 		gpios = <&gpio0 17 0>;
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dnskw.dtsi b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
index 6875ac0..7c8bc17 100644
--- a/arch/arm/boot/dts/kirkwood-dnskw.dtsi
+++ b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
@@ -217,3 +217,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dockstar.dts b/arch/arm/boot/dts/kirkwood-dockstar.dts
index 0196cf6..b5aebbc 100644
--- a/arch/arm/boot/dts/kirkwood-dockstar.dts
+++ b/arch/arm/boot/dts/kirkwood-dockstar.dts
@@ -91,3 +91,20 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		compatible = "marvell,88e1116";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dreamplug.dts b/arch/arm/boot/dts/kirkwood-dreamplug.dts
index 289e51d..e0c93d4 100644
--- a/arch/arm/boot/dts/kirkwood-dreamplug.dts
+++ b/arch/arm/boot/dts/kirkwood-dreamplug.dts
@@ -99,3 +99,31 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		reg = <1>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
+
+&eth1 {
+	status = "okay";
+	ethernet1-port@0 {
+		phy-handle = <&ethphy1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-goflexnet.dts b/arch/arm/boot/dts/kirkwood-goflexnet.dts
index c3573be..aba5849 100644
--- a/arch/arm/boot/dts/kirkwood-goflexnet.dts
+++ b/arch/arm/boot/dts/kirkwood-goflexnet.dts
@@ -170,3 +170,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts b/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
index 44fd97d..210dfb9 100644
--- a/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
+++ b/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
@@ -96,3 +96,33 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		compatible = "marvell,88e1121";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		compatible = "marvell,88e1121";
+		reg = <1>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
+
+&eth1 {
+	status = "okay";
+	ethernet1-port@0 {
+		phy-handle = <&ethphy1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ib62x0.dts b/arch/arm/boot/dts/kirkwood-ib62x0.dts
index 5335b1a..fff3e65 100644
--- a/arch/arm/boot/dts/kirkwood-ib62x0.dts
+++ b/arch/arm/boot/dts/kirkwood-ib62x0.dts
@@ -119,3 +119,19 @@
 
 
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-iconnect.dts b/arch/arm/boot/dts/kirkwood-iconnect.dts
index 12ccf74..cfaf6bc 100644
--- a/arch/arm/boot/dts/kirkwood-iconnect.dts
+++ b/arch/arm/boot/dts/kirkwood-iconnect.dts
@@ -168,3 +168,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@11 {
+		device_type = "ethernet-phy";
+		reg = <11>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts b/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
index 3694e94..315f095 100644
--- a/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
+++ b/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
@@ -191,3 +191,27 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy1: ethernet-phy@11 {
+		device_type = "ethernet-phy";
+		reg = <11>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		speed = <1000>;
+		duplex = <1>;
+	};
+};
+
+&eth1 {
+	status = "okay";
+	ethernet1-port@0 {
+		phy-handle = <&ethphy1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-is2.dts b/arch/arm/boot/dts/kirkwood-is2.dts
index 0bdce0a..2e5fe72 100644
--- a/arch/arm/boot/dts/kirkwood-is2.dts
+++ b/arch/arm/boot/dts/kirkwood-is2.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
index 5bbd054..f9194b1 100644
--- a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
+++ b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
@@ -43,3 +43,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-lsxl.dtsi b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
index 37d45c4..dcc6470 100644
--- a/arch/arm/boot/dts/kirkwood-lsxl.dtsi
+++ b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
@@ -201,3 +201,31 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
+
+&eth1 {
+	status = "okay";
+	ethernet1-port@0 {
+		phy-handle = <&ethphy1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-mplcec4.dts b/arch/arm/boot/dts/kirkwood-mplcec4.dts
index 7588241..ceac0de 100644
--- a/arch/arm/boot/dts/kirkwood-mplcec4.dts
+++ b/arch/arm/boot/dts/kirkwood-mplcec4.dts
@@ -182,3 +182,30 @@
 	};
 };
 
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		reg = <1>;
+	};
+
+	ethphy1: ethernet-phy@2 {
+		device_type = "ethernet-phy";
+		reg = <2>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
+
+&eth1 {
+	status = "okay";
+	ethernet1-port@0 {
+		phy-handle = <&ethphy1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts b/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
index 1ca66ab..b66b2cd 100644
--- a/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
+++ b/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
@@ -178,3 +178,19 @@
                 };
         };
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ns2-common.dtsi b/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
index 6affd92..6a48bfd 100644
--- a/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
@@ -82,3 +82,19 @@
 	};
 
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy {
+		device_type = "ethernet-phy";
+                /* overwrite reg property in board file */
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ns2.dts b/arch/arm/boot/dts/kirkwood-ns2.dts
index f2d36ecf..8ffd552 100644
--- a/arch/arm/boot/dts/kirkwood-ns2.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2lite.dts b/arch/arm/boot/dts/kirkwood-ns2lite.dts
index b02eb4e..16332f8 100644
--- a/arch/arm/boot/dts/kirkwood-ns2lite.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2lite.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2max.dts b/arch/arm/boot/dts/kirkwood-ns2max.dts
index bcec4d6..68d767d 100644
--- a/arch/arm/boot/dts/kirkwood-ns2max.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2max.dts
@@ -47,3 +47,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2mini.dts b/arch/arm/boot/dts/kirkwood-ns2mini.dts
index adab1ab..5b1b17b 100644
--- a/arch/arm/boot/dts/kirkwood-ns2mini.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2mini.dts
@@ -48,3 +48,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
index d27f724..f8be3e3 100644
--- a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
+++ b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
@@ -210,3 +210,19 @@
 		};
         };
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-topkick.dts b/arch/arm/boot/dts/kirkwood-topkick.dts
index 66eb45b..34eacf2 100644
--- a/arch/arm/boot/dts/kirkwood-topkick.dts
+++ b/arch/arm/boot/dts/kirkwood-topkick.dts
@@ -201,3 +201,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6281.dts b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
index 8295c83..0bd67bf 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6281.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
@@ -49,4 +49,6 @@
 			gpios = <&gpio0 16 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6282.dts b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
index df3f95d..a675278 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6282.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
@@ -49,4 +49,6 @@
 			gpios = <&gpio1 5 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219.dtsi b/arch/arm/boot/dts/kirkwood-ts219.dtsi
index 64ea27c..68fe091 100644
--- a/arch/arm/boot/dts/kirkwood-ts219.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ts219.dtsi
@@ -76,3 +76,19 @@
 		};
 	};
 };
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy {
+		device_type = "ethernet-phy";
+                /* overwrite reg property in board file */
+	};
+};
+
+&eth0 {
+	status = "okay";
+	ethernet0-port@0 {
+		phy-handle = <&ethphy0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
index fada7e6..7c2b690 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -202,5 +202,57 @@
 			clocks = <&gate_clk 4>;
 			status = "disabled";
 		};
+
+		mdio: mdio-bus@72004 {
+			compatible = "marvell,orion-mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x72004 0x84>;
+			interrupts = <46>;
+			clocks = <&gate_clk 0>;
+			status = "disabled";
+
+			/* add phy nodes in board file */
+		};
+
+		eth0: ethernet-controller@72000 {
+			compatible = "marvell,orion-eth";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x72000 0x4000>;
+			clocks = <&gate_clk 0>;
+			marvell,tx-checksum-limit = <1600>;
+			status = "disabled";
+
+			ethernet0-port@0 {
+				device_type = "network";
+				compatible = "marvell,orion-eth-port";
+				reg = <0>;
+				interrupts = <11>;
+				/* overwrite MAC address in bootloader */
+				local-mac-address = [00 00 00 00 00 00];
+				/* set phy-handle property in board file */
+			};
+		};
+
+		eth1: ethernet-controller@76000 {
+			compatible = "marvell,orion-eth";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x76000 0x4000>;
+			clocks = <&gate_clk 19>;
+			marvell,tx-checksum-limit = <1600>;
+			status = "disabled";
+
+			ethernet1-port@1 {
+				device_type = "network";
+				compatible = "marvell,orion-eth-port";
+				reg = <1>;
+				interrupts = <15>;
+				/* overwrite MAC address in bootloader */
+				local-mac-address = [00 00 00 00 00 00];
+				/* set phy-handle property in board file */
+			};
+		};
 	};
 };
-- 
1.7.10.4
