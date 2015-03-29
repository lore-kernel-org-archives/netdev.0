From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 1/2] ipv6: coding style: comparison for equality with NULL
Date: Sun, 29 Mar 2015 14:00:04 +0100
Message-ID: <1427634005-4313-2-git-send-email-ipm@chirality.org.uk>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43482 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752880AbbC2NAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 09:00:10 -0400
In-Reply-To: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 code uses a mixture of coding styles. In some instances check for NULL
pointer is done as x == NULL and sometimes as !x. !x is preferred according to
checkpatch and this patch makes the code consistent by adopting the latter
form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf.c        | 88 +++++++++++++++++++++++-----------------------
 net/ipv6/af_inet6.c        |  8 ++---
 net/ipv6/ah6.c             |  2 +-
 net/ipv6/anycast.c         | 10 +++---
 net/ipv6/datagram.c        |  6 ++--
 net/ipv6/esp6.c            |  2 +-
 net/ipv6/exthdrs_core.c    | 10 +++---
 net/ipv6/icmp.c            | 13 ++++---
 net/ipv6/ip6_flowlabel.c   | 16 ++++-----
 net/ipv6/ip6_gre.c         |  8 ++---
 net/ipv6/ip6_output.c      | 22 ++++++------
 net/ipv6/ip6_tunnel.c      |  8 ++---
 net/ipv6/ip6_vti.c         |  6 ++--
 net/ipv6/ip6mr.c           | 48 ++++++++++++-------------
 net/ipv6/ipv6_sockglue.c   | 10 +++---
 net/ipv6/mcast.c           | 14 ++++----
 net/ipv6/ndisc.c           | 20 +++++------
 net/ipv6/raw.c             | 10 +++---
 net/ipv6/reassembly.c      |  6 ++--
 net/ipv6/route.c           |  2 +-
 net/ipv6/sit.c             | 12 +++----
 net/ipv6/sysctl_net_ipv6.c |  2 +-
 net/ipv6/tcp_ipv6.c        | 12 +++----
 net/ipv6/udp.c             | 10 +++---
 net/ipv6/xfrm6_policy.c    |  2 +-
 25 files changed, 173 insertions(+), 174 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2660263..e86f743 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -334,7 +334,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		return ERR_PTR(-EINVAL);
 
 	ndev = kzalloc(sizeof(struct inet6_dev), GFP_KERNEL);
-	if (ndev == NULL)
+	if (!ndev)
 		return ERR_PTR(err);
 
 	rwlock_init(&ndev->lock);
