From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v6 net-next 03/10] ARM: dts: armada-38x: enable buffer manager
 support on Armada 38x boards
Date: Mon, 14 Mar 2016 09:38:58 +0100
Message-ID: <1457944745-7634-4-git-send-email-gregory.clement@free-electrons.com>
References: <1457944745-7634-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Simon Guinot <simon.guinot@sequanux.org>,
 Dmitri Epshtein <dima@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Timor Kardashov <timork@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Sebastian Careba <nitroshift@yahoo.com>, Marcin Wojtas <mw@semihalf.com>,
 Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457944745-7634-1-git-send-email-gregory.clement@free-electrons.com>
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

From: Marcin Wojtas <mw@semihalf.com>

Since mvneta driver supports using hardware buffer management (BM), in
order to use it, board files have to be adjusted accordingly. This commit
enables BM on:
* A385-DB-AP - each port has its own pool for long and common pool for
short packets,
* A388-ClearFog - same as above,
* A388-DB - to each port unique 'short' and 'long' pools are mapped,
* A388-GP - same as above.

Moreover appropriate entry is added to 'soc' node ranges, as well as "okay"
status for 'bm' and 'bm-bppi' (internal SRAM) nodes.

[gregory.clement@free-electrons.com: add suppport for the ClearFog board]

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/boot/dts/armada-385-db-ap.dts              | 20 +++++++++++++++++++-
 arch/arm/boot/dts/armada-388-clearfog.dts           |  6 ++++++
 arch/arm/boot/dts/armada-388-db.dts                 | 17 ++++++++++++++++-
 arch/arm/boot/dts/armada-388-gp.dts                 | 17 ++++++++++++++++-
 arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi | 15 ++++++++++++++-
 5 files changed, 71 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/armada-385-db-ap.dts b/arch/arm/boot/dts/armada-385-db-ap.dts
index acd5b1519edb..5f9451be21ff 100644
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
 
diff --git a/arch/arm/boot/dts/armada-388-clearfog.dts b/arch/arm/boot/dts/armada-388-clearfog.dts
index c6e180eb3b11..c60206efb583 100644
--- a/arch/arm/boot/dts/armada-388-clearfog.dts
+++ b/arch/arm/boot/dts/armada-388-clearfog.dts
@@ -78,6 +78,9 @@
 		internal-regs {
 			ethernet@30000 {
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
+				bm,pool-short = <1>;
 				status = "okay";
 
 				fixed-link {
@@ -88,6 +91,9 @@
 
 			ethernet@34000 {
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <3>;
+				bm,pool-short = <1>;
 				status = "okay";
 
 				fixed-link {
diff --git a/arch/arm/boot/dts/armada-388-db.dts b/arch/arm/boot/dts/armada-388-db.dts
index ff47af57f091..ea93ed727030 100644
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
index cd316021d6ce..466b01eb1038 100644
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
diff --git a/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi b/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
index 3f792a563c05..8c9842237b60 100644
--- a/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
+++ b/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
@@ -58,7 +58,8 @@
 		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000
 			  MBUS_ID(0x01, 0x1d) 0 0xfff00000 0x100000
 			  MBUS_ID(0x09, 0x19) 0 0xf1100000 0x10000
-			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000>;
+			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0xf1200000 0x100000>;
 
 		internal-regs {
 			ethernet@70000 {
@@ -66,6 +67,9 @@
 				pinctrl-names = "default";
 				phy = <&phy_dedicated>;
 				phy-mode = "rgmii-id";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
+				bm,pool-short = <1>;
 				status = "okay";
 			};
 
@@ -110,6 +114,15 @@
 				pinctrl-names = "default";
 				status = "okay";
 			};
+
+			bm@c8000 {
+				status = "okay";
+			};
 		};
+
+		bm-bppi {
+			status = "okay";
+		};
+
 	};
 };
-- 
2.5.0
