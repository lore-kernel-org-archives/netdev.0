From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/6] mlx4_en: Removed redundant skb->len check
Date: Sun, 21 Jun 2009 11:15:39 +0300
Message-ID: <4A3DEC2B.2080104@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51486 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751990AbZFUHZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:25:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need this check in the transmit function

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index c0177c3..e631323 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -614,10 +614,6 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int lso_header_size;
 	void *fragptr;
 
-	if (unlikely(!skb->len)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
 	real_size = get_real_size(skb, dev, &lso_header_size);
 	if (unlikely(!real_size))
 		goto tx_drop;
-- 
1.6.0

