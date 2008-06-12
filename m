From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] net-next-2.6 updates: key, ipv6 and tcp.
Date: Thu, 12 Jun 2008 10:51:54 +0900 (JST)
Message-ID: <20080612.105154.76614473.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59290 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbYFLBvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 21:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following changes since commit
573bf470e693f73a6ac437b17a64a10902ba54bf
    ipv4 addr: Send netlink notification for address label changes
at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-next-2.6-misc-20080612a

Regards,

--
HEADLINES
---------

    ipv6 mcast: Remove unused macro (MLDV2_QQIC) from mcast.c.
    ipv6 mroute: Use MRT6_VERSION instead of MRT_VERSION in ip6mr.c.
    ipv6 addrconf: Remove IFA_GLOBAL definition from include/net/if_inet6.h.
    ipv6 addrconf: Introduce addrconf_is_prefix_route() helper.
    ipv6 netns: Address labels per namespace
    key: Introduce pfkey_sockaddr_len() for raw sockaddr{} length.
    key: Share common code path to fill sockaddr{}.
    key: Share common code path to extract address from sockaddr{}.
    key: Use xfrm_addr_cmp() where appropriate.
    tcp md5sig: Share MD5 Signature option parser between IPv4 and IPv6.
    tcp md5sig: Remove redundant protocol argument.
    tcp md5sig: Share most of hash calcucaltion bits between IPv4 and IPv6.
    tcp md5sig: Let the caller pass appropriate key for tcp_v{4,6}_do_calc_md5_hash().

DIFFSTAT
--------

 include/net/addrconf.h |    3 
 include/net/if_inet6.h |    1 
 include/net/tcp.h      |   21 +-
 net/ipv4/tcp.c         |   70 +++++
 net/ipv4/tcp_input.c   |   40 +++
 net/ipv4/tcp_ipv4.c    |  164 +++----------
 net/ipv4/tcp_output.c  |    3 
 net/ipv6/addrconf.c    |   22 +-
 net/ipv6/addrlabel.c   |  106 ++++++--
 net/ipv6/ip6mr.c       |    2 
 net/ipv6/mcast.c       |    1 
 net/ipv6/tcp_ipv6.c    |  136 ++--------
 net/key/af_key.c       |  622 +++++++++++++-----------------------------------
 13 files changed, 449 insertions(+), 742 deletions(-)

CHANGESETS
----------

commit 9cba632e24ef18e2905c18997a8f24e8d7a29e71
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:34:00 2008 +0300

    ipv6 mcast: Remove unused macro (MLDV2_QQIC) from mcast.c.
    
    This patch removes  MLDV2_QQIC macro from mcast.c
    as it is unused.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fd632dd..ee30ec4 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -164,7 +164,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 	((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
 	(MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
 
-#define MLDV2_QQIC(value) MLDV2_EXP(0x80, 4, 3, value)
 #define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
 
 #define IPV6_MLD_MAX_MSF	64

---
commit 7d120c55df02a2b87f4aa317f1f04e398398dcdc
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:35:13 2008 +0300

    ipv6 mroute: Use MRT6_VERSION instead of MRT_VERSION in ip6mr.c.
    
    MRT6_VERSION should be used instead of MRT_VERSION in ip6mr.c.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index bf268b3..0b11b37 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1240,7 +1240,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 
 #endif
 	/*
-	 *	Spurious command, or MRT_VERSION which you cannot
+	 *	Spurious command, or MRT6_VERSION which you cannot
 	 *	set.
 	 */
 	default:

---
commit 0399e5f07ad7024f70881d44f19d767d3f25a980
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:36:58 2008 +0300

    ipv6 addrconf: Remove IFA_GLOBAL definition from include/net/if_inet6.h.
    
    This patches removes IFA_GLOBAL definition from linux/include/net/if_inet6.h
    as it is unused.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b2cfc49..db66c79 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -148,7 +148,6 @@ struct ifacaddr6
 #define	IFA_HOST	IPV6_ADDR_LOOPBACK
 #define	IFA_LINK	IPV6_ADDR_LINKLOCAL
 #define	IFA_SITE	IPV6_ADDR_SITELOCAL
-#define	IFA_GLOBAL	0x0000U
 
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;

---
commit 2b5ead46442d80928cce987ae6acf3fe99968ad8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue May 13 01:16:24 2008 +0900

    ipv6 addrconf: Introduce addrconf_is_prefix_route() helper.
    
    This inline function, for readability, returns if the route
    is a "prefix" route regardless if it was installed by RA or by
    hand.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 147588f..9ea4e62 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -231,6 +231,12 @@ static inline int addrconf_qdisc_ok(struct net_device *dev)
 	return (dev->qdisc != &noop_qdisc);
 }
 
+/* Check if a route is valid prefix route */
+static inline int addrconf_is_prefix_route(const struct rt6_info *rt)
+{
+	return ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0);
+}
+
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
 {
 	if (del_timer(&ifp->timer))
@@ -777,7 +783,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
 		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && addrconf_is_prefix_route(rt)) {
 			if (onlink == 0) {
 				ip6_del_rt(rt);
 				rt = NULL;
@@ -1788,7 +1794,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && addrconf_is_prefix_route(rt)) {
 			/* Autoconf prefix route */
 			if (valid_lft == 0) {
 				ip6_del_rt(rt);

---
commit 3de232554a91adc74e80dc15c304be806bd7e1f9
Author: Benjamin Thery <benjamin.thery@bull.net>
Date:   Wed May 28 14:51:24 2008 +0200

    ipv6 netns: Address labels per namespace
    
    This pacth makes IPv6 address labels per network namespace.
    It keeps the global label tables, ip6addrlbl_table, but
    adds a 'net' member to each ip6addrlbl_entry.
    This new member is taken into account when matching labels.
    
    Changelog
    =========
    * v1: Initial version
    * v2:
      * Minize the penalty when network namespaces are not configured:
          *  the 'net' member is added only if CONFIG_NET_NS is
             defined. This saves space when network namespaces are not
             configured.
          * 'net' value is retrieved with the inlined function
             ip6addrlbl_net() that always return &init_net when
             CONFIG_NET_NS is not defined.
      * 'net' member in ip6addrlbl_entry renamed to the less generic
        'lbl_net' name (helps code search).
    
    Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index bbd3d58..06b2814 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -121,7 +121,8 @@ static inline int addrconf_finite_timeout(unsigned long timeout)
  */
 extern int			ipv6_addr_label_init(void);
 extern void			ipv6_addr_label_rtnl_register(void);
-extern u32			ipv6_addr_label(const struct in6_addr *addr,
+extern u32			ipv6_addr_label(struct net *net,
+						const struct in6_addr *addr,
 						int type, int ifindex);
 
 /*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9ea4e62..fa43374 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -964,7 +964,8 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
-static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
+static int ipv6_get_saddr_eval(struct net *net,
+			       struct ipv6_saddr_score *score,
 			       struct ipv6_saddr_dst *dst,
 			       int i)
 {
@@ -1043,7 +1044,8 @@ static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
 		break;
 	case IPV6_SADDR_RULE_LABEL:
 		/* Rule 6: Prefer matching label */
-		ret = ipv6_addr_label(&score->ifa->addr, score->addr_type,
+		ret = ipv6_addr_label(net,
+				      &score->ifa->addr, score->addr_type,
 				      score->ifa->idev->dev->ifindex) == dst->label;
 		break;
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1097,7 +1099,7 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 	dst.addr = daddr;
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
 	dst.scope = __ipv6_addr_src_scope(dst_type);
-	dst.label = ipv6_addr_label(daddr, dst_type, dst.ifindex);
+	dst.label = ipv6_addr_label(net, daddr, dst_type, dst.ifindex);
 	dst.prefs = prefs;
 
 	hiscore->rule = -1;
@@ -1165,8 +1167,8 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 			for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
 				int minihiscore, miniscore;
 
-				minihiscore = ipv6_get_saddr_eval(hiscore, &dst, i);
-				miniscore = ipv6_get_saddr_eval(score, &dst, i);
+				minihiscore = ipv6_get_saddr_eval(net, hiscore, &dst, i);
+				miniscore = ipv6_get_saddr_eval(net, score, &dst, i);
 
 				if (minihiscore > miniscore) {
 					if (i == IPV6_SADDR_RULE_SCOPE &&
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 9bfa884..0890903 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -29,6 +29,9 @@
  */
 struct ip6addrlbl_entry
 {
+#ifdef CONFIG_NET_NS
+	struct net *lbl_net;
+#endif
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -46,6 +49,16 @@ static struct ip6addrlbl_table
 	u32 seq;
 } ip6addrlbl_table;
 
+static inline
+struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
+{
+#ifdef CONFIG_NET_NS
+	return lbl->lbl_net;
+#else
+	return &init_net;
+#endif
+}
+
 /*
  * Default policy table (RFC3484 + extensions)
  *
@@ -65,7 +78,7 @@ static struct ip6addrlbl_table
 
 #define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
 
-static const __initdata struct ip6addrlbl_init_table
+static const __net_initdata struct ip6addrlbl_init_table
 {
 	const struct in6_addr *prefix;
 	int prefixlen;
@@ -108,6 +121,9 @@ static const __initdata struct ip6addrlbl_init_table
 /* Object management */
 static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 {
+#ifdef CONFIG_NET_NS
+	release_net(p->lbl_net);
+#endif
 	kfree(p);
 }
 
@@ -128,10 +144,13 @@ static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 }
 
 /* Find label */
-static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
+static int __ip6addrlbl_match(struct net *net,
+			      struct ip6addrlbl_entry *p,
 			      const struct in6_addr *addr,
 			      int addrtype, int ifindex)
 {
+	if (!net_eq(ip6addrlbl_net(p), net))
+		return 0;
 	if (p->ifindex && p->ifindex != ifindex)
 		return 0;
 	if (p->addrtype && p->addrtype != addrtype)
@@ -141,19 +160,21 @@ static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
 	return 1;
 }
 
-static struct ip6addrlbl_entry *__ipv6_addr_label(const struct in6_addr *addr,
+static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
+						  const struct in6_addr *addr,
 						  int type, int ifindex)
 {
 	struct hlist_node *pos;
 	struct ip6addrlbl_entry *p;
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (__ip6addrlbl_match(p, addr, type, ifindex))
+		if (__ip6addrlbl_match(net, p, addr, type, ifindex))
 			return p;
 	}
 	return NULL;
 }
 
-u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
+u32 ipv6_addr_label(struct net *net,
+		    const struct in6_addr *addr, int type, int ifindex)
 {
 	u32 label;
 	struct ip6addrlbl_entry *p;
@@ -161,7 +182,7 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 	type &= IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, type, ifindex);
+	p = __ipv6_addr_label(net, addr, type, ifindex);
 	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
 	rcu_read_unlock();
 
@@ -174,7 +195,8 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 }
 
 /* allocate one entry */
-static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
+static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
+						 const struct in6_addr *prefix,
 						 int prefixlen, int ifindex,
 						 u32 label)
 {
@@ -216,6 +238,9 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
+#ifdef CONFIG_NET_NS
+	newp->lbl_net = hold_net(net);
+#endif
 	atomic_set(&newp->refcnt, 1);
 	return newp;
 }
@@ -237,6 +262,7 @@ static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 		hlist_for_each_entry_safe(p, pos, n,
 					  &ip6addrlbl_table.head, list) {
 			if (p->prefixlen == newp->prefixlen &&
+			    net_eq(ip6addrlbl_net(p), ip6addrlbl_net(newp)) &&
 			    p->ifindex == newp->ifindex &&
 			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
 				if (!replace) {
@@ -261,7 +287,8 @@ out:
 }
 
 /* add a label */
-static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_add(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex, u32 label, int replace)
 {
 	struct ip6addrlbl_entry *newp;
@@ -274,7 +301,7 @@ static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 			(unsigned int)label,
 			replace);
 
-	newp = ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
+	newp = ip6addrlbl_alloc(net, prefix, prefixlen, ifindex, label);
 	if (IS_ERR(newp))
 		return PTR_ERR(newp);
 	spin_lock(&ip6addrlbl_table.lock);
@@ -286,7 +313,8 @@ static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 }
 
 /* remove a label */
-static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int __ip6addrlbl_del(struct net *net,
+			    const struct in6_addr *prefix, int prefixlen,
 			    int ifindex)
 {
 	struct ip6addrlbl_entry *p = NULL;
@@ -300,6 +328,7 @@ static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 
 	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
 		if (p->prefixlen == prefixlen &&
+		    net_eq(ip6addrlbl_net(p), net) &&
 		    p->ifindex == ifindex &&
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
@@ -311,7 +340,8 @@ static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 	return ret;
 }
 
-static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_del(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex)
 {
 	struct in6_addr prefix_buf;
@@ -324,13 +354,13 @@ static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
 	spin_lock(&ip6addrlbl_table.lock);
-	ret = __ip6addrlbl_del(&prefix_buf, prefixlen, ifindex);
+	ret = __ip6addrlbl_del(net, &prefix_buf, prefixlen, ifindex);
 	spin_unlock(&ip6addrlbl_table.lock);
 	return ret;
 }
 
 /* add default label */
-static __init int ip6addrlbl_init(void)
+static int __net_init ip6addrlbl_net_init(struct net *net)
 {
 	int err = 0;
 	int i;
@@ -338,7 +368,8 @@ static __init int ip6addrlbl_init(void)
 	ADDRLABEL(KERN_DEBUG "%s()\n", __func__);
 
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
-		int ret = ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
+		int ret = ip6addrlbl_add(net,
+					 ip6addrlbl_init_table[i].prefix,
 					 ip6addrlbl_init_table[i].prefixlen,
 					 0,
 					 ip6addrlbl_init_table[i].label, 0);
@@ -349,11 +380,32 @@ static __init int ip6addrlbl_init(void)
 	return err;
 }
 
+static void __net_exit ip6addrlbl_net_exit(struct net *net)
+{
+	struct ip6addrlbl_entry *p = NULL;
+	struct hlist_node *pos, *n;
+
+	/* Remove all labels belonging to the exiting net */
+	spin_lock(&ip6addrlbl_table.lock);
+	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
+		if (net_eq(ip6addrlbl_net(p), net)) {
+			hlist_del_rcu(&p->list);
+			ip6addrlbl_put(p);
+		}
+	}
+	spin_unlock(&ip6addrlbl_table.lock);
+}
+
+static struct pernet_operations ipv6_addr_label_ops = {
+	.init = ip6addrlbl_net_init,
+	.exit = ip6addrlbl_net_exit,
+};
+
 int __init ipv6_addr_label_init(void)
 {
 	spin_lock_init(&ip6addrlbl_table.lock);
 
-	return ip6addrlbl_init();
+	return register_pernet_subsys(&ipv6_addr_label_ops);
 }
 
 static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
@@ -371,9 +423,6 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 label;
 	int err = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -385,7 +434,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -403,12 +452,12 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	switch(nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
-		err = ip6addrlbl_add(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_add(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index, label,
 				     nlh->nlmsg_flags & NLM_F_REPLACE);
 		break;
 	case RTM_DELADDRLABEL:
-		err = ip6addrlbl_del(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_del(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index);
 		break;
 	default:
@@ -458,12 +507,10 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx = 0, s_idx = cb->args[0];
 	int err;
 
-	if (net != &init_net)
-		return 0;
-
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (idx >= s_idx) {
+		if (idx >= s_idx &&
+		    net_eq(ip6addrlbl_net(p), net)) {
 			if ((err = ip6addrlbl_fill(skb, p,
 						   ip6addrlbl_table.seq,
 						   NETLINK_CB(cb->skb).pid,
@@ -499,9 +546,6 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 	struct ip6addrlbl_entry *p;
 	struct sk_buff *skb;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -513,7 +557,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -524,7 +568,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		return -EINVAL;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, ipv6_addr_type(addr), ifal->ifal_index);
+	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
 	if (p && ip6addrlbl_hold(p))
 		p = NULL;
 	lseq = ip6addrlbl_table.seq;
@@ -552,7 +596,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		goto out;
 	}
 
-	err = rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
 out:
 	return err;
 }

---
commit 9e8b4ed8bb7d2f0f91dccf0abf648771d76e7a01
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 00:50:45 2008 +0900

    key: Introduce pfkey_sockaddr_len() for raw sockaddr{} length.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9bba7ac..02c8aba 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -579,6 +579,19 @@ static uint8_t pfkey_proto_from_xfrm(uint8_t proto)
 	return (proto ? proto : IPSEC_PROTO_ANY);
 }
 
+static inline int pfkey_sockaddr_len(sa_family_t family)
+{
+	switch (family) {
+	case AF_INET:
+		return sizeof(struct sockaddr_in);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return sizeof(struct sockaddr_in6);
+#endif
+	}
+	return 0;
+}
+
 static int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr,
 				     xfrm_address_t *xaddr)
 {
@@ -642,20 +655,11 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **
 }
 
 #define PFKEY_ALIGN8(a) (1 + (((a) - 1) | (8 - 1)))
+
 static int
 pfkey_sockaddr_size(sa_family_t family)
 {
-	switch (family) {
-	case AF_INET:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in));
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in6));
-#endif
-	default:
-		return 0;
-	}
-	/* NOTREACHED */
+	return PFKEY_ALIGN8(pfkey_sockaddr_len(family));
 }
 
 static inline int pfkey_mode_from_xfrm(int mode)
@@ -1952,9 +1956,7 @@ static int pfkey_xfrm_policy2msg_size(struct xfrm_policy *xp)
 
 	for (i=0; i<xp->xfrm_nr; i++) {
 		t = xp->xfrm_vec + i;
-		socklen += (t->encap_family == AF_INET ?
-			    sizeof(struct sockaddr_in) :
-			    sizeof(struct sockaddr_in6));
+		socklen += pfkey_sockaddr_len(t->encap_family);
 	}
 
 	return sizeof(struct sadb_msg) +
@@ -1996,9 +1998,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	int i;
 	int size;
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
-	int socklen = (xp->family == AF_INET ?
-		       sizeof(struct sockaddr_in) :
-		       sizeof(struct sockaddr_in6));
+	int socklen = pfkey_sockaddr_len(xp->family);
 
 	size = pfkey_xfrm_policy2msg_size(xp);
 
@@ -2122,9 +2122,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
 		if (t->mode == XFRM_MODE_TUNNEL)
-			req_size += ((t->encap_family == AF_INET ?
-				     sizeof(struct sockaddr_in) :
-				     sizeof(struct sockaddr_in6)) * 2);
+			req_size += pfkey_sockaddr_len(t->encap_family) * 2;
 		else
 			size -= 2*socklen;
 		rq = (void*)skb_put(skb, req_size);
@@ -2459,17 +2457,7 @@ out:
 #ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_sockaddr_pair_size(sa_family_t family)
 {
-	switch (family) {
-	case AF_INET:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in) * 2);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in6) * 2);
-#endif
-	default:
-		return 0;
-	}
-	/* NOTREACHED */
+	return PFKEY_ALIGN8(pfkey_sockaddr_len(family) * 2);
 }
 
 static int parse_sockaddr_pair(struct sadb_x_ipsecrequest *rq,

---
commit e5b56652c11baf144eb713c33ff70a1b5d6d09bc
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 01:46:41 2008 +0900

    key: Share common code path to fill sockaddr{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 02c8aba..2b05cb6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -691,6 +691,36 @@ static inline int pfkey_mode_to_xfrm(int mode)
 	}
 }
 
