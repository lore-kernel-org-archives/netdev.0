From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 05/13] ARM: dts: DRA7: Add DCAN nodes
Date: Mon, 8 Sep 2014 17:10:34 +0300
Message-ID: <1410185442-907-6-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SoC supports 2 DCAN nodes. Add them.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 arch/arm/boot/dts/dra7.dtsi | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dtsi
index 370009e..4ce1a4f 100644
--- a/arch/arm/boot/dts/dra7.dtsi
+++ b/arch/arm/boot/dts/dra7.dtsi
@@ -34,6 +34,8 @@
 		serial3 = &uart4;
 		serial4 = &uart5;
 		serial5 = &uart6;
+		d_can0 = &dcan1;
+		d_can1 = &dcan2;
 	};
 
 	timer {
@@ -1267,6 +1269,34 @@
 			ti,irqs-skip = <10 133 139 140>;
 			ti,irqs-safe-map = <0>;
 		};
+
+		dcan1: d_can@481cc000 {
+			compatible = "bosch,d_can";
+			ti,hwmods = "dcan1";
+			reg = <0x4ae3c000 0x2000>,
+			      <0x558 0x4>; /* index to RAMINIT reg within syscon */
+			raminit-syscon = <&dra7_ctrl_core>;
+			raminit-start-bit = <3>;
+			raminit-done-bit = <1>;
+			raminit-pulse;
+			interrupts = <GIC_SPI 222 IRQ_TYPE_LEVEL_HIGH>;
+			clocks = <&dcan1_sys_clk_mux>;
+			status = "disabled";
+		};
+
+		dcan2: d_can@481d0000 {
+			compatible = "bosch,d_can";
+			ti,hwmods = "dcan2";
+			reg = <0x48480000 0x2000>,
+			      <0x558 0x4>; /* index to RAMINIT reg within syscon */
+			raminit-syscon = <&dra7_ctrl_core>;
+			raminit-start-bit = <5>;
+			raminit-done-bit = <2>;
+			raminit-pulse;
+			interrupts = <GIC_SPI 225 IRQ_TYPE_LEVEL_HIGH>;
+			clocks = <&sys_clkin1>;
+			status = "disabled";
+		};
 	};
 };
 
-- 
1.8.3.2

