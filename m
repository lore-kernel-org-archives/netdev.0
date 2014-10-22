From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 5/6] ethernet: renesas: remove unnecessary check
Date: Wed, 22 Oct 2014 09:46:25 +0530
Message-ID: <1413951386-29645-6-git-send-email-varkab@cdac.in>
References: <N>
 <1413951386-29645-1-git-send-email-varkab@cdac.in>
Cc: Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:55517 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbaJVETq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 00:19:46 -0400
Received: by mail-pd0-f169.google.com with SMTP id w10so2723840pde.14
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 21:19:45 -0700 (PDT)
In-Reply-To: <1413951386-29645-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 60e9c2c..d824ba5 100644
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
-- 
1.7.9.5
