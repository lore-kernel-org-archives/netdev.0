From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [RFC PATCH 2/2] tunneling: capture inner headers during encapsulation
Date: Thu, 25 Oct 2012 11:29:13 -0700
Message-ID: <1351189753-5912-3-git-send-email-joseph.gasparakis@intel.com>
References: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49302 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759865Ab2JYSV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 14:21:57 -0400
In-Reply-To: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populating the inner header pointers of skb for vxlan and ipgre
---
 drivers/net/vxlan.c | 4 ++++
 net/ipv4/ip_gre.c   | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 51de9ed..7cd1e5a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -647,6 +647,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u8 tos, ttl;
 	int err;
 
+	skb->inner_mac_header = skb->mac_header;
+	skb->inner_network_header = skb->network_header;
+	skb->inner_transport_header = skb->transport_header;
+
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..b20ff8f 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -902,6 +902,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tunnel->err_count = 0;
 	}
 
+	skb->inner_mac_header = skb->mac_header;
+	skb->inner_network_header = skb->network_header;
+	skb->inner_transport_header = skb->transport_header;
+
 	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->dst.header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
-- 
1.7.11.7
