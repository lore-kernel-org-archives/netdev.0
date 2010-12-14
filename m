From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 09/12] cxgb4: remove a bitmap
Date: Tue, 14 Dec 2010 12:18:13 -0800
Message-ID: <1292357896-14339-10-git-send-email-dm@chelsio.com>
References: <1292357896-14339-1-git-send-email-dm@chelsio.com>
 <1292357896-14339-2-git-send-email-dm@chelsio.com>
 <1292357896-14339-3-git-send-email-dm@chelsio.com>
 <1292357896-14339-4-git-send-email-dm@chelsio.com>
 <1292357896-14339-5-git-send-email-dm@chelsio.com>
 <1292357896-14339-6-git-send-email-dm@chelsio.com>
 <1292357896-14339-7-git-send-email-dm@chelsio.com>
 <1292357896-14339-8-git-send-email-dm@chelsio.com>
 <1292357896-14339-9-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28546 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759926Ab0LNU0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 15:26:39 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBEKQcRM031245
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:26:38 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBEKIHoG014468
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:18:17 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBEKIHM9014467
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 12:18:17 -0800
In-Reply-To: <1292357896-14339-9-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver keeps a bitmap of the netdevs it registered so it knows what to
unregister later.  Remove that and look at reg_state instead.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 -
 drivers/net/cxgb4/cxgb4_main.c |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 9caf95f..01d49ea 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -482,7 +482,6 @@ struct adapter {
 	void __iomem *regs;
 	struct pci_dev *pdev;
 	struct device *pdev_dev;
-	unsigned long registered_device_map;
 	unsigned int fn;
 	unsigned int flags;
 
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 3db21d1..d016e10 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3725,7 +3725,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		err = register_netdev(adapter->port[i]);
 		if (err)
 			break;
-		__set_bit(i, &adapter->registered_device_map);
 		adapter->chan_map[pi->tx_chan] = i;
 		print_port_info(adapter->port[i]);
 	}
@@ -3785,7 +3784,7 @@ static void __devexit remove_one(struct pci_dev *pdev)
 			detach_ulds(adapter);
 
 		for_each_port(adapter, i)
-			if (test_bit(i, &adapter->registered_device_map))
+			if (adapter->port[i]->reg_state == NETREG_REGISTERED)
 				unregister_netdev(adapter->port[i]);
 
 		if (adapter->debugfs_root)
-- 
1.5.4

