From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 2/6] ethernet: wiznet: remove unnecessary check
Date: Wed, 22 Oct 2014 09:46:22 +0530
Message-ID: <1413951386-29645-3-git-send-email-varkab@cdac.in>
References: <N>
 <1413951386-29645-1-git-send-email-varkab@cdac.in>
Cc: Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42671 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbaJVETh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 00:19:37 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so2712405pde.40
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 21:19:36 -0700 (PDT)
In-Reply-To: <1413951386-29645-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/wiznet/w5300.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index f961f14..315d090 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -558,8 +558,7 @@ static int w5300_hw_probe(struct platform_device *pdev)
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!mem)
-		return -ENXIO;
+
 	mem_size = resource_size(mem);
 
 	priv->base = devm_ioremap_resource(&pdev->dev, mem);
-- 
1.7.9.5
