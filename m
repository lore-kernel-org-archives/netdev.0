From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/5] wan: pci200syn: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:31:46 +0900
Message-ID: <000d01cef48f$300c0d80$90242880$%han@samsung.com>
References: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:41089 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760469Ab3LIDbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:31:47 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00MOOSGYJDA0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:31:46 +0900 (KST)
In-reply-to: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/pci200syn.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index ddbce54..fe4e3ec 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -260,7 +260,6 @@ static void pci200_pci_remove_one(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	if (card->ports[0].netdev)
 		free_netdev(card->ports[0].netdev);
 	if (card->ports[1].netdev)
-- 
1.7.10.4
