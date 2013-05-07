From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 23/36] net: ethernet: s6gmac: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:46:55 +0900
Message-ID: <002801ce4add$e65e2340$b31a69c0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:53236 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756366Ab3EGEq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:46:56 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME001J3VY3THB0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:46:55 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/s6gmac.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index b6739af..a99739c 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1040,7 +1040,6 @@ static int s6gmac_remove(struct platform_device *pdev)
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
 		free_netdev(dev);
-		platform_set_drvdata(pdev, NULL);
 	}
 	return 0;
 }
-- 
1.7.2.5
