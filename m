From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net] Driver: Vmxnet3: Fix regression caused by 5738a09
Date: Wed,  6 Jan 2016 10:44:27 -0800
Message-ID: <1452105867-12598-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:37096 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751954AbcAFSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 13:44:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Bingkuo Liu <bingkuol@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 8 ++++----
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 4179037..0cbf520 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1380,10 +1380,10 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 					skip_page_frags = true;
 					goto rcd_done;
 				}
-				new_dma_addr = dma_map_page(&adapter->pdev->dev
-							, rbi->page,
-							0, PAGE_SIZE,
-							PCI_DMA_FROMDEVICE);
+				new_dma_addr = dma_map_page(&adapter->pdev->dev,
+							    new_page,
+							    0, PAGE_SIZE,
+							    PCI_DMA_FROMDEVICE);
 				if (dma_mapping_error(&adapter->pdev->dev,
 						      new_dma_addr)) {
 					put_page(new_page);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 4c58c83..bdb8a6c 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.4.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.5.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040400
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040500
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.8.5.6
