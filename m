From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] rtl818x_pci: Disable pci device in error handling code
Date: Wed, 13 Jan 2016 22:29:40 +0800
Message-ID: <1452695381-27660-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>
To: andrea.merello@gmail.com, Larry.Finger@lwfinger.net,
	flamingice@sourmilk.net, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:39329 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757717AbcAMOaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 09:30:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pci_request_regions in rtl8180_probe fails, pci_disable_device is not
called to disable the device which is enabled by pci_enbale_device.

This patch fixes the problem by adding a new lable in error handling code.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
index a43a16f..c76af5d 100644
--- a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
@@ -1736,7 +1736,7 @@ static int rtl8180_probe(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR "%s (rtl8180): Cannot obtain PCI resources\n",
 		       pci_name(pdev));
-		return err;
+		goto err_disable_dev;
 	}
 
 	io_addr = pci_resource_start(pdev, 0);
@@ -1938,6 +1938,8 @@ static int rtl8180_probe(struct pci_dev *pdev,
 
  err_free_reg:
 	pci_release_regions(pdev);
+
+ err_disable_dev:
 	pci_disable_device(pdev);
 	return err;
 }
-- 
1.7.9.5
