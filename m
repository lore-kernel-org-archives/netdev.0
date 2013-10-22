From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 01/15] net: pasemi: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:14:45 +0900
Message-ID: <000701cecedd$3d7f24c0$b87d6e40$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Olof Johansson' <olof@lixom.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:53240 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab3JVEOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:14:47 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100CNJYFLBL50@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:14:45 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
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
index 5b65356..dbaa49e 100644
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
