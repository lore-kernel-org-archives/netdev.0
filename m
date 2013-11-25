From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/5] wan: pci200syn: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:58:39 +0900
Message-ID: <000e01cee981$dc085670$94190350$%han@samsung.com>
References: <000b01cee981$9254d850$b6fe88f0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:11632 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab3KYB6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:58:40 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS0035VQTR13C0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:58:39 +0900 (KST)
In-reply-to: <000b01cee981$9254d850$b6fe88f0$%han@samsung.com>
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
