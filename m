From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 1/8] ARM: dts: armada-38x: add buffer manager nodes
Date: Tue, 16 Feb 2016 16:33:36 +0100
Message-ID: <1455636823-14470-2-git-send-email-gregory.clement@free-electrons.com>
References: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Simon Guinot <simon.guinot@sequanux.org>,
 Nadav Haklai <nadavh@marvell.com>, Timor Kardashov <timork@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Sebastian Careba <nitroshift@yahoo.com>, Marcin Wojtas <mw@semihalf.com>,
 Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
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

Armada 38x network controller supports hardware buffer management (BM).
Since it is now enabled in mvneta driver, appropriate nodes can be added
to armada-38x.dtsi - for the actual common BM unit (bm@c8000) and its
internal SRAM (bm-bppi), which is used for indirect access to buffer
pointer ring residing in DRAM.

Pools - ports mapping, bm-bppi entry in 'soc' node's ranges and optional
parameters are supposed to be set in board files.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 arch/arm/boot/dts/armada-38x.dtsi | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
index e8b7f6726772..1b7d690d8e10 100644
--- a/arch/arm/boot/dts/armada-38x.dtsi
+++ b/arch/arm/boot/dts/armada-38x.dtsi
@@ -540,6 +540,14 @@
 				status = "disabled";
 			};
 
+			bm: bm@c8000 {
+				compatible = "marvell,armada-380-neta-bm";
+				reg = <0xc8000 0xac>;
+				clocks = <&gateclk 13>;
+				internal-mem = <&bm_bppi>;
+				status = "disabled";
+			};
+
 			sata@e0000 {
 				compatible = "marvell,armada-380-ahci";
 				reg = <0xe0000 0x2000>;
@@ -618,6 +626,16 @@
 			#size-cells = <1>;
 			ranges = <0 MBUS_ID(0x09, 0x15) 0 0x800>;
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
