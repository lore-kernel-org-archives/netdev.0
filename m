From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v3 2/2] 8139too: Add netif_napi_del in the driver
Date: Mon, 22 Dec 2014 08:43:14 +0800
Message-ID: <1419208994-23908-1-git-send-email-baijiaju1990@163.com>
Cc: jgarzik@pobox.com, Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:56587 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363AbaLVAno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 19:43:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For linux-3.18.0
The driver lacks netif_napi_del in the normal path and error path
to match the call of netif_napi_add in rtl8139_init_one.
This patch fixes this problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/realtek/8139too.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..80fe3fb 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1098,6 +1098,7 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 	return 0;
 
 err_out:
+	netif_napi_del(&tp->napi);
 	__rtl8139_cleanup_dev (dev);
 	pci_disable_device (pdev);
 	return i;
@@ -1112,6 +1113,7 @@ static void rtl8139_remove_one(struct pci_dev *pdev)
 	assert (dev != NULL);
 
 	cancel_delayed_work_sync(&tp->thread);
+	netif_napi_del(&tp->napi);
 
 	unregister_netdev (dev);
 
-- 
1.7.9.5
