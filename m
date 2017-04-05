From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: trust shinfo->gso_segs
Date: Wed, 05 Apr 2017 08:49:02 -0700
Message-ID: <1491407342.10124.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34798 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755386AbdDEPtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 11:49:06 -0400
Received: by mail-it0-f68.google.com with SMTP id e75so1759741itd.1
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 08:49:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4 is the only driver in the tree making a point to recompute
shinfo->gso_segs.

Lets remove superfluous code.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e0c5ffb3e3a6607456e1f191b0b8c8becfc71219..3ba89bc43d74d8c023776079bcd0bbadd70fb5c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -978,8 +978,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		ring->tso_packets++;
 
-		i = ((skb->len - lso_header_size) / shinfo->gso_size) +
-			!!((skb->len - lso_header_size) % shinfo->gso_size);
+		i = shinfo->gso_segs;
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
 		ring->packets += i;
 	} else {
