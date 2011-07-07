From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCHv2] vmxnet3: round down # of queues to power of two
Date: Wed, 6 Jul 2011 18:16:53 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1107061813100.3509@sbhatewara-dev1.eng.vmware.com>
References: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yongwang@vmware.com
To: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, dtor@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:44541 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752188Ab1GGBQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 21:16:50 -0400
Received: from mailhost4.vmware.com (mailhost4.vmware.com [10.16.67.124])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 812F913423
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2011 18:16:50 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


vmxnet3 device supports only power-of-two number of queues. The driver
therefore needs to check this and rounds down the number of queues to the
nearest power of two.

Signed-off-by: Yong Wang <yongwang@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Reviewed-by: Dmitry Torokhov <dtor@vmware.com>
--

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index fabcded..009277e 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2897,6 +2897,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	else
 #endif
 		num_rx_queues = 1;
+	num_rx_queues = rounddown_pow_of_two(num_rx_queues);
 
 	if (enable_mq)
 		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
@@ -2904,6 +2905,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	else
 		num_tx_queues = 1;
 
+	num_tx_queues = rounddown_pow_of_two(num_tx_queues);
 	netdev = alloc_etherdev_mq(sizeof(struct vmxnet3_adapter),
 				   max(num_tx_queues, num_rx_queues));
 	printk(KERN_INFO "# of Tx queues : %d, # of Rx queues : %d\n",
@@ -3088,6 +3090,7 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 	else
 #endif
 		num_rx_queues = 1;
+	num_rx_queues = rounddown_pow_of_two(num_rx_queues);
 
 	cancel_work_sync(&adapter->work);
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index a9cb3fa..b18eac1 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -56,6 +56,7 @@
 #include <linux/if_vlan.h>
 #include <linux/if_arp.h>
 #include <linux/inetdevice.h>
+#include <linux/log2.h>
 
 #include "vmxnet3_defs.h"
 
@@ -69,10 +70,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.14.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.18.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01010E00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01011200
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
