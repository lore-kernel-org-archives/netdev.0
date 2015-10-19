From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] net, can, ti_hecc: fix a run time warn_on.
Date: Mon, 19 Oct 2015 08:22:18 +0200
Message-ID: <1445235739-26537-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a warning in clk_enable by calling
clk_prepare_enable instead.

Signed-off-by: Heiko Schocher <hs@denx.de>
---

 drivers/net/can/ti_hecc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index cf345cb..c08e8ea 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -951,7 +951,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
 	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
 		HECC_DEF_NAPI_WEIGHT);
 
-	clk_enable(priv->clk);
+	clk_prepare_enable(priv->clk);
 	err = register_candev(ndev);
 	if (err) {
 		dev_err(&pdev->dev, "register_candev() failed\n");
-- 
2.1.0

