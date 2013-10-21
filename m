From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 13/15] net: natsemi: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:15:34 +0900
Message-ID: <004501cece03$6d0ee700$472cb500$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:36955 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab3JUCPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:15:36 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ008QYY9ZQGF0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:15:35 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/natsemi/natsemi.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 7a5e295..64ec2a4 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -970,7 +970,6 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 
  err_ioremap:
 	pci_release_regions(pdev);
-	pci_set_drvdata(pdev, NULL);
 
  err_pci_request_regions:
 	free_netdev(dev);
@@ -3220,7 +3219,6 @@ static void natsemi_remove1(struct pci_dev *pdev)
 	pci_release_regions (pdev);
 	iounmap(ioaddr);
 	free_netdev (dev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #ifdef CONFIG_PM
-- 
1.7.10.4
