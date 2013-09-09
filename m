From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/2] irda: vlsi_ir: Remove casting the return value which is a
 void pointer
Date: Mon, 09 Sep 2013 14:24:24 +0900
Message-ID: <004c01cead1c$d899f120$89cdd360$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Samuel Ortiz' <samuel@sortiz.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:46682 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab3IIFYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 01:24:25 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSU00C53F0OBT40@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Sep 2013 14:24:24 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting the return value which is a void pointer is redundant.
The conversion from void pointer to any other pointer type is
guaranteed by the C programming language.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/vlsi_ir.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 5f47584..c5bd58b 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -543,7 +543,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	int		crclen, len = 0;
 	struct sk_buff	*skb;
 	int		ret = 0;
-	struct net_device *ndev = (struct net_device *)pci_get_drvdata(r->pdev);
+	struct net_device *ndev = pci_get_drvdata(r->pdev);
 	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
-- 
1.7.10.4
