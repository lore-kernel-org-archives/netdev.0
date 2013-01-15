From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 07/10] vmxnet3: remove device counter
Date: Tue, 15 Jan 2013 09:28:32 -0800
Message-ID: <1358270915-32758-8-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:43750 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab3AORaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:16 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so232386pad.2
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:15 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An atomic counter of devices present is maintained but never used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    5 -----
 drivers/net/vmxnet3/vmxnet3_int.h |    1 -
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 0e55153..1f66a7e 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -43,8 +43,6 @@ static DEFINE_PCI_DEVICE_TABLE(vmxnet3_pciid_table) = {
 
 MODULE_DEVICE_TABLE(pci, vmxnet3_pciid_table);
 
-static atomic_t devices_found;
-
 static int enable_mq = 1;
 static int irq_share_mode;
 
@@ -3005,8 +3003,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	vmxnet3_declare_features(adapter, dma64);
 
-	adapter->dev_number = atomic_read(&devices_found);
-
 	adapter->share_intr = irq_share_mode;
 	if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE &&
 	    adapter->num_tx_queues != adapter->num_rx_queues)
@@ -3057,7 +3053,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	}
 
 	vmxnet3_check_link(adapter, false);
-	atomic_inc(&devices_found);
 	return 0;
 
 err_register:
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 55465ed..3198384 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -352,7 +352,6 @@ struct vmxnet3_adapter {
 
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
 
-	int dev_number;
 	int share_intr;
 };
 
-- 
1.7.10.4
