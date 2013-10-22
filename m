From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/15] net: 8139cp: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:17:27 +0900
Message-ID: <000d01cecedd$9e167810$da436830$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:41810 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab3JVER3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:17:29 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100M2DYJDVLL0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:17:28 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/realtek/8139cp.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index d2e5919..f2a2128 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -2052,7 +2052,6 @@ static void cp_remove_one (struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
-- 
1.7.10.4
