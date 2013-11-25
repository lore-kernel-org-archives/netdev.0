From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/2] irda: vlsi_ir: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:55:04 +0900
Message-ID: <000a01cee981$5c1b2960$14517c20$%han@samsung.com>
References: <000901cee981$483ca4f0$d8b5eed0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:10765 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138Ab3KYBzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:55:06 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS003REQNS5FB0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:55:04 +0900 (KST)
In-reply-to: <000901cee981$483ca4f0$d8b5eed0$%han@samsung.com>
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
index c5bd58b..649fcbb 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1695,7 +1695,6 @@ out_freedev:
 out_disable:
 	pci_disable_device(pdev);
 out:
-	pci_set_drvdata(pdev, NULL);
 	return -ENODEV;
 }
 
@@ -1721,8 +1720,6 @@ static void vlsi_irda_remove(struct pci_dev *pdev)
 
 	free_netdev(ndev);
 
-	pci_set_drvdata(pdev, NULL);
-
 	IRDA_MESSAGE("%s: %s removed\n", drivername, pci_name(pdev));
 }
 
-- 
1.7.10.4
