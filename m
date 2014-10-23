From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v2 2/6] ethernet: wiznet: remove unnecessary check
Date: Thu, 23 Oct 2014 07:28:47 +0530
Message-ID: <1414029531-5067-3-git-send-email-varkab@cdac.in>
References: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64165 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161AbaJWB7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:59:12 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so100886pad.35
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:59:10 -0700 (PDT)
In-Reply-To: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/wiznet/w5300.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index f961f14..7974b7d 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -558,14 +558,12 @@ static int w5300_hw_probe(struct platform_device *pdev)
 	}
 
 	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!mem)
-		return -ENXIO;
-	mem_size = resource_size(mem);
-
 	priv->base = devm_ioremap_resource(&pdev->dev, mem);
 	if (IS_ERR(priv->base))
 		return PTR_ERR(priv->base);
 
+	mem_size = resource_size(mem);
+
 	spin_lock_init(&priv->reg_lock);
 	priv->indirect = mem_size < W5300_BUS_DIRECT_SIZE;
 	if (priv->indirect) {
-- 
1.7.9.5