+static unsigned int pfkey_sockaddr_fill(xfrm_address_t *xaddr, __be16 port,
+				       struct sockaddr *sa,
+				       unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+	    {
+		struct sockaddr_in *sin = (struct sockaddr_in *)sa;
+		sin->sin_family = AF_INET;
+		sin->sin_port = port;
+		sin->sin_addr.s_addr = xaddr->a4;
+		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+		return 32;
+	    }
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+	    {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sa;
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = port;
+		sin6->sin6_flowinfo = 0;
+		ipv6_addr_copy(&sin6->sin6_addr, (struct in6_addr *)xaddr->a6);
+		sin6->sin6_scope_id = 0;
+		return 128;
+	    }
+#endif
+	}
+	return 0;
+}
+
 static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 					      int add_keys, int hsc)
 {
@@ -701,13 +731,9 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	struct sadb_address *addr;
 	struct sadb_key *key;
 	struct sadb_x_sa2 *sa2;
-	struct sockaddr_in *sin;
 	struct sadb_x_sec_ctx *sec_ctx;
 	struct xfrm_sec_ctx *xfrm_ctx;
 	int ctx_size = 0;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int size;
 	int auth_key_size = 0;
 	int encrypt_key_size = 0;
@@ -865,29 +891,12 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	   protocol's number." - RFC2367 */
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
 
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, x->props.saddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* dst address */
@@ -898,70 +907,32 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 			sizeof(uint64_t);
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
-	addr->sadb_address_prefixlen = 32; /* XXX */
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->id.daddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
 
-		if (x->sel.saddr.a4 != x->props.saddr.a4) {
-			addr = (struct sadb_address*) skb_put(skb,
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len =
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
-			sin = (struct sockaddr_in *) (addr + 1);
-			sin->sin_family = AF_INET;
-			sin->sin_addr.s_addr = x->sel.saddr.a4;
-			sin->sin_port = x->sel.sport;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->id.daddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
+		BUG();
 
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, x->id.daddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
+	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr,
+			  x->props.family)) {
+		addr = (struct sadb_address*) skb_put(skb,
+			sizeof(struct sadb_address)+sockaddr_size);
+		addr->sadb_address_len =
+			(sizeof(struct sadb_address)+sockaddr_size)/
+			sizeof(uint64_t);
+		addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
+		addr->sadb_address_proto =
+			pfkey_proto_from_xfrm(x->sel.proto);
+		addr->sadb_address_prefixlen = x->sel.prefixlen_s;
+		addr->sadb_address_reserved = 0;
 
-		if (memcmp (x->sel.saddr.a6, x->props.saddr.a6,
-			    sizeof(struct in6_addr))) {
-			addr = (struct sadb_address *) skb_put(skb,
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len =
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
-			sin6 = (struct sockaddr_in6 *) (addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = x->sel.sport;
-			sin6->sin6_flowinfo = 0;
-			memcpy(&sin6->sin6_addr, x->sel.saddr.a6,
-			       sizeof(struct in6_addr));
-			sin6->sin6_scope_id = 0;
-		}
+		pfkey_sockaddr_fill(&x->sel.saddr, x->sel.sport,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
 	}
-#endif
-	else
-		BUG();
 
 	/* auth key */
 	if (add_keys && auth_key_size) {
@@ -1989,12 +1960,8 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	struct sadb_address *addr;
 	struct sadb_lifetime *lifetime;
 	struct sadb_x_policy *pol;
-	struct sockaddr_in   *sin;
 	struct sadb_x_sec_ctx *sec_ctx;
 	struct xfrm_sec_ctx *xfrm_ctx;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6  *sin6;
-#endif
 	int i;
 	int size;
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
@@ -2016,26 +1983,10 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	addr->sadb_address_proto = pfkey_proto_from_xfrm(xp->selector.proto);
 	addr->sadb_address_prefixlen = xp->selector.prefixlen_s;
 	addr->sadb_address_reserved = 0;
-	/* src address */
-	if (xp->family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = xp->selector.saddr.a4;
-		sin->sin_port = xp->selector.sport;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (xp->family == AF_INET6) {
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = xp->selector.sport;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, xp->selector.saddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	if (!pfkey_sockaddr_fill(&xp->selector.saddr,
+				 xp->selector.sport,
+				 (struct sockaddr *) (addr + 1),
+				 xp->family))
 		BUG();
 
 	/* dst address */
@@ -2048,26 +1999,10 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	addr->sadb_address_proto = pfkey_proto_from_xfrm(xp->selector.proto);
 	addr->sadb_address_prefixlen = xp->selector.prefixlen_d;
 	addr->sadb_address_reserved = 0;
-	if (xp->family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = xp->selector.daddr.a4;
-		sin->sin_port = xp->selector.dport;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (xp->family == AF_INET6) {
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = xp->selector.dport;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, xp->selector.daddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
-		BUG();
+
+	pfkey_sockaddr_fill(&xp->selector.daddr, xp->selector.dport,
+			    (struct sockaddr *) (addr + 1),
+			    xp->family);
 
 	/* hard time */
 	lifetime = (struct sadb_lifetime *)  skb_put(skb,
@@ -2121,10 +2056,13 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 		int mode;
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
-		if (t->mode == XFRM_MODE_TUNNEL)
-			req_size += pfkey_sockaddr_len(t->encap_family) * 2;
-		else
+		if (t->mode == XFRM_MODE_TUNNEL) {
+			socklen = pfkey_sockaddr_len(t->encap_family);
+			req_size += socklen * 2;
+		} else {
 			size -= 2*socklen;
+			socklen = 0;
+		}
 		rq = (void*)skb_put(skb, req_size);
 		pol->sadb_x_policy_len += req_size/8;
 		memset(rq, 0, sizeof(*rq));
@@ -2139,42 +2077,15 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 		if (t->optional)
 			rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_USE;
 		rq->sadb_x_ipsecrequest_reqid = t->reqid;
+
 		if (t->mode == XFRM_MODE_TUNNEL) {
-			switch (t->encap_family) {
-			case AF_INET:
-				sin = (void*)(rq+1);
-				sin->sin_family = AF_INET;
-				sin->sin_addr.s_addr = t->saddr.a4;
-				sin->sin_port = 0;
-				memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-				sin++;
-				sin->sin_family = AF_INET;
-				sin->sin_addr.s_addr = t->id.daddr.a4;
-				sin->sin_port = 0;
-				memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-				break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-			case AF_INET6:
-				sin6 = (void*)(rq+1);
-				sin6->sin6_family = AF_INET6;
-				sin6->sin6_port = 0;
-				sin6->sin6_flowinfo = 0;
-				memcpy(&sin6->sin6_addr, t->saddr.a6,
-				       sizeof(struct in6_addr));
-				sin6->sin6_scope_id = 0;
-
-				sin6++;
-				sin6->sin6_family = AF_INET6;
-				sin6->sin6_port = 0;
-				sin6->sin6_flowinfo = 0;
-				memcpy(&sin6->sin6_addr, t->id.daddr.a6,
-				       sizeof(struct in6_addr));
-				sin6->sin6_scope_id = 0;
-				break;
-#endif
-			default:
-				break;
-			}
+			u8 *sa = (void *)(rq + 1);
+			pfkey_sockaddr_fill(&t->saddr, 0,
+					    (struct sockaddr *)sa,
+					    t->encap_family);
+			pfkey_sockaddr_fill(&t->id.daddr, 0,
+					    (struct sockaddr *) (sa + socklen),
+					    t->encap_family);
 		}
 	}
 
@@ -3079,10 +2990,6 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	struct sadb_msg *hdr;
 	struct sadb_address *addr;
 	struct sadb_x_policy *pol;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int sockaddr_size;
 	int size;
 	struct sadb_x_sec_ctx *sec_ctx;
@@ -3131,29 +3038,11 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->props.saddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* dst address */
@@ -3165,29 +3054,11 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->id.daddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->id.daddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->id.daddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
@@ -3313,10 +3184,6 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	struct sadb_sa *sa;
 	struct sadb_address *addr;
 	struct sadb_x_nat_t_port *n_port;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int sockaddr_size;
 	int size;
 	__u8 satype = (x->id.proto == IPPROTO_ESP ? SADB_SATYPE_ESP : 0);
@@ -3380,29 +3247,11 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->props.saddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* NAT_T_SPORT (old port) */
@@ -3421,28 +3270,11 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = ipaddr->a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, &ipaddr->a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(ipaddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* NAT_T_DPORT (new port) */
@@ -3460,10 +3292,6 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 			    struct xfrm_selector *sel)
 {
 	struct sadb_address *addr;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
 	addr->sadb_address_len = (sizeof(struct sadb_address) + sasize)/8;
 	addr->sadb_address_exttype = type;
@@ -3472,50 +3300,16 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 
 	switch (type) {
 	case SADB_EXT_ADDRESS_SRC:
-		if (sel->family == AF_INET) {
-			addr->sadb_address_prefixlen = sel->prefixlen_s;
-			sin = (struct sockaddr_in *)(addr + 1);
-			sin->sin_family = AF_INET;
-			memcpy(&sin->sin_addr.s_addr, &sel->saddr,
-			       sizeof(sin->sin_addr.s_addr));
-			sin->sin_port = 0;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (sel->family == AF_INET6) {
-			addr->sadb_address_prefixlen = sel->prefixlen_s;
-			sin6 = (struct sockaddr_in6 *)(addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = 0;
-			sin6->sin6_flowinfo = 0;
-			sin6->sin6_scope_id = 0;
-			memcpy(&sin6->sin6_addr.s6_addr, &sel->saddr,
-			       sizeof(sin6->sin6_addr.s6_addr));
-		}
-#endif
+		addr->sadb_address_prefixlen = sel->prefixlen_s;
+		pfkey_sockaddr_fill(&sel->saddr, 0,
+				    (struct sockaddr *)(addr + 1),
+				    sel->family);
 		break;
 	case SADB_EXT_ADDRESS_DST:
-		if (sel->family == AF_INET) {
-			addr->sadb_address_prefixlen = sel->prefixlen_d;
-			sin = (struct sockaddr_in *)(addr + 1);
-			sin->sin_family = AF_INET;
-			memcpy(&sin->sin_addr.s_addr, &sel->daddr,
-			       sizeof(sin->sin_addr.s_addr));
-			sin->sin_port = 0;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (sel->family == AF_INET6) {
-			addr->sadb_address_prefixlen = sel->prefixlen_d;
-			sin6 = (struct sockaddr_in6 *)(addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = 0;
-			sin6->sin6_flowinfo = 0;
-			sin6->sin6_scope_id = 0;
-			memcpy(&sin6->sin6_addr.s6_addr, &sel->daddr,
-			       sizeof(sin6->sin6_addr.s6_addr));
-		}
-#endif
+		addr->sadb_address_prefixlen = sel->prefixlen_d;
+		pfkey_sockaddr_fill(&sel->daddr, 0,
+				    (struct sockaddr *)(addr + 1),
+				    sel->family);
 		break;
 	default:
 		return -EINVAL;
@@ -3530,10 +3324,8 @@ static int set_ipsecrequest(struct sk_buff *skb,
 			    xfrm_address_t *src, xfrm_address_t *dst)
 {
 	struct sadb_x_ipsecrequest *rq;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
+	u8 *sa;
+	int socklen = pfkey_sockaddr_len(family);
 	int size_req;
 
 	size_req = sizeof(struct sadb_x_ipsecrequest) +
@@ -3547,38 +3339,10 @@ static int set_ipsecrequest(struct sk_buff *skb,
 	rq->sadb_x_ipsecrequest_level = level;
 	rq->sadb_x_ipsecrequest_reqid = reqid;
 
-	switch (family) {
-	case AF_INET:
-		sin = (struct sockaddr_in *)(rq + 1);
-		sin->sin_family = AF_INET;
-		memcpy(&sin->sin_addr.s_addr, src,
-		       sizeof(sin->sin_addr.s_addr));
-		sin++;
-		sin->sin_family = AF_INET;
-		memcpy(&sin->sin_addr.s_addr, dst,
-		       sizeof(sin->sin_addr.s_addr));
-		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		sin6 = (struct sockaddr_in6 *)(rq + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
-		memcpy(&sin6->sin6_addr.s6_addr, src,
-		       sizeof(sin6->sin6_addr.s6_addr));
-		sin6++;
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
-		memcpy(&sin6->sin6_addr.s6_addr, dst,
-		       sizeof(sin6->sin6_addr.s6_addr));
-		break;
-#endif
-	default:
+	sa = (u8 *) (rq + 1);
+	if (!pfkey_sockaddr_fill(src, 0, (struct sockaddr *)sa, family) ||
+	    !pfkey_sockaddr_fill(dst, 0, (struct sockaddr *)(sa + socklen), family))
 		return -EINVAL;
-	}
 
 	return 0;
 }

---
commit 5f95ac9111f75aa240dc3bcabffc0f047f13cb64
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 02:46:24 2008 +0900

    key: Share common code path to extract address from sockaddr{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 2b05cb6..771bd61 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -592,25 +592,30 @@ static inline int pfkey_sockaddr_len(sa_family_t family)
 	return 0;
 }
 
-static int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr,
-				     xfrm_address_t *xaddr)
+static
+int pfkey_sockaddr_extract(const struct sockaddr *sa, xfrm_address_t *xaddr)
 {
-	switch (((struct sockaddr*)(addr + 1))->sa_family) {
+	switch (sa->sa_family) {
 	case AF_INET:
 		xaddr->a4 =
-			((struct sockaddr_in *)(addr + 1))->sin_addr.s_addr;
+			((struct sockaddr_in *)sa)->sin_addr.s_addr;
 		return AF_INET;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		memcpy(xaddr->a6,
-		       &((struct sockaddr_in6 *)(addr + 1))->sin6_addr,
+		       &((struct sockaddr_in6 *)sa)->sin6_addr,
 		       sizeof(struct in6_addr));
 		return AF_INET6;
 #endif
-	default:
-		return 0;
 	}
-	/* NOTREACHED */
+	return 0;
+}
+
+static
+int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr, xfrm_address_t *xaddr)
+{
+	return pfkey_sockaddr_extract((struct sockaddr *)(addr + 1),
+				      xaddr);
 }
 
 static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **ext_hdrs)
@@ -1828,10 +1833,6 @@ static int
 parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 {
 	struct xfrm_tmpl *t = xp->xfrm_vec + xp->xfrm_nr;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int mode;
 
 	if (xp->xfrm_nr >= XFRM_MAX_DEPTH)
@@ -1856,31 +1857,19 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
-		struct sockaddr *sa;
-		sa = (struct sockaddr *)(rq+1);
-		switch(sa->sa_family) {
-		case AF_INET:
-			sin = (struct sockaddr_in*)sa;
-			t->saddr.a4 = sin->sin_addr.s_addr;
-			sin++;
-			if (sin->sin_family != AF_INET)
-				return -EINVAL;
-			t->id.daddr.a4 = sin->sin_addr.s_addr;
-			break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		case AF_INET6:
-			sin6 = (struct sockaddr_in6*)sa;
-			memcpy(t->saddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
-			sin6++;
-			if (sin6->sin6_family != AF_INET6)
-				return -EINVAL;
-			memcpy(t->id.daddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
-			break;
-#endif
-		default:
+		u8 *sa = (u8 *) (rq + 1);
+		int family, socklen;
+
+		family = pfkey_sockaddr_extract((struct sockaddr *)sa,
+						&t->saddr);
+		if (!family)
 			return -EINVAL;
-		}
-		t->encap_family = sa->sa_family;
+
+		socklen = pfkey_sockaddr_len(family);
+		if (pfkey_sockaddr_extract((struct sockaddr *)(sa + socklen),
+					   &t->id.daddr) != family)
+			return -EINVAL;
+		t->encap_family = family;
 	} else
 		t->encap_family = xp->family;
 
@@ -2375,44 +2364,24 @@ static int parse_sockaddr_pair(struct sadb_x_ipsecrequest *rq,
 			       xfrm_address_t *saddr, xfrm_address_t *daddr,
 			       u16 *family)
 {
-	struct sockaddr *sa = (struct sockaddr *)(rq + 1);
+	u8 *sa = (u8 *) (rq + 1);
+	int af, socklen;
+
 	if (rq->sadb_x_ipsecrequest_len <
-	    pfkey_sockaddr_pair_size(sa->sa_family))
+	    pfkey_sockaddr_pair_size(((struct sockaddr *)sa)->sa_family))
 		return -EINVAL;
 
-	switch (sa->sa_family) {
-	case AF_INET:
-		{
-			struct sockaddr_in *sin;
-			sin = (struct sockaddr_in *)sa;
-			if ((sin+1)->sin_family != AF_INET)
-				return -EINVAL;
-			memcpy(&saddr->a4, &sin->sin_addr, sizeof(saddr->a4));
-			sin++;
-			memcpy(&daddr->a4, &sin->sin_addr, sizeof(daddr->a4));
-			*family = AF_INET;
-			break;
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		{
-			struct sockaddr_in6 *sin6;
-			sin6 = (struct sockaddr_in6 *)sa;
-			if ((sin6+1)->sin6_family != AF_INET6)
-				return -EINVAL;
-			memcpy(&saddr->a6, &sin6->sin6_addr,
-			       sizeof(saddr->a6));
-			sin6++;
-			memcpy(&daddr->a6, &sin6->sin6_addr,
-			       sizeof(daddr->a6));
-			*family = AF_INET6;
-			break;
-		}
-#endif
-	default:
+	af = pfkey_sockaddr_extract((struct sockaddr *) sa,
+				    saddr);
+	if (!af)
+		return -EINVAL;
+
+	socklen = pfkey_sockaddr_len(af);
+	if (pfkey_sockaddr_extract((struct sockaddr *) (sa + socklen),
+				   daddr) != af)
 		return -EINVAL;
-	}
 
+	*family = af;
 	return 0;
 }
 

---
commit 81b302a321a0d99ff172b8cb2a8de17bff2f9499
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 03:17:38 2008 +0900

    key: Use xfrm_addr_cmp() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 771bd61..841af9f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -767,14 +767,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	}
 
 	/* identity & sensitivity */
-
-	if ((x->props.family == AF_INET &&
-	     x->sel.saddr.a4 != x->props.saddr.a4)
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	    || (x->props.family == AF_INET6 &&
-		memcmp (x->sel.saddr.a6, x->props.saddr.a6, sizeof (struct in6_addr)))
-#endif
-		)
+	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr, x->props.family))
 		size += sizeof(struct sadb_address) + sockaddr_size;
 
 	if (add_keys) {

---
commit 7d5d5525bd88313e6fd90c0659665aee5114bc2d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 12:29:53 2008 +0900

    tcp md5sig: Share MD5 Signature option parser between IPv4 and IPv6.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..b1c4b78 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -399,6 +399,8 @@ extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
 						  int estab);
 
+extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
+
 /*
  *	TCP v4 functions exported for the inet6 API
  */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eba873e..f331e67 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3450,6 +3450,43 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 	return 1;
 }
 
+#ifdef CONFIG_TCP_MD5SIG
+/*
+ * Parse MD5 Signature option
+ */
+u8 *tcp_parse_md5sig_option(struct tcphdr *th)
+{
+	int length = (th->doff << 2) - sizeof (*th);
+	u8 *ptr = (u8*)(th + 1);
+
+	/* If the TCP option is too short, we can short cut */
+	if (length < TCPOLEN_MD5SIG)
+		return NULL;
+
+	while (length > 0) {
+		int opcode = *ptr++;
+		int opsize;
+
+		switch(opcode) {
+		case TCPOPT_EOL:
+			return NULL;
+		case TCPOPT_NOP:
+			length--;
+			continue;
+		default:
+			opsize = *ptr++;
+			if (opsize < 2 || opsize > length)
+				return NULL;
+			if (opcode == TCPOPT_MD5SIG)
+				return ptr;
+		}
+		ptr += opsize - 2;
+		length -= opsize;
+	}
+	return NULL;
+}
+#endif
+
 static inline void tcp_store_ts_recent(struct tcp_sock *tp)
 {
 	tp->rx_opt.ts_recent = tp->rx_opt.rcv_tsval;
@@ -5467,6 +5504,9 @@ EXPORT_SYMBOL(sysctl_tcp_ecn);
 EXPORT_SYMBOL(sysctl_tcp_reordering);
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 EXPORT_SYMBOL(tcp_parse_options);
+#ifdef CONFIG_TCP_MD5SIG
+EXPORT_SYMBOL(tcp_parse_md5sig_option);
+#endif
 EXPORT_SYMBOL(tcp_rcv_established);
 EXPORT_SYMBOL(tcp_rcv_state_process);
 EXPORT_SYMBOL(tcp_initialize_rcv_mss);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..56f5509 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1134,52 +1134,12 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	struct tcp_md5sig_key *hash_expected;
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff << 2) - sizeof(struct tcphdr);
 	int genhash;
-	unsigned char *ptr;
 	unsigned char newhash[16];
 
 	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
+	hash_location = tcp_parse_md5sig_option(th);
 
-	/*
-	 * If the TCP option length is less than the TCP_MD5SIG
-	 * option length, then we can shortcut
-	 */
-	if (length < TCPOLEN_MD5SIG) {
-		if (hash_expected)
-			return 1;
-		else
-			return 0;
-	}
-
-	/* Okay, we can't shortcut - we have to grub through the options */
-	ptr = (unsigned char *)(th + 1);
-	while (length > 0) {
-		int opcode = *ptr++;
-		int opsize;
-
-		switch (opcode) {
-		case TCPOPT_EOL:
-			goto done_opts;
-		case TCPOPT_NOP:
-			length--;
-			continue;
-		default:
-			opsize = *ptr++;
-			if (opsize < 2)
-				goto done_opts;
-			if (opsize > length)
-				goto done_opts;
-
-			if (opcode == TCPOPT_MD5SIG) {
-				hash_location = ptr;
-				goto done_opts;
-			}
-		}
-		ptr += opsize-2;
-		length -= opsize;
-	}
-done_opts:
 	/* We've parsed the options - do we have a hash? */
 	if (!hash_expected && !hash_location)
 		return 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..dd4ddb3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -844,43 +844,12 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	struct tcp_md5sig_key *hash_expected;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff << 2) - sizeof (*th);
 	int genhash;
-	u8 *ptr;
 	u8 newhash[16];
 
 	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
+	hash_location = tcp_parse_md5sig_option(th);
 
-	/* If the TCP option is too short, we can short cut */
-	if (length < TCPOLEN_MD5SIG)
-		return hash_expected ? 1 : 0;
-
-	/* parse options */
-	ptr = (u8*)(th + 1);
-	while (length > 0) {
-		int opcode = *ptr++;
-		int opsize;
-
-		switch(opcode) {
-		case TCPOPT_EOL:
-			goto done_opts;
-		case TCPOPT_NOP:
-			length--;
-			continue;
-		default:
-			opsize = *ptr++;
-			if (opsize < 2 || opsize > length)
-				goto done_opts;
-			if (opcode == TCPOPT_MD5SIG) {
-				hash_location = ptr;
-				goto done_opts;
-			}
-		}
-		ptr += opsize - 2;
-		length -= opsize;
-	}
-
-done_opts:
 	/* do we have a hash as expected? */
 	if (!hash_expected) {
 		if (!hash_location)

---
commit 076fb7223357769c39f3ddf900bba6752369c76a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 12:48:12 2008 +0900

    tcp md5sig: Remove redundant protocol argument.
    
    Protocol is always TCP, so remove useless protocol argument.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b1c4b78..ae2549c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1123,7 +1123,6 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
 						     struct tcphdr *th,
-						     int protocol,
 						     unsigned int tcplen);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
@@ -1373,7 +1372,6 @@ struct tcp_sock_af_ops {
 						  struct dst_entry *dst,
 						  struct request_sock *req,
 						  struct tcphdr *th,
-						  int protocol,
 						  unsigned int len);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 56f5509..f25445d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -95,8 +95,7 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen);
+				   struct tcphdr *th, unsigned int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -586,8 +585,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -680,8 +678,7 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -1006,7 +1003,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
+				   struct tcphdr *th,
 				   unsigned int tcplen)
 {
 	struct scatterlist sg[4];
@@ -1039,7 +1036,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->saddr = saddr;
 	bp->daddr = daddr;
 	bp->pad = 0;
-	bp->protocol = protocol;
+	bp->protocol = IPPROTO_TCP;
 	bp->len = htons(tcplen);
 
 	sg_init_table(sg, 4);
@@ -1099,7 +1096,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct sock *sk,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
+			 struct tcphdr *th,
 			 unsigned int tcplen)
 {
 	__be32 saddr, daddr;
@@ -1115,7 +1112,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	}
 	return tcp_v4_do_calc_md5_hash(md5_hash, key,
 				       saddr, daddr,
-				       th, protocol, tcplen);
+				       th, tcplen);
 }
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
@@ -1166,8 +1163,7 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	genhash = tcp_v4_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  iph->saddr, iph->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  th, skb->len);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ad993ec..f3ffd67 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -607,7 +607,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 					       md5,
 					       sk, NULL, NULL,
 					       tcp_hdr(skb),
-					       sk->sk_protocol,
 					       skb->len);
 	}
 #endif
@@ -2266,7 +2265,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
+					       tcp_hdr(skb),
 					       skb->len);
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index dd4ddb3..334d21c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -736,8 +736,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+				   struct tcphdr *th, unsigned int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;
@@ -761,7 +760,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
 	bp->len = htonl(tcplen);
-	bp->protocol = htonl(protocol);
+	bp->protocol = htonl(IPPROTO_TCP);
 
 	sg_init_table(sg, 4);
 
@@ -821,8 +820,7 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				struct sock *sk,
 				struct dst_entry *dst,
 				struct request_sock *req,
-				struct tcphdr *th, int protocol,
-				unsigned int tcplen)
+				struct tcphdr *th, unsigned int tcplen)
 {
 	struct in6_addr *saddr, *daddr;
 
@@ -835,7 +833,7 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	}
 	return tcp_v6_do_calc_md5_hash(md5_hash, key,
 				       saddr, daddr,
-				       th, protocol, tcplen);
+				       th, tcplen);
 }
 
 static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
