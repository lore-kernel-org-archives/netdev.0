From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] net: docbook fixes for netif_ functions
Date: Wed, 31 Oct 2007 14:08:48 -0700
Message-ID: <20071031140848.4a425df2@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"Randy.Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39863 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754266AbXJaVJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 17:09:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation updates for network interfaces.

1. Add doc for netif_napi_add
2. Remove doc for unused returns from netif_rx
3. Add doc for netif_receive_skb

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-10-31 09:16:09.000000000 -0700
+++ b/include/linux/netdevice.h	2007-10-31 10:02:15.000000000 -0700
@@ -739,6 +739,16 @@ static inline void *netdev_priv(const st
  */
 #define SET_NETDEV_DEV(net, pdev)	((net)->dev.parent = (pdev))
 
+/**
+ *	netif_napi_add - initialize a napi context
+ *	@dev:  network device
+ *	@napi: napi context
+ *	@poll: polling function
+ *	@weight: default weight
+ *
+ * netif_napi_add() must be used to initialize a napi context prior to calling
+ * *any* of the other napi related functions.
+ */
 static inline void netif_napi_add(struct net_device *dev,
 				  struct napi_struct *napi,
 				  int (*poll)(struct napi_struct *, int),
--- a/net/core/dev.c	2007-10-31 09:16:09.000000000 -0700
+++ b/net/core/dev.c	2007-10-31 10:00:39.000000000 -0700
@@ -1751,9 +1751,6 @@ DEFINE_PER_CPU(struct netif_rx_stats, ne
  *
  *	return values:
  *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_CN_LOW   (low congestion)
- *	NET_RX_CN_MOD   (moderate congestion)
- *	NET_RX_CN_HIGH  (high congestion)
  *	NET_RX_DROP     (packet was dropped)
  *
  */
@@ -2001,6 +1998,21 @@ out:
 }
 #endif
 
+/**
+ *	netif_receive_skb - process receive buffer from network
+ *	@skb: buffer to process
+ *
+ *	netif_receive_skb() is the main receive data processing function.
+ *	It always succeeds. The buffer may be dropped during processing
+ *	for congestion control or by the protocol layers.
+ *
+ *	This function may only be called from softirq context and interrupts
+ *	should be enabled.
+ *
+ *	return values (usually ignored).
+ *	NET_RX_SUCCESS	(no congestion)
+ *	NET_RX_DROP     (packet was dropped)
+ */
 int netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
