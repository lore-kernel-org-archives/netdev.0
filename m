From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 8/8] net: can: c_can: Add support for TI am3352 DCAN
Date: Fri, 7 Nov 2014 16:49:22 +0200
Message-ID: <1415371762-29885-9-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
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
Received: from arroyo.ext.ti.com ([192.94.94.40]:55218 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbaKGOuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 09:50:25 -0500
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AM3352 SoC has 2 DCAN modules. Add compatible id and
raminit driver data for am3352 DCAN.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt |  2 +-
 drivers/net/can/c_can/c_can_platform.c              | 10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index f682fdb..6731730 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -4,7 +4,7 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "bosch,c_can" for C_CAN controllers and
 			  "bosch,d_can" for D_CAN controllers.
-			  Can be "ti,dra7-d_can".
+			  Can be "ti,dra7-d_can" or "ti,am3352-d_can".
 - reg			: physical base address and size of the C_CAN/D_CAN
 			  registers map
 - interrupts		: property with a value describing the interrupt
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 7a81db4..eb09068 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -205,6 +205,15 @@ static struct c_can_driver_data dra7_dcan_drvdata = {
 	.raminit_pulse = true,
 };
 
+static u8 am3352_raminit_start_bits[] = {0, 1};
+static u8 am3352_raminit_done_bits[] = {8, 9};
+static struct c_can_driver_data am3352_dcan_drvdata = {
+	.id = BOSCH_D_CAN,
+	.num_can = 2,
+	.raminit_start_bits = am3352_raminit_start_bits,
+	.raminit_done_bits = am3352_raminit_done_bits,
+};
+
 static struct platform_device_id c_can_id_table[] = {
 	{
 		.name = KBUILD_MODNAME,
@@ -226,6 +235,7 @@ static const struct of_device_id c_can_of_table[] = {
 	{ .compatible = "bosch,c_can", .data = &c_can_drvdata },
 	{ .compatible = "bosch,d_can", .data = &d_can_drvdata },
 	{ .compatible = "ti,dra7-d_can", .data = &dra7_dcan_drvdata },
+	{ .compatible = "ti,am3352-d_can", .data = &am3352_dcan_drvdata },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, c_can_of_table);
-- 
1.8.3.2
