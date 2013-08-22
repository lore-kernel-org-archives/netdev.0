From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/2] ethernet: moxa: remove unnecessary platform_set_drvdata()
Date: Thu, 22 Aug 2013 10:55:21 +0900
Message-ID: <001901ce9eda$a9351310$fb9f3930$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jonas Jensen' <jonas.jensen@gmail.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:28128 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab3HVBzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 21:55:23 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MRW0056PTBQL1C0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 22 Aug 2013 10:55:22 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/moxa/moxart_ether.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 6eee686..83c2091 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -533,7 +533,6 @@ static int moxart_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	free_irq(ndev->irq, ndev);
 	moxart_mac_free_memory(ndev);
-	platform_set_drvdata(pdev, NULL);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.7.10.4
