From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/6] can: gs_usb: fix memory leak in gs_cmd_reset()
Date: Fri,  9 Jun 2017 14:55:11 +0200
Message-ID: <20170609125513.24436-5-mkl@pengutronix.de>
References: <20170609125513.24436-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-stable <stable@vger.kernel.org>,
        Maximilian Schneider <max@schneidersoft.net>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170609125513.24436-1-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the missing kfree() in gs_cmd_reset() to free the
memory that is not used anymore after usb_control_msg().

Cc: linux-stable <stable@vger.kernel.org>
Cc: Maximilian Schneider <max@schneidersoft.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index eecee7f8dfb7..afcc1312dbaf 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -265,6 +265,8 @@ static int gs_cmd_reset(struct gs_usb *gsusb, struct gs_can *gsdev)
 			     sizeof(*dm),
 			     1000);
 
+	kfree(dm);
+
 	return rc;
 }
 
-- 
2.11.0
