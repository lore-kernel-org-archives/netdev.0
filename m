From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v2 5/6] ethernet: renesas: remove unnecessary check
Date: Thu, 23 Oct 2014 07:28:50 +0530
Message-ID: <1414029531-5067-6-git-send-email-varkab@cdac.in>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:41137 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282AbaJWB7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:59:21 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so119745pab.6
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:59:20 -0700 (PDT)
In-Reply-To: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/renesas/sh_eth.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 60e9c2c..ffb49f3 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2769,10 +2769,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	/* get base addr */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (unlikely(res == NULL)) {
-		dev_err(&pdev->dev, "invalid resource\n");
-		return -EINVAL;
-	}
 
 	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
 	if (!ndev)
@@ -2781,8 +2777,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_get_sync(&pdev->dev);
 
-	/* The sh Ether-specific entries in the device structure. */
-	ndev->base_addr = res->start;
 	devno = pdev->id;
 	if (devno < 0)
 		devno = 0;
@@ -2806,6 +2800,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_release;
 	}
 
+	/* The sh Ether-specific entries in the device structure. */
+	ndev->base_addr = res->start;
+
 	spin_lock_init(&mdp->lock);
 	mdp->pdev = pdev;
 
-- 
1.7.9.5
