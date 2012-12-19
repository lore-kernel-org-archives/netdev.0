From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] drivers/net: Use of_match_ptr() macro in smc91x.c
Date: Wed, 19 Dec 2012 16:47:09 +0530
Message-ID: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
Cc: steve.glendinning@shawell.net, davem@davemloft.net,
	sachin.kamat@linaro.org, patches@linaro.org, nico@fluxnic.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:50163 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab2LSLxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 06:53:50 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so1166929pbc.23
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 03:53:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This eliminates having an #ifdef returning NULL for the case
when OF is disabled.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
Compile tested on linux-next.
---
 drivers/net/ethernet/smsc/smc91x.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 022b45b..a670d23 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2386,8 +2386,6 @@ static const struct of_device_id smc91x_match[] = {
 	{},
 };
 MODULE_DEVICE_TABLE(of, smc91x_match);
-#else
-#define smc91x_match NULL
 #endif
 
 static struct dev_pm_ops smc_drv_pm_ops = {
@@ -2402,7 +2400,7 @@ static struct platform_driver smc_driver = {
 		.name	= CARDNAME,
 		.owner	= THIS_MODULE,
 		.pm	= &smc_drv_pm_ops,
-		.of_match_table = smc91x_match,
+		.of_match_table = of_match_ptr(smc91x_match),
 	},
 };
 
-- 
1.7.4.1
