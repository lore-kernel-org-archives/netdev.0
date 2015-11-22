From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 13/13] ARM: mvebu: enable buffer manager support on Armada XP boards
Date: Sun, 22 Nov 2015 08:53:59 +0100
Message-ID: <1448178839-3541-14-git-send-email-mw@semihalf.com>
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
enables BM on AXP-DB and AXP-GP in same manner - because number of ports
on those boards is the same as number of possible pools, each port is
supposed to use single pool for all kind of packets.

Moreover appropriate entry is added to 'soc' node ranges, as well as "okay"
status for 'bm' and 'bm-bppi' (internal SRAM) nodes.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm/boot/dts/armada-xp-db.dts | 19 ++++++++++++++++++-
 arch/arm/boot/dts/armada-xp-gp.dts | 19 ++++++++++++++++++-
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/armada-xp-db.dts b/arch/arm/boot/dts/armada-xp-db.dts
index f774101..3065730 100644
--- a/arch/arm/boot/dts/armada-xp-db.dts
+++ b/arch/arm/boot/dts/armada-xp-db.dts
@@ -77,7 +77,8 @@
 			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
 			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x1000000
 			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
-			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000>;
+			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0 0xf1200000 0x100000>;
 
 		devbus-bootcs {
 			status = "okay";
@@ -181,21 +182,33 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
 			};
 			ethernet@74000 {
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <1>;
 			};
 			ethernet@30000 {
 				status = "okay";
 				phy = <&phy2>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
 			};
 			ethernet@34000 {
 				status = "okay";
 				phy = <&phy3>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <3>;
+			};
+
+			bm@c0000 {
+				status = "okay";
 			};
 
 			mvsdio@d4000 {
@@ -230,5 +243,9 @@
 				};
 			};
 		};
+
+		bm-bppi {
+			status = "okay";
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/armada-xp-gp.dts b/arch/arm/boot/dts/armada-xp-gp.dts
index 4878d73..a1ded01 100644
--- a/arch/arm/boot/dts/armada-xp-gp.dts
+++ b/arch/arm/boot/dts/armada-xp-gp.dts
@@ -96,7 +96,8 @@
 			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
 			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x1000000
 			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
-			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000>;
+			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0 0xf1200000 0x100000>;
 
 		devbus-bootcs {
 			status = "okay";
@@ -196,21 +197,29 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "qsgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
 			};
 			ethernet@74000 {
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "qsgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <1>;
 			};
 			ethernet@30000 {
 				status = "okay";
 				phy = <&phy2>;
 				phy-mode = "qsgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
 			};
 			ethernet@34000 {
 				status = "okay";
 				phy = <&phy3>;
 				phy-mode = "qsgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <3>;
 			};
 
 			/* Front-side USB slot */
@@ -235,6 +244,10 @@
 				};
 			};
 
+			bm@c0000 {
+				status = "okay";
+			};
+
 			nand@d0000 {
 				status = "okay";
 				num-cs = <1>;
@@ -243,5 +256,9 @@
 				nand-on-flash-bbt;
 			};
 		};
+
+		bm-bppi {
+			status = "okay";
+		};
 	};
 };
-- 
1.8.3.1
