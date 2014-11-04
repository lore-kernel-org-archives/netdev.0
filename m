From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v3 7/8] net: can: c_can: Add support for TI DRA7 DCAN
Date: Tue, 4 Nov 2014 12:21:00 +0200
Message-ID: <1415096461-25576-8-git-send-email-rogerq@ti.com>
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
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1415096461-25576-1-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DRA7 SoC has 2 CAN IPs. Provide compatible IDs and RAMINIT
register data for both.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 Documentation/devicetree/bindings/net/can/c_can.txt |  1 +
 drivers/net/can/c_can/c_can_platform.c              | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 917ac0e..746cc07 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -4,6 +4,7 @@ Bosch C_CAN/D_CAN controller Device Tree Bindings
 Required properties:
 - compatible		: Should be "bosch,c_can" for C_CAN controllers and
 			  "bosch,d_can" for D_CAN controllers.
+			  Can be "ti,dra7-d_can1" or "ti,dra7-d_can2".
 - reg			: physical base address and size of the C_CAN/D_CAN
 			  registers map
 - interrupts		: property with a value describing the interrupt
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index d058820..dc618ce 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -195,6 +195,20 @@ static struct c_can_driver_data d_can_drvdata = {
 	.id = BOSCH_D_CAN,
 };
 
+static struct c_can_driver_data dra7_dcan1_drvdata = {
+	.id = BOSCH_D_CAN,
+	.raminit_start_bit = 3,
+	.raminit_done_bit = 1,
+	.raminit_pulse = true,
+};
+
+static struct c_can_driver_data dra7_dcan2_drvdata = {
+	.id = BOSCH_D_CAN,
+	.raminit_start_bit = 5,
+	.raminit_done_bit = 2,
+	.raminit_pulse = true,
+};
+
 static struct platform_device_id c_can_id_table[] = {
 	{
 		.name = KBUILD_MODNAME,
@@ -215,6 +229,8 @@ MODULE_DEVICE_TABLE(platform, c_can_id_table);
 static const struct of_device_id c_can_of_table[] = {
 	{ .compatible = "bosch,c_can", .data = &c_can_drvdata },
 	{ .compatible = "bosch,d_can", .data = &d_can_drvdata },
+	{ .compatible = "ti,dra7-d_can1", .data = &dra7_dcan1_drvdata },
+	{ .compatible = "ti,dra7-d_can2", .data = &dra7_dcan2_drvdata },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, c_can_of_table);
-- 
1.8.3.2

