From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v3 7/7] vmxnet3: update to version 3
Date: Mon, 13 Jun 2016 18:50:07 -0700
Message-ID: <1465869007-10822-8-git-send-email-skhare@vmware.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 7 ++++++-
 drivers/net/vmxnet3/vmxnet3_int.h | 4 ++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index d0bcc1d9..c68fe49 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3345,7 +3345,12 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pci;
 
 	ver = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_VRRS);
-	if (ver & (1 << VMXNET3_REV_2)) {
+	if (ver & (1 << VMXNET3_REV_3)) {
+		VMXNET3_WRITE_BAR1_REG(adapter,
+				       VMXNET3_REG_VRRS,
+				       1 << VMXNET3_REV_3);
+		adapter->version = VMXNET3_REV_3 + 1;
+	} else if (ver & (1 << VMXNET3_REV_2)) {
 		VMXNET3_WRITE_BAR1_REG(adapter,
 				       VMXNET3_REG_VRRS,
 				       1 << VMXNET3_REV_2);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 63df4f2..74fc030 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.4.8.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.9.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01040800
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040900
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
2.8.2
