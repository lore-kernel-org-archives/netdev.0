From: "govindarajulu.v" <govindarajulu90@gmail.com>
Subject: [PATCH net-next] mlx4: use __netdev_pick_tx instead of __skb_tx_hash in mlx4_en_select_queue
Date: Mon,  3 Jun 2013 23:37:42 +0530
Message-ID: <1370282862-13302-1-git-send-email-govindarajulu90@gmail.com>
Cc: eric.dumazet@gmail.com,
	"govindarajulu.v" <govindarajulu90@gmail.com>
To: amirv@mellanox.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:39949 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab3FCSIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:08:12 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so993155pab.22
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 11:08:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "govindarajulu.v" <govindarajulu90@gmail.com>

mlx4_en_select_queue() uses __skb_tx_hash to select the transmit queue.
XPS settings are ignored by this. Instead, we can use __netdev_pick_tx
to select the transmit queue.

Compile test only.

Signed-off-by: govindarajulu.v <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 4e6877a..7c49238 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -544,7 +544,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb))
 		up = vlan_tx_tag_get(skb) >> VLAN_PRIO_SHIFT;
 
-	return __skb_tx_hash(dev, skb, rings_p_up) + up * rings_p_up;
+	return __netdev_pick_tx(dev, skb) % rings_p_up + up * rings_p_up;
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
-- 
1.8.2.3
