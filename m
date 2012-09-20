From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] at91ether: return PTR_ERR if call to clk_get fails
Date: Thu, 20 Sep 2012 03:04:36 -0400
Message-ID: <1348124676-6627-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48046 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab2ITHEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 03:04:45 -0400
Received: by pbbrr13 with SMTP id rr13so4403660pbb.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 00:04:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we are currently returning ENODEV, as the clk_get may give a exact
error code in its returned pointer, assign it to the ret by using the
PTR_ERR function, so that the subsequent goto label will jump to the
error path and clean the driver and return the error correctly.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 7788419..4e980a7 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -1086,7 +1086,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	/* Clock */
 	lp->ether_clk = clk_get(&pdev->dev, "ether_clk");
 	if (IS_ERR(lp->ether_clk)) {
-		res = -ENODEV;
+		res = PTR_ERR(lp->ether_clk);
 		goto err_ioumap;
 	}
 	clk_enable(lp->ether_clk);
-- 
1.7.1
