From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 09/14] netpoll: check netpoll tx status on the right device
Date: Thu,  9 Aug 2012 23:00:21 +0800
Message-ID: <1344524426-11588-10-git-send-email-amwang@redhat.com>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030865Ab2HIPBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 11:01:00 -0400
In-Reply-To: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although this doesn't matter actually, because netpoll_tx_running()
doesn't use the parameter, the code will be more readable.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 include/linux/if_team.h         |    2 +-
 net/bridge/br_forward.c         |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e428916..d688a8a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -398,7 +398,7 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
 	skb->queue_mapping = qdisc_skb_cb(skb)->slave_dev_queue_mapping;
 
-	if (unlikely(netpoll_tx_running(slave_dev)))
+	if (unlikely(netpoll_tx_running(bond->dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
 	else
 		dev_queue_xmit(skb);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 33fcc20..a55df56 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -107,7 +107,7 @@ static inline int team_dev_queue_xmit(struct team *team, struct team_port *port,
 	skb_set_queue_mapping(skb, qdisc_skb_cb(skb)->slave_dev_queue_mapping);
 
 	skb->dev = port->dev;
-	if (unlikely(netpoll_tx_running(port->dev))) {
+	if (unlikely(netpoll_tx_running(team->dev))) {
 		team_netpoll_send_skb(port, skb);
 		return 0;
 	}
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e9466d4..02015a5 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -65,7 +65,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	skb->dev = to->dev;
 
-	if (unlikely(netpoll_tx_running(to->dev))) {
+	if (unlikely(netpoll_tx_running(to->br->dev))) {
 		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
 			kfree_skb(skb);
 		else {
-- 
1.7.7.6
