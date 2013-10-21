From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/15] net: ksz884x: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:14:45 +0900
Message-ID: <004301cece03$4f51fcc0$edf5f640$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:52644 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab3JUCPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:15:18 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00KWRY8BKRE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:14:45 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 8ebc352..6462dc5 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7150,8 +7150,6 @@ static void pcidev_exit(struct pci_dev *pdev)
 	struct platform_info *info = pci_get_drvdata(pdev);
 	struct dev_info *hw_priv = &info->dev_info;
 
-	pci_set_drvdata(pdev, NULL);
-
 	release_mem_region(pci_resource_start(pdev, 0),
 		pci_resource_len(pdev, 0));
 	for (i = 0; i < hw_priv->hw.dev_count; i++) {
-- 
1.7.10.4
