From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 11/13] ARM: mvebu: enable buffer manager support on Armada 38x boards
Date: Sun, 22 Nov 2015 08:53:57 +0100
Message-ID: <1448178839-3541-12-git-send-email-mw@semihalf.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since mvneta driver supports using hardware buffer management (BM), in
order to use it, board files have to be adjusted accordingly. This commit
enables BM on:
* A385-DB-AP - each port has its own pool for long and common pool for
short packets,
* A388-DB - to each port unique 'short' and 'long' pools are mapped,
* A388-GP - same as above.

Moreover appropriate entry is added to 'soc' node ranges, as well as "okay"
status for 'bm' and 'bm-bppi' (internal SRAM) nodes.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm/boot/dts/armada-385-db-ap.dts | 20 +++++++++++++++++++-
 arch/arm/boot/dts/armada-388-db.dts    | 17 ++++++++++++++++-
 arch/arm/boot/dts/armada-388-gp.dts    | 17 ++++++++++++++++-
 3 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/arch/arm/boot/dts/armada-385-db-ap.dts b/arch/arm/boot/dts/armada-385-db-ap.dts
index acd5b15..5f9451b 100644
--- a/arch/arm/boot/dts/armada-385-db-ap.dts
+++ b/arch/arm/boot/dts/armada-385-db-ap.dts
@@ -61,7 +61,8 @@
 		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000
 			  MBUS_ID(0x01, 0x1d) 0 0xfff00000 0x100000
 			  MBUS_ID(0x09, 0x19) 0 0xf1100000 0x10000
-			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000>;
+			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0xf1200000 0x100000>;
 
 		internal-regs {
 			spi1: spi@10680 {
@@ -138,12 +139,18 @@
 				status = "okay";
 				phy = <&phy2>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <1>;
+				bm,pool-short = <3>;
 			};
 
 			ethernet@34000 {
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
+				bm,pool-short = <3>;
 			};
 
 			ethernet@70000 {
@@ -157,6 +164,13 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
+				bm,pool-short = <3>;
+			};
+
+			bm@c8000 {
+				status = "okay";
 			};
 
 			nfc: flash@d0000 {
@@ -178,6 +192,10 @@
 			};
 		};
 
+		bm-bppi {
+			status = "okay";
+		};
+
 		pcie-controller {
 			status = "okay";
 
diff --git a/arch/arm/boot/dts/armada-388-db.dts b/arch/arm/boot/dts/armada-388-db.dts
index ff47af5..ea93ed7 100644
--- a/arch/arm/boot/dts/armada-388-db.dts
+++ b/arch/arm/boot/dts/armada-388-db.dts
@@ -66,7 +66,8 @@
 		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000
 			  MBUS_ID(0x01, 0x1d) 0 0xfff00000 0x100000
 			  MBUS_ID(0x09, 0x19) 0 0xf1100000 0x10000
-			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000>;
+			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0xf1200000 0x100000>;
 
 		internal-regs {
 			spi@10600 {
@@ -99,6 +100,9 @@
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
+				bm,pool-short = <3>;
 			};
 
 			usb@58000 {
@@ -109,6 +113,9 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
+				bm,pool-short = <1>;
 			};
 
 			mdio@72004 {
@@ -129,6 +136,10 @@
 				status = "okay";
 			};
 
+			bm@c8000 {
+				status = "okay";
+			};
+
 			flash@d0000 {
 				status = "okay";
 				num-cs = <1>;
@@ -169,6 +180,10 @@
 			};
 		};
 
+		bm-bppi {
+			status = "okay";
+		};
+
 		pcie-controller {
 			status = "okay";
 			/*
diff --git a/arch/arm/boot/dts/armada-388-gp.dts b/arch/arm/boot/dts/armada-388-gp.dts
index a633be3..0a3bd7f 100644
--- a/arch/arm/boot/dts/armada-388-gp.dts
+++ b/arch/arm/boot/dts/armada-388-gp.dts
@@ -60,7 +60,8 @@
 		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000
 			  MBUS_ID(0x01, 0x1d) 0 0xfff00000 0x100000
 			  MBUS_ID(0x09, 0x19) 0 0xf1100000 0x10000
-			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000>;
+			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0xf1200000 0x100000>;
 
 		internal-regs {
 			spi@10600 {
@@ -133,6 +134,9 @@
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
+				bm,pool-short = <3>;
 			};
 
 			/* CON4 */
@@ -152,6 +156,9 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
+				bm,pool-short = <1>;
 			};
 
 
@@ -186,6 +193,10 @@
 				};
 			};
 
+			bm@c8000 {
+				status = "okay";
+			};
+
 			sata@e0000 {
 				pinctrl-names = "default";
 				pinctrl-0 = <&sata2_pins>, <&sata3_pins>;
@@ -240,6 +251,10 @@
 			};
 		};
 
+		bm-bppi {
+			status = "okay";
+		};
+
 		pcie-controller {
 			status = "okay";
 			/*
-- 
1.8.3.1
