From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: cleanups
Date: Tue, 05 Oct 2010 08:00:18 +0200
Message-ID: <1286258418.2457.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57526 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab0JEGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 02:00:24 -0400
Received: by wyb28 with SMTP id 28so5697048wyb.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 23:00:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code style cleanups before upcoming functional changes.
C99 initializer for fib_props array.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_frontend.c  |  121 +++++++++--------
 net/ipv4/fib_rules.c     |   10 -
 net/ipv4/fib_semantics.c |  257 +++++++++++++++++++------------------
 3 files changed, 206 insertions(+), 182 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4a69a95..b05c23b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -225,30 +225,33 @@ EXPORT_SYMBOL(inet_addr_type);
 unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
 				__be32 addr)
 {
-       return __inet_dev_addr_type(net, dev, addr);
+	return __inet_dev_addr_type(net, dev, addr);
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
 /* Given (packet source, input interface) and optional (dst, oif, tos):
-   - (main) check, that source is valid i.e. not broadcast or our local
-     address.
-   - figure out what "logical" interface this packet arrived
-     and calculate "specific destination" address.
-   - check, that packet arrived from expected physical interface.
+ * - (main) check, that source is valid i.e. not broadcast or our local
+ *   address.
+ * - figure out what "logical" interface this packet arrived
+ *   and calculate "specific destination" address.
+ * - check, that packet arrived from expected physical interface.
  */
-
 int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			struct net_device *dev, __be32 *spec_dst,
 			u32 *itag, u32 mark)
 {
 	struct in_device *in_dev;
-	struct flowi fl = { .nl_u = { .ip4_u =
-				      { .daddr = src,
-					.saddr = dst,
-					.tos = tos } },
-			    .mark = mark,
-			    .iif = oif };
-
+	struct flowi fl = {
+		.nl_u = {
+			.ip4_u = {
+				.daddr = src,
+				.saddr = dst,
+				.tos = tos
+			}
+		},
+		.mark = mark,
+		.iif = oif
+	};
 	struct fib_result res;
 	int no_addr, rpf, accept_local;
 	bool dev_match;
@@ -477,9 +480,9 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 }
 
 /*
- *	Handle IP routing ioctl calls. These are used to manipulate the routing tables
+ * Handle IP routing ioctl calls.
+ * These are used to manipulate the routing tables
  */
-
 int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 {
 	struct fib_config cfg;
@@ -523,7 +526,7 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	return -EINVAL;
 }
 
-const struct nla_policy rtm_ipv4_policy[RTA_MAX+1] = {
+const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_SRC]		= { .type = NLA_U32 },
 	[RTA_IIF]		= { .type = NLA_U32 },
@@ -537,7 +540,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX+1] = {
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
-			    struct nlmsghdr *nlh, struct fib_config *cfg)
+			     struct nlmsghdr *nlh, struct fib_config *cfg)
 {
 	struct nlattr *attr;
 	int err, remaining;
@@ -692,12 +695,11 @@ out:
 }
 
 /* Prepare and feed intra-kernel routing request.
-   Really, it should be netlink message, but :-( netlink
-   can be not configured, so that we feed it directly
-   to fib engine. It is legal, because all events occur
-   only when netlink is already locked.
+ * Really, it should be netlink message, but :-( netlink
+ * can be not configured, so that we feed it directly
+ * to fib engine. It is legal, because all events occur
+ * only when netlink is already locked.
  */
-
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
@@ -743,9 +745,9 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 	struct in_ifaddr *prim = ifa;
 	__be32 mask = ifa->ifa_mask;
 	__be32 addr = ifa->ifa_local;
-	__be32 prefix = ifa->ifa_address&mask;
+	__be32 prefix = ifa->ifa_address & mask;
 
