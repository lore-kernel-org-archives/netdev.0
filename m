From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH net-next] vmxnet3: Use single tx queue when CONFIG_PCI_MSI
 not defined
Date: Tue, 10 May 2011 09:13:56 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1105100903110.1095@sbhatewara-dev1.eng.vmware.com>
References: <alpine.LRH.2.00.1105091715150.26660@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1105091715150.26660@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Resending this patch with few changes.


Avoid multiple queues when MSI or MSI-X not available

Limit number of Tx queues to 1 if MSI/MSI-X support is not configured in
the kernel. This will make number of tx and rx queues equal when MSI/X 
is not configured thus providing better performance.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c 
b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7a494f7..ab2e753 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2882,6 +2882,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	int num_tx_queues;
 	int num_rx_queues;
 
+	if (!pci_msi_enabled())
+		enable_mq = 0;
+
 #ifdef VMXNET3_RSS
 	if (enable_mq)
 		num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 8ba7b5f..f50d36f 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.25.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.9.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01001900
+#define VMXNET3_DRIVER_VERSION_NUM      0x01010900
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
