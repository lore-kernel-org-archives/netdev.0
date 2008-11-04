From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net/: Kill now superfluous ->last_rx stores.
Date: Mon, 03 Nov 2008 22:01:45 -0800 (PST)
Message-ID: <20081103.220145.73307270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbYKDGCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 01:02:09 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 39D3FC8C183
	for <netdev@vger.kernel.org>; Mon,  3 Nov 2008 22:01:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/: Kill now superfluous ->last_rx stores.

The generic packet receive code takes care of setting
netdev->last_rx when necessary, for the sake of the
bonding ARP monitor.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/8021q/vlan_core.c        |    1 -
 net/8021q/vlan_dev.c         |    2 --
 net/bluetooth/bnep/core.c    |    1 -
 net/dsa/tag_dsa.c            |    1 -
 net/dsa/tag_edsa.c           |    1 -
 net/dsa/tag_trailer.c        |    1 -
 net/ieee80211/ieee80211_rx.c |    2 --
 7 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 916061f..118adef 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -24,7 +24,6 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		 * due to congestion. */
 		return NET_RX_SUCCESS;
 	}
-	skb->dev->last_rx = jiffies;
 	skb->vlan_tci = 0;
 
 	stats = &skb->dev->stats;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c269fcb..e4bf39f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -163,8 +163,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		goto err_unlock;
 	}
 
-	skb->dev->last_rx = jiffies;
-
 	stats = &skb->dev->stats;
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 80ba30c..7a4d530 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -311,7 +311,6 @@ static inline int bnep_rx_frame(struct bnep_session *s, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	u8 type;
 
-	dev->last_rx = jiffies;
 	s->stats.rx_bytes += skb->len;
 
 	type = *(u8 *) skb->data; skb_pull(skb, 1);
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index bdc0510..ff55823 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -161,7 +161,6 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb_push(skb, ETH_HLEN);
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->last_rx = jiffies;
 	skb->dev->stats.rx_packets++;
 	skb->dev->stats.rx_bytes += skb->len;
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index f985ea9..24b1c76 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -180,7 +180,6 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb_push(skb, ETH_HLEN);
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->last_rx = jiffies;
 	skb->dev->stats.rx_packets++;
 	skb->dev->stats.rx_bytes += skb->len;
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d311776..3bfd2e5 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -97,7 +97,6 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb_push(skb, ETH_HLEN);
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->last_rx = jiffies;
 	skb->dev->stats.rx_packets++;
 	skb->dev->stats.rx_bytes += skb->len;
 
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index a91ef84..3dd58b5 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -533,8 +533,6 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 	}
 #endif
 
-	dev->last_rx = jiffies;
-
 #ifdef NOT_YET
 	if ((ieee->iw_mode == IW_MODE_MASTER ||
 	     ieee->iw_mode == IW_MODE_REPEAT) && !from_assoc_ap) {
-- 
1.5.6.5

