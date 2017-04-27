From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 1/9] ipvlan: fix coding style for the ipvlan tree
Date: Thu, 27 Apr 2017 15:51:34 +0100
Message-ID: <20170427145142.15830-2-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:58459 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755229AbdD0Owg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:36 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the ipvlan and ipvtap drivers to comply to the Linux coding
style, fixing errors and warnings reported by checkpatch.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 29 ++++++++++++++++-------------
 drivers/net/ipvlan/ipvlan_main.c | 31 ++++++++++++++-----------------
 drivers/net/ipvlan/ipvtap.c      |  1 +
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 1f3295e..1266f01 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -17,7 +17,7 @@ void ipvlan_init_secret(void)
 }
 
 void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
-			    unsigned int len, bool success, bool mcast)
+		     unsigned int len, bool success, bool mcast)
 {
 	if (likely(success)) {
 		struct ipvl_pcpu_stats *pcptr;
@@ -95,9 +95,9 @@ struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
 
 	list_for_each_entry(addr, &ipvlan->addrs, anode) {
 		if ((is_v6 && addr->atype == IPVL_IPV6 &&
-		    ipv6_addr_equal(&addr->ip6addr, iaddr)) ||
+		     ipv6_addr_equal(&addr->ip6addr, iaddr)) ||
 		    (!is_v6 && addr->atype == IPVL_IPV4 &&
-		    addr->ip4addr.s_addr == ((struct in_addr *)iaddr)->s_addr))
+		     addr->ip4addr.s_addr == ((struct in_addr *)iaddr)->s_addr))
 			return addr;
 	}
 	return NULL;
@@ -179,7 +179,7 @@ static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
 
 unsigned int ipvlan_mac_hash(const unsigned char *addr)
 {
-	u32 hash = jhash_1word(__get_unaligned_cpu32(addr+2),
+	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
 			       ipvlan_jhash_secret);
 
 	return hash & IPVLAN_MAC_FILTER_MASK;
@@ -234,11 +234,13 @@ void ipvlan_process_multicast(struct work_struct *work)
 				nskb->pkt_type = pkt_type;
 				nskb->dev = ipvlan->dev;
 				if (tx_pkt)
-					ret = dev_forward_skb(ipvlan->dev, nskb);
+					ret = dev_forward_skb(ipvlan->dev,
+							      nskb);
 				else
 					ret = netif_rx(nskb);
 			}
-			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
+			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS,
+					true);
 			local_bh_enable();
 		}
 		rcu_read_unlock();
@@ -461,11 +463,11 @@ static int ipvlan_process_outbound(struct sk_buff *skb)
 		skb_reset_network_header(skb);
 	}
 
-	if (skb->protocol == htons(ETH_P_IPV6))
+	if (skb->protocol == htons(ETH_P_IPV6)) {
 		ret = ipvlan_process_v6_outbound(skb);
-	else if (skb->protocol == htons(ETH_P_IP))
+	} else if (skb->protocol == htons(ETH_P_IP)) {
 		ret = ipvlan_process_v4_outbound(skb);
-	else {
+	} else {
 		pr_warn_ratelimited("Dropped outbound packet type=%x\n",
 				    ntohs(skb->protocol));
 		kfree_skb(skb);
@@ -534,7 +536,8 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
 		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 		if (lyr3h) {
-			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
+			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h,
+						  addr_type, true);
 			if (addr)
 				return ipvlan_rcv_frame(addr, &skb, true);
 		}
@@ -570,7 +573,7 @@ int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
 		goto out;
 
-	switch(port->mode) {
+	switch (port->mode) {
 	case IPVLAN_MODE_L2:
 		return ipvlan_xmit_mode_l2(skb, dev);
 	case IPVLAN_MODE_L3:
@@ -580,7 +583,7 @@ int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Should not reach here */
 	WARN_ONCE(true, "ipvlan_queue_xmit() called for mode = [%hx]\n",
-			  port->mode);
+		  port->mode);
 out:
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
@@ -685,7 +688,7 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 
 	/* Should not reach here */
 	WARN_ONCE(true, "ipvlan_handle_frame() called for mode = [%hx]\n",
-			  port->mode);
+		  port->mode);
 	kfree_skb(skb);
 	return RX_HANDLER_CONSUMED;
 }
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index aa8575c..b837807 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,7 +9,7 @@
 
 #include "ipvlan.h"
 
