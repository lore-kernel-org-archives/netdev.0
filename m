From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/5] wan: pc300too: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:31:12 +0900
Message-ID: <000c01cef48f$1c26ab40$547401c0$%han@samsung.com>
References: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:9170 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760310Ab3LIDbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:31:16 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI005UGSG31080@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:31:15 +0900 (KST)
In-reply-to: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/pc300too.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index 53efc57..5b72f7f 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -281,7 +281,6 @@ static void pc300_pci_remove_one(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	if (card->ports[0].netdev)
 		free_netdev(card->ports[0].netdev);
 	if (card->ports[1].netdev)
-- 
1.7.10.4
