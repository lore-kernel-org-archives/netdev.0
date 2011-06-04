From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] net: fix smc91x.c device tree support
Date: Sat, 04 Jun 2011 01:31:27 -0600
Message-ID: <20110604073127.27163.47519.stgit@ponder>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:50862 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab1FDHb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2011 03:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing semicolon at end of smc91x.c match tabledevice driver.
Also remove unnecessary #ifdef around of_match_table pointer.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/smc91x.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index dc4805f..f628574 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2400,8 +2400,10 @@ static const struct of_device_id smc91x_match[] = {
 	{ .compatible = "smsc,lan91c94", },
 	{ .compatible = "smsc,lan91c111", },
 	{},
-}
+};
 MODULE_DEVICE_TABLE(of, smc91x_match);
+#else
+#define smc91x_match NULL
 #endif
 
 static struct dev_pm_ops smc_drv_pm_ops = {
@@ -2416,9 +2418,7 @@ static struct platform_driver smc_driver = {
 		.name	= CARDNAME,
 		.owner	= THIS_MODULE,
 		.pm	= &smc_drv_pm_ops,
-#ifdef CONFIG_OF
 		.of_match_table = smc91x_match,
-#endif
 	},
 };
 

