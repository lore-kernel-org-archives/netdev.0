From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 11/13] ARM: dts: am437x-gp-evm: Add pinctrl sleep states for dcan pins
Date: Mon, 8 Sep 2014 17:10:40 +0300
Message-ID: <1410185442-907-12-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Dave Gerlach <d-gerlach@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:52506 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506AbaIHOLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:11:41 -0400
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Gerlach <d-gerlach@ti.com>

Define pinctrl sleep states for both dcan0 and dcan1 to place pull downs
on the lines to optimize power savings during suspend.

Signed-off-by: Dave Gerlach <d-gerlach@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 arch/arm/boot/dts/am437x-gp-evm.dts | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/am437x-gp-evm.dts b/arch/arm/boot/dts/am437x-gp-evm.dts
index 6d03baa..ca9e1ab 100644
--- a/arch/arm/boot/dts/am437x-gp-evm.dts
+++ b/arch/arm/boot/dts/am437x-gp-evm.dts
@@ -262,12 +262,26 @@
 		>;
 	};
 
+	dcan0_sleep: dcan0_sleep_pins {
+		pinctrl-single,pins = <
+			0x178 (PIN_INPUT_PULLDOWN | MUX_MODE7)
+			0x17c (PIN_INPUT_PULLDOWN | MUX_MODE7)
+		>;
+	};
+
 	dcan1_default: dcan1_default_pins {
 		pinctrl-single,pins = <
 			0x180 (PIN_OUTPUT_PULLDOWN | MUX_MODE2) /* uart1_rxd.d_can1_tx */
 			0x184 (PIN_INPUT_PULLUP | MUX_MODE2) /* uart1_txd.d_can1_rx */
 		>;
 	};
+
+	dcan1_sleep: dcan1_sleep_pins {
+		pinctrl-single,pins = <
+			0x180 (PIN_INPUT_PULLDOWN | MUX_MODE7)
+			0x184 (PIN_INPUT_PULLDOWN | MUX_MODE7)
+		>;
+	};
 };
 
 &i2c0 {
@@ -527,13 +541,15 @@
 };
 
 &dcan0 {
-	pinctrl-names = "default";
+	pinctrl-names = "default", "sleep";
 	pinctrl-0 = <&dcan0_default>;
+	pinctrl-1 = <&dcan0_sleep>;
 	status = "okay";
 };
 
 &dcan1 {
-	pinctrl-names = "default";
+	pinctrl-names = "default", "sleep";
 	pinctrl-0 = <&dcan1_default>;
+	pinctrl-1 = <&dcan1_sleep>;
 	status = "okay";
 };
-- 
1.8.3.2
