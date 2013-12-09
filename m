From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/5] wan: lmc: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:30:41 +0900
Message-ID: <000b01cef48f$09664100$1c32c300$%han@samsung.com>
References: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58955 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760259Ab3LIDan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:30:43 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00JILSF6LU90@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:30:42 +0900 (KST)
In-reply-to: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/lmc/lmc_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 7ef435b..c59b91f 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -973,7 +973,6 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
     return 0;
 
 err_hdlcdev:
-	pci_set_drvdata(pdev, NULL);
 	kfree(sc);
 err_kzalloc:
 	pci_release_regions(pdev);
@@ -995,7 +994,6 @@ static void lmc_remove_one(struct pci_dev *pdev)
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
