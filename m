From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/5] net: ns83820: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:46:38 +0900
Message-ID: <000401cee980$2ea9f8e0$8bfdeaa0$%han@samsung.com>
References: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:8729 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab3KYBqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:46:40 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS003FPQ9R7AA0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:46:39 +0900 (KST)
In-reply-to: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/natsemi/ns83820.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index d3b4700..e3e1e2f 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2236,7 +2236,6 @@ out_disable:
 	pci_disable_device(pci_dev);
 out_free:
 	free_netdev(ndev);
-	pci_set_drvdata(pci_dev, NULL);
 out:
 	return err;
 }
@@ -2260,7 +2259,6 @@ static void ns83820_remove_one(struct pci_dev *pci_dev)
 			dev->rx_info.descs, dev->rx_info.phy_descs);
 	pci_disable_device(dev->pci_dev);
 	free_netdev(ndev);
-	pci_set_drvdata(pci_dev, NULL);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(ns83820_pci_tbl) = {
-- 
1.7.10.4
