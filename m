From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 3/8] ARM: dts: armada-xp: add buffer manager nodes
Date: Tue, 16 Feb 2016 16:33:38 +0100
Message-ID: <1455636823-14470-4-git-send-email-gregory.clement@free-electrons.com>
References: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcin Wojtas <mw@semihalf.com>

Armada XP network controller supports hardware buffer management (BM).
Since it is now enabled in mvneta driver, appropriate nodes can be added
to armada-xp.dtsi - for the actual common BM unit (bm@c0000) and its
internal SRAM (bm-bppi), which is used for indirect access to buffer
pointer ring residing in DRAM.

Pools - ports mapping, bm-bppi entry in 'soc' node's ranges and optional
parameters are supposed to be set in board files.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp.dtsi | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/arm/boot/dts/armada-xp.dtsi b/arch/arm/boot/dts/armada-xp.dtsi
index be23196829bb..bd459360d7a6 100644
--- a/arch/arm/boot/dts/armada-xp.dtsi
+++ b/arch/arm/boot/dts/armada-xp.dtsi
@@ -253,6 +253,14 @@
 				marvell,crypto-sram-size = <0x800>;
 			};
 
+			bm: bm@c0000 {
+				compatible = "marvell,armada-380-neta-bm";
+				reg = <0xc0000 0xac>;
+				clocks = <&gateclk 13>;
+				internal-mem = <&bm_bppi>;
+				status = "disabled";
+			};
+
 			xor@f0900 {
 				compatible = "marvell,orion-xor";
 				reg = <0xF0900 0x100
@@ -291,6 +299,16 @@
 			#size-cells = <1>;
 			ranges = <0 MBUS_ID(0x09, 0x05) 0 0x800>;
 		};
+
+		bm_bppi: bm-bppi {
+			compatible = "mmio-sram";
+			reg = <MBUS_ID(0x0c, 0x04) 0 0x100000>;
+			ranges = <0 MBUS_ID(0x0c, 0x04) 0 0x100000>;
+			#address-cells = <1>;
+			#size-cells = <1>;
+			clocks = <&gateclk 13>;
+			status = "disabled";
+		};
 	};
 
 	clocks {
-- 
2.5.0
