From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/3] cirrus: cs89x0: Use module_platform_driver_probe macro
Date: Tue,  5 Mar 2013 10:01:20 +0530
Message-ID: <1362457882-12892-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:35180 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932483Ab3CEEmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 23:42:00 -0500
Received: by mail-pb0-f44.google.com with SMTP id wz12so3865778pbc.31
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 20:41:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_platform_driver_probe() eliminates the boilerplate and simplifies
the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/cirrus/cs89x0.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 1384469..73c1c8c 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1978,18 +1978,6 @@ static struct platform_driver cs89x0_driver = {
 	.remove	= cs89x0_platform_remove,
 };
 
-static int __init cs89x0_init(void)
-{
-	return platform_driver_probe(&cs89x0_driver, cs89x0_platform_probe);
-}
-
-module_init(cs89x0_init);
-
-static void __exit cs89x0_cleanup(void)
-{
-	platform_driver_unregister(&cs89x0_driver);
-}
-
-module_exit(cs89x0_cleanup);
+module_platform_driver_probe(cs89x0_driver, cs89x0_platform_probe);
 
 #endif /* CONFIG_CS89x0_PLATFORM */
-- 
1.7.4.1
