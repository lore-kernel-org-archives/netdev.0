From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/5] net: ns83820: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:27:27 +0900
Message-ID: <000601cef48e$95b42e70$c11c8b50$%han@samsung.com>
References: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:40412 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760297Ab3LID12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:27:28 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00MDRS9RJDA0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:27:27 +0900 (KST)
In-reply-to: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
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
index 5213e73..dbccf1d 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2235,7 +2235,6 @@ out_disable:
 	pci_disable_device(pci_dev);
 out_free:
 	free_netdev(ndev);
-	pci_set_drvdata(pci_dev, NULL);
 out:
 	return err;
 }
@@ -2259,7 +2258,6 @@ static void ns83820_remove_one(struct pci_dev *pci_dev)
 			dev->rx_info.descs, dev->rx_info.phy_descs);
 	pci_disable_device(dev->pci_dev);
 	free_netdev(ndev);
-	pci_set_drvdata(pci_dev, NULL);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(ns83820_pci_tbl) = {
-- 
1.7.10.4
