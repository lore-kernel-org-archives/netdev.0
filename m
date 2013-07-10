From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 07/12] drivers/net/can/c_can: don't use devm_pinctrl_get_select_default() in probe
Date: Wed, 10 Jul 2013 16:57:42 +0100
Message-ID: <1373471889-18107-7-git-send-email-wsa@the-dreams.de>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>,
	Jingoo Han <jg1.han@samsung.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit ab78029 (drivers/pinctrl: grab default handles from device core),
we can rely on device core for setting the default pins. Compile tested only.

Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13)
Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
 drivers/net/can/c_can/c_can_platform.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index b918c73..c6f838d 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -32,7 +32,6 @@
 #include <linux/clk.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
-#include <linux/pinctrl/consumer.h>
 
 #include <linux/can/dev.h>
 
@@ -114,7 +113,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	struct c_can_priv *priv;
 	const struct of_device_id *match;
 	const struct platform_device_id *id;
-	struct pinctrl *pinctrl;
 	struct resource *mem, *res;
 	int irq;
 	struct clk *clk;
@@ -131,11 +129,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		id = platform_get_device_id(pdev);
 	}
 
-	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
-	if (IS_ERR(pinctrl))
-		dev_warn(&pdev->dev,
-			"failed to configure pins from driver\n");
-
 	/* get the appropriate clk */
 	clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(clk)) {
-- 
1.7.10.4
