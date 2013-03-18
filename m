From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v2 3/4] ARM: dts: mxs: add enet_out clock to devicetree
Date: Mon, 18 Mar 2013 16:26:24 +0800
Message-ID: <1363595185-12302-4-git-send-email-shawn.guo@linaro.org>
References: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:23880
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181Ab3CRI0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:26:38 -0400
In-Reply-To: <1363595185-12302-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>

Put the clock to the devicetree, so the driver can take care of it
later. Then, we don't have to do the enabling as a workaround in board
init.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
[shawn.guo: add enet_out into imx28.dtsi and overwrite it for m28evk]
Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 arch/arm/boot/dts/imx28-m28evk.dts |    2 ++
 arch/arm/boot/dts/imx28.dtsi       |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/imx28-m28evk.dts b/arch/arm/boot/dts/imx28-m28evk.dts
index 6ce3d17..3d2e1a4 100644
--- a/arch/arm/boot/dts/imx28-m28evk.dts
+++ b/arch/arm/boot/dts/imx28-m28evk.dts
@@ -221,6 +221,8 @@
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
+			clocks = <&clks 57>, <&clks 57>;
+			clock-names = "ipg", "ahb";
 			status = "okay";
 		};
 
diff --git a/arch/arm/boot/dts/imx28.dtsi b/arch/arm/boot/dts/imx28.dtsi
index 7ba4966..dc1203d 100644
--- a/arch/arm/boot/dts/imx28.dtsi
+++ b/arch/arm/boot/dts/imx28.dtsi
@@ -940,8 +940,8 @@
 			compatible = "fsl,imx28-fec";
 			reg = <0x800f0000 0x4000>;
 			interrupts = <101>;
-			clocks = <&clks 57>, <&clks 57>;
-			clock-names = "ipg", "ahb";
+			clocks = <&clks 57>, <&clks 57>, <&clks 64>;
+			clock-names = "ipg", "ahb", "enet_out";
 			status = "disabled";
 		};
 
-- 
1.7.9.5