-	if (ifa->ifa_flags&IFA_F_SECONDARY) {
+	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, prefix, mask);
 		if (prim == NULL) {
 			printk(KERN_WARNING "fib_add_ifaddr: bug: prim == NULL\n");
@@ -755,22 +757,24 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 
 	fib_magic(RTM_NEWROUTE, RTN_LOCAL, addr, 32, prim);
 
-	if (!(dev->flags&IFF_UP))
+	if (!(dev->flags & IFF_UP))
 		return;
 
 	/* Add broadcast address, if it is explicitly assigned. */
 	if (ifa->ifa_broadcast && ifa->ifa_broadcast != htonl(0xFFFFFFFF))
 		fib_magic(RTM_NEWROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 
-	if (!ipv4_is_zeronet(prefix) && !(ifa->ifa_flags&IFA_F_SECONDARY) &&
+	if (!ipv4_is_zeronet(prefix) && !(ifa->ifa_flags & IFA_F_SECONDARY) &&
 	    (prefix != addr || ifa->ifa_prefixlen < 32)) {
-		fib_magic(RTM_NEWROUTE, dev->flags&IFF_LOOPBACK ? RTN_LOCAL :
-			  RTN_UNICAST, prefix, ifa->ifa_prefixlen, prim);
+		fib_magic(RTM_NEWROUTE,
+			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
+			  prefix, ifa->ifa_prefixlen, prim);
 
 		/* Add network specific broadcasts, when it takes a sense */
 		if (ifa->ifa_prefixlen < 31) {
 			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix, 32, prim);
-			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix|~mask, 32, prim);
+			fib_magic(RTM_NEWROUTE, RTN_BROADCAST, prefix | ~mask,
+				  32, prim);
 		}
 	}
 }
@@ -781,17 +785,18 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 	struct net_device *dev = in_dev->dev;
 	struct in_ifaddr *ifa1;
 	struct in_ifaddr *prim = ifa;
-	__be32 brd = ifa->ifa_address|~ifa->ifa_mask;
-	__be32 any = ifa->ifa_address&ifa->ifa_mask;
+	__be32 brd = ifa->ifa_address | ~ifa->ifa_mask;
+	__be32 any = ifa->ifa_address & ifa->ifa_mask;
 #define LOCAL_OK	1
 #define BRD_OK		2
 #define BRD0_OK		4
 #define BRD1_OK		8
 	unsigned ok = 0;
 
