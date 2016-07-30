From: Salil Kapur <salilkapur93@gmail.com>
Subject: [PATCH] Networking: Core: netpoll: Fixed a missing spin_unlock
Date: Sat, 30 Jul 2016 06:23:47 +0530
Message-ID: <1469840027-17057-1-git-send-email-salilkapur93@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	salilkapur93@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the case when the loop breaks at line 390, the txq lock is not
released. Added an unlock statement before the break statement.

Signed-off-by: Salil Kapur <salilkapur93@gmail.com>
---
 net/core/netpoll.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fc75c9e..9124f76 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -386,8 +386,10 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 					    !vlan_hw_offload_capable(netif_skb_features(skb),
 								     skb->vlan_proto)) {
 						skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-						if (unlikely(!skb))
+						if (unlikely(!skb)) {
+							__netif_tx_unlock(txq);
 							break;
+						}
 						skb->vlan_tci = 0;
 					}
 
-- 
1.9.1
