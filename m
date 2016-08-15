From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ena: Remove unnecessary pci_set_drvdata()
Date: Mon, 15 Aug 2016 22:50:34 +0000
Message-ID: <1471301434-24531-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	Saeed Bishara <saeed@annapurnalabs.com>,
	Zorik Machulsky <zorik@annapurnalabs.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33069 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbcHOWuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 18:50:44 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so4197380pac.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 15:50:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 94790df..499a22b 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3060,7 +3060,6 @@ err_device_destroy:
 err_free_region:
 	ena_release_bars(ena_dev, pdev);
 err_free_ena_dev:
-	pci_set_drvdata(pdev, NULL);
 	vfree(ena_dev);
 err_disable_device:
 	pci_disable_device(pdev);
@@ -3156,8 +3155,6 @@ static void ena_remove(struct pci_dev *pdev)
 
 	ena_release_bars(ena_dev, pdev);
 
-	pci_set_drvdata(pdev, NULL);
-
 	pci_disable_device(pdev);
 
 	ena_com_destroy_interrupt_moderation(ena_dev);
