From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 40/52] net: sis190: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:02:17 +0900
Message-ID: <007201ceaec5$3bc946c0$b35bd440$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:58767 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab3IKICT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:02:19 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY008KIBNFXAP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:02:18 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sis/sis190.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index ee18e6f..acbbe48 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1921,7 +1921,6 @@ static void sis190_remove_one(struct pci_dev *pdev)
 	cancel_work_sync(&tp->phy_task);
 	unregister_netdev(dev);
 	sis190_release_board(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static struct pci_driver sis190_pci_driver = {
-- 
1.7.10.4
