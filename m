From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net] Driver: Vmxnet3: segCnt can be 1 for LRO packets
Date: Tue,  7 Jun 2016 22:55:17 -0700
Message-ID: <1465365317-120893-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>, Jin Heo <heoj@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:54457 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751735AbcFHFzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 01:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device emulation may send segCnt of 1 for LRO packets.

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Jin Heo <heoj@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index db8022a..6f399b2 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1369,7 +1369,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 				rcdlro = (struct Vmxnet3_RxCompDescExt *)rcd;
 
 				segCnt = rcdlro->segCnt;
-				BUG_ON(segCnt <= 1);
+				BUG_ON(segCnt == 0);
 				mss = rcdlro->mss;
 				if (unlikely(segCnt <= 1))
 					segCnt = 0;
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index c482539..3d2b64e 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.7.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.8.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040700
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040800
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
2.8.2
