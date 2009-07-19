From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH] mlx4_en: Fix double pci unmapping.
Date: Sun, 19 Jul 2009 10:23:09 +0300
Message-ID: <4A62C9DD.8040506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:36750 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751310AbZGSGd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 02:33:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In cases of fragmented skb, with the data pointers being wrapped around
the TX buffer, the completion handling code would not forward the data
pointer and the firs fragment was unmapped several times, while others
were not unmapped at all.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index d5c18c6..3e8a404 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -249,6 +249,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				pci_unmap_page(mdev->pdev,
 					(dma_addr_t) be64_to_cpu(data->addr),
 					 frag->size, PCI_DMA_TODEVICE);
+				++data;
 			}
 		}
 		/* Stamp the freed descriptor */
-- 
1.6.0

