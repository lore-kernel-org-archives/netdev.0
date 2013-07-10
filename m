From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 08/12] drivers/net/ethernet/cadence: don't use devm_pinctrl_get_select_default() in probe
Date: Wed, 10 Jul 2013 16:57:43 +0100
Message-ID: <1373471889-18107-8-git-send-email-wsa@the-dreams.de>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
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
 drivers/net/ethernet/cadence/at91_ether.c |   11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3f19571..bb5d63f 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -29,7 +29,6 @@
 #include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/of_net.h>
-#include <linux/pinctrl/consumer.h>
 
 #include "macb.h"
 
@@ -309,7 +308,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	struct resource *regs;
 	struct net_device *dev;
 	struct phy_device *phydev;
-	struct pinctrl *pinctrl;
 	struct macb *lp;
 	int res;
 	u32 reg;
@@ -319,15 +317,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	if (!regs)
 		return -ENOENT;
 
-	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
-	if (IS_ERR(pinctrl)) {
-		res = PTR_ERR(pinctrl);
-		if (res == -EPROBE_DEFER)
-			return res;
-
-		dev_warn(&pdev->dev, "No pinctrl provided\n");
-	}
-
 	dev = alloc_etherdev(sizeof(struct macb));
 	if (!dev)
 		return -ENOMEM;
-- 
1.7.10.4
