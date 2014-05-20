From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 1/2] ARM: dts: imx6sl: add fec sleep pinctrl for pin PM state
Date: Tue, 20 May 2014 14:50:44 +0800
Message-ID: <1400568645-10214-2-git-send-email-b38611@freescale.com>
References: <1400568645-10214-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>, <B38611@freescale.com>,
	<b20596@freescale.com>
To: <davem@davemloft.net>, <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:6834
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751988AbaETIJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 04:09:03 -0400
In-Reply-To: <1400568645-10214-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when system suspend, need to set pins to low power state to
save IO power consumption, there are three states of pinctrl:
"default", "idle" and "sleep". Currently enet supports default
and sleep state.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx6sl-evk.dts |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/arch/arm/boot/dts/imx6sl-evk.dts b/arch/arm/boot/dts/imx6sl-evk.dts
index a8d9a93..050786d 100644
--- a/arch/arm/boot/dts/imx6sl-evk.dts
+++ b/arch/arm/boot/dts/imx6sl-evk.dts
@@ -116,8 +116,9 @@
 };
 
 &fec {
-	pinctrl-names = "default";
+	pinctrl-names = "default", "sleep";
 	pinctrl-0 = <&pinctrl_fec>;
+	pinctrl-1 = <&pinctrl_fec_sleep>;
 	phy-mode = "rmii";
 	status = "okay";
 };
@@ -300,6 +301,19 @@
 			>;
 		};
 
+		pinctrl_fec_sleep: fecgrp-sleep {
+			fsl,pins = <
+				MX6SL_PAD_FEC_MDC__GPIO4_IO23      0x3080
+				MX6SL_PAD_FEC_CRS_DV__GPIO4_IO25   0x3080
+				MX6SL_PAD_FEC_RXD0__GPIO4_IO17     0x3080
+				MX6SL_PAD_FEC_RXD1__GPIO4_IO18     0x3080
+				MX6SL_PAD_FEC_TX_EN__GPIO4_IO22    0x3080
+				MX6SL_PAD_FEC_TXD0__GPIO4_IO24     0x3080
+				MX6SL_PAD_FEC_TXD1__GPIO4_IO16     0x3080
+				MX6SL_PAD_FEC_REF_CLK__GPIO4_IO26  0x3080
+			>;
+		};
+
 		pinctrl_i2c1: i2c1grp {
 			fsl,pins = <
 				MX6SL_PAD_I2C1_SCL__I2C1_SCL	0x4001b8b1
-- 
1.7.8