@@ -879,8 +877,7 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	genhash = tcp_v6_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  &ip6h->saddr, &ip6h->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  th, skb->len);
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for "
@@ -1020,7 +1017,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		tcp_v6_do_calc_md5_hash((__u8 *)&opt[1], key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					t1, tot_len);
 	}
 #endif
 
@@ -1126,7 +1123,7 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 		tcp_v6_do_calc_md5_hash((__u8 *)topt, key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					t1, tot_len);
 	}
 #endif
 

---
commit 8d26d76dd4a4c87ef037a44a42a0608ffc730199
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 13:19:16 2008 +0900

    tcp md5sig: Share most of hash calcucaltion bits between IPv4 and IPv6.
    
    We can share most part of the hash calculation code because
    the only difference between IPv4 and IPv6 is their pseudo headers.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ae2549c..eac26b7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1117,6 +1117,13 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
+extern int			tcp_calc_md5_hash(char *md5_hash,
+						  struct tcp_md5sig_key *key,
+						  int bplen,
+						  struct tcphdr *th,
+						  unsigned int tcplen,
+						  struct tcp_md5sig_pool *hp);
+
 extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct tcp_md5sig_key *key,
 						     struct sock *sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab66683..6efbae0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2459,6 +2459,76 @@ static unsigned long tcp_md5sig_users;
 static struct tcp_md5sig_pool **tcp_md5sig_pool;
 static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
 
