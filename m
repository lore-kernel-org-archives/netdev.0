From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/2] irda: vlsi_ir: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:29:08 +0900
Message-ID: <000901cef48e$d1dda3e0$7598eba0$%han@samsung.com>
References: <000801cef48e$ba4f5de0$2eee19a0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:47186 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760403Ab3LID3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:29:10 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00509SCL4R90@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:29:09 +0900 (KST)
In-reply-to: <000801cef48e$ba4f5de0$2eee19a0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/vlsi_ir.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index cc9b866..4850066 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1693,7 +1693,6 @@ out_freedev:
 out_disable:
 	pci_disable_device(pdev);
 out:
-	pci_set_drvdata(pdev, NULL);
 	return -ENODEV;
 }
 
@@ -1719,8 +1718,6 @@ static void vlsi_irda_remove(struct pci_dev *pdev)
 
 	free_netdev(ndev);
 
-	pci_set_drvdata(pdev, NULL);
-
 	IRDA_MESSAGE("%s: %s removed\n", drivername, pci_name(pdev));
 }
 
-- 
1.7.10.4
