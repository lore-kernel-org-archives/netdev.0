From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 02/12] batman-adv: Keep interface_tx as local function
Date: Mon, 20 Jun 2011 12:16:55 +0200
Message-ID: <1308565025-21293-3-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57159 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab1FTKR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 06:17:28 -0400
In-Reply-To: <1308565025-21293-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

interface_tx is not used outside of soft-interface.c and thus doesn't
need to be declared inside soft-interface.h

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/soft-interface.c |    2 +-
 net/batman-adv/soft-interface.h |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b8d3f248..0fc997e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -553,7 +553,7 @@ static int interface_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
+static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index c24906d..001546f 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -25,7 +25,6 @@
 int my_skb_head_push(struct sk_buff *skb, unsigned int len);
 int softif_neigh_seq_print_text(struct seq_file *seq, void *offset);
 void softif_neigh_purge(struct bat_priv *bat_priv);
-int interface_tx(struct sk_buff *skb, struct net_device *soft_iface);
 void interface_rx(struct net_device *soft_iface,
 		  struct sk_buff *skb, struct hard_iface *recv_if,
 		  int hdr_size);
-- 
1.7.5.3

