From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v3 8/8] net: can: c_can: Add support for TI am3352 DCAN
Date: Tue, 4 Nov 2014 12:21:01 +0200
Message-ID: <1415096461-25576-9-git-send-email-rogerq@ti.com>
References: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:49530 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbaKDKWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 05:22:09 -0500
In-Reply-To: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AM3352 SoC has 2 DCAN modules. Add compatible id and
raminit driver data for am3352 DCAN.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt |  3 ++-
 drivers/net/can/c_can/c_can_platform.c              | 14 ++++++++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 746cc07..27205d9 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -4,7 +4,8 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "bosch,c_can" for C_CAN controllers and
 			  "bosch,d_can" for D_CAN controllers.
-			  Can be "ti,dra7-d_can1" or "ti,dra7-d_can2".
+			  Can be "ti,dra7-d_can1" or "ti,dra7-d_can2" or
+			  "ti,am3352-d_can0" or "ti,am3352-d_can1".
 - reg			: physical base address and size of the C_CAN/D_CAN
 			  registers map
 - interrupts		: property with a value describing the interrupt
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index dc618ce..7dcdcde 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -209,6 +209,18 @@ static struct c_can_driver_data dra7_dcan2_drvdata = {
 	.raminit_pulse = true,
 };
 
+static struct c_can_driver_data am3352_dcan0_drvdata = {
+	.id = BOSCH_D_CAN,
+	.raminit_start_bit = 0,
+	.raminit_done_bit = 8,
+};
+
+static struct c_can_driver_data am3352_dcan1_drvdata = {
+	.id = BOSCH_D_CAN,
+	.raminit_start_bit = 1,
+	.raminit_done_bit = 9,
+};
+
 static struct platform_device_id c_can_id_table[] = {
 	{
 		.name = KBUILD_MODNAME,
@@ -231,6 +243,8 @@ static const struct of_device_id c_can_of_table[] = {
 	{ .compatible = "bosch,d_can", .data = &d_can_drvdata },
 	{ .compatible = "ti,dra7-d_can1", .data = &dra7_dcan1_drvdata },
 	{ .compatible = "ti,dra7-d_can2", .data = &dra7_dcan2_drvdata },
+	{ .compatible = "ti,am3352-d_can0", .data = &am3352_dcan0_drvdata },
+	{ .compatible = "ti,am3352-d_can1", .data = &am3352_dcan1_drvdata },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, c_can_of_table);
-- 
1.8.3.2
