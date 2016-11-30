From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v5 net-next 7/7] ARM64: dts: marvell: Add network support for Armada 3700
Date: Wed, 30 Nov 2016 22:42:52 +0100
Message-ID: <f205231e640a2324b8f007073cf54b166a263ed4.1480542157.git-series.gregory.clement@free-electrons.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
References: <cover.0270f6d2413a709521fe2c8c17fbebea6f2e78d1.1480542157.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add neta nodes for network support both in device tree for the SoC and
the board.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 arch/arm64/boot/dts/marvell/armada-3720-db.dts | 23 +++++++++++++++++++-
 arch/arm64/boot/dts/marvell/armada-37xx.dtsi   | 23 +++++++++++++++++++-
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/arch/arm64/boot/dts/marvell/armada-3720-db.dts b/arch/arm64/boot/dts/marvell/armada-3720-db.dts
index 1372e9a6aaa4..c8b82e4145de 100644
--- a/arch/arm64/boot/dts/marvell/armada-3720-db.dts
+++ b/arch/arm64/boot/dts/marvell/armada-3720-db.dts
@@ -81,3 +81,26 @@
 &pcie0 {
 	status = "okay";
 };
+
+&mdio {
+	status = "okay";
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
+
+&eth0 {
+	phy-mode = "rgmii-id";
+	phy = <&phy0>;
+	status = "okay";
+};
+
+&eth1 {
+	phy-mode = "rgmii-id";
+	phy = <&phy1>;
+	status = "okay";
+};
diff --git a/arch/arm64/boot/dts/marvell/armada-37xx.dtsi b/arch/arm64/boot/dts/marvell/armada-37xx.dtsi
index e9bd58793464..3b8eb45bdc76 100644
--- a/arch/arm64/boot/dts/marvell/armada-37xx.dtsi
+++ b/arch/arm64/boot/dts/marvell/armada-37xx.dtsi
@@ -140,6 +140,29 @@
 				};
 			};
 
+			eth0: ethernet@30000 {
+				   compatible = "marvell,armada-3700-neta";
+				   reg = <0x30000 0x4000>;
+				   interrupts = <GIC_SPI 42 IRQ_TYPE_LEVEL_HIGH>;
+				   clocks = <&sb_periph_clk 8>;
+				   status = "disabled";
+			};
+
+			mdio: mdio@32004 {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				compatible = "marvell,orion-mdio";
+				reg = <0x32004 0x4>;
+			};
+
+			eth1: ethernet@40000 {
+				compatible = "marvell,armada-3700-neta";
+				reg = <0x40000 0x4000>;
+				interrupts = <GIC_SPI 45 IRQ_TYPE_LEVEL_HIGH>;
+				clocks = <&sb_periph_clk 7>;
+				status = "disabled";
+			};
+
 			usb3: usb@58000 {
 				compatible = "marvell,armada3700-xhci",
 				"generic-xhci";
-- 
git-series 0.8.10
