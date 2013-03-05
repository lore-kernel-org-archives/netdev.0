From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/3] net: at91_ether: use module_platform_driver_probe()
Date: Tue, 05 Mar 2013 11:42:03 +0900
Message-ID: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:50489 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759052Ab3CECmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:42:05 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MJ600328262CAB0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 05 Mar 2013 11:42:03 +0900 (KST)
Received: from DOJG1HAN02 ([12.23.120.99])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MJ600BJT263SR50@mmp1.samsung.com> for netdev@vger.kernel.org;
 Tue, 05 Mar 2013 11:42:03 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses module_platform_driver_probe() macro which makes
the code smaller and simpler.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cadence/at91_ether.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 3becdb2..1a57e16 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -519,18 +519,7 @@ static struct platform_driver at91ether_driver = {
 	},
 };
 
-static int __init at91ether_init(void)
-{
-	return platform_driver_probe(&at91ether_driver, at91ether_probe);
-}
-
-static void __exit at91ether_exit(void)
-{
-	platform_driver_unregister(&at91ether_driver);
-}
-
-module_init(at91ether_init)
-module_exit(at91ether_exit)
+module_platform_driver_probe(at91ether_driver, at91ether_probe);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
-- 
1.7.2.5
