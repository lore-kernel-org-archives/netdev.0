From: Mike Sinkovsky <msink@permonline.ru>
Subject: [PATCH] net: WIZnet drivers: fix possible NULL dereference
Date: Wed, 11 Apr 2012 11:53:53 +0600
Message-ID: <1334123633-11833-1-git-send-email-msink@permonline.ru>
References: <20120410084006.GA27006@elgon.mountain>
Cc: Mike Sinkovsky <msink@permonline.ru>
To: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.ccl.ru ([195.222.140.73]:50586 "EHLO mail4.ccl.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268Ab2DKFyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 01:54:22 -0400
In-Reply-To: <20120410084006.GA27006@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes possible null dereference in probe() function: when both 
.mac_addr and .link_gpio are unknown, dev.platform_data may be NULL

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Mike Sinkovsky <msink@permonline.ru>
---
 drivers/net/ethernet/wiznet/w5100.c |    2 +-
 drivers/net/ethernet/wiznet/w5300.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index c28e1d5..157d2f0 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -682,7 +682,7 @@ static int __devinit w5100_hw_probe(struct platform_device *pdev)
 		return ret;
 	priv->irq = irq;
 
-	priv->link_gpio = data->link_gpio;
+	priv->link_gpio = data ? data->link_gpio : -EINVAL;
 	if (gpio_is_valid(priv->link_gpio)) {
 		char *link_name = devm_kzalloc(&pdev->dev, 16, GFP_KERNEL);
 		if (!link_name)
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 88afde9..86d07bb 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -596,7 +596,7 @@ static int __devinit w5300_hw_probe(struct platform_device *pdev)
 		return ret;
 	priv->irq = irq;
 
-	priv->link_gpio = data->link_gpio;
+	priv->link_gpio = data ? data->link_gpio : -EINVAL;
 	if (gpio_is_valid(priv->link_gpio)) {
 		char *link_name = devm_kzalloc(&pdev->dev, 16, GFP_KERNEL);
 		if (!link_name)
-- 
1.6.3.3
