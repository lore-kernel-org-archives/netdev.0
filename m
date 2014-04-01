From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 03/16] can: c_can: free_c_can_dev(): add missing netif_napi_del()
Date: Tue,  1 Apr 2014 23:42:17 +0200
Message-ID: <1396388550-23081-4-git-send-email-mkl@pengutronix.de>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the missing netif_napi_del() to the free_c_can_dev() function.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 951bfed..6c03731 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1269,6 +1269,9 @@ EXPORT_SYMBOL_GPL(c_can_power_up);
 
 void free_c_can_dev(struct net_device *dev)
 {
+	struct c_can_priv *priv = netdev_priv(dev);
+
+	netif_napi_del(&priv->napi);
 	free_candev(dev);
 }
 EXPORT_SYMBOL_GPL(free_c_can_dev);
-- 
1.9.0.279.gdc9e3eb

