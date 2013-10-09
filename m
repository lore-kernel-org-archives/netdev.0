From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: at91-can: fix device to driver data mapping for platform devices
Date: Wed,  9 Oct 2013 23:11:58 +0200
Message-ID: <1381353118-25111-4-git-send-email-mkl@pengutronix.de>
References: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>,
	Ludovic Desroches <ludovic.desroches@atmel.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In commit:

    3078cde7 can: at91_can: add dt support

device tree support was added to the at91_can driver. In this commit the
mapping of device to driver data was mixed up. This results in the sam9x5
parameters being used for the sam9263 and the workaround for the broken mailbox
0 on the sam9263 not being activated.

This patch fixes the broken platform_device_id table.

Cc: linux-stable <stable@vger.kernel.org>
Cc: Ludovic Desroches <ludovic.desroches@atmel.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/at91_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 3b1ff61..693d8ff 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1405,10 +1405,10 @@ static int at91_can_remove(struct platform_device *pdev)
 
 static const struct platform_device_id at91_can_id_table[] = {
 	{
-		.name = "at91_can",
+		.name = "at91sam9x5_can",
 		.driver_data = (kernel_ulong_t)&at91_at91sam9x5_data,
 	}, {
-		.name = "at91sam9x5_can",
+		.name = "at91_can",
 		.driver_data = (kernel_ulong_t)&at91_at91sam9263_data,
 	}, {
 		/* sentinel */
-- 
1.8.4.rc3

