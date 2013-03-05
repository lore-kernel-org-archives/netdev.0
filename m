From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/3] net: macb: use module_platform_driver_probe()
Date: Tue, 05 Mar 2013 11:43:18 +0900
Message-ID: <005201ce194b$318a6c80$949f4580$%han@samsung.com>
References: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:35797 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758905Ab3CECnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:43:31 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MJ6003WQ27NOQD0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 05 Mar 2013 11:43:18 +0900 (KST)
In-reply-to: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses module_platform_driver_probe() macro which makes
the code smaller and simpler.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cadence/macb.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7903943..3a5d680 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1737,18 +1737,7 @@ static struct platform_driver macb_driver = {
 	},
 };
 
-static int __init macb_init(void)
-{
-	return platform_driver_probe(&macb_driver, macb_probe);
-}
-
-static void __exit macb_exit(void)
-{
-	platform_driver_unregister(&macb_driver);
-}
-
-module_init(macb_init);
-module_exit(macb_exit);
+module_platform_driver_probe(macb_driver, macb_probe);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
-- 
1.7.2.5