+int tcp_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+		      int bplen,
+		      struct tcphdr *th, unsigned int tcplen,
+		      struct tcp_md5sig_pool *hp)
+{
+	struct scatterlist sg[4];
+	__u16 data_len;
+	int block = 0;
+	__sum16 cksum;
+	struct hash_desc *desc = &hp->md5_desc;
+	int err;
+	unsigned int nbytes = 0;
+
+	sg_init_table(sg, 4);
+
+	/* 1. The TCP pseudo-header */
+	sg_set_buf(&sg[block++], &hp->md5_blk, bplen);
+	nbytes += bplen;
+
+	/* 2. The TCP header, excluding options, and assuming a
+	 * checksum of zero
+	 */
+	cksum = th->check;
+	th->check = 0;
+	sg_set_buf(&sg[block++], th, sizeof(*th));
+	nbytes += sizeof(*th);
+
+	/* 3. The TCP segment data (if any) */
+	data_len = tcplen - (th->doff << 2);
+	if (data_len > 0) {
+		u8 *data = (u8 *)th + (th->doff << 2);
+		sg_set_buf(&sg[block++], data, data_len);
+		nbytes += data_len;
+	}
+
+	/* 4. an independently-specified key or password, known to both
+	 * TCPs and presumably connection-specific
+	 */
+	sg_set_buf(&sg[block++], key->key, key->keylen);
+	nbytes += key->keylen;
+
+	sg_mark_end(&sg[block - 1]);
+
+	/* Now store the hash into the packet */
+	err = crypto_hash_init(desc);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
+		return -1;
+	}
+	err = crypto_hash_update(desc, sg, nbytes);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
+		return -1;
+	}
+	err = crypto_hash_final(desc, md5_hash);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
+		return -1;
+	}
+
+	/* Reset header */
+	th->check = cksum;
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_calc_md5_hash);
+
 static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
 {
 	int cpu;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f25445d..e331cdb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1006,15 +1006,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct tcphdr *th,
 				   unsigned int tcplen)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 old_checksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp4_pseudohdr *bp;
-	struct hash_desc *desc;
 	int err;
-	unsigned int nbytes = 0;
 
 	/*
 	 * Okay, so RFC2385 is turned on for this connection,
@@ -1026,10 +1020,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		goto clear_hash_noput;
 
 	bp = &hp->md5_blk.ip4;
-	desc = &hp->md5_desc;
 
 	/*
-	 * 1. the TCP pseudo-header (in the order: source IP address,
+	 * The TCP pseudo-header (in the order: source IP address,
 	 * destination IP address, zero-padded protocol number, and
 	 * segment length)
 	 */
@@ -1039,50 +1032,13 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->protocol = IPPROTO_TCP;
 	bp->len = htons(tcplen);
 
-	sg_init_table(sg, 4);
-
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. the TCP header, excluding options, and assuming a
-	 * checksum of zero/
-	 */
-	old_checksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(struct tcphdr));
-	nbytes += sizeof(struct tcphdr);
-
-	/* 3. the TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		unsigned char *data = (unsigned char *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
-
-	/* 4. an independently-specified key or password, known to both
-	 * TCPs and presumably connection-specific
-	 */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
-
-	sg_mark_end(&sg[block - 1]);
-
-	/* Now store the Hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err)
-		goto clear_hash;
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err)
-		goto clear_hash;
-	err = crypto_hash_final(desc, md5_hash);
+	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
+				th, tcplen, hp);
 	if (err)
 		goto clear_hash;
 
-	/* Reset header, and free up the crypto */
+	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
-	th->check = old_checksum;
-
 out:
 	return 0;
 clear_hash:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 334d21c..0ae0311 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -738,23 +738,17 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *daddr,
 				   struct tcphdr *th, unsigned int tcplen)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 cksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp6_pseudohdr *bp;
-	struct hash_desc *desc;
 	int err;
-	unsigned int nbytes = 0;
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp) {
 		printk(KERN_WARNING "%s(): hash pool not found...\n", __func__);
 		goto clear_hash_noput;
 	}
+
 	bp = &hp->md5_blk.ip6;
-	desc = &hp->md5_desc;
 
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
@@ -762,51 +756,14 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->len = htonl(tcplen);
 	bp->protocol = htonl(IPPROTO_TCP);
 
-	sg_init_table(sg, 4);
-
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. TCP header, excluding options */
-	cksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(*th));
-	nbytes += sizeof(*th);
-
-	/* 3. TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		u8 *data = (u8 *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
-
-	/* 4. shared key */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
-
-	sg_mark_end(&sg[block - 1]);
+	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
+				th, tcplen, hp);
 
-	/* Now store the hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
-		goto clear_hash;
-	}
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
-		goto clear_hash;
-	}
-	err = crypto_hash_final(desc, md5_hash);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
+	if (err)
 		goto clear_hash;
-	}
 
-	/* Reset header, and free up the crypto */
+	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
-	th->check = cksum;
 out:
 	return 0;
 clear_hash:

---
commit 9501f9722922f2e80e1f9dc6682311d65c2b5690
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 18 12:45:16 2008 +0900

    tcp md5sig: Let the caller pass appropriate key for tcp_v{4,6}_do_calc_md5_hash().
    
    As we do for other socket/timewait-socket specific parameters,
    let the callers pass appropriate arguments to
    tcp_v{4,6}_do_calc_md5_hash().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index eac26b7..07005eb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1142,6 +1142,16 @@ extern int			tcp_v4_md5_do_add(struct sock *sk,
 extern int			tcp_v4_md5_do_del(struct sock *sk,
 						  __be32 addr);
 
+#ifdef CONFIG_TCP_MD5SIG
+#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
+				 &(struct tcp_md5sig_key) {		 \
+					.key = (twsk)->tw_md5_key,	 \
+					.keylen = (twsk)->tw_md5_keylen, \
+				} : NULL)
+#else
+#define tcp_twsk_md5_key(twsk)	NULL
+#endif
+
 extern struct tcp_md5sig_pool	**tcp_alloc_md5sig_pool(void);
 extern void			tcp_free_md5sig_pool(void);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e331cdb..f7ff2a6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -96,6 +96,12 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
 				   struct tcphdr *th, unsigned int tcplen);
+#else
+static inline
+struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+{
+	return NULL;
+}
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -604,9 +610,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
-			    struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 ts)
+static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+			    u32 win, u32 ts, int oif,
+			    struct tcp_md5sig_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -618,10 +624,6 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-	struct tcp_md5sig_key tw_key;
-#endif
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
@@ -647,23 +649,6 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 	rep.th.window  = htons(win);
 
 #ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * The SKB holds an imcoming packet, but may not have a valid ->sk
-	 * pointer. This is especially the case when we're dealing with a
-	 * TIME_WAIT ack, because the sk structure is long gone, and only
-	 * the tcp_timewait_sock remains. So the md5 key is stashed in that
-	 * structure, and we use it in preference.  I believe that (twsk ||
-	 * skb->sk) holds true, but we program defensively.
-	 */
-	if (!twsk && skb->sk) {
-		key = tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr);
-	} else if (twsk && twsk->tw_md5_keylen) {
-		tw_key.key = twsk->tw_md5_key;
-		tw_key.keylen = twsk->tw_md5_keylen;
-		key = &tw_key;
-	} else
-		key = NULL;
-
 	if (key) {
 		int offset = (ts) ? 3 : 0;
 
@@ -685,8 +670,8 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
-	if (twsk)
-		arg.bound_dev_if = twsk->tw_sk.tw_bound_dev_if;
+	if (oif)
+		arg.bound_dev_if = oif;
 
 	ip_send_reply(dev_net(skb->dev)->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
@@ -699,9 +684,12 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent,
+			tw->tw_bound_dev_if,
+			tcp_twsk_md5_key(tcptw)
+			);
 
 	inet_twsk_put(tw);
 }
@@ -709,9 +697,11 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
+	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
-			req->ts_recent);
+			req->ts_recent,
+			0,
+			tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr));
 }
 
 /*
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0ae0311..ecdbb9f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -82,6 +82,12 @@ static struct inet_connection_sock_af_ops ipv6_specific;
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
+#else
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+						   struct in6_addr *addr)
+{
+	return NULL;
+}
 #endif
 
 static void tcp_v6_hash(struct sock *sk)
@@ -1011,8 +1017,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	kfree_skb(buff);
 }
 
-static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
-			    struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts)
+static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
+			    struct tcp_md5sig_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
@@ -1021,22 +1027,6 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-	struct tcp_md5sig_key tw_key;
-#endif
-
-#ifdef CONFIG_TCP_MD5SIG
-	if (!tw && skb->sk) {
-		key = tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr);
-	} else if (tw && tw->tw_md5_keylen) {
-		tw_key.key = tw->tw_md5_key;
-		tw_key.keylen = tw->tw_md5_keylen;
-		key = &tw_key;
-	} else {
-		key = NULL;
-	}
-#endif
 
 	if (ts)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
@@ -1116,16 +1106,17 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v6_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw));
 
 	inet_twsk_put(tw);
 }
 
 static void tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
 {
-	tcp_v6_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent);
+	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
+			tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr));
 }
 
 

---
commit 9cba632e24ef18e2905c18997a8f24e8d7a29e71
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:34:00 2008 +0300

    ipv6 mcast: Remove unused macro (MLDV2_QQIC) from mcast.c.
    
    This patch removes  MLDV2_QQIC macro from mcast.c
    as it is unused.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fd632dd..ee30ec4 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -164,7 +164,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 	((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
 	(MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
 
-#define MLDV2_QQIC(value) MLDV2_EXP(0x80, 4, 3, value)
 #define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
 
 #define IPV6_MLD_MAX_MSF	64

---
commit 7d120c55df02a2b87f4aa317f1f04e398398dcdc
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:35:13 2008 +0300

    ipv6 mroute: Use MRT6_VERSION instead of MRT_VERSION in ip6mr.c.
    
    MRT6_VERSION should be used instead of MRT_VERSION in ip6mr.c.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index bf268b3..0b11b37 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1240,7 +1240,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, int
 
 #endif
 	/*
-	 *	Spurious command, or MRT_VERSION which you cannot
+	 *	Spurious command, or MRT6_VERSION which you cannot
 	 *	set.
 	 */
 	default:

---
commit 0399e5f07ad7024f70881d44f19d767d3f25a980
Author: Rami Rosen <ramirose@gmail.com>
Date:   Wed Apr 23 14:36:58 2008 +0300

    ipv6 addrconf: Remove IFA_GLOBAL definition from include/net/if_inet6.h.
    
    This patches removes IFA_GLOBAL definition from linux/include/net/if_inet6.h
    as it is unused.
    
    Signed-off-by: Rami Rosen <ramirose@gmail.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b2cfc49..db66c79 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -148,7 +148,6 @@ struct ifacaddr6
 #define	IFA_HOST	IPV6_ADDR_LOOPBACK
 #define	IFA_LINK	IPV6_ADDR_LINKLOCAL
 #define	IFA_SITE	IPV6_ADDR_SITELOCAL
-#define	IFA_GLOBAL	0x0000U
 
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;

