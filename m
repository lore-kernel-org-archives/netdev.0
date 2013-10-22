From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 10/15] net: sis190: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:18:57 +0900
Message-ID: <001001cecedd$d3bd83f0$7b388bd0$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:27524 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab3JVETH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:19:07 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100BCKYNTHDL0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:19:05 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
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
