From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next] Driver: Vmxnet3: Fix use of mfTableLen for big endian architectures
Date: Fri, 13 Nov 2015 15:42:10 -0800
Message-ID: <1447458130-31985-1-git-send-email-skhare@vmware.com>
Cc: pv-drivers@vmware.com, uebayasi@gmail.com,
	Shrikrishna Khare <skhare@vmware.com>,
	Bhavesh Davda <bhavesh@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Reported-by: Masao Uebayashi <uebayasi@gmail.com>
Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 7 ++++---
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 46f4cad..899ea42 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2157,12 +2157,13 @@ vmxnet3_set_mc(struct net_device *netdev)
 		if (!netdev_mc_empty(netdev)) {
 			new_table = vmxnet3_copy_mc(netdev);
 			if (new_table) {
-				rxConf->mfTableLen = cpu_to_le16(
-					netdev_mc_count(netdev) * ETH_ALEN);
+				size_t sz = netdev_mc_count(netdev) * ETH_ALEN;
+
+				rxConf->mfTableLen = cpu_to_le16(sz);
 				new_table_pa = dma_map_single(
 							&adapter->pdev->dev,
 							new_table,
-							rxConf->mfTableLen,
+							sz,
 							PCI_DMA_TODEVICE);
 			}
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 3f859a5..4c58c83 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.3.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.4.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040300
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040400
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.8.5.6