---
commit 2b5ead46442d80928cce987ae6acf3fe99968ad8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue May 13 01:16:24 2008 +0900

    ipv6 addrconf: Introduce addrconf_is_prefix_route() helper.
    
    This inline function, for readability, returns if the route
    is a "prefix" route regardless if it was installed by RA or by
    hand.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 147588f..9ea4e62 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -231,6 +231,12 @@ static inline int addrconf_qdisc_ok(struct net_device *dev)
 	return (dev->qdisc != &noop_qdisc);
 }
 
+/* Check if a route is valid prefix route */
+static inline int addrconf_is_prefix_route(const struct rt6_info *rt)
+{
+	return ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0);
+}
+
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
 {
 	if (del_timer(&ifp->timer))
@@ -777,7 +783,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
 		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && addrconf_is_prefix_route(rt)) {
 			if (onlink == 0) {
 				ip6_del_rt(rt);
 				rt = NULL;
@@ -1788,7 +1794,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && addrconf_is_prefix_route(rt)) {
 			/* Autoconf prefix route */
 			if (valid_lft == 0) {
 				ip6_del_rt(rt);

---
commit 3de232554a91adc74e80dc15c304be806bd7e1f9
Author: Benjamin Thery <benjamin.thery@bull.net>
Date:   Wed May 28 14:51:24 2008 +0200

    ipv6 netns: Address labels per namespace
    
    This pacth makes IPv6 address labels per network namespace.
    It keeps the global label tables, ip6addrlbl_table, but
    adds a 'net' member to each ip6addrlbl_entry.
    This new member is taken into account when matching labels.
    
    Changelog
    =========
    * v1: Initial version
    * v2:
      * Minize the penalty when network namespaces are not configured:
          *  the 'net' member is added only if CONFIG_NET_NS is
             defined. This saves space when network namespaces are not
             configured.
          * 'net' value is retrieved with the inlined function
             ip6addrlbl_net() that always return &init_net when
             CONFIG_NET_NS is not defined.
      * 'net' member in ip6addrlbl_entry renamed to the less generic
        'lbl_net' name (helps code search).
    
    Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index bbd3d58..06b2814 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -121,7 +121,8 @@ static inline int addrconf_finite_timeout(unsigned long timeout)
  */
 extern int			ipv6_addr_label_init(void);
 extern void			ipv6_addr_label_rtnl_register(void);
-extern u32			ipv6_addr_label(const struct in6_addr *addr,
+extern u32			ipv6_addr_label(struct net *net,
+						const struct in6_addr *addr,
 						int type, int ifindex);
 
 /*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9ea4e62..fa43374 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -964,7 +964,8 @@ static inline int ipv6_saddr_preferred(int type)
 	return 0;
 }
 
-static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
+static int ipv6_get_saddr_eval(struct net *net,
+			       struct ipv6_saddr_score *score,
 			       struct ipv6_saddr_dst *dst,
 			       int i)
 {
@@ -1043,7 +1044,8 @@ static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
 		break;
 	case IPV6_SADDR_RULE_LABEL:
 		/* Rule 6: Prefer matching label */
-		ret = ipv6_addr_label(&score->ifa->addr, score->addr_type,
+		ret = ipv6_addr_label(net,
+				      &score->ifa->addr, score->addr_type,
 				      score->ifa->idev->dev->ifindex) == dst->label;
 		break;
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1097,7 +1099,7 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 	dst.addr = daddr;
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
 	dst.scope = __ipv6_addr_src_scope(dst_type);
-	dst.label = ipv6_addr_label(daddr, dst_type, dst.ifindex);
+	dst.label = ipv6_addr_label(net, daddr, dst_type, dst.ifindex);
 	dst.prefs = prefs;
 
 	hiscore->rule = -1;
@@ -1165,8 +1167,8 @@ int ipv6_dev_get_saddr(struct net_device *dst_dev,
 			for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
 				int minihiscore, miniscore;
 
-				minihiscore = ipv6_get_saddr_eval(hiscore, &dst, i);
-				miniscore = ipv6_get_saddr_eval(score, &dst, i);
+				minihiscore = ipv6_get_saddr_eval(net, hiscore, &dst, i);
+				miniscore = ipv6_get_saddr_eval(net, score, &dst, i);
 
 				if (minihiscore > miniscore) {
 					if (i == IPV6_SADDR_RULE_SCOPE &&
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 9bfa884..0890903 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -29,6 +29,9 @@
  */
 struct ip6addrlbl_entry
 {
+#ifdef CONFIG_NET_NS
+	struct net *lbl_net;
+#endif
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -46,6 +49,16 @@ static struct ip6addrlbl_table
 	u32 seq;
 } ip6addrlbl_table;
 
+static inline
+struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
+{
+#ifdef CONFIG_NET_NS
+	return lbl->lbl_net;
+#else
+	return &init_net;
+#endif
+}
+
 /*
  * Default policy table (RFC3484 + extensions)
  *
@@ -65,7 +78,7 @@ static struct ip6addrlbl_table
 
 #define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
 
-static const __initdata struct ip6addrlbl_init_table
+static const __net_initdata struct ip6addrlbl_init_table
 {
 	const struct in6_addr *prefix;
 	int prefixlen;
@@ -108,6 +121,9 @@ static const __initdata struct ip6addrlbl_init_table
 /* Object management */
 static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 {
+#ifdef CONFIG_NET_NS
+	release_net(p->lbl_net);
+#endif
 	kfree(p);
 }
 
@@ -128,10 +144,13 @@ static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 }
 
 /* Find label */
-static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
+static int __ip6addrlbl_match(struct net *net,
+			      struct ip6addrlbl_entry *p,
 			      const struct in6_addr *addr,
 			      int addrtype, int ifindex)
 {
+	if (!net_eq(ip6addrlbl_net(p), net))
+		return 0;
 	if (p->ifindex && p->ifindex != ifindex)
 		return 0;
 	if (p->addrtype && p->addrtype != addrtype)
@@ -141,19 +160,21 @@ static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
 	return 1;
 }
 
-static struct ip6addrlbl_entry *__ipv6_addr_label(const struct in6_addr *addr,
+static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
+						  const struct in6_addr *addr,
 						  int type, int ifindex)
 {
 	struct hlist_node *pos;
 	struct ip6addrlbl_entry *p;
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (__ip6addrlbl_match(p, addr, type, ifindex))
+		if (__ip6addrlbl_match(net, p, addr, type, ifindex))
 			return p;
 	}
 	return NULL;
 }
 
-u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
+u32 ipv6_addr_label(struct net *net,
+		    const struct in6_addr *addr, int type, int ifindex)
 {
 	u32 label;
 	struct ip6addrlbl_entry *p;
@@ -161,7 +182,7 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 	type &= IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, type, ifindex);
+	p = __ipv6_addr_label(net, addr, type, ifindex);
 	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
 	rcu_read_unlock();
 
@@ -174,7 +195,8 @@ u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
 }
 
 /* allocate one entry */
-static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
+static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
+						 const struct in6_addr *prefix,
 						 int prefixlen, int ifindex,
 						 u32 label)
 {
@@ -216,6 +238,9 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
+#ifdef CONFIG_NET_NS
+	newp->lbl_net = hold_net(net);
+#endif
 	atomic_set(&newp->refcnt, 1);
 	return newp;
 }
@@ -237,6 +262,7 @@ static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 		hlist_for_each_entry_safe(p, pos, n,
 					  &ip6addrlbl_table.head, list) {
 			if (p->prefixlen == newp->prefixlen &&
+			    net_eq(ip6addrlbl_net(p), ip6addrlbl_net(newp)) &&
 			    p->ifindex == newp->ifindex &&
 			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
 				if (!replace) {
@@ -261,7 +287,8 @@ out:
 }
 
 /* add a label */
-static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_add(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex, u32 label, int replace)
 {
 	struct ip6addrlbl_entry *newp;
@@ -274,7 +301,7 @@ static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 			(unsigned int)label,
 			replace);
 
-	newp = ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
+	newp = ip6addrlbl_alloc(net, prefix, prefixlen, ifindex, label);
 	if (IS_ERR(newp))
 		return PTR_ERR(newp);
 	spin_lock(&ip6addrlbl_table.lock);
@@ -286,7 +313,8 @@ static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
 }
 
 /* remove a label */
-static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int __ip6addrlbl_del(struct net *net,
+			    const struct in6_addr *prefix, int prefixlen,
 			    int ifindex)
 {
 	struct ip6addrlbl_entry *p = NULL;
@@ -300,6 +328,7 @@ static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 
 	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
 		if (p->prefixlen == prefixlen &&
+		    net_eq(ip6addrlbl_net(p), net) &&
 		    p->ifindex == ifindex &&
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
@@ -311,7 +340,8 @@ static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 	return ret;
 }
 
-static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_del(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex)
 {
 	struct in6_addr prefix_buf;
@@ -324,13 +354,13 @@ static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
 	spin_lock(&ip6addrlbl_table.lock);
-	ret = __ip6addrlbl_del(&prefix_buf, prefixlen, ifindex);
+	ret = __ip6addrlbl_del(net, &prefix_buf, prefixlen, ifindex);
 	spin_unlock(&ip6addrlbl_table.lock);
 	return ret;
 }
 
 /* add default label */
-static __init int ip6addrlbl_init(void)
+static int __net_init ip6addrlbl_net_init(struct net *net)
 {
 	int err = 0;
 	int i;
@@ -338,7 +368,8 @@ static __init int ip6addrlbl_init(void)
 	ADDRLABEL(KERN_DEBUG "%s()\n", __func__);
 
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
-		int ret = ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
+		int ret = ip6addrlbl_add(net,
+					 ip6addrlbl_init_table[i].prefix,
 					 ip6addrlbl_init_table[i].prefixlen,
 					 0,
 					 ip6addrlbl_init_table[i].label, 0);
@@ -349,11 +380,32 @@ static __init int ip6addrlbl_init(void)
 	return err;
 }
 
+static void __net_exit ip6addrlbl_net_exit(struct net *net)
+{
+	struct ip6addrlbl_entry *p = NULL;
+	struct hlist_node *pos, *n;
+
+	/* Remove all labels belonging to the exiting net */
+	spin_lock(&ip6addrlbl_table.lock);
+	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
+		if (net_eq(ip6addrlbl_net(p), net)) {
+			hlist_del_rcu(&p->list);
+			ip6addrlbl_put(p);
+		}
+	}
+	spin_unlock(&ip6addrlbl_table.lock);
+}
+
+static struct pernet_operations ipv6_addr_label_ops = {
+	.init = ip6addrlbl_net_init,
+	.exit = ip6addrlbl_net_exit,
+};
+
 int __init ipv6_addr_label_init(void)
 {
 	spin_lock_init(&ip6addrlbl_table.lock);
 
-	return ip6addrlbl_init();
+	return register_pernet_subsys(&ipv6_addr_label_ops);
 }
 
 static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
@@ -371,9 +423,6 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 label;
 	int err = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -385,7 +434,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -403,12 +452,12 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	switch(nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
-		err = ip6addrlbl_add(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_add(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index, label,
 				     nlh->nlmsg_flags & NLM_F_REPLACE);
 		break;
 	case RTM_DELADDRLABEL:
-		err = ip6addrlbl_del(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_del(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index);
 		break;
 	default:
@@ -458,12 +507,10 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx = 0, s_idx = cb->args[0];
 	int err;
 
-	if (net != &init_net)
-		return 0;
-
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (idx >= s_idx) {
+		if (idx >= s_idx &&
+		    net_eq(ip6addrlbl_net(p), net)) {
 			if ((err = ip6addrlbl_fill(skb, p,
 						   ip6addrlbl_table.seq,
 						   NETLINK_CB(cb->skb).pid,
@@ -499,9 +546,6 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 	struct ip6addrlbl_entry *p;
 	struct sk_buff *skb;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -513,7 +557,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -524,7 +568,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		return -EINVAL;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, ipv6_addr_type(addr), ifal->ifal_index);
+	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
 	if (p && ip6addrlbl_hold(p))
 		p = NULL;
 	lseq = ip6addrlbl_table.seq;
@@ -552,7 +596,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		goto out;
 	}
 
-	err = rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
 out:
 	return err;
 }

---
commit 9e8b4ed8bb7d2f0f91dccf0abf648771d76e7a01
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 00:50:45 2008 +0900

    key: Introduce pfkey_sockaddr_len() for raw sockaddr{} length.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9bba7ac..02c8aba 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -579,6 +579,19 @@ static uint8_t pfkey_proto_from_xfrm(uint8_t proto)
 	return (proto ? proto : IPSEC_PROTO_ANY);
 }
 
+static inline int pfkey_sockaddr_len(sa_family_t family)
+{
+	switch (family) {
+	case AF_INET:
+		return sizeof(struct sockaddr_in);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		return sizeof(struct sockaddr_in6);
+#endif
+	}
+	return 0;
+}
+
 static int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr,
 				     xfrm_address_t *xaddr)
 {
@@ -642,20 +655,11 @@ static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **
 }
 
 #define PFKEY_ALIGN8(a) (1 + (((a) - 1) | (8 - 1)))
+
 static int
 pfkey_sockaddr_size(sa_family_t family)
 {
-	switch (family) {
-	case AF_INET:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in));
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in6));
-#endif
-	default:
-		return 0;
-	}
-	/* NOTREACHED */
+	return PFKEY_ALIGN8(pfkey_sockaddr_len(family));
 }
 
 static inline int pfkey_mode_from_xfrm(int mode)
@@ -1952,9 +1956,7 @@ static int pfkey_xfrm_policy2msg_size(struct xfrm_policy *xp)
 
 	for (i=0; i<xp->xfrm_nr; i++) {
 		t = xp->xfrm_vec + i;
-		socklen += (t->encap_family == AF_INET ?
-			    sizeof(struct sockaddr_in) :
-			    sizeof(struct sockaddr_in6));
+		socklen += pfkey_sockaddr_len(t->encap_family);
 	}
 
 	return sizeof(struct sadb_msg) +
@@ -1996,9 +1998,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	int i;
 	int size;
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
-	int socklen = (xp->family == AF_INET ?
-		       sizeof(struct sockaddr_in) :
-		       sizeof(struct sockaddr_in6));
+	int socklen = pfkey_sockaddr_len(xp->family);
 
 	size = pfkey_xfrm_policy2msg_size(xp);
 
@@ -2122,9 +2122,7 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
 		if (t->mode == XFRM_MODE_TUNNEL)
-			req_size += ((t->encap_family == AF_INET ?
-				     sizeof(struct sockaddr_in) :
-				     sizeof(struct sockaddr_in6)) * 2);
+			req_size += pfkey_sockaddr_len(t->encap_family) * 2;
 		else
 			size -= 2*socklen;
 		rq = (void*)skb_put(skb, req_size);
@@ -2459,17 +2457,7 @@ out:
 #ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_sockaddr_pair_size(sa_family_t family)
 {
-	switch (family) {
-	case AF_INET:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in) * 2);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		return PFKEY_ALIGN8(sizeof(struct sockaddr_in6) * 2);
-#endif
-	default:
-		return 0;
-	}
-	/* NOTREACHED */
+	return PFKEY_ALIGN8(pfkey_sockaddr_len(family) * 2);
 }
 
 static int parse_sockaddr_pair(struct sadb_x_ipsecrequest *rq,

---
commit e5b56652c11baf144eb713c33ff70a1b5d6d09bc
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 01:46:41 2008 +0900

    key: Share common code path to fill sockaddr{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 02c8aba..2b05cb6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -691,6 +691,36 @@ static inline int pfkey_mode_to_xfrm(int mode)
 	}
 }
 
+static unsigned int pfkey_sockaddr_fill(xfrm_address_t *xaddr, __be16 port,
+				       struct sockaddr *sa,
+				       unsigned short family)
+{
+	switch (family) {
+	case AF_INET:
+	    {
+		struct sockaddr_in *sin = (struct sockaddr_in *)sa;
+		sin->sin_family = AF_INET;
+		sin->sin_port = port;
+		sin->sin_addr.s_addr = xaddr->a4;
+		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+		return 32;
+	    }
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+	    {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sa;
+		sin6->sin6_family = AF_INET6;
+		sin6->sin6_port = port;
+		sin6->sin6_flowinfo = 0;
+		ipv6_addr_copy(&sin6->sin6_addr, (struct in6_addr *)xaddr->a6);
+		sin6->sin6_scope_id = 0;
+		return 128;
+	    }
+#endif
+	}
+	return 0;
+}
+
 static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 					      int add_keys, int hsc)
 {
@@ -701,13 +731,9 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	struct sadb_address *addr;
 	struct sadb_key *key;
 	struct sadb_x_sa2 *sa2;
-	struct sockaddr_in *sin;
 	struct sadb_x_sec_ctx *sec_ctx;
 	struct xfrm_sec_ctx *xfrm_ctx;
 	int ctx_size = 0;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int size;
 	int auth_key_size = 0;
 	int encrypt_key_size = 0;
@@ -865,29 +891,12 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	   protocol's number." - RFC2367 */
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
 
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, x->props.saddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* dst address */
@@ -898,70 +907,32 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 			sizeof(uint64_t);
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
-	addr->sadb_address_prefixlen = 32; /* XXX */
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->id.daddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
 
-		if (x->sel.saddr.a4 != x->props.saddr.a4) {
-			addr = (struct sadb_address*) skb_put(skb,
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len =
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
-			sin = (struct sockaddr_in *) (addr + 1);
-			sin->sin_family = AF_INET;
-			sin->sin_addr.s_addr = x->sel.saddr.a4;
-			sin->sin_port = x->sel.sport;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->id.daddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
+		BUG();
 
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, x->id.daddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
+	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr,
+			  x->props.family)) {
+		addr = (struct sadb_address*) skb_put(skb,
+			sizeof(struct sadb_address)+sockaddr_size);
+		addr->sadb_address_len =
+			(sizeof(struct sadb_address)+sockaddr_size)/
+			sizeof(uint64_t);
+		addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
+		addr->sadb_address_proto =
+			pfkey_proto_from_xfrm(x->sel.proto);
+		addr->sadb_address_prefixlen = x->sel.prefixlen_s;
+		addr->sadb_address_reserved = 0;
 
-		if (memcmp (x->sel.saddr.a6, x->props.saddr.a6,
-			    sizeof(struct in6_addr))) {
-			addr = (struct sadb_address *) skb_put(skb,
-				sizeof(struct sadb_address)+sockaddr_size);
-			addr->sadb_address_len =
-				(sizeof(struct sadb_address)+sockaddr_size)/
-				sizeof(uint64_t);
-			addr->sadb_address_exttype = SADB_EXT_ADDRESS_PROXY;
-			addr->sadb_address_proto =
-				pfkey_proto_from_xfrm(x->sel.proto);
-			addr->sadb_address_prefixlen = x->sel.prefixlen_s;
-			addr->sadb_address_reserved = 0;
-
-			sin6 = (struct sockaddr_in6 *) (addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = x->sel.sport;
-			sin6->sin6_flowinfo = 0;
-			memcpy(&sin6->sin6_addr, x->sel.saddr.a6,
-			       sizeof(struct in6_addr));
-			sin6->sin6_scope_id = 0;
-		}
+		pfkey_sockaddr_fill(&x->sel.saddr, x->sel.sport,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
 	}
-#endif
-	else
-		BUG();
 
 	/* auth key */
 	if (add_keys && auth_key_size) {
@@ -1989,12 +1960,8 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	struct sadb_address *addr;
 	struct sadb_lifetime *lifetime;
 	struct sadb_x_policy *pol;
-	struct sockaddr_in   *sin;
 	struct sadb_x_sec_ctx *sec_ctx;
 	struct xfrm_sec_ctx *xfrm_ctx;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6  *sin6;
-#endif
 	int i;
 	int size;
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
@@ -2016,26 +1983,10 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	addr->sadb_address_proto = pfkey_proto_from_xfrm(xp->selector.proto);
 	addr->sadb_address_prefixlen = xp->selector.prefixlen_s;
 	addr->sadb_address_reserved = 0;
-	/* src address */
-	if (xp->family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = xp->selector.saddr.a4;
-		sin->sin_port = xp->selector.sport;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (xp->family == AF_INET6) {
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = xp->selector.sport;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, xp->selector.saddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	if (!pfkey_sockaddr_fill(&xp->selector.saddr,
+				 xp->selector.sport,
+				 (struct sockaddr *) (addr + 1),
+				 xp->family))
 		BUG();
 
 	/* dst address */
@@ -2048,26 +1999,10 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 	addr->sadb_address_proto = pfkey_proto_from_xfrm(xp->selector.proto);
 	addr->sadb_address_prefixlen = xp->selector.prefixlen_d;
 	addr->sadb_address_reserved = 0;
-	if (xp->family == AF_INET) {
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = xp->selector.daddr.a4;
-		sin->sin_port = xp->selector.dport;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (xp->family == AF_INET6) {
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = xp->selector.dport;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, xp->selector.daddr.a6,
-		       sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
-		BUG();
+
+	pfkey_sockaddr_fill(&xp->selector.daddr, xp->selector.dport,
+			    (struct sockaddr *) (addr + 1),
+			    xp->family);
 
 	/* hard time */
 	lifetime = (struct sadb_lifetime *)  skb_put(skb,
@@ -2121,10 +2056,13 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 		int mode;
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
-		if (t->mode == XFRM_MODE_TUNNEL)
-			req_size += pfkey_sockaddr_len(t->encap_family) * 2;
-		else
+		if (t->mode == XFRM_MODE_TUNNEL) {
+			socklen = pfkey_sockaddr_len(t->encap_family);
+			req_size += socklen * 2;
+		} else {
 			size -= 2*socklen;
+			socklen = 0;
+		}
 		rq = (void*)skb_put(skb, req_size);
 		pol->sadb_x_policy_len += req_size/8;
 		memset(rq, 0, sizeof(*rq));
@@ -2139,42 +2077,15 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, in
 		if (t->optional)
 			rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_USE;
 		rq->sadb_x_ipsecrequest_reqid = t->reqid;
+
 		if (t->mode == XFRM_MODE_TUNNEL) {
-			switch (t->encap_family) {
-			case AF_INET:
-				sin = (void*)(rq+1);
-				sin->sin_family = AF_INET;
-				sin->sin_addr.s_addr = t->saddr.a4;
-				sin->sin_port = 0;
-				memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-				sin++;
-				sin->sin_family = AF_INET;
-				sin->sin_addr.s_addr = t->id.daddr.a4;
-				sin->sin_port = 0;
-				memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-				break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-			case AF_INET6:
-				sin6 = (void*)(rq+1);
-				sin6->sin6_family = AF_INET6;
-				sin6->sin6_port = 0;
-				sin6->sin6_flowinfo = 0;
-				memcpy(&sin6->sin6_addr, t->saddr.a6,
-				       sizeof(struct in6_addr));
-				sin6->sin6_scope_id = 0;
-
-				sin6++;
-				sin6->sin6_family = AF_INET6;
-				sin6->sin6_port = 0;
-				sin6->sin6_flowinfo = 0;
-				memcpy(&sin6->sin6_addr, t->id.daddr.a6,
-				       sizeof(struct in6_addr));
-				sin6->sin6_scope_id = 0;
-				break;
-#endif
-			default:
-				break;
-			}
+			u8 *sa = (void *)(rq + 1);
+			pfkey_sockaddr_fill(&t->saddr, 0,
+					    (struct sockaddr *)sa,
+					    t->encap_family);
+			pfkey_sockaddr_fill(&t->id.daddr, 0,
+					    (struct sockaddr *) (sa + socklen),
+					    t->encap_family);
 		}
 	}
 
@@ -3079,10 +2990,6 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	struct sadb_msg *hdr;
 	struct sadb_address *addr;
 	struct sadb_x_policy *pol;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int sockaddr_size;
 	int size;
 	struct sadb_x_sec_ctx *sec_ctx;
@@ -3131,29 +3038,11 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->props.saddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* dst address */
@@ -3165,29 +3054,11 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->id.daddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->id.daddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->id.daddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
@@ -3313,10 +3184,6 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	struct sadb_sa *sa;
 	struct sadb_address *addr;
 	struct sadb_x_nat_t_port *n_port;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int sockaddr_size;
 	int size;
 	__u8 satype = (x->id.proto == IPPROTO_ESP ? SADB_SATYPE_ESP : 0);
@@ -3380,29 +3247,11 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_SRC;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = x->props.saddr.a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr,
-		       x->props.saddr.a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(&x->props.saddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* NAT_T_SPORT (old port) */
@@ -3421,28 +3270,11 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	addr->sadb_address_exttype = SADB_EXT_ADDRESS_DST;
 	addr->sadb_address_proto = 0;
 	addr->sadb_address_reserved = 0;
-	if (x->props.family == AF_INET) {
-		addr->sadb_address_prefixlen = 32;
-
-		sin = (struct sockaddr_in *) (addr + 1);
-		sin->sin_family = AF_INET;
-		sin->sin_addr.s_addr = ipaddr->a4;
-		sin->sin_port = 0;
-		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	else if (x->props.family == AF_INET6) {
-		addr->sadb_address_prefixlen = 128;
-
-		sin6 = (struct sockaddr_in6 *) (addr + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		memcpy(&sin6->sin6_addr, &ipaddr->a6, sizeof(struct in6_addr));
-		sin6->sin6_scope_id = 0;
-	}
-#endif
-	else
+	addr->sadb_address_prefixlen =
+		pfkey_sockaddr_fill(ipaddr, 0,
+				    (struct sockaddr *) (addr + 1),
+				    x->props.family);
+	if (!addr->sadb_address_prefixlen)
 		BUG();
 
 	/* NAT_T_DPORT (new port) */
@@ -3460,10 +3292,6 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 			    struct xfrm_selector *sel)
 {
 	struct sadb_address *addr;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	addr = (struct sadb_address *)skb_put(skb, sizeof(struct sadb_address) + sasize);
 	addr->sadb_address_len = (sizeof(struct sadb_address) + sasize)/8;
 	addr->sadb_address_exttype = type;
@@ -3472,50 +3300,16 @@ static int set_sadb_address(struct sk_buff *skb, int sasize, int type,
 
 	switch (type) {
 	case SADB_EXT_ADDRESS_SRC:
-		if (sel->family == AF_INET) {
-			addr->sadb_address_prefixlen = sel->prefixlen_s;
-			sin = (struct sockaddr_in *)(addr + 1);
-			sin->sin_family = AF_INET;
-			memcpy(&sin->sin_addr.s_addr, &sel->saddr,
-			       sizeof(sin->sin_addr.s_addr));
-			sin->sin_port = 0;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (sel->family == AF_INET6) {
-			addr->sadb_address_prefixlen = sel->prefixlen_s;
-			sin6 = (struct sockaddr_in6 *)(addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = 0;
-			sin6->sin6_flowinfo = 0;
-			sin6->sin6_scope_id = 0;
-			memcpy(&sin6->sin6_addr.s6_addr, &sel->saddr,
-			       sizeof(sin6->sin6_addr.s6_addr));
-		}
-#endif
+		addr->sadb_address_prefixlen = sel->prefixlen_s;
+		pfkey_sockaddr_fill(&sel->saddr, 0,
+				    (struct sockaddr *)(addr + 1),
+				    sel->family);
 		break;
 	case SADB_EXT_ADDRESS_DST:
-		if (sel->family == AF_INET) {
-			addr->sadb_address_prefixlen = sel->prefixlen_d;
-			sin = (struct sockaddr_in *)(addr + 1);
-			sin->sin_family = AF_INET;
-			memcpy(&sin->sin_addr.s_addr, &sel->daddr,
-			       sizeof(sin->sin_addr.s_addr));
-			sin->sin_port = 0;
-			memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		else if (sel->family == AF_INET6) {
-			addr->sadb_address_prefixlen = sel->prefixlen_d;
-			sin6 = (struct sockaddr_in6 *)(addr + 1);
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = 0;
-			sin6->sin6_flowinfo = 0;
-			sin6->sin6_scope_id = 0;
-			memcpy(&sin6->sin6_addr.s6_addr, &sel->daddr,
-			       sizeof(sin6->sin6_addr.s6_addr));
-		}
-#endif
+		addr->sadb_address_prefixlen = sel->prefixlen_d;
+		pfkey_sockaddr_fill(&sel->daddr, 0,
+				    (struct sockaddr *)(addr + 1),
+				    sel->family);
 		break;
 	default:
 		return -EINVAL;
@@ -3530,10 +3324,8 @@ static int set_ipsecrequest(struct sk_buff *skb,
 			    xfrm_address_t *src, xfrm_address_t *dst)
 {
 	struct sadb_x_ipsecrequest *rq;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
+	u8 *sa;
+	int socklen = pfkey_sockaddr_len(family);
 	int size_req;
 
 	size_req = sizeof(struct sadb_x_ipsecrequest) +
@@ -3547,38 +3339,10 @@ static int set_ipsecrequest(struct sk_buff *skb,
 	rq->sadb_x_ipsecrequest_level = level;
 	rq->sadb_x_ipsecrequest_reqid = reqid;
 
-	switch (family) {
-	case AF_INET:
-		sin = (struct sockaddr_in *)(rq + 1);
-		sin->sin_family = AF_INET;
-		memcpy(&sin->sin_addr.s_addr, src,
-		       sizeof(sin->sin_addr.s_addr));
-		sin++;
-		sin->sin_family = AF_INET;
-		memcpy(&sin->sin_addr.s_addr, dst,
-		       sizeof(sin->sin_addr.s_addr));
-		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		sin6 = (struct sockaddr_in6 *)(rq + 1);
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
-		memcpy(&sin6->sin6_addr.s6_addr, src,
-		       sizeof(sin6->sin6_addr.s6_addr));
-		sin6++;
-		sin6->sin6_family = AF_INET6;
-		sin6->sin6_port = 0;
-		sin6->sin6_flowinfo = 0;
-		sin6->sin6_scope_id = 0;
-		memcpy(&sin6->sin6_addr.s6_addr, dst,
-		       sizeof(sin6->sin6_addr.s6_addr));
-		break;
-#endif
-	default:
+	sa = (u8 *) (rq + 1);
+	if (!pfkey_sockaddr_fill(src, 0, (struct sockaddr *)sa, family) ||
+	    !pfkey_sockaddr_fill(dst, 0, (struct sockaddr *)(sa + socklen), family))
 		return -EINVAL;
-	}
 
 	return 0;
 }

---
commit 5f95ac9111f75aa240dc3bcabffc0f047f13cb64
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 02:46:24 2008 +0900

    key: Share common code path to extract address from sockaddr{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 2b05cb6..771bd61 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -592,25 +592,30 @@ static inline int pfkey_sockaddr_len(sa_family_t family)
 	return 0;
 }
 
-static int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr,
-				     xfrm_address_t *xaddr)
+static
+int pfkey_sockaddr_extract(const struct sockaddr *sa, xfrm_address_t *xaddr)
 {
-	switch (((struct sockaddr*)(addr + 1))->sa_family) {
+	switch (sa->sa_family) {
 	case AF_INET:
 		xaddr->a4 =
-			((struct sockaddr_in *)(addr + 1))->sin_addr.s_addr;
+			((struct sockaddr_in *)sa)->sin_addr.s_addr;
 		return AF_INET;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		memcpy(xaddr->a6,
-		       &((struct sockaddr_in6 *)(addr + 1))->sin6_addr,
+		       &((struct sockaddr_in6 *)sa)->sin6_addr,
 		       sizeof(struct in6_addr));
 		return AF_INET6;
 #endif
-	default:
-		return 0;
 	}
-	/* NOTREACHED */
+	return 0;
+}
+
+static
+int pfkey_sadb_addr2xfrm_addr(struct sadb_address *addr, xfrm_address_t *xaddr)
+{
+	return pfkey_sockaddr_extract((struct sockaddr *)(addr + 1),
+				      xaddr);
 }
 
 static struct  xfrm_state *pfkey_xfrm_state_lookup(struct sadb_msg *hdr, void **ext_hdrs)
@@ -1828,10 +1833,6 @@ static int
 parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 {
 	struct xfrm_tmpl *t = xp->xfrm_vec + xp->xfrm_nr;
-	struct sockaddr_in *sin;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct sockaddr_in6 *sin6;
-#endif
 	int mode;
 
 	if (xp->xfrm_nr >= XFRM_MAX_DEPTH)
@@ -1856,31 +1857,19 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
-		struct sockaddr *sa;
-		sa = (struct sockaddr *)(rq+1);
-		switch(sa->sa_family) {
-		case AF_INET:
-			sin = (struct sockaddr_in*)sa;
-			t->saddr.a4 = sin->sin_addr.s_addr;
-			sin++;
-			if (sin->sin_family != AF_INET)
-				return -EINVAL;
-			t->id.daddr.a4 = sin->sin_addr.s_addr;
-			break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-		case AF_INET6:
-			sin6 = (struct sockaddr_in6*)sa;
-			memcpy(t->saddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
-			sin6++;
-			if (sin6->sin6_family != AF_INET6)
-				return -EINVAL;
-			memcpy(t->id.daddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
-			break;
-#endif
-		default:
+		u8 *sa = (u8 *) (rq + 1);
+		int family, socklen;
+
+		family = pfkey_sockaddr_extract((struct sockaddr *)sa,
+						&t->saddr);
+		if (!family)
 			return -EINVAL;
-		}
-		t->encap_family = sa->sa_family;
+
+		socklen = pfkey_sockaddr_len(family);
+		if (pfkey_sockaddr_extract((struct sockaddr *)(sa + socklen),
+					   &t->id.daddr) != family)
+			return -EINVAL;
+		t->encap_family = family;
 	} else
 		t->encap_family = xp->family;
 
@@ -2375,44 +2364,24 @@ static int parse_sockaddr_pair(struct sadb_x_ipsecrequest *rq,
 			       xfrm_address_t *saddr, xfrm_address_t *daddr,
 			       u16 *family)
 {
-	struct sockaddr *sa = (struct sockaddr *)(rq + 1);
+	u8 *sa = (u8 *) (rq + 1);
+	int af, socklen;
+
 	if (rq->sadb_x_ipsecrequest_len <
-	    pfkey_sockaddr_pair_size(sa->sa_family))
+	    pfkey_sockaddr_pair_size(((struct sockaddr *)sa)->sa_family))
 		return -EINVAL;
 
-	switch (sa->sa_family) {
-	case AF_INET:
-		{
-			struct sockaddr_in *sin;
-			sin = (struct sockaddr_in *)sa;
-			if ((sin+1)->sin_family != AF_INET)
-				return -EINVAL;
-			memcpy(&saddr->a4, &sin->sin_addr, sizeof(saddr->a4));
-			sin++;
-			memcpy(&daddr->a4, &sin->sin_addr, sizeof(daddr->a4));
-			*family = AF_INET;
-			break;
-		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case AF_INET6:
-		{
-			struct sockaddr_in6 *sin6;
-			sin6 = (struct sockaddr_in6 *)sa;
-			if ((sin6+1)->sin6_family != AF_INET6)
-				return -EINVAL;
-			memcpy(&saddr->a6, &sin6->sin6_addr,
-			       sizeof(saddr->a6));
-			sin6++;
-			memcpy(&daddr->a6, &sin6->sin6_addr,
-			       sizeof(daddr->a6));
-			*family = AF_INET6;
-			break;
-		}
-#endif
-	default:
+	af = pfkey_sockaddr_extract((struct sockaddr *) sa,
+				    saddr);
+	if (!af)
+		return -EINVAL;
+
+	socklen = pfkey_sockaddr_len(af);
+	if (pfkey_sockaddr_extract((struct sockaddr *) (sa + socklen),
+				   daddr) != af)
 		return -EINVAL;
-	}
 
+	*family = af;
 	return 0;
 }
 

---
commit 81b302a321a0d99ff172b8cb2a8de17bff2f9499
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Apr 28 03:17:38 2008 +0900

    key: Use xfrm_addr_cmp() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 771bd61..841af9f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -767,14 +767,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(struct xfrm_state *x,
 	}
 
 	/* identity & sensitivity */
-
-	if ((x->props.family == AF_INET &&
-	     x->sel.saddr.a4 != x->props.saddr.a4)
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	    || (x->props.family == AF_INET6 &&
-		memcmp (x->sel.saddr.a6, x->props.saddr.a6, sizeof (struct in6_addr)))
-#endif
-		)
+	if (xfrm_addr_cmp(&x->sel.saddr, &x->props.saddr, x->props.family))
 		size += sizeof(struct sadb_address) + sockaddr_size;
 
 	if (add_keys) {

---
commit 7d5d5525bd88313e6fd90c0659665aee5114bc2d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 12:29:53 2008 +0900

    tcp md5sig: Share MD5 Signature option parser between IPv4 and IPv6.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..b1c4b78 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -399,6 +399,8 @@ extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
 						  int estab);
 
+extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
+
 /*
  *	TCP v4 functions exported for the inet6 API
  */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eba873e..f331e67 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3450,6 +3450,43 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 	return 1;
 }
 
+#ifdef CONFIG_TCP_MD5SIG
+/*
+ * Parse MD5 Signature option
+ */
+u8 *tcp_parse_md5sig_option(struct tcphdr *th)
+{
+	int length = (th->doff << 2) - sizeof (*th);
+	u8 *ptr = (u8*)(th + 1);
+
+	/* If the TCP option is too short, we can short cut */
+	if (length < TCPOLEN_MD5SIG)
+		return NULL;
+
+	while (length > 0) {
+		int opcode = *ptr++;
+		int opsize;
+
+		switch(opcode) {
+		case TCPOPT_EOL:
+			return NULL;
+		case TCPOPT_NOP:
+			length--;
+			continue;
+		default:
+			opsize = *ptr++;
+			if (opsize < 2 || opsize > length)
+				return NULL;
+			if (opcode == TCPOPT_MD5SIG)
+				return ptr;
+		}
+		ptr += opsize - 2;
+		length -= opsize;
+	}
+	return NULL;
+}
+#endif
+
 static inline void tcp_store_ts_recent(struct tcp_sock *tp)
 {
 	tp->rx_opt.ts_recent = tp->rx_opt.rcv_tsval;
@@ -5467,6 +5504,9 @@ EXPORT_SYMBOL(sysctl_tcp_ecn);
 EXPORT_SYMBOL(sysctl_tcp_reordering);
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 EXPORT_SYMBOL(tcp_parse_options);
+#ifdef CONFIG_TCP_MD5SIG
+EXPORT_SYMBOL(tcp_parse_md5sig_option);
+#endif
 EXPORT_SYMBOL(tcp_rcv_established);
 EXPORT_SYMBOL(tcp_rcv_state_process);
 EXPORT_SYMBOL(tcp_initialize_rcv_mss);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..56f5509 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1134,52 +1134,12 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	struct tcp_md5sig_key *hash_expected;
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff << 2) - sizeof(struct tcphdr);
 	int genhash;
-	unsigned char *ptr;
 	unsigned char newhash[16];
 
 	hash_expected = tcp_v4_md5_do_lookup(sk, iph->saddr);
+	hash_location = tcp_parse_md5sig_option(th);
 
-	/*
-	 * If the TCP option length is less than the TCP_MD5SIG
-	 * option length, then we can shortcut
-	 */
-	if (length < TCPOLEN_MD5SIG) {
-		if (hash_expected)
-			return 1;
-		else
-			return 0;
-	}
-
-	/* Okay, we can't shortcut - we have to grub through the options */
-	ptr = (unsigned char *)(th + 1);
-	while (length > 0) {
-		int opcode = *ptr++;
-		int opsize;
-
-		switch (opcode) {
-		case TCPOPT_EOL:
-			goto done_opts;
-		case TCPOPT_NOP:
-			length--;
-			continue;
-		default:
-			opsize = *ptr++;
-			if (opsize < 2)
-				goto done_opts;
-			if (opsize > length)
-				goto done_opts;
-
-			if (opcode == TCPOPT_MD5SIG) {
-				hash_location = ptr;
-				goto done_opts;
-			}
-		}
-		ptr += opsize-2;
-		length -= opsize;
-	}
-done_opts:
 	/* We've parsed the options - do we have a hash? */
 	if (!hash_expected && !hash_location)
 		return 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..dd4ddb3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -844,43 +844,12 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	struct tcp_md5sig_key *hash_expected;
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff << 2) - sizeof (*th);
 	int genhash;
-	u8 *ptr;
 	u8 newhash[16];
 
 	hash_expected = tcp_v6_md5_do_lookup(sk, &ip6h->saddr);
+	hash_location = tcp_parse_md5sig_option(th);
 
-	/* If the TCP option is too short, we can short cut */
-	if (length < TCPOLEN_MD5SIG)
-		return hash_expected ? 1 : 0;
-
-	/* parse options */
-	ptr = (u8*)(th + 1);
-	while (length > 0) {
-		int opcode = *ptr++;
-		int opsize;
-
-		switch(opcode) {
-		case TCPOPT_EOL:
-			goto done_opts;
-		case TCPOPT_NOP:
-			length--;
-			continue;
-		default:
-			opsize = *ptr++;
-			if (opsize < 2 || opsize > length)
-				goto done_opts;
-			if (opcode == TCPOPT_MD5SIG) {
-				hash_location = ptr;
-				goto done_opts;
-			}
-		}
-		ptr += opsize - 2;
-		length -= opsize;
-	}
-
-done_opts:
 	/* do we have a hash as expected? */
 	if (!hash_expected) {
 		if (!hash_location)

---
commit 076fb7223357769c39f3ddf900bba6752369c76a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 12:48:12 2008 +0900

    tcp md5sig: Remove redundant protocol argument.
    
    Protocol is always TCP, so remove useless protocol argument.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b1c4b78..ae2549c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1123,7 +1123,6 @@ extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct dst_entry *dst,
 						     struct request_sock *req,
 						     struct tcphdr *th,
-						     int protocol,
 						     unsigned int tcplen);
 extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
 						   struct sock *addr_sk);
@@ -1373,7 +1372,6 @@ struct tcp_sock_af_ops {
 						  struct dst_entry *dst,
 						  struct request_sock *req,
 						  struct tcphdr *th,
-						  int protocol,
 						  unsigned int len);
 	int			(*md5_add) (struct sock *sk,
 					    struct sock *addr_sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 56f5509..f25445d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -95,8 +95,7 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 						   __be32 addr);
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen);
+				   struct tcphdr *th, unsigned int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -586,8 +585,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -680,8 +678,7 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 					key,
 					ip_hdr(skb)->daddr,
 					ip_hdr(skb)->saddr,
-					&rep.th, IPPROTO_TCP,
-					arg.iov[0].iov_len);
+					&rep.th, arg.iov[0].iov_len);
 	}
 #endif
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
@@ -1006,7 +1003,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
-				   struct tcphdr *th, int protocol,
+				   struct tcphdr *th,
 				   unsigned int tcplen)
 {
 	struct scatterlist sg[4];
@@ -1039,7 +1036,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->saddr = saddr;
 	bp->daddr = daddr;
 	bp->pad = 0;
-	bp->protocol = protocol;
+	bp->protocol = IPPROTO_TCP;
 	bp->len = htons(tcplen);
 
 	sg_init_table(sg, 4);
@@ -1099,7 +1096,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 			 struct sock *sk,
 			 struct dst_entry *dst,
 			 struct request_sock *req,
-			 struct tcphdr *th, int protocol,
+			 struct tcphdr *th,
 			 unsigned int tcplen)
 {
 	__be32 saddr, daddr;
@@ -1115,7 +1112,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	}
 	return tcp_v4_do_calc_md5_hash(md5_hash, key,
 				       saddr, daddr,
-				       th, protocol, tcplen);
+				       th, tcplen);
 }
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
@@ -1166,8 +1163,7 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 	genhash = tcp_v4_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  iph->saddr, iph->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  th, skb->len);
 
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ad993ec..f3ffd67 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -607,7 +607,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 					       md5,
 					       sk, NULL, NULL,
 					       tcp_hdr(skb),
-					       sk->sk_protocol,
 					       skb->len);
 	}
 #endif
@@ -2266,7 +2265,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
+					       tcp_hdr(skb),
 					       skb->len);
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index dd4ddb3..334d21c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -736,8 +736,7 @@ static int tcp_v6_parse_md5_keys (struct sock *sk, char __user *optval,
 static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
-				   struct tcphdr *th, int protocol,
-				   unsigned int tcplen)
+				   struct tcphdr *th, unsigned int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;
@@ -761,7 +760,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	ipv6_addr_copy(&bp->saddr, saddr);
 	ipv6_addr_copy(&bp->daddr, daddr);
 	bp->len = htonl(tcplen);
-	bp->protocol = htonl(protocol);
+	bp->protocol = htonl(IPPROTO_TCP);
 
 	sg_init_table(sg, 4);
 
@@ -821,8 +820,7 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				struct sock *sk,
 				struct dst_entry *dst,
 				struct request_sock *req,
-				struct tcphdr *th, int protocol,
-				unsigned int tcplen)
+				struct tcphdr *th, unsigned int tcplen)
 {
 	struct in6_addr *saddr, *daddr;
 
@@ -835,7 +833,7 @@ static int tcp_v6_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	}
 	return tcp_v6_do_calc_md5_hash(md5_hash, key,
 				       saddr, daddr,
-				       th, protocol, tcplen);
+				       th, tcplen);
 }
 
 static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
@@ -879,8 +877,7 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	genhash = tcp_v6_do_calc_md5_hash(newhash,
 					  hash_expected,
 					  &ip6h->saddr, &ip6h->daddr,
-					  th, sk->sk_protocol,
-					  skb->len);
+					  th, skb->len);
 	if (genhash || memcmp(hash_location, newhash, 16) != 0) {
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash %s for "
@@ -1020,7 +1017,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		tcp_v6_do_calc_md5_hash((__u8 *)&opt[1], key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					t1, tot_len);
 	}
 #endif
 
@@ -1126,7 +1123,7 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 		tcp_v6_do_calc_md5_hash((__u8 *)topt, key,
 					&ipv6_hdr(skb)->daddr,
 					&ipv6_hdr(skb)->saddr,
-					t1, IPPROTO_TCP, tot_len);
+					t1, tot_len);
 	}
 #endif
 