@@ -346,7 +346,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->cnf.sysctl = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
-	if (ndev->nd_parms == NULL) {
+	if (!ndev->nd_parms) {
 		kfree(ndev);
 		return ERR_PTR(err);
 	}
@@ -481,7 +481,7 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
 			flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	ncm = nlmsg_data(nlh);
@@ -519,7 +519,7 @@ void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
@@ -574,10 +574,10 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 		break;
 	default:
 		dev = __dev_get_by_index(net, ifindex);
-		if (dev == NULL)
+		if (!dev)
 			goto errout;
 		in6_dev = __in6_dev_get(dev);
-		if (in6_dev == NULL)
+		if (!in6_dev)
 			goto errout;
 		devconf = &in6_dev->cnf;
 		break;
@@ -585,7 +585,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 
 	err = -ENOBUFS;
 	skb = nlmsg_new(inet6_netconf_msgsize_devconf(-1), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf,
@@ -854,7 +854,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 
 	ifa = kzalloc(sizeof(struct inet6_ifaddr), GFP_ATOMIC);
 
-	if (ifa == NULL) {
+	if (!ifa) {
 		ADBG("ipv6_add_addr: malloc failed\n");
 		err = -ENOBUFS;
 		goto out;
@@ -1558,7 +1558,7 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 			    : ifp->flags;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    !(ifp_flags&banned_flags) &&
-		    (dev == NULL || ifp->idev->dev == dev ||
+		    (!dev || ifp->idev->dev == dev ||
 		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
 			rcu_read_unlock_bh();
 			return 1;
@@ -1580,7 +1580,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
-			if (dev == NULL || ifp->idev->dev == dev)
+			if (!dev || ifp->idev->dev == dev)
 				return true;
 		}
 	}
@@ -1649,7 +1649,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
-			if (dev == NULL || ifp->idev->dev == dev ||
+			if (!dev || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {
 				result = ifp;
 				in6_ifa_hold(ifp);
@@ -2114,7 +2114,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	struct fib6_table *table;
 
 	table = fib6_get_table(dev_net(dev), RT6_TABLE_PREFIX);
-	if (table == NULL)
+	if (!table)
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
@@ -2278,7 +2278,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 
 	in6_dev = in6_dev_get(dev);
 
-	if (in6_dev == NULL) {
+	if (!in6_dev) {
 		net_dbg_ratelimited("addrconf: device %s not configured\n",
 				    dev->name);
 		return;
@@ -2377,7 +2377,7 @@ ok:
 
 		ifp = ipv6_get_ifaddr(net, &addr, dev, 1);
 
-		if (ifp == NULL && valid_lft) {
+		if (!ifp && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
@@ -2486,7 +2486,7 @@ int addrconf_set_dstaddr(struct net *net, void __user *arg)
 	dev = __dev_get_by_index(net, ireq.ifr6_ifindex);
 
 	err = -ENODEV;
-	if (dev == NULL)
+	if (!dev)
 		goto err_exit;
 
 #if IS_ENABLED(CONFIG_IPV6_SIT)
@@ -2658,7 +2658,7 @@ static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
 		return -ENODEV;
 
 	idev = __in6_dev_get(dev);
-	if (idev == NULL)
+	if (!idev)
 		return -ENXIO;
 
 	read_lock_bh(&idev->lock);
@@ -2810,7 +2810,7 @@ static void init_loopback(struct net_device *dev)
 	ASSERT_RTNL();
 
 	idev = ipv6_find_idev(dev);
-	if (idev == NULL) {
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -3019,7 +3019,7 @@ static void addrconf_sit_config(struct net_device *dev)
 	 */
 
 	idev = ipv6_find_idev(dev);
-	if (idev == NULL) {
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -3044,7 +3044,7 @@ static void addrconf_gre_config(struct net_device *dev)
 	ASSERT_RTNL();
 
 	idev = ipv6_find_idev(dev);
-	if (idev == NULL) {
+	if (!idev) {
 		pr_debug("%s: add_dev failed\n", __func__);
 		return;
 	}
@@ -3241,7 +3241,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
-	if (idev == NULL)
+	if (!idev)
 		return -ENODEV;
 
 	/*
@@ -3996,7 +3996,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ifm = nlmsg_data(nlh);
 	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer_pfx);
-	if (pfx == NULL)
+	if (!pfx)
 		return -EINVAL;
 
 	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
@@ -4108,7 +4108,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ifm = nlmsg_data(nlh);
 	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer_pfx);
-	if (pfx == NULL)
+	if (!pfx)
 		return -EINVAL;
 
 	if (tb[IFA_CACHEINFO]) {
@@ -4123,7 +4123,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	dev =  __dev_get_by_index(net, ifm->ifa_index);
-	if (dev == NULL)
+	if (!dev)
 		return -ENODEV;
 
 	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
@@ -4133,7 +4133,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		     IFA_F_NOPREFIXROUTE | IFA_F_MCAUTOJOIN;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
-	if (ifa == NULL) {
+	if (!ifa) {
 		/*
 		 * It would be best to check for !NLM_F_CREATE here but
 		 * userspace already relies on not having to provide this.
@@ -4208,7 +4208,7 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	u32 preferred, valid;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, ifa->prefix_len, ifa->flags, rt_scope(ifa->scope),
@@ -4269,7 +4269,7 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 		scope = RT_SCOPE_SITE;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
@@ -4295,7 +4295,7 @@ static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 		scope = RT_SCOPE_SITE;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
@@ -4468,7 +4468,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto errout;
 
 	addr = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer);
-	if (addr == NULL) {
+	if (!addr) {
 		err = -EINVAL;
 		goto errout;
 	}
@@ -4511,7 +4511,7 @@ static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet6_fill_ifaddr(skb, ifa, 0, 0, event, 0);
@@ -4664,24 +4664,24 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	if (nla_put(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
-	if (nla == NULL)
+	if (!nla)
 		goto nla_put_failure;
 	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
 
 	/* XXX - MC not implemented */
 
 	nla = nla_reserve(skb, IFLA_INET6_STATS, IPSTATS_MIB_MAX * sizeof(u64));
-	if (nla == NULL)
+	if (!nla)
 		goto nla_put_failure;
 	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_STATS, nla_len(nla));
 
 	nla = nla_reserve(skb, IFLA_INET6_ICMP6STATS, ICMP6_MIB_MAX * sizeof(u64));
-	if (nla == NULL)
+	if (!nla)
 		goto nla_put_failure;
 	snmp6_fill_stats(nla_data(nla), idev, IFLA_INET6_ICMP6STATS, nla_len(nla));
 
 	nla = nla_reserve(skb, IFLA_INET6_TOKEN, sizeof(struct in6_addr));
-	if (nla == NULL)
+	if (!nla)
 		goto nla_put_failure;
 
 	if (nla_put_u8(skb, IFLA_INET6_ADDR_GEN_MODE, idev->addr_gen_mode))
@@ -4727,7 +4727,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	ASSERT_RTNL();
 
-	if (token == NULL)
+	if (!token)
 		return -EINVAL;
 	if (ipv6_addr_any(token))
 		return -EINVAL;
@@ -4843,7 +4843,7 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	void *protoinfo;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*hdr), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	hdr = nlmsg_data(nlh);
@@ -4862,7 +4862,7 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
 		goto nla_put_failure;
 	protoinfo = nla_nest_start(skb, IFLA_PROTINFO);
-	if (protoinfo == NULL)
+	if (!protoinfo)
 		goto nla_put_failure;
 
 	if (inet6_fill_ifla6_attrs(skb, idev) < 0)
@@ -4923,7 +4923,7 @@ void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_if_nlmsg_size(), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet6_fill_ifinfo(skb, idev, 0, 0, event, 0);
@@ -4956,7 +4956,7 @@ static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
 	struct prefix_cacheinfo	ci;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*pmsg), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	pmsg = nlmsg_data(nlh);
@@ -4995,7 +4995,7 @@ static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_prefix_nlmsg_size(), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet6_fill_prefix(skb, idev, pinfo, 0, 0, event, 0);
@@ -5596,7 +5596,7 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	char path[sizeof("net/ipv6/conf/") + IFNAMSIZ];
 
 	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
-	if (t == NULL)
+	if (!t)
 		goto out;
 
 	for (i = 0; t->addrconf_vars[i].data; i++) {
@@ -5608,7 +5608,7 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
 
 	t->sysctl_header = register_net_sysctl(net, path, t->addrconf_vars);
-	if (t->sysctl_header == NULL)
+	if (!t->sysctl_header)
 		goto free;
 
 	p->sysctl = t;
@@ -5624,7 +5624,7 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 {
 	struct addrconf_sysctl_table *t;
 
-	if (p->sysctl == NULL)
+	if (!p->sysctl)
 		return;
 
 	t = p->sysctl;
@@ -5667,11 +5667,11 @@ static int __net_init addrconf_init_net(struct net *net)
 	struct ipv6_devconf *all, *dflt;
 
 	all = kmemdup(&ipv6_devconf, sizeof(ipv6_devconf), GFP_KERNEL);
-	if (all == NULL)
+	if (!all)
 		goto err_alloc_all;
 
 	dflt = kmemdup(&ipv6_devconf_dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
-	if (dflt == NULL)
+	if (!dflt)
 		goto err_alloc_dflt;
 
 	/* these will be inherited by all namespaces */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d8dcc52..0e48897 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -164,11 +164,11 @@ lookup_protocol:
 	answer_flags = answer->flags;
 	rcu_read_unlock();
 
-	WARN_ON(answer_prot->slab == NULL);
+	WARN_ON(!answer_prot->slab);
 
 	err = -ENOBUFS;
 	sk = sk_alloc(net, PF_INET6, GFP_KERNEL, answer_prot);
-	if (sk == NULL)
+	if (!sk)
 		goto out;
 
 	sock_init_data(sock, sk);
@@ -391,7 +391,7 @@ int inet6_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	if (sk == NULL)
+	if (!sk)
 		return -EINVAL;
 
 	/* Free mc lists */
@@ -640,7 +640,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 	dst = __sk_dst_check(sk, np->dst_cookie);
 
-	if (dst == NULL) {
+	if (!dst) {
 		struct inet_sock *inet = inet_sk(sk);
 		struct in6_addr *final_p, final;
 		struct flowi6 fl6;
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index a6727ad..ed7d4e3f 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -681,7 +681,7 @@ static int ah6_init_state(struct xfrm_state *x)
 		goto error;
 
 	ahp = kzalloc(sizeof(*ahp), GFP_KERNEL);
-	if (ahp == NULL)
+	if (!ahp)
 		return -ENOMEM;
 
 	ahash = crypto_alloc_ahash(x->aalg->alg_name, 0, 0);
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 9e6b0ee..514ac25 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -70,7 +70,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		return -EINVAL;
 
 	pac = sock_kmalloc(sk, sizeof(struct ipv6_ac_socklist), GFP_KERNEL);
-	if (pac == NULL)
+	if (!pac)
 		return -ENOMEM;
 	pac->acl_next = NULL;
 	pac->acl_addr = *addr;
@@ -93,7 +93,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	} else
 		dev = __dev_get_by_index(net, ifindex);
 
-	if (dev == NULL) {
+	if (!dev) {
 		err = -ENODEV;
 		goto error;
 	}
@@ -222,7 +222,7 @@ static struct ifacaddr6 *aca_alloc(struct rt6_info *rt,
 	struct ifacaddr6 *aca;
 
 	aca = kzalloc(sizeof(*aca), GFP_ATOMIC);
-	if (aca == NULL)
+	if (!aca)
 		return NULL;
 
 	aca->aca_addr = *addr;
@@ -268,7 +268,7 @@ int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
 		goto out;
 	}
 	aca = aca_alloc(rt, addr);
-	if (aca == NULL) {
+	if (!aca) {
 		ip6_rt_put(rt);
 		err = -ENOMEM;
 		goto out;
@@ -337,7 +337,7 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
 
-	if (idev == NULL)
+	if (!idev)
 		return -ENODEV;
 	return __ipv6_dev_ac_dec(idev, addr);
 }
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ace8dac..762a58c 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -71,7 +71,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		fl6.flowlabel = usin->sin6_flowinfo&IPV6_FLOWINFO_MASK;
 		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
+			if (!flowlabel)
 				return -EINVAL;
 		}
 	}
@@ -373,7 +373,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	err = -EAGAIN;
 	skb = sock_dequeue_err_skb(sk);
-	if (skb == NULL)
+	if (!skb)
 		goto out;
 
 	copied = skb->len;
@@ -463,7 +463,7 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len,
 
 	err = -EAGAIN;
 	skb = xchg(&np->rxpmtu, NULL);
-	if (skb == NULL)
+	if (!skb)
 		goto out;
 
 	copied = skb->len;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index e48f2c7..31f1b5d 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -495,7 +495,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	int err;
 
 	err = -EINVAL;
-	if (x->ealg == NULL)
+	if (!x->ealg)
 		goto error;
 
 	err = -ENAMETOOLONG;
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 8af3eb5..5c5d23e 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -82,7 +82,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 		if (nexthdr == NEXTHDR_NONE)
 			return -1;
 		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
-		if (hp == NULL)
+		if (!hp)
 			return -1;
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			__be16 _frag_off, *fp;
@@ -91,7 +91,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 							       frag_off),
 						sizeof(_frag_off),
 						&_frag_off);
-			if (fp == NULL)
+			if (!fp)
 				return -1;
 
 			*frag_offp = *fp;
@@ -218,7 +218,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		}
 
 		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
-		if (hp == NULL)
+		if (!hp)
 			return -EBADMSG;
 
 		if (nexthdr == NEXTHDR_ROUTING) {
@@ -226,7 +226,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 
 			rh = skb_header_pointer(skb, start, sizeof(_rh),
 						&_rh);
-			if (rh == NULL)
+			if (!rh)
 				return -EBADMSG;
 
 			if (flags && (*flags & IP6_FH_F_SKIP_RH) &&
@@ -245,7 +245,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 							       frag_off),
 						sizeof(_frag_off),
 						&_frag_off);
-			if (fp == NULL)
+			if (!fp)
 				return -EBADMSG;
 
 			_frag_off = ntohs(*fp) & ~0x7;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index a5e9519..2c2b5d5 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -160,8 +160,7 @@ static bool is_ineligible(const struct sk_buff *skb)
 		tp = skb_header_pointer(skb,
 			ptr+offsetof(struct icmp6hdr, icmp6_type),
 			sizeof(_type), &_type);
-		if (tp == NULL ||
-		    !(*tp & ICMPV6_INFOMSG_MASK))
+		if (!tp || !(*tp & ICMPV6_INFOMSG_MASK))
 			return true;
 	}
 	return false;
@@ -231,7 +230,7 @@ static bool opt_unrec(struct sk_buff *skb, __u32 offset)
 
 	offset += skb_network_offset(skb);
 	op = skb_header_pointer(skb, offset, sizeof(_optval), &_optval);
-	if (op == NULL)
+	if (!op)
 		return true;
 	return (*op & 0xC0) == 0x80;
 }
@@ -244,7 +243,7 @@ int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	int err = 0;
 
 	skb = skb_peek(&sk->sk_write_queue);
-	if (skb == NULL)
+	if (!skb)
 		goto out;
 
 	icmp6h = icmp6_hdr(skb);
@@ -479,7 +478,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
-	if (sk == NULL)
+	if (!sk)
 		return;
 	sk->sk_mark = mark;
 	np = inet6_sk(sk);
@@ -582,7 +581,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
-	if (sk == NULL)
+	if (!sk)
 		return;
 	sk->sk_mark = mark;
 	np = inet6_sk(sk);
@@ -839,7 +838,7 @@ static int __net_init icmpv6_sk_init(struct net *net)
 
 	net->ipv6.icmp_sk =
 		kzalloc(nr_cpu_ids * sizeof(struct sock *), GFP_KERNEL);
-	if (net->ipv6.icmp_sk == NULL)
+	if (!net->ipv6.icmp_sk)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 4573038..3f54ac5 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -205,7 +205,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 			fl->label = htonl(prandom_u32())&IPV6_FLOWLABEL_MASK;
 			if (fl->label) {
 				lfl = __fl_lookup(net, fl->label);
-				if (lfl == NULL)
+				if (!lfl)
 					break;
 			}
 		}
@@ -297,7 +297,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 {
 	struct ipv6_txoptions *fl_opt = fl->opt;
 
-	if (fopt == NULL || fopt->opt_flen == 0)
+	if (!fopt || fopt->opt_flen == 0)
 		return fl_opt;
 
 	if (fl_opt != NULL) {
@@ -366,7 +366,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 
 	err = -ENOMEM;
 	fl = kzalloc(sizeof(*fl), GFP_KERNEL);
-	if (fl == NULL)
+	if (!fl)
 		goto done;
 
 	if (olen > 0) {
@@ -376,7 +376,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 
 		err = -ENOMEM;
 		fl->opt = kmalloc(sizeof(*fl->opt) + olen, GFP_KERNEL);
-		if (fl->opt == NULL)
+		if (!fl->opt)
 			goto done;
 
 		memset(fl->opt, 0, sizeof(*fl->opt));
@@ -596,7 +596,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 			return -EINVAL;
 
 		fl = fl_create(net, sk, &freq, optval, optlen, &err);
-		if (fl == NULL)
+		if (!fl)
 			return err;
 		sfl1 = kmalloc(sizeof(*sfl1), GFP_KERNEL);
 
@@ -616,7 +616,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 			}
 			rcu_read_unlock_bh();
 
-			if (fl1 == NULL)
+			if (!fl1)
 				fl1 = fl_lookup(net, freq.flr_label);
 			if (fl1) {
 recheck:
@@ -633,7 +633,7 @@ recheck:
 					goto release;
 
 				err = -ENOMEM;
-				if (sfl1 == NULL)
+				if (!sfl1)
 					goto release;
 				if (fl->linger > fl1->linger)
 					fl1->linger = fl->linger;
@@ -653,7 +653,7 @@ release:
 			goto done;
 
 		err = -ENOMEM;
-		if (sfl1 == NULL)
+		if (!sfl1)
 			goto done;
 
 		err = mem_check(sk);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index bc28b7d..aa9ea6e 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -395,7 +395,7 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
 				p[1]);
-	if (t == NULL)
+	if (!t)
 		return;
 
 	switch (type) {
@@ -980,7 +980,7 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 						 &p->raddr, &p->laddr,
 						 p->link, strict);
 
-		if (rt == NULL)
+		if (!rt)
 			return;
 
 		if (rt->dst.dev) {
@@ -1073,7 +1073,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 			}
 			ip6gre_tnl_parm_from_user(&p1, &p);
 			t = ip6gre_tunnel_locate(net, &p1, 0);
-			if (t == NULL)
+			if (!t)
 				t = netdev_priv(dev);
 		}
 		memset(&p, 0, sizeof(p));
@@ -1144,7 +1144,7 @@ static int ip6gre_tunnel_ioctl(struct net_device *dev,
 			err = -ENOENT;
 			ip6gre_tnl_parm_from_user(&p1, &p);
 			t = ip6gre_tunnel_locate(net, &p1, 0);
-			if (t == NULL)
+			if (!t)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(ign->fb_tunnel_dev))
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b06ad00..8b6d402 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -177,7 +177,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
-			if (skb2 == NULL) {
+			if (!skb2) {
 				IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
@@ -823,7 +823,7 @@ static inline int ip6_rt_check(const struct rt6key *rt_key,
 			       const struct in6_addr *addr_cache)
 {
 	return (rt_key->plen != 128 || !ipv6_addr_equal(fl_addr, &rt_key->addr)) &&
-		(addr_cache == NULL || !ipv6_addr_equal(fl_addr, addr_cache));
+		(!addr_cache || !ipv6_addr_equal(fl_addr, addr_cache));
 }
 
 static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
@@ -882,7 +882,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 #endif
 	int err;
 
-	if (*dst == NULL)
+	if (!*dst)
 		*dst = ip6_route_output(net, sk, fl6);
 
 	err = (*dst)->error;
@@ -1045,11 +1045,11 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	 * udp datagram
 	 */
 	skb = skb_peek_tail(queue);
-	if (skb == NULL) {
+	if (!skb) {
 		skb = sock_alloc_send_skb(sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
 			(flags & MSG_DONTWAIT), &err);
-		if (skb == NULL)
+		if (!skb)
 			return err;
 
 		/* reserve space for Hardware header */
@@ -1107,7 +1107,7 @@ static void ip6_append_data_mtu(unsigned int *mtu,
 				unsigned int orig_mtu)
 {
 	if (!(rt->dst.flags & DST_XFRM_TUNNEL)) {
-		if (skb == NULL) {
+		if (!skb) {
 			/* first fragment, reserve header_len */
 			*mtu = orig_mtu - rt->dst.header_len;
 
@@ -1139,7 +1139,7 @@ static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
 			return -EINVAL;
 
 		v6_cork->opt = kzalloc(opt->tot_len, sk->sk_allocation);
-		if (unlikely(v6_cork->opt == NULL))
+		if (unlikely(!v6_cork->opt))
 			return -ENOBUFS;
 
 		v6_cork->opt->tot_len = opt->tot_len;
@@ -1331,7 +1331,7 @@ alloc_new_skb:
 			else
 				fraggap = 0;
 			/* update mtu and maxfraglen if necessary */
-			if (skb == NULL || skb_prev == NULL)
+			if (!skb || !skb_prev)
 				ip6_append_data_mtu(&mtu, &maxfraglen,
 						    fragheaderlen, skb, rt,
 						    orig_mtu);
@@ -1383,10 +1383,10 @@ alloc_new_skb:
 					skb = sock_wmalloc(sk,
 							   alloclen + hh_len, 1,
 							   sk->sk_allocation);
-				if (unlikely(skb == NULL))
+				if (unlikely(!skb))
 					err = -ENOBUFS;
 			}
-			if (skb == NULL)
+			if (!skb)
 				goto error;
 			/*
 			 *	Fill in the control structures
@@ -1578,7 +1578,7 @@ struct sk_buff *__ip6_make_skb(struct sock *sk,
 	unsigned char proto = fl6->flowi6_proto;
 
 	skb = __skb_dequeue(queue);
-	if (skb == NULL)
+	if (!skb)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 41f84f7..6740206 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -131,7 +131,7 @@ struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 	struct dst_entry *dst = t->dst_cache;
 
 	if (dst && dst->obsolete &&
-	    dst->ops->check(dst, t->dst_cookie) == NULL) {
+	    !dst->ops->check(dst, t->dst_cookie)) {
 		t->dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
@@ -325,7 +325,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 
 	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
 			   ip6_tnl_dev_setup);
-	if (dev == NULL)
+	if (!dev)
 		goto failed;
 
 	dev_net_set(dev, net);
@@ -496,7 +496,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 
 	rcu_read_lock();
 	t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->daddr, &ipv6h->saddr);
-	if (t == NULL)
+	if (!t)
 		goto out;
 
 	tproto = ACCESS_ONCE(t->parms.proto);
@@ -1274,7 +1274,7 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 						 &p->raddr, &p->laddr,
 						 p->link, strict);
 
-		if (rt == NULL)
+		if (!rt)
 			return;
 
 		if (rt->dst.dev) {
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5fb9e21..a045d54 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -218,7 +218,7 @@ static struct ip6_tnl *vti6_tnl_create(struct net *net, struct __ip6_tnl_parm *p
 		sprintf(name, "ip6_vti%%d");
 
 	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN, vti6_dev_setup);
-	if (dev == NULL)
+	if (!dev)
 		goto failed;
 
 	dev_net_set(dev, net);
@@ -716,7 +716,7 @@ vti6_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		} else {
 			memset(&p, 0, sizeof(p));
 		}
-		if (t == NULL)
+		if (!t)
 			t = netdev_priv(dev);
 		vti6_parm_to_user(&p, &t->parms);
 		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
@@ -767,7 +767,7 @@ vti6_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = -ENOENT;
 			vti6_parm_from_user(&p1, &p);
 			t = vti6_locate(net, &p1, 0);
-			if (t == NULL)
+			if (!t)
 				break;
 			err = -EPERM;
 			if (t->dev == ip6n->fb_tnl_dev)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4b9315a..ebb0514 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -173,7 +173,7 @@ static int ip6mr_rule_action(struct fib_rule *rule, struct flowi *flp,
 	}
 
 	mrt = ip6mr_get_table(rule->fr_net, rule->table);
-	if (mrt == NULL)
+	if (!mrt)
 		return -EAGAIN;
 	res->mrt = mrt;
 	return 0;
@@ -237,7 +237,7 @@ static int __net_init ip6mr_rules_init(struct net *net)
 	INIT_LIST_HEAD(&net->ipv6.mr6_tables);
 
 	mrt = ip6mr_new_table(net, RT6_TABLE_DFLT);
-	if (mrt == NULL) {
+	if (!mrt) {
 		err = -ENOMEM;
 		goto err1;
 	}
@@ -309,7 +309,7 @@ static struct mr6_table *ip6mr_new_table(struct net *net, u32 id)
 		return mrt;
 
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
-	if (mrt == NULL)
+	if (!mrt)
 		return NULL;
 	mrt->id = id;
 	write_pnet(&mrt->net, net);
@@ -408,7 +408,7 @@ static void *ip6mr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return ERR_PTR(-ENOENT);
 
 	iter->mrt = mrt;
@@ -492,7 +492,7 @@ static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return ERR_PTR(-ENOENT);
 
 	it->mrt = mrt;
@@ -665,7 +665,7 @@ static int pim6_rcv(struct sk_buff *skb)
 		dev_hold(reg_dev);
 	read_unlock(&mrt_lock);
 
-	if (reg_dev == NULL)
+	if (!reg_dev)
 		goto drop;
 
 	skb->mac_header = skb->network_header;
@@ -743,7 +743,7 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 		sprintf(name, "pim6reg%u", mrt->id);
 
 	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
-	if (dev == NULL)
+	if (!dev)
 		return NULL;
 
 	dev_net_set(dev, net);
@@ -1072,7 +1072,7 @@ skip:
 static struct mfc6_cache *ip6mr_cache_alloc(void)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
-	if (c == NULL)
+	if (!c)
 		return NULL;
 	c->mfc_un.res.minvif = MAXMIFS;
 	return c;
@@ -1081,7 +1081,7 @@ static struct mfc6_cache *ip6mr_cache_alloc(void)
 static struct mfc6_cache *ip6mr_cache_alloc_unres(void)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
-	if (c == NULL)
+	if (!c)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10 * HZ;
@@ -1198,7 +1198,7 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	if (mrt->mroute6_sk == NULL) {
+	if (!mrt->mroute6_sk) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -1493,7 +1493,7 @@ static int ip6mr_mfc_add(struct net *net, struct mr6_table *mrt,
 		return -EINVAL;
 
 	c = ip6mr_cache_alloc();
-	if (c == NULL)
+	if (!c)
 		return -ENOMEM;
 
 	c->mf6c_origin = mfc->mf6cc_origin.sin6_addr;
@@ -1663,7 +1663,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	if (optname != MRT6_INIT) {
@@ -1812,7 +1812,7 @@ int ip6_mroute_getsockopt(struct sock *sk, int optname, char __user *optval,
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	switch (optname) {
@@ -1859,7 +1859,7 @@ int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	switch (cmd) {
@@ -1933,7 +1933,7 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 	struct mr6_table *mrt;
 
 	mrt = ip6mr_get_table(net, raw6_sk(sk)->ip6mr_table ? : RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	switch (cmd) {
@@ -2003,7 +2003,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 
-	if (vif->dev == NULL)
+	if (!vif->dev)
 		goto out_free;
 
 #ifdef CONFIG_IPV6_PIMSM_V2
@@ -2192,7 +2192,7 @@ int ip6_mr_input(struct sk_buff *skb)
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt,
 				 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr);
-	if (cache == NULL) {
+	if (!cache) {
 		int vif = ip6mr_find_vif(mrt, skb->dev);
 
 		if (vif >= 0)
@@ -2204,7 +2204,7 @@ int ip6_mr_input(struct sk_buff *skb)
 	/*
 	 *	No usable cache entry
 	 */
-	if (cache == NULL) {
+	if (!cache) {
 		int vif;
 
 		vif = ip6mr_find_vif(mrt, skb->dev);
@@ -2243,13 +2243,13 @@ static int __ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	    nla_put_u32(skb, RTA_IIF, mrt->vif6_table[c->mf6c_parent].dev->ifindex) < 0)
 		return -EMSGSIZE;
 	mp_attr = nla_nest_start(skb, RTA_MULTIPATH);
-	if (mp_attr == NULL)
+	if (!mp_attr)
 		return -EMSGSIZE;
 
 	for (ct = c->mfc_un.res.minvif; ct < c->mfc_un.res.maxvif; ct++) {
 		if (MIF_EXISTS(mrt, ct) && c->mfc_un.res.ttls[ct] < 255) {
 			nhp = nla_reserve_nohdr(skb, sizeof(*nhp));
-			if (nhp == NULL) {
+			if (!nhp) {
 				nla_nest_cancel(skb, mp_attr);
 				return -EMSGSIZE;
 			}
@@ -2282,7 +2282,7 @@ int ip6mr_get_route(struct net *net,
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 
 	mrt = ip6mr_get_table(net, RT6_TABLE_DFLT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	read_lock(&mrt_lock);
@@ -2307,7 +2307,7 @@ int ip6mr_get_route(struct net *net,
 		}
 
 		dev = skb->dev;
-		if (dev == NULL || (vif = ip6mr_find_vif(mrt, dev)) < 0) {
+		if (!dev || (vif = ip6mr_find_vif(mrt, dev)) < 0) {
 			read_unlock(&mrt_lock);
 			return -ENODEV;
 		}
@@ -2359,7 +2359,7 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	int err;
 
 	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
@@ -2424,7 +2424,7 @@ static void mr6_netlink_event(struct mr6_table *mrt, struct mfc6_cache *mfc,
 
 	skb = nlmsg_new(mr6_msgsize(mfc->mf6c_parent >= MAXMIFS, mrt->maxvif),
 			GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = ip6mr_fill_mroute(mrt, skb, 0, 0, mfc, cmd, 0);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9b2cb14..63e6956 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -85,7 +85,7 @@ int ip6_ra_control(struct sock *sk, int sel)
 			return 0;
 		}
 	}
-	if (new_ra == NULL) {
+	if (!new_ra) {
 		write_unlock_bh(&ip6_ra_lock);
 		return -ENOBUFS;
 	}
@@ -145,7 +145,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	int retv = -ENOPROTOOPT;
 	bool needs_rtnl = setsockopt_needs_rtnl(optname);
 
-	if (optval == NULL)
+	if (!optval)
 		val = 0;
 	else {
 		if (optlen >= sizeof(int)) {
@@ -392,7 +392,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		 */
 		if (optlen == 0)
 			optval = NULL;
-		else if (optval == NULL)
+		else if (!optval)
 			goto e_inval;
 		else if (optlen < sizeof(struct ipv6_opt_hdr) ||
 			 optlen & 0x7 || optlen > 8 * 255)
@@ -443,7 +443,7 @@ sticky_done:
 
 		if (optlen == 0)
 			goto e_inval;
-		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
+		else if (optlen < sizeof(struct in6_pktinfo) || !optval)
 			goto e_inval;
 
 		if (copy_from_user(&pkt, optval, sizeof(struct in6_pktinfo))) {
@@ -482,7 +482,7 @@ sticky_done:
 
 		opt = sock_kmalloc(sk, sizeof(*opt) + optlen, GFP_KERNEL);
 		retv = -ENOBUFS;
-		if (opt == NULL)
+		if (!opt)
 			break;
 
 		memset(opt, 0, sizeof(*opt));
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index cbb66fd..3017c4a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -157,7 +157,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	mc_lst = sock_kmalloc(sk, sizeof(struct ipv6_mc_socklist), GFP_KERNEL);
 
-	if (mc_lst == NULL)
+	if (!mc_lst)
 		return -ENOMEM;
 
 	mc_lst->next = NULL;
@@ -173,7 +173,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	} else
 		dev = __dev_get_by_index(net, ifindex);
 
-	if (dev == NULL) {
+	if (!dev) {
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return -ENODEV;
 	}
@@ -823,7 +823,7 @@ static struct ifmcaddr6 *mca_alloc(struct inet6_dev *idev,
 	struct ifmcaddr6 *mc;
 
 	mc = kzalloc(sizeof(*mc), GFP_ATOMIC);
-	if (mc == NULL)
+	if (!mc)
 		return NULL;
 
 	setup_timer(&mc->mca_timer, igmp6_timer_handler, (unsigned long)mc);
@@ -860,7 +860,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 	/* we need to take a reference on idev */
 	idev = in6_dev_get(dev);
 
-	if (idev == NULL)
+	if (!idev)
 		return -EINVAL;
 
 	write_lock_bh(&idev->lock);
@@ -1328,7 +1328,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-	if (idev == NULL)
+	if (!idev)
 		return 0;
 
 	mld = (struct mld_msg *)icmp6_hdr(skb);
@@ -1443,7 +1443,7 @@ int igmp6_event_report(struct sk_buff *skb)
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-	if (idev == NULL)
+	if (!idev)
 		return -ENODEV;
 
 	/*
@@ -1962,7 +1962,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	skb = sock_alloc_send_skb(sk, hlen + tlen + full_len, 1, &err);
 
-	if (skb == NULL) {
+	if (!skb) {
 		rcu_read_lock();
 		IP6_INC_STATS(net, __in6_dev_get(dev),
 			      IPSTATS_MIB_OUTDISCARDS);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 247ad7c..482dfb9 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -311,7 +311,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 	bool is_multicast = ipv6_addr_is_multicast(addr);
 
 	in6_dev = in6_dev_get(dev);
-	if (in6_dev == NULL) {
+	if (!in6_dev) {
 		return -EINVAL;
 	}
 
@@ -356,7 +356,7 @@ static int pndisc_constructor(struct pneigh_entry *n)
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
-	if (dev == NULL || __in6_dev_get(dev) == NULL)
+	if (!dev || !__in6_dev_get(dev))
 		return -EINVAL;
 	addrconf_addr_solict_mult(addr, &maddr);
 	ipv6_dev_mc_inc(dev, &maddr);
@@ -369,7 +369,7 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
-	if (dev == NULL || __in6_dev_get(dev) == NULL)
+	if (!dev || !__in6_dev_get(dev))
 		return;
 	addrconf_addr_solict_mult(addr, &maddr);
 	ipv6_dev_mc_dec(dev, &maddr);
@@ -560,7 +560,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	int optlen = 0;
 	struct nd_msg *msg;
 
-	if (saddr == NULL) {
+	if (!saddr) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
 				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
@@ -1030,13 +1030,13 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 	size_t msg_size = base_size + nla_total_size(sizeof(struct in6_addr));
 
 	skb = nlmsg_new(msg_size, GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		err = -ENOBUFS;
 		goto errout;
 	}
 
 	nlh = nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, base_size, 0);
-	if (nlh == NULL) {
+	if (!nlh) {
 		goto nla_put_failure;
 	}
 
@@ -1104,7 +1104,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	 */
 
 	in6_dev = __in6_dev_get(skb->dev);
-	if (in6_dev == NULL) {
+	if (!in6_dev) {
 		ND_PRINTK(0, err, "RA: can't find inet6 device for %s\n",
 			  skb->dev->name);
 		return;
@@ -1199,11 +1199,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	ND_PRINTK(3, info, "RA: rt: %p  lifetime: %d, for dev: %s\n",
 		  rt, lifetime, skb->dev->name);
-	if (rt == NULL && lifetime) {
+	if (!rt && lifetime) {
 		ND_PRINTK(3, info, "RA: adding default router\n");
 
 		rt = rt6_add_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev, pref);
-		if (rt == NULL) {
+		if (!rt) {
 			ND_PRINTK(0, err,
 				  "RA: %s failed to add default route\n",
 				  __func__);
@@ -1211,7 +1211,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		}
 
 		neigh = dst_neigh_lookup(&rt->dst, &ipv6_hdr(skb)->saddr);
-		if (neigh == NULL) {
+		if (!neigh) {
 			ND_PRINTK(0, err,
 				  "RA: %s got default router without neighbour\n",
 				  __func__);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a5287b3..e33576d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -172,7 +172,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 
-	if (sk == NULL)
+	if (!sk)
 		goto out;
 
 	net = dev_net(skb->dev);
@@ -630,7 +630,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	skb = sock_alloc_send_skb(sk,
 				  length + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
-	if (skb == NULL)
+	if (!skb)
 		goto error;
 	skb_reserve(skb, hlen);
 
@@ -789,7 +789,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
 			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-				if (flowlabel == NULL)
+				if (!flowlabel)
 					return -EINVAL;
 			}
 		}
@@ -831,13 +831,13 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		}
 		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
+			if (!flowlabel)
 				return -EINVAL;
 		}
 		if (!(opt->opt_nflen|opt->opt_flen))
 			opt = NULL;
 	}
-	if (opt == NULL)
+	if (!opt)
 		opt = np->opt;
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index d7d70e6..24fbc0a 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -430,7 +430,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 		int i, plen = 0;
 
 		clone = alloc_skb(0, GFP_ATOMIC);
-		if (clone == NULL)
+		if (!clone)
 			goto out_oom;
 		clone->next = head->next;
 		head->next = clone;
@@ -632,7 +632,7 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 	table = ip6_frags_ns_ctl_table;
 	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(ip6_frags_ns_ctl_table), GFP_KERNEL);
-		if (table == NULL)
+		if (!table)
 			goto err_alloc;
 
 		table[0].data = &net->ipv6.frags.high_thresh;
@@ -648,7 +648,7 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 	}
 
 	hdr = register_net_sysctl(net, "net/ipv6", table);
-	if (hdr == NULL)
+	if (!hdr)
 		goto err_reg;
 
 	net->ipv6.sysctl.frags_hdr = hdr;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 58c0e6a..fe742fa 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1476,7 +1476,7 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 	int remaining;
 	u32 *mp;
 
-	if (cfg->fc_mx == NULL)
+	if (!cfg->fc_mx)
 		return 0;
 
 	mp = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e4cbd57..c61ed24 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -251,7 +251,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 
 	dev = alloc_netdev(sizeof(*t), name, NET_NAME_UNKNOWN,
 			   ipip6_tunnel_setup);
-	if (dev == NULL)
+	if (!dev)
 		return NULL;
 
 	dev_net_set(dev, net);
@@ -555,7 +555,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 				skb->dev,
 				iph->daddr,
 				iph->saddr);
-	if (t == NULL)
+	if (!t)
 		goto out;
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
@@ -838,7 +838,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		if (skb_dst(skb))
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
-		if (neigh == NULL) {
+		if (!neigh) {
 			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
@@ -867,7 +867,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		if (skb_dst(skb))
 			neigh = dst_neigh_lookup(skb_dst(skb), &iph6->daddr);
 
-		if (neigh == NULL) {
+		if (!neigh) {
 			net_dbg_ratelimited("nexthop == NULL\n");
 			goto tx_error;
 		}
@@ -1158,7 +1158,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				break;
 			}
 			t = ipip6_tunnel_locate(net, &p, 0);
-			if (t == NULL)
+			if (!t)
 				t = netdev_priv(dev);
 		}
 
@@ -1242,7 +1242,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				goto done;
 			err = -ENOENT;
 			t = ipip6_tunnel_locate(net, &p, 0);
-			if (t == NULL)
+			if (!t)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(sitn->fb_tunnel_dev))
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 30f5a4a..abcc79f 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -179,7 +179,7 @@ int ipv6_sysctl_register(void)
 	int err = -ENOMEM;
 
 	ip6_header = register_net_sysctl(&init_net, "net/ipv6", ipv6_rotable);
-	if (ip6_header == NULL)
+	if (!ip6_header)
 		goto out;
 
 	err = register_pernet_subsys(&ipv6_sysctl_net_ops);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index cbdf691..a8a74d3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -141,7 +141,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 			struct ip6_flowlabel *flowlabel;
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
+			if (!flowlabel)
 				return -EINVAL;
 			fl6_sock_release(flowlabel);
 		}
@@ -247,7 +247,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		goto failure;
 	}
 
-	if (saddr == NULL) {
+	if (!saddr) {
 		saddr = &fl6.saddr;
 		sk->sk_v6_rcv_saddr = *saddr;
 	}
@@ -412,7 +412,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		/* Only in fast or simultaneous open. If a fast open socket is
 		 * is already accepted it is treated as a connected one below.
 		 */
-		if (fastopen && fastopen->sk == NULL)
+		if (fastopen && !fastopen->sk)
 			break;
 
 		if (!sock_owned_by_user(sk)) {
@@ -750,7 +750,7 @@ static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb, u32 seq,
 
 	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
 			 GFP_ATOMIC);
-	if (buff == NULL)
+	if (!buff)
 		return;
 
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
@@ -1008,7 +1008,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		newsk = tcp_v4_syn_recv_sock(sk, skb, req, dst);
 
-		if (newsk == NULL)
+		if (!newsk)
 			return NULL;
 
 		newtcp6sk = (struct tcp6_sock *)newsk;
@@ -1065,7 +1065,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 
 	newsk = tcp_create_openreq_child(sk, req, skb);
-	if (newsk == NULL)
+	if (!newsk)
 		goto out_nonewsk;
 
 	/*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7fe0329..58efd2c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -550,7 +550,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	sk = __udp6_lib_lookup(net, daddr, uh->dest,
 			       saddr, uh->source, inet6_iif(skb), udptable);
-	if (sk == NULL) {
+	if (!sk) {
 		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
 				   ICMP6_MIB_INERRORS);
 		return;
@@ -749,7 +749,7 @@ static void flush_stack(struct sock **stack, unsigned int count,
 
 	for (i = 0; i < count; i++) {
 		sk = stack[i];
-		if (likely(skb1 == NULL))
+		if (likely(!skb1))
 			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 		if (!skb1) {
 			atomic_inc(&sk->sk_drops);
@@ -1207,7 +1207,7 @@ do_udp_sendmsg:
 			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
 			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-				if (flowlabel == NULL)
+				if (!flowlabel)
 					return -EINVAL;
 			}
 		}
@@ -1255,14 +1255,14 @@ do_udp_sendmsg:
 		}
 		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
+			if (!flowlabel)
 				return -EINVAL;
 		}
 		if (!(opt->opt_nflen|opt->opt_flen))
 			opt = NULL;
 		connected = 0;
 	}
-	if (opt == NULL)
+	if (!opt)
 		opt = np->opt;
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 11dbcc1..91d934c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -370,7 +370,7 @@ static void __net_exit xfrm6_net_exit(struct net *net)
 {
 	struct ctl_table *table;
 
-	if (net->ipv6.sysctl.xfrm6_hdr == NULL)
+	if (!net->ipv6.sysctl.xfrm6_hdr)
 		return;
 
 	table = net->ipv6.sysctl.xfrm6_hdr->ctl_table_arg;
-- 
1.9.1
