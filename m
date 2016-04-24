From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH net] RDMA/nes: don't leak skb if carrier down
Date: Sun, 24 Apr 2016 22:18:59 +0200
Message-ID: <1461529139-28582-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alternatively one could free the skb, OTOH I don't think this test is
useful so just remove it.

Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
---
 Noticed this while working on the TX_LOCKED removal.

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 3ea9e05..9291453 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -500,9 +500,6 @@ static int nes_netdev_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 *		skb_shinfo(skb)->nr_frags, skb_is_gso(skb));
 	 */
 
-	if (!netif_carrier_ok(netdev))
-		return NETDEV_TX_OK;
-
 	if (netif_queue_stopped(netdev))
 		return NETDEV_TX_BUSY;
 
-- 
2.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
