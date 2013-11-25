From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: vmxnet3: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 11:05:23 +0900
Message-ID: <001701cee982$cd4cdd30$67e69790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Shreyas Bhatewara' <sbhatewara@vmware.com>,
	pv-drivers@vmware.com, 'Jingoo Han' <jg1.han@samsung.com>,
	'Andy King' <acking@vmware.com>,
	'Aditya Sarwade' <asarwade@vmware.com>,
	'George Zhang' <georgezhang@vmware.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:13246 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab3KYCF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 21:05:26 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS003VJR505FC0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 11:05:24 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e2788c..a300a18 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3132,7 +3132,6 @@ err_alloc_queue_desc:
 err_alloc_shared:
 	dma_unmap_single(&adapter->pdev->dev, adapter->adapter_pa,
 			 sizeof(struct vmxnet3_adapter), PCI_DMA_TODEVICE);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return err;
 }
-- 
1.7.10.4
