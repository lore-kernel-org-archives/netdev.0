From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 08/10] vmxnet3: remove unused irq_share_mode
Date: Tue, 15 Jan 2013 09:28:33 -0800
Message-ID: <1358270915-32758-9-git-send-email-stephen@networkplumber.org>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49424 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab3AORaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:18 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so233269pad.17
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:17 -0800 (PST)
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This static variable is never set, it initializes to 0 which
is VMXNET3_INTR_BUDDYSHARE, and never changes.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1f66a7e..45c39cc 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -44,7 +44,6 @@ static DEFINE_PCI_DEVICE_TABLE(vmxnet3_pciid_table) = {
 MODULE_DEVICE_TABLE(pci, vmxnet3_pciid_table);
 
 static int enable_mq = 1;
-static int irq_share_mode;
 
 static void
 vmxnet3_write_mac_addr(struct vmxnet3_adapter *adapter, u8 *mac);
@@ -3003,9 +3002,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	vmxnet3_declare_features(adapter, dma64);
 
-	adapter->share_intr = irq_share_mode;
-	if (adapter->share_intr == VMXNET3_INTR_BUDDYSHARE &&
-	    adapter->num_tx_queues != adapter->num_rx_queues)
+	if (adapter->num_tx_queues == adapter->num_rx_queues)
+		adapter->share_intr = VMXNET3_INTR_BUDDYSHARE;
+	else
 		adapter->share_intr = VMXNET3_INTR_DONTSHARE;
 
 	vmxnet3_alloc_intr_resources(adapter);
-- 
1.7.10.4
