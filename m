From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v6 net-next 02/10] ARM: dts: armada-38x: add buffer manager nodes
Date: Mon, 14 Mar 2016 09:38:57 +0100
Message-ID: <1457944745-7634-3-git-send-email-gregory.clement@free-electrons.com>
References: <1457944745-7634-1-git-send-email-gregory.clement@free-electrons.com>
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
	Dmitri Epshtein <dima@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47347 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751362AbcCNIjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 04:39:12 -0400
In-Reply-To: <1457944745-7634-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 arch/arm/boot/dts/armada-38x.dtsi | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/arch/arm/boot/dts/armada-38x.dtsi b/arch/arm/boot/dts/armada-38x.dtsi
index e8b7f6726772..066a8f06405c 100644
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
@@ -618,6 +626,17 @@
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
+			no-memory-wc;
+			status = "disabled";
+		};
 	};
 
 	clocks {
-- 
2.5.0