---
commit 8d26d76dd4a4c87ef037a44a42a0608ffc730199
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 17 13:19:16 2008 +0900

    tcp md5sig: Share most of hash calcucaltion bits between IPv4 and IPv6.
    
    We can share most part of the hash calculation code because
    the only difference between IPv4 and IPv6 is their pseudo headers.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ae2549c..eac26b7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1117,6 +1117,13 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
+extern int			tcp_calc_md5_hash(char *md5_hash,
+						  struct tcp_md5sig_key *key,
+						  int bplen,
+						  struct tcphdr *th,
+						  unsigned int tcplen,
+						  struct tcp_md5sig_pool *hp);
+
 extern int			tcp_v4_calc_md5_hash(char *md5_hash,
 						     struct tcp_md5sig_key *key,
 						     struct sock *sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ab66683..6efbae0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2459,6 +2459,76 @@ static unsigned long tcp_md5sig_users;
 static struct tcp_md5sig_pool **tcp_md5sig_pool;
 static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
 
+int tcp_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
+		      int bplen,
+		      struct tcphdr *th, unsigned int tcplen,
+		      struct tcp_md5sig_pool *hp)
+{
+	struct scatterlist sg[4];
+	__u16 data_len;
+	int block = 0;
+	__sum16 cksum;
+	struct hash_desc *desc = &hp->md5_desc;
+	int err;
+	unsigned int nbytes = 0;
+
+	sg_init_table(sg, 4);
+
+	/* 1. The TCP pseudo-header */
+	sg_set_buf(&sg[block++], &hp->md5_blk, bplen);
+	nbytes += bplen;
+
+	/* 2. The TCP header, excluding options, and assuming a
+	 * checksum of zero
+	 */
+	cksum = th->check;
+	th->check = 0;
+	sg_set_buf(&sg[block++], th, sizeof(*th));
+	nbytes += sizeof(*th);
+
+	/* 3. The TCP segment data (if any) */
+	data_len = tcplen - (th->doff << 2);
+	if (data_len > 0) {
+		u8 *data = (u8 *)th + (th->doff << 2);
+		sg_set_buf(&sg[block++], data, data_len);
+		nbytes += data_len;
+	}
+
+	/* 4. an independently-specified key or password, known to both
+	 * TCPs and presumably connection-specific
+	 */
+	sg_set_buf(&sg[block++], key->key, key->keylen);
+	nbytes += key->keylen;
+
+	sg_mark_end(&sg[block - 1]);
+
+	/* Now store the hash into the packet */
+	err = crypto_hash_init(desc);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
+		return -1;
+	}
+	err = crypto_hash_update(desc, sg, nbytes);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
+		return -1;
+	}
+	err = crypto_hash_final(desc, md5_hash);
+	if (err) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
+		return -1;
+	}
+
+	/* Reset header */
+	th->check = cksum;
+
+	return 0;
+}
+EXPORT_SYMBOL(tcp_calc_md5_hash);
+
 static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool **pool)
 {
 	int cpu;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f25445d..e331cdb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1006,15 +1006,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct tcphdr *th,
 				   unsigned int tcplen)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 old_checksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp4_pseudohdr *bp;
