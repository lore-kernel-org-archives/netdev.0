From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Re: [PATCH] 8139too in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 21:53:41 +0800
Message-ID: <000601d01c5c$5f923250$1eb696f0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:53696 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbaLTNx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 08:53:56 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have written it in the e-mail. Does not it display??

Okay, I send it again:

diff --git a/drivers/net/ethernet/realtek/8139too.c
b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..f277c5f 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -782,11 +782,11 @@ static struct net_device *rtl8139_init_board(struct
pci_dev *pdev)
 	rc = pci_enable_device (pdev);
 	if (rc)
 		goto err_out;
+	disable_dev_on_err = 1;
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
-	disable_dev_on_err = 1;
 
 	pci_set_master (pdev);
 
@@ -1098,6 +1098,7 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 	return 0;
 
 err_out:
+	netif_napi_del (&tp->napi);
 	__rtl8139_cleanup_dev (dev);
 	pci_disable_device (pdev);
 	return i;
@@ -1112,6 +1113,7 @@ static void rtl8139_remove_one(struct pci_dev *pdev)
 	assert (dev != NULL);
 
 	cancel_delayed_work_sync(&tp->thread);
+	netif_napi_del (&tp->napi);
 
 	unregister_netdev (dev);
