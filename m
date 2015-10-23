From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] drivers: net: cpsw: use module_platform_driver
Date: Fri, 23 Oct 2015 14:41:12 +0300
Message-ID: <1445600472-19242-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Tony Lindgren <tony@atomide.com>
To: "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:44732 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbbJWLll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 07:41:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reasons to probe cpsw from late_initcall level
and it's not recommended. Hence, use module_platform_driver()
to register and probe cpsw driver from module_init() level.

Cc: Tony Lindgren <tony@atomide.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8fc90f1..e35a34d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2578,17 +2578,7 @@ static struct platform_driver cpsw_driver = {
 	.remove = cpsw_remove,
 };
 
-static int __init cpsw_init(void)
-{
-	return platform_driver_register(&cpsw_driver);
-}
-late_initcall(cpsw_init);
-
-static void __exit cpsw_exit(void)
-{
-	platform_driver_unregister(&cpsw_driver);
-}
-module_exit(cpsw_exit);
+module_platform_driver(cpsw_driver);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Cyril Chemparathy <cyril@ti.com>");
-- 
2.6.2