-	struct hash_desc *desc;
 	int err;
-	unsigned int nbytes = 0;
 
 	/*
 	 * Okay, so RFC2385 is turned on for this connection,
@@ -1026,10 +1020,9 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 		goto clear_hash_noput;
 
 	bp = &hp->md5_blk.ip4;
-	desc = &hp->md5_desc;
 
 	/*
-	 * 1. the TCP pseudo-header (in the order: source IP address,
+	 * The TCP pseudo-header (in the order: source IP address,
 	 * destination IP address, zero-padded protocol number, and
 	 * segment length)
 	 */
@@ -1039,50 +1032,13 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->protocol = IPPROTO_TCP;
 	bp->len = htons(tcplen);
 
-	sg_init_table(sg, 4);
-
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. the TCP header, excluding options, and assuming a
-	 * checksum of zero/
-	 */
-	old_checksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(struct tcphdr));
-	nbytes += sizeof(struct tcphdr);
-
-	/* 3. the TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		unsigned char *data = (unsigned char *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
-
-	/* 4. an independently-specified key or password, known to both
-	 * TCPs and presumably connection-specific
-	 */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
-
-	sg_mark_end(&sg[block - 1]);
-
-	/* Now store the Hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err)
-		goto clear_hash;
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err)
-		goto clear_hash;
-	err = crypto_hash_final(desc, md5_hash);
+	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
+				th, tcplen, hp);
 	if (err)
 		goto clear_hash;
 
-	/* Reset header, and free up the crypto */
+	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
-	th->check = old_checksum;
-
 out:
 	return 0;
 clear_hash:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 334d21c..0ae0311 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -738,23 +738,17 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   struct in6_addr *daddr,
 				   struct tcphdr *th, unsigned int tcplen)
 {
-	struct scatterlist sg[4];
-	__u16 data_len;
-	int block = 0;
-	__sum16 cksum;
 	struct tcp_md5sig_pool *hp;
 	struct tcp6_pseudohdr *bp;
-	struct hash_desc *desc;
 	int err;
-	unsigned int nbytes = 0;
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp) {
 		printk(KERN_WARNING "%s(): hash pool not found...\n", __func__);
 		goto clear_hash_noput;
 	}
