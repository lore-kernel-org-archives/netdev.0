From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 7/8] net: can: c_can: Add support for TI DRA7 DCAN
Date: Fri, 7 Nov 2014 16:49:21 +0200
Message-ID: <1415371762-29885-8-git-send-email-rogerq@ti.com>
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
Received: from devils.ext.ti.com ([198.47.26.153]:48057 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbaKGOuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 09:50:23 -0500
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DRA7 SoC has 2 CAN IPs. Provide compatible IDs and RAMINIT
register data for both.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt |  1 +
 drivers/net/can/c_can/c_can_platform.c              | 11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index a3ca3ee..f682fdb 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -4,6 +4,7 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "bosch,c_can" for C_CAN controllers and
 			  "bosch,d_can" for D_CAN controllers.
+			  Can be "ti,dra7-d_can".
 - reg			: physical base address and size of the C_CAN/D_CAN
 			  registers map
 - interrupts		: property with a value describing the interrupt
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 71b9063..7a81db4 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -195,6 +195,16 @@ static struct c_can_driver_data d_can_drvdata = {
 	.id = BOSCH_D_CAN,
 };
 
+static u8 dra7_raminit_start_bits[] = {3, 5};
+static u8 dra7_raminit_done_bits[] = {1, 2};
+static struct c_can_driver_data dra7_dcan_drvdata = {
+	.id = BOSCH_D_CAN,
+	.num_can = 2,
+	.raminit_start_bits = dra7_raminit_start_bits,
+	.raminit_done_bits = dra7_raminit_done_bits,
+	.raminit_pulse = true,
+};
+
 static struct platform_device_id c_can_id_table[] = {
 	{
 		.name = KBUILD_MODNAME,
@@ -215,6 +225,7 @@ MODULE_DEVICE_TABLE(platform, c_can_id_table);
 static const struct of_device_id c_can_of_table[] = {
 	{ .compatible = "bosch,c_can", .data = &c_can_drvdata },
 	{ .compatible = "bosch,d_can", .data = &d_can_drvdata },
+	{ .compatible = "ti,dra7-d_can", .data = &dra7_dcan_drvdata },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, c_can_of_table);
-- 
1.8.3.2
