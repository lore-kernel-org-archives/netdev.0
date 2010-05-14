From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH] gianfar: Remove legacy PM callbacks
Date: Fri, 14 May 2010 18:27:36 +0400
Message-ID: <20100514142736.GB13137@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:34243 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754187Ab0ENO1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 10:27:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These callbacks were needed because dev_pm_ops support for OF
platform devices was in the powerpc tree, and the patch that
added dev_pm_ops for gianfar driver was in the netdev tree. Now
that netdev and powerpc trees have merged into Linus' tree, we
can remove the legacy hooks.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5d3763f..fb23f04 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1288,21 +1288,9 @@ static struct dev_pm_ops gfar_pm_ops = {
 
 #define GFAR_PM_OPS (&gfar_pm_ops)
 
-static int gfar_legacy_suspend(struct of_device *ofdev, pm_message_t state)
-{
-	return gfar_suspend(&ofdev->dev);
-}
-
-static int gfar_legacy_resume(struct of_device *ofdev)
-{
-	return gfar_resume(&ofdev->dev);
-}
-
 #else
 
 #define GFAR_PM_OPS NULL
-#define gfar_legacy_suspend NULL
-#define gfar_legacy_resume NULL
 
 #endif
 
@@ -3055,8 +3043,6 @@ static struct of_platform_driver gfar_driver = {
 
 	.probe = gfar_probe,
 	.remove = gfar_remove,
-	.suspend = gfar_legacy_suspend,
-	.resume = gfar_legacy_resume,
 	.driver.pm = GFAR_PM_OPS,
 };
 
-- 
1.7.0.5
