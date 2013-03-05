From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/3] net: cs89x0: use module_platform_driver_probe()
Date: Tue, 05 Mar 2013 11:43:50 +0900
Message-ID: <005301ce194b$44ca8e10$ce5faa30$%han@samsung.com>
References: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:11600 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758979Ab3CECnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:43:52 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MJ6004S528Z4VF0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 05 Mar 2013 11:43:51 +0900 (KST)
Received: from DOJG1HAN02 ([12.23.120.99])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MJ600B3Z292SR60@mmp1.samsung.com> for netdev@vger.kernel.org;
 Tue, 05 Mar 2013 11:43:50 +0900 (KST)
In-reply-to: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses module_platform_driver_probe() macro which makes
the code smaller and simpler.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
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
1.7.2.5