-static u32 ipvl_nf_hook_refcnt = 0;
+static u32 ipvl_nf_hook_refcnt;
 
 static struct nf_hook_ops ipvl_nfops[] __read_mostly = {
 	{
@@ -73,8 +73,9 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
 			if (!err) {
 				mdev->l3mdev_ops = &ipvl_l3mdev_ops;
 				mdev->priv_flags |= IFF_L3MDEV_MASTER;
-			} else
+			} else {
 				return err;
+			}
 		} else if (port->mode == IPVLAN_MODE_L3S) {
 			/* Old mode was L3S */
 			mdev->priv_flags &= ~IFF_L3MDEV_MASTER;
@@ -107,7 +108,7 @@ static int ipvlan_port_create(struct net_device *dev)
 		return -EBUSY;
 	}
 
-	port = kzalloc(sizeof(struct ipvl_port), GFP_KERNEL);
+	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	if (!port)
 		return -ENOMEM;
 
@@ -163,7 +164,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
 #define IPVLAN_STATE_MASK \
-	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
+	((1 << __LINK_STATE_NOCARRIER) | (1 << __LINK_STATE_DORMANT))
 
 static int ipvlan_init(struct net_device *dev)
 {
@@ -274,7 +275,7 @@ static void ipvlan_change_rx_flags(struct net_device *dev, int change)
 	struct net_device *phy_dev = ipvlan->phy_dev;
 
 	if (change & IFF_ALLMULTI)
-		dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
+		dev_set_allmulti(phy_dev, (dev->flags & IFF_ALLMULTI) ? 1 : -1);
 }
 
 static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
@@ -319,7 +320,7 @@ static void ipvlan_get_stats64(struct net_device *dev,
 		for_each_possible_cpu(idx) {
 			pcptr = per_cpu_ptr(ipvlan->pcpu_stats, idx);
 			do {
-				strt= u64_stats_fetch_begin_irq(&pcptr->syncp);
+				strt = u64_stats_fetch_begin_irq(&pcptr->syncp);
 				rx_pkts = pcptr->rx_pkts;
 				rx_bytes = pcptr->rx_bytes;
 				rx_mcast = pcptr->rx_mcast;
@@ -386,7 +387,7 @@ static const struct net_device_ops ipvlan_netdev_ops = {
 
 static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 			      unsigned short type, const void *daddr,
-			      const void *saddr, unsigned len)
+			      const void *saddr, unsigned int len)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct net_device *phy_dev = ipvlan->phy_dev;
@@ -400,7 +401,7 @@ static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 }
 
 static const struct header_ops ipvlan_header_ops = {
-	.create  	= ipvlan_hard_header,
+	.create		= ipvlan_hard_header,
 	.parse		= eth_header_parse,
 	.cache		= eth_header_cache,
 	.cache_update	= eth_header_cache_update,
@@ -571,13 +572,12 @@ int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		goto remove_ida;
 
 	err = netdev_upper_dev_link(phy_dev, dev);
-	if (err) {
+	if (err)
 		goto unregister_netdev;
-	}
+
 	err = ipvlan_set_port_mode(port, mode);
-	if (err) {
+	if (err)
 		goto unlink_netdev;
-	}
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
 	netif_stacked_transfer_operstate(phy_dev, dev);
@@ -627,8 +627,7 @@ void ipvlan_link_setup(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(ipvlan_link_setup);
 
-static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] =
-{
+static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] = {
 	[IFLA_IPVLAN_MODE] = { .type = NLA_U16 },
 };
 
@@ -709,7 +708,7 @@ static int ipvlan_add_addr(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
 {
 	struct ipvl_addr *addr;
 
-	addr = kzalloc(sizeof(struct ipvl_addr), GFP_ATOMIC);
+	addr = kzalloc(sizeof(*addr), GFP_ATOMIC);
 	if (!addr)
 		return -ENOMEM;
 
@@ -743,8 +742,6 @@ static void ipvlan_del_addr(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6)
 	ipvlan_ht_addr_del(addr);
 	list_del(&addr->anode);
 	kfree_rcu(addr, rcu);
-
-	return;
 }
 
 static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
diff --git a/drivers/net/ipvlan/ipvtap.c b/drivers/net/ipvlan/ipvtap.c
index 2b713b6..04b2d50 100644
--- a/drivers/net/ipvlan/ipvtap.c
+++ b/drivers/net/ipvlan/ipvtap.c
@@ -32,6 +32,7 @@ static struct cdev ipvtap_cdev;
 static const void *ipvtap_net_namespace(struct device *d)
 {
 	struct net_device *dev = to_net_dev(d->parent);
+
 	return dev_net(dev);
 }
 
-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
