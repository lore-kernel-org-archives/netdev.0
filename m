From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 24/36] net: ethernet: seeq: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:47:43 +0900
Message-ID: <002901ce4ade$03652b00$0a2f8100$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:46414 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757921Ab3EGErw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:47:52 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME0078WVYZT480@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:47:50 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/seeq/sgiseeq.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 0ad5694..856e523 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -818,7 +818,6 @@ static int __exit sgiseeq_remove(struct platform_device *pdev)
 	dma_free_noncoherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
 			     sp->srings_dma);
 	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
-- 
1.7.2.5
