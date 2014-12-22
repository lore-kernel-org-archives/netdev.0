From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] [PATCH v3 1/2] 8139too: Fix the lack of pci_disable_device
Date: Mon, 22 Dec 2014 08:28:52 +0800
Message-ID: <1419208132-23657-1-git-send-email-baijiaju1990@163.com>
Cc: jgarzik@pobox.com, Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:46017 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbaLVA3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 19:29:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For linux-3.18.0
When pci_request_regions is failed in rtl8139_init_board, pci_disable_device 
is not called to disable the device which are enabled by pci_enable_device, 
because of disable_dev_on_err is not assigned 1.
This patch fix this problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/realtek/8139too.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..49bbcf3 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -783,10 +783,10 @@ static struct net_device *rtl8139_init_board(struct pci_dev *pdev)
 	if (rc)
 		goto err_out;
 
+	disable_dev_on_err = 1;
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
-	disable_dev_on_err = 1;
 
 	pci_set_master (pdev);
 
-- 
1.7.9.5
