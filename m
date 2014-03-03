From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 6/8] can: flexcan: flexcan_remove(): add missing netif_napi_del()
Date: Mon,  3 Mar 2014 14:54:33 +0100
Message-ID: <1393854875-8171-7-git-send-email-mkl@pengutronix.de>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the missing netif_napi_del() to the flexcan_remove() function.

Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 330b5b9..dff4fa4 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -1184,9 +1184,10 @@ static int flexcan_probe(struct platform_device *pdev)
 static int flexcan_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
+	struct flexcan_priv *priv = netdev_priv(dev);
 
 	unregister_flexcandev(dev);
-
+	netif_napi_del(&priv->napi);
 	free_candev(dev);
 
 	return 0;
-- 
1.9.0
