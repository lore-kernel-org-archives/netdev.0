From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/8] ARM: dts: dra7x-evm: Prevent glitch on DCAN1 pinmux
Date: Sun, 12 Jul 2015 21:18:10 +0200
Message-ID: <1436728691-1145-8-git-send-email-mkl@pengutronix.de>
References: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Roger Quadros <rogerq@ti.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52617 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbbGLTSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 15:18:21 -0400
In-Reply-To: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Quadros <rogerq@ti.com>

Driver core sets "default" pinmux on on probe and CAN driver
sets "sleep" pinmux during register. This causes a small window
where the CAN pins are in "default" state with the DCAN module
being disabled.

Change the "default" state to be like sleep so this glitch is
avoided. Add a new "active" state that is used by the driver
when CAN is actually active.

Signed-off-by: Roger Quadros <rogerq@ti.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 arch/arm/boot/dts/dra7-evm.dts  | 5 +++--
 arch/arm/boot/dts/dra72-evm.dts | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/arm/boot/dts/dra7-evm.dts b/arch/arm/boot/dts/dra7-evm.dts
index aa465904f6cc..096f68be99e2 100644
--- a/arch/arm/boot/dts/dra7-evm.dts
+++ b/arch/arm/boot/dts/dra7-evm.dts
@@ -686,7 +686,8 @@
 
 &dcan1 {
 	status = "ok";
-	pinctrl-names = "default", "sleep";
-	pinctrl-0 = <&dcan1_pins_default>;
+	pinctrl-names = "default", "sleep", "active";
+	pinctrl-0 = <&dcan1_pins_sleep>;
 	pinctrl-1 = <&dcan1_pins_sleep>;
+	pinctrl-2 = <&dcan1_pins_default>;
 };
diff --git a/arch/arm/boot/dts/dra72-evm.dts b/arch/arm/boot/dts/dra72-evm.dts
index 4e1b60581782..803738414086 100644
--- a/arch/arm/boot/dts/dra72-evm.dts
+++ b/arch/arm/boot/dts/dra72-evm.dts
@@ -587,9 +587,10 @@
 
 &dcan1 {
 	status = "ok";
-	pinctrl-names = "default", "sleep";
-	pinctrl-0 = <&dcan1_pins_default>;
+	pinctrl-names = "default", "sleep", "active";
+	pinctrl-0 = <&dcan1_pins_sleep>;
 	pinctrl-1 = <&dcan1_pins_sleep>;
+	pinctrl-2 = <&dcan1_pins_default>;
 };
 
 &qspi {
-- 
2.1.4