-	if (!(ifa->ifa_flags&IFA_F_SECONDARY))
-		fib_magic(RTM_DELROUTE, dev->flags&IFF_LOOPBACK ? RTN_LOCAL :
-			  RTN_UNICAST, any, ifa->ifa_prefixlen, prim);
+	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
+		fib_magic(RTM_DELROUTE,
+			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
+			  any, ifa->ifa_prefixlen, prim);
 	else {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
 		if (prim == NULL) {
@@ -801,9 +806,9 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 	}
 
 	/* Deletion is more complicated than add.
-	   We should take care of not to delete too much :-)
-
-	   Scan address list to be sure that addresses are really gone.
+	 * We should take care of not to delete too much :-)
+	 *
+	 * Scan address list to be sure that addresses are really gone.
 	 */
 
 	for (ifa1 = in_dev->ifa_list; ifa1; ifa1 = ifa1->ifa_next) {
@@ -817,23 +822,23 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 			ok |= BRD0_OK;
 	}
 
-	if (!(ok&BRD_OK))
+	if (!(ok & BRD_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
-	if (!(ok&BRD1_OK))
+	if (!(ok & BRD1_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, brd, 32, prim);
-	if (!(ok&BRD0_OK))
+	if (!(ok & BRD0_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
-	if (!(ok&LOCAL_OK)) {
+	if (!(ok & LOCAL_OK)) {
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
 		if (inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
-			   We must flush stray FIB entries.
-
-			   First of all, we scan fib_info list searching
-			   for stray nexthop entries, then ignite fib_flush.
-			*/
+			 * We must flush stray FIB entries.
+			 *
+			 * First of all, we scan fib_info list searching
+			 * for stray nexthop entries, then ignite fib_flush.
+			 */
 			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
 				fib_flush(dev_net(dev));
 		}
@@ -844,14 +849,20 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 #undef BRD1_OK
 }
 
-static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb )
+static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 {
 
 	struct fib_result       res;
-	struct flowi            fl = { .mark = frn->fl_mark,
-				       .nl_u = { .ip4_u = { .daddr = frn->fl_addr,
-							    .tos = frn->fl_tos,
-							    .scope = frn->fl_scope } } };
+	struct flowi            fl = {
+		.mark = frn->fl_mark,
+		.nl_u = {
+			.ip4_u = {
+				.daddr = frn->fl_addr,
+				.tos = frn->fl_tos,
+				.scope = frn->fl_scope
+			}
+		}
+	};
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r = NULL;
@@ -899,8 +910,8 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	nl_fib_lookup(frn, tb);
 
-	pid = NETLINK_CB(skb).pid;       /* pid of sending process */
-	NETLINK_CB(skb).pid = 0;         /* from kernel */
+	pid = NETLINK_CB(skb).pid;      /* pid of sending process */
+	NETLINK_CB(skb).pid = 0;        /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
 	netlink_unicast(net->ipv4.fibnl, skb, pid, MSG_DONTWAIT);
 }
@@ -947,7 +958,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 		fib_del_ifaddr(ifa);
 		if (ifa->ifa_dev->ifa_list == NULL) {
 			/* Last address was deleted from this interface.
-			   Disable IP.
+			 * Disable IP.
 			 */
 			fib_disable_ip(dev, 1, 0);
 		} else {
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 76daeb5..3230052 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -6,7 +6,7 @@
  *		IPv4 Forwarding Information Base: policy rules.
  *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
- * 		Thomas Graf <tgraf@suug.ch>
+ *		Thomas Graf <tgraf@suug.ch>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -14,7 +14,7 @@
  *		2 of the License, or (at your option) any later version.
  *
  * Fixes:
- * 		Rani Assaf	:	local_rule cannot be deleted
+ *		Rani Assaf	:	local_rule cannot be deleted
  *		Marc Boucher	:	routing by fwmark
  */
 
@@ -32,8 +32,7 @@
 #include <net/ip_fib.h>
 #include <net/fib_rules.h>
 
-struct fib4_rule
-{
+struct fib4_rule {
 	struct fib_rule		common;
 	u8			dst_len;
 	u8			src_len;
@@ -91,7 +90,8 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto errout;
 	}
 
-	if ((tbl = fib_get_table(rule->fr_net, rule->table)) == NULL)
+	tbl = fib_get_table(rule->fr_net, rule->table);
+	if (!tbl)
 		goto errout;
 
 	err = fib_table_lookup(tbl, flp, (struct fib_result *) arg->result);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 20f09c5..ba52f39 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -60,21 +60,30 @@ static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
 
 static DEFINE_SPINLOCK(fib_multipath_lock);
 
-#define for_nexthops(fi) { int nhsel; const struct fib_nh * nh; \
-for (nhsel=0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
-
-#define change_nexthops(fi) { int nhsel; struct fib_nh *nexthop_nh; \
-for (nhsel=0, nexthop_nh = (struct fib_nh *)((fi)->fib_nh); nhsel < (fi)->fib_nhs; nexthop_nh++, nhsel++)
+#define for_nexthops(fi) {						\
+	int nhsel; const struct fib_nh *nh;				\
+	for (nhsel = 0, nh = (fi)->fib_nh;				\
+	     nhsel < (fi)->fib_nhs;					\
+	     nh++, nhsel++)
+
+#define change_nexthops(fi) {						\
+	int nhsel; struct fib_nh *nexthop_nh;				\
+	for (nhsel = 0,	nexthop_nh = (struct fib_nh *)((fi)->fib_nh);	\
+	     nhsel < (fi)->fib_nhs;					\
+	     nexthop_nh++, nhsel++)
 
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
 
 /* Hope, that gcc will optimize it to get rid of dummy loop */
 
-#define for_nexthops(fi) { int nhsel = 0; const struct fib_nh * nh = (fi)->fib_nh; \
-for (nhsel=0; nhsel < 1; nhsel++)
+#define for_nexthops(fi) {						\
+	int nhsel; const struct fib_nh *nh = (fi)->fib_nh;		\
+	for (nhsel = 0; nhsel < 1; nhsel++)
 
-#define change_nexthops(fi) { int nhsel = 0; struct fib_nh *nexthop_nh = (struct fib_nh *)((fi)->fib_nh); \
-for (nhsel=0; nhsel < 1; nhsel++)
+#define change_nexthops(fi) {						\
+	int nhsel;							\
+	struct fib_nh *nexthop_nh = (struct fib_nh *)((fi)->fib_nh);	\
+	for (nhsel = 0; nhsel < 1; nhsel++)
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
@@ -86,54 +95,54 @@ static const struct
 	int	error;
 	u8	scope;
 } fib_props[RTN_MAX + 1] = {
-	{
+	[RTN_UNSPEC] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_NOWHERE,
-	},	/* RTN_UNSPEC */
-	{
+	},
+	[RTN_UNICAST] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_UNICAST */
-	{
+	},
+	[RTN_LOCAL] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_HOST,
-	},	/* RTN_LOCAL */
-	{
+	},
+	[RTN_BROADCAST] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_LINK,
-	},	/* RTN_BROADCAST */
-	{
+	},
+	[RTN_ANYCAST] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_LINK,
-	},	/* RTN_ANYCAST */
-	{
+	},
+	[RTN_MULTICAST] = {
 		.error	= 0,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_MULTICAST */
-	{
+	},
+	[RTN_BLACKHOLE] = {
 		.error	= -EINVAL,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_BLACKHOLE */
-	{
+	},
+	[RTN_UNREACHABLE] = {
 		.error	= -EHOSTUNREACH,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_UNREACHABLE */
-	{
+	},
+	[RTN_PROHIBIT] = {
 		.error	= -EACCES,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_PROHIBIT */
-	{
+	},
+	[RTN_THROW] = {
 		.error	= -EAGAIN,
 		.scope	= RT_SCOPE_UNIVERSE,
-	},	/* RTN_THROW */
-	{
+	},
+	[RTN_NAT] = {
 		.error	= -EINVAL,
 		.scope	= RT_SCOPE_NOWHERE,
-	},	/* RTN_NAT */
-	{
+	},
+	[RTN_XRESOLVE] = {
 		.error	= -EINVAL,
 		.scope	= RT_SCOPE_NOWHERE,
-	},	/* RTN_XRESOLVE */
+	},
 };
 
 
@@ -142,7 +151,7 @@ static const struct
 void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
-		printk(KERN_WARNING "Freeing alive fib_info %p\n", fi);
+		pr_warning("Freeing alive fib_info %p\n", fi);
 		return;
 	}
 	change_nexthops(fi) {
@@ -173,7 +182,7 @@ void fib_release_info(struct fib_info *fi)
 	spin_unlock_bh(&fib_info_lock);
 }
 
-static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
+static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 {
 	const struct fib_nh *onh = ofi->fib_nh;
 
@@ -187,7 +196,7 @@ static __inline__ int nh_comp(const struct fib_info *fi, const struct fib_info *
 #ifdef CONFIG_NET_CLS_ROUTE
 		    nh->nh_tclassid != onh->nh_tclassid ||
 #endif
-		    ((nh->nh_flags^onh->nh_flags)&~RTNH_F_DEAD))
+		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
 			return -1;
 		onh++;
 	} endfor_nexthops(fi);
@@ -238,7 +247,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 		    nfi->fib_priority == fi->fib_priority &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
 			   sizeof(fi->fib_metrics)) == 0 &&
-		    ((nfi->fib_flags^fi->fib_flags)&~RTNH_F_DEAD) == 0 &&
+		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) == 0 &&
 		    (nfi->fib_nhs == 0 || nh_comp(fi, nfi) == 0))
 			return fi;
 	}
@@ -247,9 +256,8 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 }
 
 /* Check, that the gateway is already configured.
-   Used only by redirect accept routine.
+ * Used only by redirect accept routine.
  */
-
 int ip_fib_check_default(__be32 gw, struct net_device *dev)
 {
 	struct hlist_head *head;
@@ -264,7 +272,7 @@ int ip_fib_check_default(__be32 gw, struct net_device *dev)
 	hlist_for_each_entry(nh, node, head, nh_hash) {
 		if (nh->nh_dev == dev &&
 		    nh->nh_gw == gw &&
-		    !(nh->nh_flags&RTNH_F_DEAD)) {
+		    !(nh->nh_flags & RTNH_F_DEAD)) {
 			spin_unlock(&fib_info_lock);
 			return 0;
 		}
@@ -362,10 +370,10 @@ int fib_detect_death(struct fib_info *fi, int order,
 	}
 	if (state == NUD_REACHABLE)
 		return 0;
-	if ((state&NUD_VALID) && order != dflt)
+	if ((state & NUD_VALID) && order != dflt)
 		return 0;
-	if ((state&NUD_VALID) ||
-	    (*last_idx<0 && order > dflt)) {
+	if ((state & NUD_VALID) ||
+	    (*last_idx < 0 && order > dflt)) {
 		*last_resort = fi;
 		*last_idx = order;
 	}
@@ -476,69 +484,69 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 
 
 /*
-   Picture
-   -------
-
-   Semantics of nexthop is very messy by historical reasons.
-   We have to take into account, that:
-   a) gateway can be actually local interface address,
-      so that gatewayed route is direct.
-   b) gateway must be on-link address, possibly
-      described not by an ifaddr, but also by a direct route.
-   c) If both gateway and interface are specified, they should not
-      contradict.
-   d) If we use tunnel routes, gateway could be not on-link.
-
-   Attempt to reconcile all of these (alas, self-contradictory) conditions
-   results in pretty ugly and hairy code with obscure logic.
-
-   I chose to generalized it instead, so that the size
-   of code does not increase practically, but it becomes
-   much more general.
-   Every prefix is assigned a "scope" value: "host" is local address,
-   "link" is direct route,
-   [ ... "site" ... "interior" ... ]
-   and "universe" is true gateway route with global meaning.
-
-   Every prefix refers to a set of "nexthop"s (gw, oif),
-   where gw must have narrower scope. This recursion stops
-   when gw has LOCAL scope or if "nexthop" is declared ONLINK,
-   which means that gw is forced to be on link.
-
-   Code is still hairy, but now it is apparently logically
-   consistent and very flexible. F.e. as by-product it allows
-   to co-exists in peace independent exterior and interior
-   routing processes.
-
-   Normally it looks as following.
-
-   {universe prefix}  -> (gw, oif) [scope link]
-			  |
-			  |-> {link prefix} -> (gw, oif) [scope local]
-						|
-						|-> {local prefix} (terminal node)
+ * Picture
+ * -------
+ *
+ * Semantics of nexthop is very messy by historical reasons.
+ * We have to take into account, that:
+ * a) gateway can be actually local interface address,
+ *    so that gatewayed route is direct.
+ * b) gateway must be on-link address, possibly
+ *    described not by an ifaddr, but also by a direct route.
+ * c) If both gateway and interface are specified, they should not
+ *    contradict.
+ * d) If we use tunnel routes, gateway could be not on-link.
+ *
+ * Attempt to reconcile all of these (alas, self-contradictory) conditions
+ * results in pretty ugly and hairy code with obscure logic.
+ *
+ * I chose to generalized it instead, so that the size
+ * of code does not increase practically, but it becomes
+ * much more general.
+ * Every prefix is assigned a "scope" value: "host" is local address,
+ * "link" is direct route,
+ * [ ... "site" ... "interior" ... ]
+ * and "universe" is true gateway route with global meaning.
+ *
+ * Every prefix refers to a set of "nexthop"s (gw, oif),
+ * where gw must have narrower scope. This recursion stops
+ * when gw has LOCAL scope or if "nexthop" is declared ONLINK,
+ * which means that gw is forced to be on link.
+ *
+ * Code is still hairy, but now it is apparently logically
+ * consistent and very flexible. F.e. as by-product it allows
+ * to co-exists in peace independent exterior and interior
+ * routing processes.
+ *
+ * Normally it looks as following.
+ *
+ * {universe prefix}  -> (gw, oif) [scope link]
+ *		  |
+ *		  |-> {link prefix} -> (gw, oif) [scope local]
+ *					|
+ *					|-> {local prefix} (terminal node)
  */
-
 static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			struct fib_nh *nh)
 {
 	int err;
 	struct net *net;
+	struct net_device *dev;
 
 	net = cfg->fc_nlinfo.nl_net;
 	if (nh->nh_gw) {
 		struct fib_result res;
 
-		if (nh->nh_flags&RTNH_F_ONLINK) {
-			struct net_device *dev;
+		if (nh->nh_flags & RTNH_F_ONLINK) {
 
 			if (cfg->fc_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
 			if (inet_addr_type(net, nh->nh_gw) != RTN_UNICAST)
 				return -EINVAL;
-			if ((dev = __dev_get_by_index(net, nh->nh_oif)) == NULL)
+			dev = __dev_get_by_index(net, nh->nh_oif);
+			if (!dev)
 				return -ENODEV;
-			if (!(dev->flags&IFF_UP))
+			if (!(dev->flags & IFF_UP))
 				return -ENETDOWN;
 			nh->nh_dev = dev;
 			dev_hold(dev);
@@ -559,7 +567,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl.fl4_scope < RT_SCOPE_LINK)
 				fl.fl4_scope = RT_SCOPE_LINK;
-			if ((err = fib_lookup(net, &fl, &res)) != 0)
+			err = fib_lookup(net, &fl, &res);
+			if (err)
 				return err;
 		}
 		err = -EINVAL;
@@ -567,11 +576,12 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			goto out;
 		nh->nh_scope = res.scope;
 		nh->nh_oif = FIB_RES_OIF(res);
-		if ((nh->nh_dev = FIB_RES_DEV(res)) == NULL)
+		nh->nh_dev = dev = FIB_RES_DEV(res);
+		if (!dev)
 			goto out;
-		dev_hold(nh->nh_dev);
+		dev_hold(dev);
 		err = -ENETDOWN;
-		if (!(nh->nh_dev->flags & IFF_UP))
+		if (!(dev->flags & IFF_UP))
 			goto out;
 		err = 0;
 out:
@@ -580,13 +590,13 @@ out:
 	} else {
 		struct in_device *in_dev;
 
-		if (nh->nh_flags&(RTNH_F_PERVASIVE|RTNH_F_ONLINK))
+		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
 			return -EINVAL;
 
 		in_dev = inetdev_by_index(net, nh->nh_oif);
 		if (in_dev == NULL)
 			return -ENODEV;
-		if (!(in_dev->dev->flags&IFF_UP)) {
+		if (!(in_dev->dev->flags & IFF_UP)) {
 			in_dev_put(in_dev);
 			return -ENETDOWN;
 		}
@@ -602,7 +612,9 @@ static inline unsigned int fib_laddr_hashfn(__be32 val)
 {
 	unsigned int mask = (fib_hash_size - 1);
 
-	return ((__force u32)val ^ ((__force u32)val >> 7) ^ ((__force u32)val >> 14)) & mask;
+	return ((__force u32)val ^
+		((__force u32)val >> 7) ^
+		((__force u32)val >> 14)) & mask;
 }
 
 static struct hlist_head *fib_hash_alloc(int bytes)
@@ -611,7 +623,8 @@ static struct hlist_head *fib_hash_alloc(int bytes)
 		return kzalloc(bytes, GFP_KERNEL);
 	else
 		return (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL | __GFP_ZERO, get_order(bytes));
+			__get_free_pages(GFP_KERNEL | __GFP_ZERO,
+					 get_order(bytes));
 }
 
 static void fib_hash_free(struct hlist_head *hash, int bytes)
@@ -806,7 +819,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto failure;
 	} else {
 		change_nexthops(fi) {
-			if ((err = fib_check_nh(cfg, fi, nexthop_nh)) != 0)
+			err = fib_check_nh(cfg, fi, nexthop_nh);
+			if (err != 0)
 				goto failure;
 		} endfor_nexthops(fi)
 	}
@@ -819,7 +833,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 link_it:
-	if ((ofi = fib_find_info(fi)) != NULL) {
+	ofi = fib_find_info(fi);
+	if (ofi) {
 		fi->fib_dead = 1;
 		free_fib_info(fi);
 		ofi->fib_treeref++;
@@ -895,7 +910,7 @@ int fib_semantic_match(struct list_head *head, const struct flowi *flp,
 			case RTN_ANYCAST:
 			case RTN_MULTICAST:
 				for_nexthops(fi) {
-					if (nh->nh_flags&RTNH_F_DEAD)
+					if (nh->nh_flags & RTNH_F_DEAD)
 						continue;
 					if (!flp->oif || flp->oif == nh->nh_oif)
 						break;
@@ -906,16 +921,15 @@ int fib_semantic_match(struct list_head *head, const struct flowi *flp,
 					goto out_fill_res;
 				}
 #else
-				if (nhsel < 1) {
+				if (nhsel < 1)
 					goto out_fill_res;
-				}
 #endif
 				endfor_nexthops(fi);
 				continue;
 
 			default:
-				printk(KERN_WARNING "fib_semantic_match bad type %#x\n",
-					fa->fa_type);
+				pr_warning("fib_semantic_match bad type %#x\n",
+					   fa->fa_type);
 				return -EINVAL;
 			}
 		}
@@ -1028,10 +1042,10 @@ nla_put_failure:
 }
 
 /*
-   Update FIB if:
-   - local address disappeared -> we must delete all the entries
-     referring to it.
-   - device went down -> we must shutdown all nexthops going via it.
+ * Update FIB if:
+ * - local address disappeared -> we must delete all the entries
+ *   referring to it.
+ * - device went down -> we must shutdown all nexthops going via it.
  */
 int fib_sync_down_addr(struct net *net, __be32 local)
 {
@@ -1078,7 +1092,7 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 		prev_fi = fi;
 		dead = 0;
 		change_nexthops(fi) {
-			if (nexthop_nh->nh_flags&RTNH_F_DEAD)
+			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
 				dead++;
 			else if (nexthop_nh->nh_dev == dev &&
 				 nexthop_nh->nh_scope != scope) {
@@ -1110,10 +1124,9 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 /*
-   Dead device goes up. We wake up dead nexthops.
-   It takes sense only on multipath routes.
+ * Dead device goes up. We wake up dead nexthops.
+ * It takes sense only on multipath routes.
  */
-
 int fib_sync_up(struct net_device *dev)
 {
 	struct fib_info *prev_fi;
@@ -1123,7 +1136,7 @@ int fib_sync_up(struct net_device *dev)
 	struct fib_nh *nh;
 	int ret;
 
-	if (!(dev->flags&IFF_UP))
+	if (!(dev->flags & IFF_UP))
 		return 0;
 
 	prev_fi = NULL;
@@ -1142,12 +1155,12 @@ int fib_sync_up(struct net_device *dev)
 		prev_fi = fi;
 		alive = 0;
 		change_nexthops(fi) {
-			if (!(nexthop_nh->nh_flags&RTNH_F_DEAD)) {
+			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD)) {
 				alive++;
 				continue;
 			}
 			if (nexthop_nh->nh_dev == NULL ||
-			    !(nexthop_nh->nh_dev->flags&IFF_UP))
+			    !(nexthop_nh->nh_dev->flags & IFF_UP))
 				continue;
 			if (nexthop_nh->nh_dev != dev ||
 			    !__in_dev_get_rtnl(dev))
@@ -1169,10 +1182,9 @@ int fib_sync_up(struct net_device *dev)
 }
 
 /*
-   The algorithm is suboptimal, but it provides really
-   fair weighted route distribution.
+ * The algorithm is suboptimal, but it provides really
+ * fair weighted route distribution.
  */
-
 void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
 {
 	struct fib_info *fi = res->fi;
@@ -1182,7 +1194,7 @@ void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
 	if (fi->fib_power <= 0) {
 		int power = 0;
 		change_nexthops(fi) {
-			if (!(nexthop_nh->nh_flags&RTNH_F_DEAD)) {
+			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD)) {
 				power += nexthop_nh->nh_weight;
 				nexthop_nh->nh_power = nexthop_nh->nh_weight;
 			}
@@ -1198,15 +1210,16 @@ void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
 
 
 	/* w should be random number [0..fi->fib_power-1],
-	   it is pretty bad approximation.
+	 * it is pretty bad approximation.
 	 */
 
 	w = jiffies % fi->fib_power;
 
 	change_nexthops(fi) {
-		if (!(nexthop_nh->nh_flags&RTNH_F_DEAD) &&
+		if (!(nexthop_nh->nh_flags & RTNH_F_DEAD) &&
 		    nexthop_nh->nh_power) {
-			if ((w -= nexthop_nh->nh_power) <= 0) {
+			w -= nexthop_nh->nh_power;
+			if (w <= 0) {
 				nexthop_nh->nh_power--;
 				fi->fib_power--;
 				res->nh_sel = nhsel;


