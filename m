From: Dave Jones <davej@redhat.com>
Subject: fix up misplaced inlines.
Date: Wed, 21 Mar 2007 20:18:28 -0400
Message-ID: <20070322001828.GF9092@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932469AbXCVASb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 20:18:31 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l2M0IUot023557
	for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 20:18:30 -0400
Received: from gelk.kernelslacker.org (vpn-248-1.boston.redhat.com [10.13.248.1])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l2M0ITAm000335
	for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 20:18:29 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.13.8/8.13.8) with ESMTP id l2M0IS7L026352
	for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 20:18:29 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.13.8/8.13.8/Submit) id l2M0IS2V026351
	for netdev@vger.kernel.org; Wed, 21 Mar 2007 20:18:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Turning up the warnings on gcc makes it emit warnings
about the placement of 'inline' in function declarations.
Here's everything that was under net/

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 4c914df..ecfe8da 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -319,7 +319,7 @@ static int __hidp_send_ctrl_message(struct hidp_session *session,
 	return 0;
 }
 
-static int inline hidp_send_ctrl_message(struct hidp_session *session,
+static inline int hidp_send_ctrl_message(struct hidp_session *session,
 			unsigned char hdr, unsigned char *data, int size)
 {
 	int err;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 7712d76..5439a3c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -61,7 +61,7 @@ static int brnf_filter_vlan_tagged __read_mostly = 1;
 #define brnf_filter_vlan_tagged 1
 #endif
 
-static __be16 inline vlan_proto(const struct sk_buff *skb)
+static inline __be16 vlan_proto(const struct sk_buff *skb)
 {
 	return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 8d65d64..27c4f62 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -808,7 +808,7 @@ lenout:
  *
  * (We also register the sk_lock with the lock validator.)
  */
-static void inline sock_lock_init(struct sock *sk)
+static inline void sock_lock_init(struct sock *sk)
 {
 	sock_lock_init_class_and_name(sk,
 			af_family_slock_key_strings[sk->sk_family],
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a7fee6b..1b61699 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -804,7 +804,7 @@ struct ipv6_saddr_score {
 #define IPV6_SADDR_SCORE_LABEL		0x0020
 #define IPV6_SADDR_SCORE_PRIVACY	0x0040
 
-static int inline ipv6_saddr_preferred(int type)
+static inline int ipv6_saddr_preferred(int type)
 {
 	if (type & (IPV6_ADDR_MAPPED|IPV6_ADDR_COMPATv4|
 		    IPV6_ADDR_LOOPBACK|IPV6_ADDR_RESERVED))
@@ -813,7 +813,7 @@ static int inline ipv6_saddr_preferred(int type)
 }
 
 /* static matching label */
-static int inline ipv6_saddr_label(const struct in6_addr *addr, int type)
+static inline int ipv6_saddr_label(const struct in6_addr *addr, int type)
 {
  /*
   * 	prefix (longest match)	label
@@ -3318,7 +3318,7 @@ errout:
 		rtnl_set_sk_err(RTNLGRP_IPV6_IFADDR, err);
 }
 
-static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
+static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 				__s32 *array, int bytes)
 {
 	BUG_ON(bytes < (DEVCONF_MAX * 4));
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0e1f4b2..a6b3117 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -308,7 +308,7 @@ static inline void rt6_probe(struct rt6_info *rt)
 /*
  * Default Router Selection (RFC 2461 6.3.6)
  */
-static int inline rt6_check_dev(struct rt6_info *rt, int oif)
+static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 {
 	struct net_device *dev = rt->rt6i_dev;
 	int ret = 0;
@@ -328,7 +328,7 @@ static int inline rt6_check_dev(struct rt6_info *rt, int oif)
 	return ret;
 }
 
-static int inline rt6_check_neigh(struct rt6_info *rt)
+static inline int rt6_check_neigh(struct rt6_info *rt)
 {
 	struct neighbour *neigh = rt->rt6i_nexthop;
 	int m = 0;
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index ee4b84a..93c4223 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -58,7 +58,7 @@ static struct kmem_cache *xfrm6_tunnel_spi_kmem __read_mostly;
 static struct hlist_head xfrm6_tunnel_spi_byaddr[XFRM6_TUNNEL_SPI_BYADDR_HSIZE];
 static struct hlist_head xfrm6_tunnel_spi_byspi[XFRM6_TUNNEL_SPI_BYSPI_HSIZE];
 
-static unsigned inline xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
+static inline unsigned xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
 {
 	unsigned h;
 
@@ -70,7 +70,7 @@ static unsigned inline xfrm6_tunnel_spi_hash_byaddr(xfrm_address_t *addr)
 	return h;
 }
 
-static unsigned inline xfrm6_tunnel_spi_hash_byspi(u32 spi)
+static inline unsigned xfrm6_tunnel_spi_hash_byspi(u32 spi)
 {
 	return spi % XFRM6_TUNNEL_SPI_BYSPI_HSIZE;
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index e85df07..abc47cc 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -93,7 +93,7 @@ void route4_reset_fastmap(struct net_device *dev, struct route4_head *head, u32
 	spin_unlock_bh(&dev->queue_lock);
 }
 
-static void __inline__
+static inline void
 route4_set_fastmap(struct route4_head *head, u32 id, int iif,
 		   struct route4_filter *f)
 {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9678995..e81e2fb 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2025,7 +2025,7 @@ nlmsg_failure:
 	return -1;
 }
 
-static int inline xfrm_sa_len(struct xfrm_state *x)
+static inline int xfrm_sa_len(struct xfrm_state *x)
 {
 	int l = 0;
 	if (x->aalg)


-- 
http://www.codemonkey.org.uk
