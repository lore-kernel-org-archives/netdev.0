From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] udp: remove a useless initialization
Date: Wed,  8 May 2013 11:04:06 +0800
Message-ID: <1367982246-10730-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539Ab3EHDES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 23:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'inner_eth' is not used until it is assigned with the same
value later.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0ae038a..3d036bdd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2311,7 +2311,7 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	struct ethhdr *inner_eth = (struct ethhdr *)skb_inner_mac_header(skb);
+	struct ethhdr *inner_eth;
 	__be16 protocol = skb->protocol;
 	netdev_features_t enc_features;
 	int outer_hlen;
