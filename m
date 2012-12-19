From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] drivers/net: Use of_match_ptr() macro in smsc911x.c
Date: Wed, 19 Dec 2012 16:47:10 +0530
Message-ID: <1355915830-29481-2-git-send-email-sachin.kamat@linaro.org>
References: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
Cc: steve.glendinning@shawell.net, davem@davemloft.net,
	sachin.kamat@linaro.org, patches@linaro.org, nico@fluxnic.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:57011 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab2LSLa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 06:30:58 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so1244733pad.2
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 03:30:58 -0800 (PST)
In-Reply-To: <1355915830-29481-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CONFIG_OF guard and use of_match_ptr macro.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
Compile tested on linux-next.
---
 drivers/net/ethernet/smsc/smsc911x.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 4616bf2..e112877 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2575,11 +2575,13 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
 #define SMSC911X_PM_OPS NULL
 #endif
 
+#ifdef CONFIG_OF
 static const struct of_device_id smsc911x_dt_ids[] = {
 	{ .compatible = "smsc,lan9115", },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
+#endif
 
 static struct platform_driver smsc911x_driver = {
 	.probe = smsc911x_drv_probe,
@@ -2588,7 +2590,7 @@ static struct platform_driver smsc911x_driver = {
 		.name	= SMSC_CHIPNAME,
 		.owner	= THIS_MODULE,
 		.pm	= SMSC911X_PM_OPS,
-		.of_match_table = smsc911x_dt_ids,
+		.of_match_table = of_match_ptr(smsc911x_dt_ids),
 	},
 };
 
-- 
1.7.4.1
