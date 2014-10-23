From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v2 4/6] ethernet: marvell: remove unnecessary check
Date: Thu, 23 Oct 2014 07:28:49 +0530
Message-ID: <1414029531-5067-5-git-send-email-varkab@cdac.in>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:45621 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161AbaJWB7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:59:17 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so102330pdi.24
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:59:17 -0700 (PDT)
In-Reply-To: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index c3b209c..a378c92 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1505,16 +1505,14 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	pep = netdev_priv(dev);
 	pep->dev = dev;
 	pep->clk = clk;
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL) {
-		err = -ENODEV;
-		goto err_netdev;
-	}
 	pep->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(pep->base)) {
 		err = -ENOMEM;
 		goto err_netdev;
 	}
+
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
 	dev->irq = res->start;
-- 
1.7.9.5
