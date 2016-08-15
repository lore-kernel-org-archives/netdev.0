From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: thunderx: Remove unnecessary pci_set_drvdata()
Date: Mon, 15 Aug 2016 22:51:29 +0000
Message-ID: <1471301489-24888-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33459 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbcHOWvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 18:51:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so4381012pfe.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 15:51:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_xcv.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_xcv.c b/drivers/net/ethernet/cavium/thunder/thunder_xcv.c
index 9210d04..67befed 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_xcv.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_xcv.c
@@ -194,7 +194,6 @@ err_release_regions:
 err_disable_device:
 	pci_disable_device(pdev);
 err_kfree:
-	pci_set_drvdata(pdev, NULL);
 	devm_kfree(dev, xcv);
 	xcv = NULL;
 	return err;
@@ -211,7 +210,6 @@ static void xcv_remove(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static struct pci_driver xcv_driver = {
