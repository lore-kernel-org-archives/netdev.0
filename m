From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 1/6] ethernet: wiznet: remove unnecessary check
Date: Wed, 22 Oct 2014 09:46:21 +0530
Message-ID: <1413951386-29645-2-git-send-email-varkab@cdac.in>
References: <N>
 <1413951386-29645-1-git-send-email-varkab@cdac.in>
Cc: Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34932 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbaJVETe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 00:19:34 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so2823109pab.24
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 21:19:33 -0700 (PDT)
In-Reply-To: <1413951386-29645-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/wiznet/w5100.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 0f56b1c..bf195e3 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -638,8 +638,7 @@ static int w5100_hw_probe(struct platform_device *pdev)
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!mem)
-		return -ENXIO;
+
 	mem_size = resource_size(mem);
 
 	priv->base = devm_ioremap_resource(&pdev->dev, mem);
-- 
1.7.9.5
