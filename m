From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/7] net: tlan: remove unnecessary pci_set_drvdata()
Date: Wed, 23 Oct 2013 16:08:32 +0900
Message-ID: <000501cecfbe$aece88f0$0c6b9ad0$%han@samsung.com>
References: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Samuel Chessman' <chessman@tux.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:45428 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab3JWHId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 03:08:33 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV400M6Y15NTOU0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 23 Oct 2013 16:08:32 +0900 (KST)
In-reply-to: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ti/tlan.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 591437e..62b19be 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -319,7 +319,6 @@ static void tlan_remove_one(struct pci_dev *pdev)
 
 	free_netdev(dev);
 
-	pci_set_drvdata(pdev, NULL);
 	cancel_work_sync(&priv->tlan_tqueue);
 }
 
-- 
1.7.10.4
