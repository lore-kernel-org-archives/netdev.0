From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v3 1/5] ethernet: wiznet: remove unnecessary check
Date: Fri, 24 Oct 2014 07:42:06 +0530
Message-ID: <1414116730-4590-2-git-send-email-varkab@cdac.in>
References: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:57726 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbaJXCOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:14:00 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so561643pdj.27
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 19:14:00 -0700 (PDT)
In-Reply-To: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

devm_ioremap_resource checks platform_get_resource() return value.
We can remove the duplicate check here.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/wiznet/w5100.c |    6 ++----
 drivers/net/ethernet/wiznet/w5300.c |    6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 0f56b1c..70a930a 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -638,14 +638,12 @@ static int w5100_hw_probe(struct platform_device *pdev)
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
 	priv->indirect = mem_size < W5100_BUS_DIRECT_SIZE;
 	if (priv->indirect) {
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
