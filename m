From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 31/52] net: pasemi: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:53:50 +0900
Message-ID: <006901ceaec4$0db805b0$29281110$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Olof Johansson' <olof@lixom.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:31458 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3IKHxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:53:52 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00CQXB9QE4T0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:53:51 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index c498181..47ddedb 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1870,7 +1870,6 @@ static void pasemi_mac_remove(struct pci_dev *pdev)
 	pasemi_dma_free_chan(&mac->tx->chan);
 	pasemi_dma_free_chan(&mac->rx->chan);
 
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 }
 
-- 
1.7.10.4
