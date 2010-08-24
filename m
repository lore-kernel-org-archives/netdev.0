From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 01/14] mlx4_en: Fixed incorrect unmapping on RX flow.
Date: Tue, 24 Aug 2010 16:45:05 +0300
Message-ID: <4C73CCE1.6050609@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49983 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755151Ab0HXNpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:45:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating new fragments to replace the ones that would be passed to the stack,
The fragments that should be replaced, are the ones that were already used.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 8e2fcb7..1ee4fd5 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -459,7 +459,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			goto fail;
 
 		/* Unmap buffer */
-		pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
+		pci_unmap_single(mdev->pdev, dma, skb_frags_rx[nr].size,
 				 PCI_DMA_FROMDEVICE);
 	}
 	/* Adjust size of last fragment to match actual length */
-- 
1.6.1.3

