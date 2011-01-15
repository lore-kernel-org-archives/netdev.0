From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 8/8] vmxnet3: Dont allocate extra MSI-x vectors
Date: Fri, 14 Jan 2011 17:00:03 -0800
Message-ID: <20110115010002.1064.74546.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of single tx and rx queues, three MSI-x vectors are allocated instead
of two. This patch fixes that.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 ++--
 drivers/net/vmxnet3/vmxnet3_int.h |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3b5b134..cc14b4a 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2712,7 +2712,7 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 			break;
 		} else {
 			/* If fails to enable required number of MSI-x vectors
-			 * try enabling 3 of them. One each for rx, tx and event
+			 * try enabling minimum number of vectors required.
 			 */
 			vectors = vector_threshold;
 			printk(KERN_ERR "Failed to enable %d MSI-X for %s, try"
@@ -2774,7 +2774,7 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 		 */
 		if (err == VMXNET3_LINUX_MIN_MSIX_VECT) {
 			if (adapter->share_intr != VMXNET3_INTR_BUDDYSHARE
-			    || adapter->num_rx_queues != 2) {
+			    || adapter->num_rx_queues != 1) {
 				adapter->share_intr = VMXNET3_INTR_TXSHARE;
 				printk(KERN_ERR "Number of rx queues : 1\n");
 				adapter->num_rx_queues = 1;
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 474f5df..fb5d245 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.16.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.25.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01001000
+#define VMXNET3_DRIVER_VERSION_NUM      0x01001900
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
@@ -289,7 +289,7 @@ struct vmxnet3_rx_queue {
 
 #define VMXNET3_LINUX_MAX_MSIX_VECT     (VMXNET3_DEVICE_MAX_TX_QUEUES + \
 					 VMXNET3_DEVICE_MAX_RX_QUEUES + 1)
-#define VMXNET3_LINUX_MIN_MSIX_VECT     3    /* 1 for each : tx, rx and event */
+#define VMXNET3_LINUX_MIN_MSIX_VECT     2 /* 1 for tx-rx pair and 1 for event */
 
 
 struct vmxnet3_intr {