+
 	bp = &hp->md5_blk.ip6;
-	desc = &hp->md5_desc;
 
 	/* 1. TCP pseudo-header (RFC2460) */
 	ipv6_addr_copy(&bp->saddr, saddr);
@@ -762,51 +756,14 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	bp->len = htonl(tcplen);
 	bp->protocol = htonl(IPPROTO_TCP);
 
-	sg_init_table(sg, 4);
-
-	sg_set_buf(&sg[block++], bp, sizeof(*bp));
-	nbytes += sizeof(*bp);
-
-	/* 2. TCP header, excluding options */
-	cksum = th->check;
-	th->check = 0;
-	sg_set_buf(&sg[block++], th, sizeof(*th));
-	nbytes += sizeof(*th);
-
-	/* 3. TCP segment data (if any) */
-	data_len = tcplen - (th->doff << 2);
-	if (data_len > 0) {
-		u8 *data = (u8 *)th + (th->doff << 2);
-		sg_set_buf(&sg[block++], data, data_len);
-		nbytes += data_len;
-	}
-
-	/* 4. shared key */
-	sg_set_buf(&sg[block++], key->key, key->keylen);
-	nbytes += key->keylen;
-
-	sg_mark_end(&sg[block - 1]);
+	err = tcp_calc_md5_hash(md5_hash, key, sizeof(*bp),
+				th, tcplen, hp);
 
-	/* Now store the hash into the packet */
-	err = crypto_hash_init(desc);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_init failed\n", __func__);
-		goto clear_hash;
-	}
-	err = crypto_hash_update(desc, sg, nbytes);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_update failed\n", __func__);
-		goto clear_hash;
-	}
-	err = crypto_hash_final(desc, md5_hash);
-	if (err) {
-		printk(KERN_WARNING "%s(): hash_final failed\n", __func__);
+	if (err)
 		goto clear_hash;
-	}
 
-	/* Reset header, and free up the crypto */
+	/* Free up the crypto pool */
 	tcp_put_md5sig_pool();
-	th->check = cksum;
 out:
 	return 0;
 clear_hash:

---
commit 9501f9722922f2e80e1f9dc6682311d65c2b5690
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 18 12:45:16 2008 +0900

    tcp md5sig: Let the caller pass appropriate key for tcp_v{4,6}_do_calc_md5_hash().
    
    As we do for other socket/timewait-socket specific parameters,
    let the callers pass appropriate arguments to
    tcp_v{4,6}_do_calc_md5_hash().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index eac26b7..07005eb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1142,6 +1142,16 @@ extern int			tcp_v4_md5_do_add(struct sock *sk,
 extern int			tcp_v4_md5_do_del(struct sock *sk,
 						  __be32 addr);
 
+#ifdef CONFIG_TCP_MD5SIG
+#define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
+				 &(struct tcp_md5sig_key) {		 \
+					.key = (twsk)->tw_md5_key,	 \
+					.keylen = (twsk)->tw_md5_keylen, \
+				} : NULL)
+#else
+#define tcp_twsk_md5_key(twsk)	NULL
+#endif
+
 extern struct tcp_md5sig_pool	**tcp_alloc_md5sig_pool(void);
 extern void			tcp_free_md5sig_pool(void);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e331cdb..f7ff2a6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -96,6 +96,12 @@ static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
 				   struct tcphdr *th, unsigned int tcplen);
+#else
+static inline
+struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+{
+	return NULL;
+}
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
@@ -604,9 +610,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
-			    struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 ts)
+static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+			    u32 win, u32 ts, int oif,
+			    struct tcp_md5sig_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -618,10 +624,6 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-	struct tcp_md5sig_key tw_key;
-#endif
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
@@ -647,23 +649,6 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 	rep.th.window  = htons(win);
 
 #ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * The SKB holds an imcoming packet, but may not have a valid ->sk
-	 * pointer. This is especially the case when we're dealing with a
-	 * TIME_WAIT ack, because the sk structure is long gone, and only
-	 * the tcp_timewait_sock remains. So the md5 key is stashed in that
-	 * structure, and we use it in preference.  I believe that (twsk ||
-	 * skb->sk) holds true, but we program defensively.
-	 */
-	if (!twsk && skb->sk) {
-		key = tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr);
-	} else if (twsk && twsk->tw_md5_keylen) {
-		tw_key.key = twsk->tw_md5_key;
-		tw_key.keylen = twsk->tw_md5_keylen;
-		key = &tw_key;
-	} else
-		key = NULL;
-
 	if (key) {
 		int offset = (ts) ? 3 : 0;
 
@@ -685,8 +670,8 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
-	if (twsk)
-		arg.bound_dev_if = twsk->tw_sk.tw_bound_dev_if;
+	if (oif)
+		arg.bound_dev_if = oif;
 
 	ip_send_reply(dev_net(skb->dev)->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
@@ -699,9 +684,12 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent,
+			tw->tw_bound_dev_if,
+			tcp_twsk_md5_key(tcptw)
+			);
 
 	inet_twsk_put(tw);
 }
@@ -709,9 +697,11 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
+	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
-			req->ts_recent);
+			req->ts_recent,
+			0,
+			tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr));
 }
 
 /*
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0ae0311..ecdbb9f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -82,6 +82,12 @@ static struct inet_connection_sock_af_ops ipv6_specific;
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
+#else
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+						   struct in6_addr *addr)
+{
+	return NULL;
+}
 #endif
 
 static void tcp_v6_hash(struct sock *sk)
@@ -1011,8 +1017,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	kfree_skb(buff);
 }
 
-static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
-			    struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts)
+static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
+			    struct tcp_md5sig_key *key)
 {
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
@@ -1021,22 +1027,6 @@ static void tcp_v6_send_ack(struct tcp_timewait_sock *tw,
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-	struct tcp_md5sig_key tw_key;
-#endif
-
-#ifdef CONFIG_TCP_MD5SIG
-	if (!tw && skb->sk) {
-		key = tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr);
-	} else if (tw && tw->tw_md5_keylen) {
-		tw_key.key = tw->tw_md5_key;
-		tw_key.keylen = tw->tw_md5_keylen;
-		key = &tw_key;
-	} else {
-		key = NULL;
-	}
-#endif
 
 	if (ts)
 		tot_len += TCPOLEN_TSTAMP_ALIGNED;
@@ -1116,16 +1106,17 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v6_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent);
+			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw));
 
 	inet_twsk_put(tw);
 }
 
 static void tcp_v6_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
 {
-	tcp_v6_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent);
+	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
+			tcp_v6_md5_do_lookup(skb->sk, &ipv6_hdr(skb)->daddr));
 }
 
 

---
