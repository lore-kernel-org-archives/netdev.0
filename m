From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Wed, 29 Jul 2015 22:51:41 +0200
Message-ID: <1438203103-27013-2-git-send-email-phil@nwl.cc>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42184 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753849AbbG2Uvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 16:51:47 -0400
In-Reply-To: <1438203103-27013-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/Kconfig        | 12 ++++++++++++
 net/ethernet/eth.c |  2 +-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/Kconfig b/net/Kconfig
index 7021c1b..21c164f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -48,6 +48,18 @@ config COMPAT_NETLINK_MESSAGES
 config NET_INGRESS
 	bool
 
+config DEFAULT_TX_QUEUE_LEN
+	prompt "Default TX queue length (in packets)" if EXPERT
+	int
+	default 1000	# Ethernet wants good queues
+	help
+	  Set the default value of tx_queue_len for newly created network
+	  interfaces. It is used by queueing disciplines to determine how many
+	  packets to keep in backlog before starting to drop new ones.
+
+	  The default value of 1000 packets is there for a very long time and
+	  in combination with GSO way too big.
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 77e0f0e..b778586 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -355,7 +355,7 @@ void ether_setup(struct net_device *dev)
 	dev->hard_header_len 	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
-	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
+	dev->tx_queue_len	= CONFIG_DEFAULT_TX_QUEUE_LEN;
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	dev->priv_flags		|= IFF_TX_SKB_SHARING;
 
-- 
2.1.2
