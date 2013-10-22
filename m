From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 14/15] net: sunhme: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:20:59 +0900
Message-ID: <001401cecede$1cb5a150$5620e3f0$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58579 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab3JVEVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:21:01 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100ES4YQTLFK0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:21:00 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sunhme.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 99043b7..0dbf46f 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3170,8 +3170,6 @@ static void happy_meal_pci_remove(struct pci_dev *pdev)
 	pci_release_regions(hp->happy_dev);
 
 	free_netdev(net_dev);
-
-	pci_set_drvdata(pdev, NULL);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
-- 
1.7.10.4
