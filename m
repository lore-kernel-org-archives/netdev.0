From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v7 2/7] ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
Date: Sun,  7 Jul 2013 22:34:56 +0200
Message-ID: <1373229296-8883-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1372762824-12202-3-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:44848 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab3GGUfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 16:35:12 -0400
In-Reply-To: <1372762824-12202-3-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds mv643xx_eth and mvmdio device tree nodes for DT enabled
Kirkwood boards. Phy nodes are also added with reg property set on a
per-board basis.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v6->v7:
- fix ethernet 1 port 0 name in kirkwood.dtsi (Reported by Jonas Gorski)

v5->v6:
- rebase for v3.11-rc1
- also convert Sheevaplug and DB628x

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   16 ++++++
 arch/arm/boot/dts/kirkwood-db.dtsi                 |   16 ++++++
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
 arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi  |   16 ++++++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   16 ++++++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   16 ++++++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 ++++++++++++++++++++
 27 files changed, 430 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood-cloudbox.dts b/arch/arm/boot/dts/kirkwood-cloudbox.dts
index 00c48d2..85eed62 100644
--- a/arch/arm/boot/dts/kirkwood-cloudbox.dts
+++ b/arch/arm/boot/dts/kirkwood-cloudbox.dts
@@ -89,3 +89,19 @@
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
diff --git a/arch/arm/boot/dts/kirkwood-db.dtsi b/arch/arm/boot/dts/kirkwood-db.dtsi
index c87cfb8..ca8bf36 100644
--- a/arch/arm/boot/dts/kirkwood-db.dtsi
+++ b/arch/arm/boot/dts/kirkwood-db.dtsi
@@ -87,3 +87,19 @@
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
diff --git a/arch/arm/boot/dts/kirkwood-dnskw.dtsi b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
index 0afe1d0..f600ed7 100644
--- a/arch/arm/boot/dts/kirkwood-dnskw.dtsi
+++ b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
@@ -219,3 +219,19 @@
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
index 7714742..915aca6 100644
--- a/arch/arm/boot/dts/kirkwood-dockstar.dts
+++ b/arch/arm/boot/dts/kirkwood-dockstar.dts
@@ -90,3 +90,20 @@
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
index 36c7ba3..300fbf8 100644
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
index 31caa64..e9ba68e 100644
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
index 1e642f3..e696c31 100644
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
index 20c4b08..69019b8 100644
--- a/arch/arm/boot/dts/kirkwood-ib62x0.dts
+++ b/arch/arm/boot/dts/kirkwood-ib62x0.dts
@@ -122,3 +122,19 @@
 
 
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
index 441204e..3d99164 100644
--- a/arch/arm/boot/dts/kirkwood-iconnect.dts
+++ b/arch/arm/boot/dts/kirkwood-iconnect.dts
@@ -176,3 +176,19 @@
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
index 00a7bfe..b08c733 100644
--- a/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
+++ b/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
@@ -194,3 +194,27 @@
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
index c3f036b..ff9be45 100644
--- a/arch/arm/boot/dts/kirkwood-is2.dts
+++ b/arch/arm/boot/dts/kirkwood-is2.dts
@@ -30,3 +30,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
index 5d9f5ea..466280b 100644
--- a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
+++ b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
@@ -50,3 +50,19 @@
 		i2c-gpio,delay-us = <2>;	/* ~100 kHz */
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
index 31b17f5..93397b1 100644
--- a/arch/arm/boot/dts/kirkwood-lsxl.dtsi
+++ b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
@@ -207,3 +207,31 @@
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
index 6179333..def825f 100644
--- a/arch/arm/boot/dts/kirkwood-mplcec4.dts
+++ b/arch/arm/boot/dts/kirkwood-mplcec4.dts
@@ -191,3 +191,30 @@
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
index ad6ade7..716b203 100644
--- a/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
+++ b/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
@@ -184,3 +184,19 @@
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
index 2afac04..e7b8017 100644
--- a/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
@@ -84,3 +84,19 @@
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
index b50e93d..e93276d 100644
--- a/arch/arm/boot/dts/kirkwood-ns2.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2.dts
@@ -30,3 +30,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2lite.dts b/arch/arm/boot/dts/kirkwood-ns2lite.dts
index af8259f..34f5e69 100644
--- a/arch/arm/boot/dts/kirkwood-ns2lite.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2lite.dts
@@ -30,3 +30,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2max.dts b/arch/arm/boot/dts/kirkwood-ns2max.dts
index 85f24d2..f834c55 100644
--- a/arch/arm/boot/dts/kirkwood-ns2max.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2max.dts
@@ -49,3 +49,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2mini.dts b/arch/arm/boot/dts/kirkwood-ns2mini.dts
index 329e530..b6b66ea 100644
--- a/arch/arm/boot/dts/kirkwood-ns2mini.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2mini.dts
@@ -50,3 +50,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
index 38dc851..7235f0c 100644
--- a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
+++ b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
@@ -166,3 +166,19 @@
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
diff --git a/arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi b/arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi
index f7143f1..f55a145 100644
--- a/arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi
+++ b/arch/arm/boot/dts/kirkwood-sheevaplug-common.dtsi
@@ -91,3 +91,19 @@
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
index f2052d7..184b8c5 100644
--- a/arch/arm/boot/dts/kirkwood-topkick.dts
+++ b/arch/arm/boot/dts/kirkwood-topkick.dts
@@ -203,3 +203,19 @@
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
index 6dd1038..222435d 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6281.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
@@ -50,4 +50,6 @@
 			gpios = <&gpio0 16 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6282.dts b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
index 6fdc5ff..510c555 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6282.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
@@ -58,4 +58,6 @@
 			gpios = <&gpio1 5 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219.dtsi b/arch/arm/boot/dts/kirkwood-ts219.dtsi
index 0c9a94c..102eaeb 100644
--- a/arch/arm/boot/dts/kirkwood-ts219.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ts219.dtsi
@@ -96,3 +96,19 @@
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
index 9809fc1..e3f3f71 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -192,5 +192,57 @@
 			clocks = <&gate_clk 17>;
 			status = "okay";
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
+			compatible = "marvell,kirkwood-eth";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x72000 0x4000>;
+			clocks = <&gate_clk 0>;
+			marvell,tx-checksum-limit = <1600>;
+			status = "disabled";
+
+			ethernet0-port@0 {
+				device_type = "network";
+				compatible = "marvell,kirkwood-eth-port";
+				reg = <0>;
+				interrupts = <11>;
+				/* overwrite MAC address in bootloader */
+				local-mac-address = [00 00 00 00 00 00];
+				/* set phy-handle property in board file */
+			};
+		};
+
+		eth1: ethernet-controller@76000 {
+			compatible = "marvell,kirkwood-eth";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x76000 0x4000>;
+			clocks = <&gate_clk 19>;
+			marvell,tx-checksum-limit = <1600>;
+			status = "disabled";
+
+			ethernet1-port@0 {
+				device_type = "network";
+				compatible = "marvell,kirkwood-eth-port";
+				reg = <0>;
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
