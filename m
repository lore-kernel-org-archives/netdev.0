From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 7/7] drivers/net/can/cc770/cc770_platform.c: adjust suspicious bit operation
Date: Wed,  6 Jun 2012 23:41:41 +0200
Message-ID: <1339018901-28439-8-git-send-email-Julia.Lawall@lip6.fr>
References: <1339018901-28439-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com,
	Julia Lawall <julia@diku.dk>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339018901-28439-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

CPUIF_DSC is 0x40, so it would seem that & is wanted rather than |.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/can/cc770/cc770_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index 53115ee..688371c 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -154,7 +154,7 @@ static int __devinit cc770_get_platform_data(struct platform_device *pdev,
 	struct cc770_platform_data *pdata = pdev->dev.platform_data;
 
 	priv->can.clock.freq = pdata->osc_freq;
-	if (priv->cpu_interface | CPUIF_DSC)
+	if (priv->cpu_interface & CPUIF_DSC)
 		priv->can.clock.freq /= 2;
 	priv->clkout = pdata->cor;
 	priv->bus_config = pdata->bcr;
