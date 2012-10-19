From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 16/21] net: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:15:00 -0700
Message-ID: <cba1f28131d0283c8ede26ee5d053d3237e1b715.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new ipv4_addr_<foo> functions to be consistent with
the ipv6_addr_<foo> and eth_addr_<foo> style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/br_multicast.c         |    4 +-
 net/core/netpoll.c                |    2 +-
 net/core/pktgen.c                 |   10 +++---
 net/ipv4/arp.c                    |    4 +-
 net/ipv4/datagram.c               |    2 +-
 net/ipv4/devinet.c                |    4 +-
 net/ipv4/fib_frontend.c           |   12 ++++----
 net/ipv4/igmp.c                   |   12 ++++----
 net/ipv4/ip_gre.c                 |   20 ++++++------
 net/ipv4/ipmr.c                   |    4 +-
 net/ipv4/netfilter/ipt_rpfilter.c |   10 +++---
 net/ipv4/ping.c                   |    2 +-
 net/ipv4/raw.c                    |    2 +-
 net/ipv4/route.c                  |   58 ++++++++++++++++++------------------
 net/ipv4/udp.c                    |    2 +-
 net/ipv6/addrconf.c               |   12 ++++----
 net/l2tp/l2tp_ip.c                |    2 +-
 net/l2tp/l2tp_ip6.c               |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c   |    6 ++--
 net/netfilter/xt_cluster.c        |    2 +-
 net/netfilter/xt_pkttype.c        |    2 +-
 net/sctp/protocol.c               |   10 +++---
 22 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2417434..1a58375 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -696,7 +696,7 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 {
 	struct br_ip br_group;
 
-	if (ipv4_is_local_multicast(group))
+	if (ipv4_addr_local_multicast(group))
 		return 0;
 
 	br_group.u.ip4 = group;
@@ -1266,7 +1266,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 {
 	struct br_ip br_group;
 
-	if (ipv4_is_local_multicast(group))
+	if (ipv4_addr_local_multicast(group))
 		return;
 
 	br_group.u.ip4 = group;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 77a0388..7a84b2a 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -495,7 +495,7 @@ static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 	memcpy(&tip, arp_ptr, 4);
 
 	/* Should we ignore arp? */
-	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
+	if (ipv4_addr_loopback(tip) || ipv4_addr_multicast(tip))
 		return;
 
 	size = arp_hdr_len(skb->dev);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3422af7..8327f05 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2396,11 +2396,11 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					t = random32() % (imx - imn) + imn;
 					s = htonl(t);
 
-					while (ipv4_is_loopback(s) ||
-					       ipv4_is_multicast(s) ||
-					       ipv4_is_lbcast(s) ||
-					       ipv4_is_zeronet(s) ||
-					       ipv4_is_local_multicast(s)) {
+					while (ipv4_addr_loopback(s) ||
+					       ipv4_addr_multicast(s) ||
+					       ipv4_addr_lbcast(s) ||
+					       ipv4_addr_zeronet(s) ||
+					       ipv4_addr_local_multicast(s)) {
 						t = random32() % (imx - imn) + imn;
 						s = htonl(t);
 					}
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4780045..b03e5e4 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -789,8 +789,8 @@ static int arp_process(struct sk_buff *skb)
  *	Check for bad requests for 127.x.x.x and requests for multicast
  *	addresses.  If this is one such, delete it.
  */
-	if (ipv4_is_multicast(tip) ||
-	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
+	if (ipv4_addr_multicast(tip) ||
+	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_addr_loopback(tip)))
 		goto out;
 
 /*
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 424fafb..83b51ad 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -43,7 +43,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	oif = sk->sk_bound_dev_if;
 	saddr = inet->inet_saddr;
-	if (ipv4_is_multicast(usin->sin_addr.s_addr)) {
+	if (ipv4_addr_multicast(usin->sin_addr.s_addr)) {
 		if (!oif)
 			oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2a6abc1..f217d83 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -491,7 +491,7 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 		in_dev_hold(in_dev);
 		ifa->ifa_dev = in_dev;
 	}
-	if (ipv4_is_loopback(ifa->ifa_local))
+	if (ipv4_addr_loopback(ifa->ifa_local))
 		ifa->ifa_scope = RT_SCOPE_HOST;
 	return inet_insert_ifa(ifa);
 }
@@ -660,7 +660,7 @@ static int inet_abc_len(__be32 addr)
 {
 	int rc = -1;	/* Something else, probably a multicast. */
 
-	if (ipv4_is_zeronet(addr))
+	if (ipv4_addr_zeronet(addr))
 		rc = 0;
 	else {
 		__u32 haddr = ntohl(addr);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 825c608..9883d33 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -164,9 +164,9 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	unsigned int ret = RTN_BROADCAST;
 	struct fib_table *local_table;
 
-	if (ipv4_is_zeronet(addr) || ipv4_is_lbcast(addr))
+	if (ipv4_addr_zeronet(addr) || ipv4_addr_lbcast(addr))
 		return RTN_BROADCAST;
-	if (ipv4_is_multicast(addr))
+	if (ipv4_addr_multicast(addr))
 		return RTN_MULTICAST;
 
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
@@ -216,7 +216,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	net = dev_net(dev);
 
 	scope = RT_SCOPE_UNIVERSE;
-	if (!ipv4_is_zeronet(ip_hdr(skb)->saddr)) {
+	if (!ipv4_addr_zeronet(ip_hdr(skb)->saddr)) {
 		fl4.flowi4_oif = 0;
 		fl4.flowi4_iif = LOOPBACK_IFINDEX;
 		fl4.daddr = ip_hdr(skb)->saddr;
@@ -760,7 +760,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 	if (ifa->ifa_broadcast && ifa->ifa_broadcast != htonl(0xFFFFFFFF))
 		fib_magic(RTM_NEWROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 
-	if (!ipv4_is_zeronet(prefix) && !(ifa->ifa_flags & IFA_F_SECONDARY) &&
+	if (!ipv4_addr_zeronet(prefix) && !(ifa->ifa_flags & IFA_F_SECONDARY) &&
 	    (prefix != addr || ifa->ifa_prefixlen < 32)) {
 		fib_magic(RTM_NEWROUTE,
 			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
@@ -807,7 +807,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 			pr_warn("%s: bug: iprim != prim\n", __func__);
 			return;
 		}
-	} else if (!ipv4_is_zeronet(any) &&
+	} else if (!ipv4_addr_zeronet(any) &&
 		   (any != ifa->ifa_local || ifa->ifa_prefixlen < 32)) {
 		fib_magic(RTM_DELROUTE,
 			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
@@ -878,7 +878,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 			__be32 brd1 = ifa1->ifa_address | ~ifa1->ifa_mask;
 			__be32 any1 = ifa1->ifa_address & ifa1->ifa_mask;
 
-			if (!ipv4_is_zeronet(any1)) {
+			if (!ipv4_addr_zeronet(any1)) {
 				if (ifa->ifa_broadcast == brd1 ||
 				    ifa->ifa_broadcast == any1)
 					ok |= BRD_OK;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 736ab70..dc9a9b3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1796,7 +1796,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	int ifindex;
 	int count = 0;
 
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_addr_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -1920,7 +1920,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	int leavegroup = 0;
 	int i, j, rv;
 
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_addr_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -2055,7 +2055,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	struct net *net = sock_net(sk);
 	int leavegroup = 0;
 
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_addr_multicast(addr))
 		return -EINVAL;
 	if (msf->imsf_fmode != MCAST_INCLUDE &&
 	    msf->imsf_fmode != MCAST_EXCLUDE)
@@ -2141,7 +2141,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	struct ip_sf_socklist *psl;
 	struct net *net = sock_net(sk);
 
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_addr_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -2203,7 +2203,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (psin->sin_family != AF_INET)
 		return -EINVAL;
 	addr = psin->sin_addr.s_addr;
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_addr_multicast(addr))
 		return -EINVAL;
 
 	rtnl_lock();
@@ -2255,7 +2255,7 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	int ret;
 
 	ret = 1;
-	if (!ipv4_is_multicast(loc_addr))
+	if (!ipv4_addr_multicast(loc_addr))
 		goto out;
 
 	rcu_read_lock();
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index dd94879..4c9ef98 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -306,7 +306,7 @@ static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 	for_each_ip_tunnel_rcu(ign->tunnels_l[h1]) {
 		if ((local != t->parms.iph.saddr &&
 		     (local != t->parms.iph.daddr ||
-		      !ipv4_is_multicast(local))) ||
+		      !ipv4_addr_multicast(local))) ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
@@ -375,7 +375,7 @@ static struct ip_tunnel __rcu **__ipgre_bucket(struct ipgre_net *ign,
 
 	if (local)
 		prio |= 1;
-	if (remote && !ipv4_is_multicast(remote)) {
+	if (remote && !ipv4_addr_multicast(remote)) {
 		prio |= 2;
 		h ^= HASH(remote);
 	}
@@ -580,7 +580,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		return;
 	}
 	if (t->parms.iph.daddr == 0 ||
-	    ipv4_is_multicast(t->parms.iph.daddr))
+	    ipv4_addr_multicast(t->parms.iph.daddr))
 		return;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
@@ -681,7 +681,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (ipv4_is_multicast(iph->daddr)) {
+		if (ipv4_addr_multicast(iph->daddr)) {
 			/* Looped back packet, drop it! */
 			if (rt_is_output_route(skb_rtable(skb)))
 				goto drop;
@@ -877,7 +877,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 		if (rt6 && mtu < dst_mtu(skb_dst(skb)) && mtu >= IPV6_MIN_MTU) {
 			if ((tunnel->parms.iph.daddr &&
-			     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+			     !ipv4_addr_multicast(tunnel->parms.iph.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
 				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
@@ -1115,7 +1115,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 
 				t = netdev_priv(dev);
 
-				if (ipv4_is_multicast(p.iph.daddr))
+				if (ipv4_addr_multicast(p.iph.daddr))
 					nflags = IFF_BROADCAST;
 				else if (p.iph.daddr)
 					nflags = IFF_POINTOPOINT;
@@ -1266,7 +1266,7 @@ static int ipgre_open(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (ipv4_is_multicast(t->parms.iph.daddr)) {
+	if (ipv4_addr_multicast(t->parms.iph.daddr)) {
 		struct flowi4 fl4;
 		struct rtable *rt;
 
@@ -1292,7 +1292,7 @@ static int ipgre_close(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
+	if (ipv4_addr_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
 		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
 		if (in_dev)
@@ -1365,7 +1365,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 
 	if (iph->daddr) {
 #ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (ipv4_is_multicast(iph->daddr)) {
+		if (ipv4_addr_multicast(iph->daddr)) {
 			if (!iph->saddr)
 				return -EINVAL;
 			dev->flags = IFF_BROADCAST;
@@ -1663,7 +1663,7 @@ static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 		if (dev->type != ARPHRD_ETHER) {
 			unsigned int nflags = 0;
 
-			if (ipv4_is_multicast(p.iph.daddr))
+			if (ipv4_addr_multicast(p.iph.daddr))
 				nflags = IFF_BROADCAST;
 			else if (p.iph.daddr)
 				nflags = IFF_POINTOPOINT;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6168c4d..99d7ed2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1092,7 +1092,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		return 0;
 	}
 
-	if (!ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
+	if (!ipv4_addr_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
 	c = ipmr_cache_alloc();
@@ -1927,7 +1927,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	 * b. packet is not a NULL-REGISTER
 	 * c. packet is not truncated
 	 */
-	if (!ipv4_is_multicast(encap->daddr) ||
+	if (!ipv4_addr_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
 	    ntohs(encap->tot_len) + pimlen > skb->len)
 		return 1;
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index c301300..86ae272 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -26,8 +26,8 @@ MODULE_DESCRIPTION("iptables: ipv4 reverse path filter match");
 /* don't try to find route from mcast/bcast/zeronet */
 static __be32 rpfilter_get_saddr(__be32 addr)
 {
-	if (ipv4_is_multicast(addr) || ipv4_is_lbcast(addr) ||
-	    ipv4_is_zeronet(addr))
+	if (ipv4_addr_multicast(addr) || ipv4_addr_lbcast(addr) ||
+	    ipv4_addr_zeronet(addr))
 		return 0;
 	return addr;
 }
@@ -80,9 +80,9 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return true ^ invert;
 
 	iph = ip_hdr(skb);
-	if (ipv4_is_multicast(iph->daddr)) {
-		if (ipv4_is_zeronet(iph->saddr))
-			return ipv4_is_local_multicast(iph->daddr) ^ invert;
+	if (ipv4_addr_multicast(iph->daddr)) {
+		if (ipv4_addr_zeronet(iph->saddr))
+			return ipv4_addr_local_multicast(iph->daddr) ^ invert;
 		flow.flowi4_iif = 0;
 	} else {
 		flow.flowi4_iif = LOOPBACK_IFINDEX;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8f3d054..68adc89 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -553,7 +553,7 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		tos |= RTO_ONLINK;
 	}
 
-	if (ipv4_is_multicast(daddr)) {
+	if (ipv4_addr_multicast(daddr)) {
 		if (!ipc.oif)
 			ipc.oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 73d1e4d..4116bf3 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -562,7 +562,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (msg->msg_flags & MSG_DONTROUTE)
 		tos |= RTO_ONLINK;
 
-	if (ipv4_is_multicast(daddr)) {
+	if (ipv4_addr_multicast(daddr)) {
 		if (!ipc.oif)
 			ipc.oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a8c6512..263dfd8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -688,8 +688,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 
 	net = dev_net(dev);
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev) ||
-	    ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw) ||
-	    ipv4_is_zeronet(new_gw))
+	    ipv4_addr_multicast(new_gw) || ipv4_addr_lbcast(new_gw) ||
+	    ipv4_addr_zeronet(new_gw))
 		goto reject_redirect;
 
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
@@ -1332,16 +1332,16 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (in_dev == NULL)
 		return -EINVAL;
 
-	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
+	if (ipv4_addr_multicast(saddr) || ipv4_addr_lbcast(saddr) ||
 	    skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
 	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
-		if (ipv4_is_loopback(saddr))
+		if (ipv4_addr_loopback(saddr))
 			goto e_inval;
 
-	if (ipv4_is_zeronet(saddr)) {
-		if (!ipv4_is_local_multicast(daddr))
+	if (ipv4_addr_zeronet(saddr)) {
+		if (!ipv4_addr_local_multicast(daddr))
 			goto e_inval;
 	} else {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
@@ -1374,7 +1374,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 #ifdef CONFIG_IP_MROUTE
-	if (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
+	if (!ipv4_addr_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
 		rth->dst.input = ip_mr_input;
 #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
@@ -1553,29 +1553,29 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
-	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
+	if (ipv4_addr_multicast(saddr) || ipv4_addr_lbcast(saddr))
 		goto martian_source;
 
 	res.fi = NULL;
-	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
+	if (ipv4_addr_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
 	/* Accept zero addresses only to limited broadcast;
 	 * I even do not know to fix it or not. Waiting for complains :-)
 	 */
-	if (ipv4_is_zeronet(saddr))
+	if (ipv4_addr_zeronet(saddr))
 		goto martian_source;
 
-	if (ipv4_is_zeronet(daddr))
+	if (ipv4_addr_zeronet(daddr))
 		goto martian_destination;
 
 	/* Following code try to avoid calling IN_DEV_NET_ROUTE_LOCALNET(),
 	 * and call it once if daddr or/and saddr are loopback addresses
 	 */
-	if (ipv4_is_loopback(daddr)) {
+	if (ipv4_addr_loopback(daddr)) {
 		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
 			goto martian_destination;
-	} else if (ipv4_is_loopback(saddr)) {
+	} else if (ipv4_addr_loopback(saddr)) {
 		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
 			goto martian_source;
 	}
@@ -1620,7 +1620,7 @@ brd_input:
 	if (skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (!ipv4_is_zeronet(saddr)) {
+	if (!ipv4_addr_zeronet(saddr)) {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
 					  in_dev, &itag);
 		if (err < 0)
@@ -1726,7 +1726,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   Note, that multicast routers are not affected, because
 	   route cache entry is created eventually.
 	 */
-	if (ipv4_is_multicast(daddr)) {
+	if (ipv4_addr_multicast(daddr)) {
 		struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 		if (in_dev) {
@@ -1735,7 +1735,7 @@ int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			if (our
 #ifdef CONFIG_IP_MROUTE
 				||
-			    (!ipv4_is_local_multicast(daddr) &&
+			    (!ipv4_addr_local_multicast(daddr) &&
 			     IN_DEV_MFORWARD(in_dev))
 #endif
 			   ) {
@@ -1772,14 +1772,14 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		return ERR_PTR(-EINVAL);
 
 	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
-		if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
+		if (ipv4_addr_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
 			return ERR_PTR(-EINVAL);
 
-	if (ipv4_is_lbcast(fl4->daddr))
+	if (ipv4_addr_lbcast(fl4->daddr))
 		type = RTN_BROADCAST;
-	else if (ipv4_is_multicast(fl4->daddr))
+	else if (ipv4_addr_multicast(fl4->daddr))
 		type = RTN_MULTICAST;
-	else if (ipv4_is_zeronet(fl4->daddr))
+	else if (ipv4_addr_zeronet(fl4->daddr))
 		return ERR_PTR(-EINVAL);
 
 	if (dev_out->flags & IFF_LOOPBACK)
@@ -1860,7 +1860,7 @@ add:
 #ifdef CONFIG_IP_MROUTE
 		if (type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
-			    !ipv4_is_local_multicast(fl4->daddr)) {
+			    !ipv4_addr_local_multicast(fl4->daddr)) {
 				rth->dst.input = ip_mr_input;
 				rth->dst.output = ip_mc_output;
 			}
@@ -1900,9 +1900,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	rcu_read_lock();
 	if (fl4->saddr) {
 		rth = ERR_PTR(-EINVAL);
-		if (ipv4_is_multicast(fl4->saddr) ||
-		    ipv4_is_lbcast(fl4->saddr) ||
-		    ipv4_is_zeronet(fl4->saddr))
+		if (ipv4_addr_multicast(fl4->saddr) ||
+		    ipv4_addr_lbcast(fl4->saddr) ||
+		    ipv4_addr_zeronet(fl4->saddr))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -1914,8 +1914,8 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		 */
 
 		if (fl4->flowi4_oif == 0 &&
-		    (ipv4_is_multicast(fl4->daddr) ||
-		     ipv4_is_lbcast(fl4->daddr))) {
+		    (ipv4_addr_multicast(fl4->daddr) ||
+		     ipv4_addr_lbcast(fl4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 			dev_out = __ip_dev_find(net, fl4->saddr, false);
 			if (dev_out == NULL)
@@ -1959,15 +1959,15 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			rth = ERR_PTR(-ENETUNREACH);
 			goto out;
 		}
-		if (ipv4_is_local_multicast(fl4->daddr) ||
-		    ipv4_is_lbcast(fl4->daddr)) {
+		if (ipv4_addr_local_multicast(fl4->daddr) ||
+		    ipv4_addr_lbcast(fl4->daddr)) {
 			if (!fl4->saddr)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
 			goto make_route;
 		}
 		if (fl4->saddr) {
-			if (ipv4_is_multicast(fl4->daddr))
+			if (ipv4_addr_multicast(fl4->daddr))
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      fl4->flowi4_scope);
 			else if (!fl4->daddr)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..3d0f229 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -918,7 +918,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		connected = 0;
 	}
 
-	if (ipv4_is_multicast(daddr)) {
+	if (ipv4_addr_multicast(daddr)) {
 		if (!ipc.oif)
 			ipc.oif = inet->mc_index;
 		if (!saddr)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..190e8c3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1535,12 +1535,12 @@ static int __ipv6_isatap_ifid(u8 *eui, __be32 addr)
 {
 	if (addr == 0)
 		return -1;
-	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
-		  ipv4_is_loopback(addr) || ipv4_is_linklocal_169(addr) ||
-		  ipv4_is_private_172(addr) || ipv4_is_test_192(addr) ||
-		  ipv4_is_anycast_6to4(addr) || ipv4_is_private_192(addr) ||
-		  ipv4_is_test_198(addr) || ipv4_is_multicast(addr) ||
-		  ipv4_is_lbcast(addr)) ? 0x00 : 0x02;
+	eui[0] = (ipv4_addr_zeronet(addr) || ipv4_addr_private_10(addr) ||
+		  ipv4_addr_loopback(addr) || ipv4_addr_linklocal_169(addr) ||
+		  ipv4_addr_private_172(addr) || ipv4_addr_test_192(addr) ||
+		  ipv4_addr_anycast_6to4(addr) || ipv4_addr_private_192(addr) ||
+		  ipv4_addr_test_198(addr) || ipv4_addr_multicast(addr) ||
+		  ipv4_addr_lbcast(addr)) ? 0x00 : 0x02;
 	eui[1] = 0;
 	eui[2] = 0x5E;
 	eui[3] = 0xFE;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 61d8b75..823875c 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -303,7 +303,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (addr_len < sizeof(*lsa))
 		return -EINVAL;
 
-	if (ipv4_is_multicast(lsa->l2tp_addr.s_addr))
+	if (ipv4_addr_multicast(lsa->l2tp_addr.s_addr))
 		return -EINVAL;
 
 	rc = ip4_datagram_connect(sk, uaddr, addr_len);
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 9275471..edc8da9 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -371,7 +371,7 @@ static int l2tp_ip6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (addr_type & IPV6_ADDR_MAPPED) {
 		daddr = &usin->sin6_addr;
-		if (ipv4_is_multicast(daddr->s6_addr32[3]))
+		if (ipv4_addr_multicast(daddr->s6_addr32[3]))
 			return -EINVAL;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index cc4c809..aeee744 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -201,7 +201,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		ip_rt_put(rt);
 		return NULL;
 	}
-	if (unlikely(!local && ipv4_is_loopback(ip_hdr(skb)->saddr))) {
+	if (unlikely(!local && ipv4_addr_loopback(ip_hdr(skb)->saddr))) {
 		IP_VS_DBG_RL("Stopping traffic from loopback address %pI4 "
 			     "to non-local address, dest: %pI4\n",
 			     &ip_hdr(skb)->saddr, &daddr);
@@ -604,7 +604,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(cp->daddr.ip) &&
+	if (local && ipv4_addr_loopback(cp->daddr.ip) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
@@ -1239,7 +1239,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #endif
 
 	/* From world but DNAT to loopback address? */
-	if (local && ipv4_is_loopback(cp->daddr.ip) &&
+	if (local && ipv4_addr_loopback(cp->daddr.ip) &&
 	    rt_is_input_route(skb_rtable(skb))) {
 		IP_VS_DBG(1, "%s(): "
 			  "stopping DNAT to loopback %pI4\n",
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index f4af1bf..266faf0 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -72,7 +72,7 @@ xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 
 	switch(family) {
 	case NFPROTO_IPV4:
-		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
+		is_multicast = ipv4_addr_multicast(ip_hdr(skb)->daddr);
 		break;
 	case NFPROTO_IPV6:
 		is_multicast =
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index 5b645cb..c65c5c9 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -31,7 +31,7 @@ pkttype_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (skb->pkt_type != PACKET_LOOPBACK)
 		type = skb->pkt_type;
 	else if (par->family == NFPROTO_IPV4 &&
-	    ipv4_is_multicast(ip_hdr(skb)->daddr))
+	    ipv4_addr_multicast(ip_hdr(skb)->daddr))
 		type = PACKET_MULTICAST;
 	else if (par->family == NFPROTO_IPV6 &&
 	    ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 2d51842..405cefc 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -406,13 +406,13 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
 	/* Check for unusable SCTP addresses. */
 	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr)) {
 		retval =  SCTP_SCOPE_UNUSABLE;
-	} else if (ipv4_is_loopback(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_addr_loopback(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LOOPBACK;
-	} else if (ipv4_is_linklocal_169(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_addr_linklocal_169(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LINK;
-	} else if (ipv4_is_private_10(addr->v4.sin_addr.s_addr) ||
-		   ipv4_is_private_172(addr->v4.sin_addr.s_addr) ||
-		   ipv4_is_private_192(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_addr_private_10(addr->v4.sin_addr.s_addr) ||
+		   ipv4_addr_private_172(addr->v4.sin_addr.s_addr) ||
+		   ipv4_addr_private_192(addr->v4.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_PRIVATE;
 	} else {
 		retval = SCTP_SCOPE_GLOBAL;
-- 
1.7.8.111.gad25c.dirty
