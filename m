From: Pan Bian <bianpan201602@163.com>
Subject: [PATCH 1/1] net: bcmgenet: fix incorrect return value checks
Date: Sun, 23 Apr 2017 18:01:05 +0800
Message-ID: <1492941665-17155-1-git-send-email-bianpan201602@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

Function platform_get_irq() will return a negative value on errors.
However, in function bcmgenet_probe(), 0 is considered as a flag of
error. This patch fixes the bug by checking whether the return value of
platform_get_irq() is less than 0.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 365895e..0bccf2b 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3329,7 +3329,7 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	priv->irq0 = platform_get_irq(pdev, 0);
 	priv->irq1 = platform_get_irq(pdev, 1);
 	priv->wol_irq = platform_get_irq(pdev, 2);
-	if (!priv->irq0 || !priv->irq1) {
+	if (priv->irq0 < 0 || priv->irq1 < 0) {
 		dev_err(&pdev->dev, "can't find IRQs\n");
 		err = -EINVAL;
 		goto err;
-- 
1.9.1
