From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 1/2] ipv4: coding style: comparison for equality with NULL
Date: Fri,  3 Apr 2015 09:17:26 +0100
Message-ID: <1428049047-14783-2-git-send-email-ipm@chirality.org.uk>
References: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:48371 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752632AbbDCIRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 04:17:39 -0400
In-Reply-To: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv4 code uses a mixture of coding styles. In some instances check
for NULL pointer is done as x == NULL and sometimes as !x. !x is
preferred according to checkpatch and this patch makes the code
consistent by adopting the latter form.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv4/af_inet.c         |  6 +++---
 net/ipv4/arp.c             | 26 ++++++++++++-------------
 net/ipv4/cipso_ipv4.c      | 36 +++++++++++++++++-----------------
 net/ipv4/devinet.c         | 40 +++++++++++++++++++-------------------
 net/ipv4/esp4.c            |  2 +-
 net/ipv4/fib_frontend.c    | 26 ++++++++++++-------------
 net/ipv4/fib_rules.c       |  4 ++--
 net/ipv4/fib_semantics.c   | 24 +++++++++++------------
 net/ipv4/fib_trie.c        | 12 ++++++------
 net/ipv4/geneve.c          |  2 +-
 net/ipv4/gre_offload.c     |  2 +-
 net/ipv4/icmp.c            |  6 +++---
 net/ipv4/igmp.c            | 12 ++++++------
 net/ipv4/inet_fragment.c   |  4 ++--
 net/ipv4/ip_fragment.c     | 11 ++++++-----
 net/ipv4/ip_gre.c          |  4 ++--
 net/ipv4/ip_input.c        |  5 +++--
 net/ipv4/ip_output.c       | 23 ++++++++++++----------
 net/ipv4/ip_sockglue.c     |  4 ++--
 net/ipv4/ip_tunnel.c       |  8 ++++----
 net/ipv4/ipcomp.c          |  2 +-
 net/ipv4/ipconfig.c        |  6 ++++--
 net/ipv4/ipip.c            |  2 +-
 net/ipv4/ipmr.c            | 48 +++++++++++++++++++++++-----------------------
 net/ipv4/ping.c            |  2 +-
 net/ipv4/raw.c             |  2 +-
 net/ipv4/route.c           | 20 +++++++++----------
 net/ipv4/sysctl_net_ipv4.c |  6 +++---
 net/ipv4/tcp.c             |  2 +-
 net/ipv4/tcp_fastopen.c    |  6 +++---
 net/ipv4/tcp_input.c       | 16 ++++++++--------
 net/ipv4/tcp_ipv4.c        |  6 +++---
 net/ipv4/tcp_metrics.c     |  2 +-
 net/ipv4/tcp_minisocks.c   |  2 +-
 net/ipv4/tcp_output.c      | 21 ++++++++++----------
 net/ipv4/udp.c             |  6 +++---
 net/ipv4/udp_diag.c        |  2 +-
 net/ipv4/xfrm4_input.c     |  2 +-
 net/ipv4/xfrm4_policy.c    |  2 +-
 39 files changed, 210 insertions(+), 202 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 64a9c0f..7d3b00c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -217,7 +217,7 @@ int inet_listen(struct socket *sock, int backlog)
 		 * shutdown() (rather than close()).
 		 */
 		if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
-		    inet_csk(sk)->icsk_accept_queue.fastopenq == NULL) {
+		    !inet_csk(sk)->icsk_accept_queue.fastopenq) {
 			if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) != 0)
 				err = fastopen_init_queue(sk, backlog);
 			else if ((sysctl_tcp_fastopen &
@@ -314,11 +314,11 @@ lookup_protocol:
 	answer_flags = answer->flags;
 	rcu_read_unlock();
 
-	WARN_ON(answer_prot->slab == NULL);
+	WARN_ON(!answer_prot->slab);
 
 	err = -ENOBUFS;
 	sk = sk_alloc(net, PF_INET, GFP_KERNEL, answer_prot);
-	if (sk == NULL)
+	if (!sk)
 		goto out;
 
 	err = 0;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 5f5c674..ffe8422 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -228,7 +228,7 @@ static int arp_constructor(struct neighbour *neigh)
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
-	if (in_dev == NULL) {
+	if (!in_dev) {
 		rcu_read_unlock();
 		return -EINVAL;
 	}
@@ -475,7 +475,7 @@ static inline int arp_fwd_pvlan(struct in_device *in_dev,
  */
 
 /*
- *	Create an arp packet. If (dest_hw == NULL), we create a broadcast
+ *	Create an arp packet. If dest_hw is not set, we create a broadcast
  *	message.
  */
 struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
@@ -495,7 +495,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	 */
 
 	skb = alloc_skb(arp_hdr_len(dev) + hlen + tlen, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return NULL;
 
 	skb_reserve(skb, hlen);
@@ -503,9 +503,9 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_ARP);
-	if (src_hw == NULL)
+	if (!src_hw)
 		src_hw = dev->dev_addr;
-	if (dest_hw == NULL)
+	if (!dest_hw)
 		dest_hw = dev->broadcast;
 
 	/*
@@ -614,7 +614,7 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 
 	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
 			 dest_hw, src_hw, target_hw);
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 	arp_xmit(skb);
@@ -644,7 +644,7 @@ static int arp_process(struct sk_buff *skb)
 	 * is ARP'able.
 	 */
 
-	if (in_dev == NULL)
+	if (!in_dev)
 		goto out;
 
 	arp = arp_hdr(skb);
@@ -808,7 +808,7 @@ static int arp_process(struct sk_buff *skb)
 		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
 			  inet_addr_type(net, sip) == RTN_UNICAST;
 
-		if (n == NULL &&
+		if (!n &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
 		      inet_addr_type(net, sip) == RTN_UNICAST) || is_garp))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
@@ -900,7 +900,7 @@ out_of_mem:
 
 static int arp_req_set_proxy(struct net *net, struct net_device *dev, int on)
 {
-	if (dev == NULL) {
+	if (!dev) {
 		IPV4_DEVCONF_ALL(net, PROXY_ARP) = on;
 		return 0;
 	}
@@ -926,7 +926,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 			return -ENODEV;
 	}
 	if (mask) {
-		if (pneigh_lookup(&arp_tbl, net, &ip, dev, 1) == NULL)
+		if (!pneigh_lookup(&arp_tbl, net, &ip, dev, 1))
 			return -ENOBUFS;
 		return 0;
 	}
@@ -947,7 +947,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
-	if (dev == NULL) {
+	if (!dev) {
 		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
 
 		if (IS_ERR(rt))
@@ -1067,7 +1067,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 		return arp_req_delete_public(net, r, dev);
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
-	if (dev == NULL) {
+	if (!dev) {
 		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
@@ -1116,7 +1116,7 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	if (r.arp_dev[0]) {
 		err = -ENODEV;
 		dev = __dev_get_by_name(net, r.arp_dev);
-		if (dev == NULL)
+		if (!dev)
 			goto out;
 
 		/* Mmmm... It is wrong... ARPHRD_NETROM==0 */
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index e361ea6..1b28e11 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -255,7 +255,7 @@ static int __init cipso_v4_cache_init(void)
 	cipso_v4_cache = kcalloc(CIPSO_V4_CACHE_BUCKETS,
 				 sizeof(struct cipso_v4_map_cache_bkt),
 				 GFP_KERNEL);
-	if (cipso_v4_cache == NULL)
+	if (!cipso_v4_cache)
 		return -ENOMEM;
 
 	for (iter = 0; iter < CIPSO_V4_CACHE_BUCKETS; iter++) {
@@ -339,7 +339,7 @@ static int cipso_v4_cache_check(const unsigned char *key,
 			secattr->cache = entry->lsm_data;
 			secattr->flags |= NETLBL_SECATTR_CACHE;
 			secattr->type = NETLBL_NLTYPE_CIPSOV4;
-			if (prev_entry == NULL) {
+			if (!prev_entry) {
 				spin_unlock_bh(&cipso_v4_cache[bkt].lock);
 				return 0;
 			}
@@ -393,10 +393,10 @@ int cipso_v4_cache_add(const unsigned char *cipso_ptr,
 	cipso_ptr_len = cipso_ptr[1];
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
-	if (entry == NULL)
+	if (!entry)
 		return -ENOMEM;
 	entry->key = kmemdup(cipso_ptr, cipso_ptr_len, GFP_ATOMIC);
-	if (entry->key == NULL) {
+	if (!entry->key) {
 		ret_val = -ENOMEM;
 		goto cache_add_failure;
 	}
@@ -547,7 +547,7 @@ doi_add_return:
  */
 void cipso_v4_doi_free(struct cipso_v4_doi *doi_def)
 {
-	if (doi_def == NULL)
+	if (!doi_def)
 		return;
 
 	switch (doi_def->type) {
@@ -598,7 +598,7 @@ int cipso_v4_doi_remove(u32 doi, struct netlbl_audit *audit_info)
 
 	spin_lock(&cipso_v4_doi_list_lock);
 	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def == NULL) {
+	if (!doi_def) {
 		spin_unlock(&cipso_v4_doi_list_lock);
 		ret_val = -ENOENT;
 		goto doi_remove_return;
@@ -644,7 +644,7 @@ struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi)
 
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def == NULL)
+	if (!doi_def)
 		goto doi_getdef_return;
 	if (!atomic_inc_not_zero(&doi_def->refcount))
 		doi_def = NULL;
@@ -664,7 +664,7 @@ doi_getdef_return:
  */
 void cipso_v4_doi_putdef(struct cipso_v4_doi *doi_def)
 {
-	if (doi_def == NULL)
+	if (!doi_def)
 		return;
 
 	if (!atomic_dec_and_test(&doi_def->refcount))
@@ -1642,7 +1642,7 @@ int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option)
 
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(get_unaligned_be32(&opt[2]));
-	if (doi_def == NULL) {
+	if (!doi_def) {
 		err_offset = 2;
 		goto validate_return_locked;
 	}
@@ -1736,7 +1736,7 @@ int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option)
 			 * not the loopback device drop the packet. Further,
 			 * there is no legitimate reason for setting this from
 			 * userspace so reject it if skb is NULL. */
-			if (skb == NULL || !(skb->dev->flags & IFF_LOOPBACK)) {
+			if (!skb || !(skb->dev->flags & IFF_LOOPBACK)) {
 				err_offset = opt_iter;
 				goto validate_return_locked;
 			}
@@ -1897,7 +1897,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	 * defined yet but it is not a problem as the only users of these
 	 * "lite" PF_INET sockets are functions which do an accept() call
 	 * afterwards so we will label the socket as part of the accept(). */
-	if (sk == NULL)
+	if (!sk)
 		return 0;
 
 	/* We allocate the maximum CIPSO option size here so we are probably
@@ -1905,7 +1905,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	 * on and after all we are only talking about 40 bytes. */
 	buf_len = CIPSO_V4_OPT_LEN_MAX;
 	buf = kmalloc(buf_len, GFP_ATOMIC);
-	if (buf == NULL) {
+	if (!buf) {
 		ret_val = -ENOMEM;
 		goto socket_setattr_failure;
 	}
@@ -1921,7 +1921,7 @@ int cipso_v4_sock_setattr(struct sock *sk,
 	 * set the IPOPT_CIPSO option. */
 	opt_len = (buf_len + 3) & ~3;
 	opt = kzalloc(sizeof(*opt) + opt_len, GFP_ATOMIC);
-	if (opt == NULL) {
+	if (!opt) {
 		ret_val = -ENOMEM;
 		goto socket_setattr_failure;
 	}
@@ -1981,7 +1981,7 @@ int cipso_v4_req_setattr(struct request_sock *req,
 	 * on and after all we are only talking about 40 bytes. */
 	buf_len = CIPSO_V4_OPT_LEN_MAX;
 	buf = kmalloc(buf_len, GFP_ATOMIC);
-	if (buf == NULL) {
+	if (!buf) {
 		ret_val = -ENOMEM;
 		goto req_setattr_failure;
 	}
@@ -1997,7 +1997,7 @@ int cipso_v4_req_setattr(struct request_sock *req,
 	 * set the IPOPT_CIPSO option. */
 	opt_len = (buf_len + 3) & ~3;
 	opt = kzalloc(sizeof(*opt) + opt_len, GFP_ATOMIC);
-	if (opt == NULL) {
+	if (!opt) {
 		ret_val = -ENOMEM;
 		goto req_setattr_failure;
 	}
@@ -2102,7 +2102,7 @@ void cipso_v4_sock_delattr(struct sock *sk)
 
 	sk_inet = inet_sk(sk);
 	opt = rcu_dereference_protected(sk_inet->inet_opt, 1);
-	if (opt == NULL || opt->opt.cipso == 0)
+	if (!opt || opt->opt.cipso == 0)
 		return;
 
 	hdr_delta = cipso_v4_delopt(&sk_inet->inet_opt);
@@ -2128,7 +2128,7 @@ void cipso_v4_req_delattr(struct request_sock *req)
 
 	req_inet = inet_rsk(req);
 	opt = req_inet->opt;
-	if (opt == NULL || opt->opt.cipso == 0)
+	if (!opt || opt->opt.cipso == 0)
 		return;
 
 	cipso_v4_delopt(&req_inet->opt);
@@ -2157,7 +2157,7 @@ int cipso_v4_getattr(const unsigned char *cipso,
 	doi = get_unaligned_be32(&cipso[2]);
 	rcu_read_lock();
 	doi_def = cipso_v4_doi_search(doi);
-	if (doi_def == NULL)
+	if (!doi_def)
 		goto getattr_return;
 	/* XXX - This code assumes only one tag per CIPSO option which isn't
 	 * really a good assumption to make but since we only support the MAC
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c6473f3..0ee2168 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -585,7 +585,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ifm = nlmsg_data(nlh);
 	in_dev = inetdev_by_index(net, ifm->ifa_index);
-	if (in_dev == NULL) {
+	if (!in_dev) {
 		err = -ENODEV;
 		goto errout;
 	}
@@ -755,21 +755,21 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 
 	ifm = nlmsg_data(nlh);
 	err = -EINVAL;
-	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
+	if (ifm->ifa_prefixlen > 32 || !tb[IFA_LOCAL])
 		goto errout;
 
 	dev = __dev_get_by_index(net, ifm->ifa_index);
 	err = -ENODEV;
-	if (dev == NULL)
+	if (!dev)
 		goto errout;
 
 	in_dev = __in_dev_get_rtnl(dev);
 	err = -ENOBUFS;
-	if (in_dev == NULL)
+	if (!in_dev)
 		goto errout;
 
 	ifa = inet_alloc_ifa();
-	if (ifa == NULL)
+	if (!ifa)
 		/*
 		 * A potential indev allocation can be left alive, it stays
 		 * assigned to its device and is destroy with it.
@@ -780,7 +780,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	neigh_parms_data_state_setall(in_dev->arp_parms);
 	in_dev_hold(in_dev);
 
-	if (tb[IFA_ADDRESS] == NULL)
+	if (!tb[IFA_ADDRESS])
 		tb[IFA_ADDRESS] = tb[IFA_LOCAL];
 
 	INIT_HLIST_NODE(&ifa->hash);
@@ -1340,7 +1340,7 @@ static void inetdev_changename(struct net_device *dev, struct in_device *in_dev)
 		if (named++ == 0)
 			goto skip;
 		dot = strchr(old, ':');
-		if (dot == NULL) {
+		if (!dot) {
 			sprintf(old, ":%d", named);
 			dot = old;
 		}
@@ -1509,7 +1509,7 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 	u32 preferred, valid;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*ifm), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	ifm = nlmsg_data(nlh);
@@ -1628,7 +1628,7 @@ static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 
 	net = dev_net(ifa->ifa_dev->dev);
 	skb = nlmsg_new(inet_nlmsg_size(), GFP_KERNEL);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet_fill_ifaddr(skb, ifa, portid, seq, event, 0);
@@ -1665,7 +1665,7 @@ static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
 		return -ENODATA;
 
 	nla = nla_reserve(skb, IFLA_INET_CONF, IPV4_DEVCONF_MAX * 4);
-	if (nla == NULL)
+	if (!nla)
 		return -EMSGSIZE;
 
 	for (i = 0; i < IPV4_DEVCONF_MAX; i++)
@@ -1754,7 +1754,7 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
 			flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	ncm = nlmsg_data(nlh);
@@ -1796,7 +1796,7 @@ void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet_netconf_msgsize_devconf(type), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
@@ -1853,10 +1853,10 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 		break;
 	default:
 		dev = __dev_get_by_index(net, ifindex);
-		if (dev == NULL)
+		if (!dev)
 			goto errout;
 		in_dev = __in_dev_get_rtnl(dev);
-		if (in_dev == NULL)
+		if (!in_dev)
 			goto errout;
 		devconf = &in_dev->cnf;
 		break;
@@ -1864,7 +1864,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 
 	err = -ENOBUFS;
 	skb = nlmsg_new(inet_netconf_msgsize_devconf(-1), GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf,
@@ -2215,7 +2215,7 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 {
 	struct devinet_sysctl_table *t = cnf->sysctl;
 
-	if (t == NULL)
+	if (!t)
 		return;
 
 	cnf->sysctl = NULL;
@@ -2276,16 +2276,16 @@ static __net_init int devinet_init_net(struct net *net)
 
 	if (!net_eq(net, &init_net)) {
 		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
-		if (all == NULL)
+		if (!all)
 			goto err_alloc_all;
 
 		dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
-		if (dflt == NULL)
+		if (!dflt)
 			goto err_alloc_dflt;
 
 #ifdef CONFIG_SYSCTL
 		tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
-		if (tbl == NULL)
+		if (!tbl)
 			goto err_alloc_ctl;
 
 		tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
@@ -2305,7 +2305,7 @@ static __net_init int devinet_init_net(struct net *net)
 
 	err = -ENOMEM;
 	forw_hdr = register_net_sysctl(net, "net/ipv4", tbl);
-	if (forw_hdr == NULL)
+	if (!forw_hdr)
 		goto err_reg_ctl;
 	net->ipv4.forw_hdr = forw_hdr;
 #endif
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 60173d4..421a80b 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -553,7 +553,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	int err;
 
 	err = -EINVAL;
-	if (x->ealg == NULL)
+	if (!x->ealg)
 		goto error;
 
 	err = -ENAMETOOLONG;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 718b0a1..2166d2b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -53,11 +53,11 @@ static int __net_init fib4_rules_init(struct net *net)
 	struct fib_table *local_table, *main_table;
 
 	main_table  = fib_trie_table(RT_TABLE_MAIN, NULL);
-	if (main_table == NULL)
+	if (!main_table)
 		return -ENOMEM;
 
 	local_table = fib_trie_table(RT_TABLE_LOCAL, main_table);
-	if (local_table == NULL)
+	if (!local_table)
 		goto fail;
 
 	hlist_add_head_rcu(&local_table->tb_hlist,
@@ -486,7 +486,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 			for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next)
 				if (strcmp(ifa->ifa_label, devname) == 0)
 					break;
-			if (ifa == NULL)
+			if (!ifa)
 				return -ENODEV;
 			cfg->fc_prefsrc = ifa->ifa_local;
 		}
@@ -514,7 +514,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 		int len = 0;
 
 		mx = kzalloc(3 * nla_total_size(4), GFP_KERNEL);
-		if (mx == NULL)
+		if (!mx)
 			return -ENOMEM;
 
 		if (rt->rt_flags & RTF_MTU)
@@ -676,7 +676,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 
 	tb = fib_get_table(net, cfg.fc_table);
-	if (tb == NULL) {
+	if (!tb) {
 		err = -ESRCH;
 		goto errout;
 	}
@@ -698,7 +698,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 
 	tb = fib_new_table(net, cfg.fc_table);
-	if (tb == NULL) {
+	if (!tb) {
 		err = -ENOBUFS;
 		goto errout;
 	}
@@ -779,7 +779,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 	else
 		tb = fib_new_table(net, RT_TABLE_LOCAL);
 
-	if (tb == NULL)
+	if (!tb)
 		return;
 
 	cfg.fc_table = tb->tb_id;
@@ -806,7 +806,7 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 
 	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, prefix, mask);
-		if (prim == NULL) {
+		if (!prim) {
 			pr_warn("%s: bug: prim == NULL\n", __func__);
 			return;
 		}
@@ -860,7 +860,7 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 
 	if (ifa->ifa_flags & IFA_F_SECONDARY) {
 		prim = inet_ifa_byprefix(in_dev, any, ifa->ifa_mask);
-		if (prim == NULL) {
+		if (!prim) {
 			pr_warn("%s: bug: prim == NULL\n", __func__);
 			return;
 		}
@@ -1030,7 +1030,7 @@ static void nl_fib_input(struct sk_buff *skb)
 		return;
 
 	skb = netlink_skb_clone(skb, GFP_KERNEL);
-	if (skb == NULL)
+	if (!skb)
 		return;
 	nlh = nlmsg_hdr(skb);
 
@@ -1051,7 +1051,7 @@ static int __net_init nl_fib_lookup_init(struct net *net)
 	};
 
 	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, &cfg);
-	if (sk == NULL)
+	if (!sk)
 		return -EAFNOSUPPORT;
 	net->ipv4.fibnl = sk;
 	return 0;
@@ -1089,7 +1089,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa, NULL);
 		atomic_inc(&net->ipv4.dev_addr_genid);
-		if (ifa->ifa_dev->ifa_list == NULL) {
+		if (!ifa->ifa_dev->ifa_list) {
 			/* Last address was deleted from this interface.
 			 * Disable IP.
 			 */
@@ -1157,7 +1157,7 @@ static int __net_init ip_fib_net_init(struct net *net)
 	size = max_t(size_t, size, L1_CACHE_BYTES);
 
 	net->ipv4.fib_table_hash = kzalloc(size, GFP_KERNEL);
-	if (net->ipv4.fib_table_hash == NULL)
+	if (!net->ipv4.fib_table_hash)
 		return -ENOMEM;
 
 	err = fib4_rules_init(net);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 8162dd8..5615198 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -153,7 +153,7 @@ static struct fib_table *fib_empty_table(struct net *net)
 	u32 id;
 
 	for (id = 1; id <= RT_TABLE_MAX; id++)
-		if (fib_get_table(net, id) == NULL)
+		if (!fib_get_table(net, id))
 			return fib_new_table(net, id);
 	return NULL;
 }
@@ -184,7 +184,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 			struct fib_table *table;
 
 			table = fib_empty_table(net);
-			if (table == NULL) {
+			if (!table) {
 				err = -ENOBUFS;
 				goto errout;
 			}
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index eac5aec..8d695b6 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -390,7 +390,7 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(fib_nlmsg_size(fa->fa_info), GFP_KERNEL);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = fib_dump_info(skb, info->portid, seq, event, tb_id,
@@ -503,7 +503,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (cfg->fc_mp == NULL)
+	if (!cfg->fc_mp)
 		return 0;
 
 	rtnh = cfg->fc_mp;
@@ -646,7 +646,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		rcu_read_lock();
 		err = -ENODEV;
 		in_dev = inetdev_by_index(net, nh->nh_oif);
-		if (in_dev == NULL)
+		if (!in_dev)
 			goto out;
 		err = -ENETDOWN;
 		if (!(in_dev->dev->flags & IFF_UP))
@@ -803,7 +803,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
-	if (fi == NULL)
+	if (!fi)
 		goto failure;
 	fib_info_cnt++;
 	if (cfg->fc_mx) {
@@ -921,7 +921,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		nh->nh_scope = RT_SCOPE_NOWHERE;
 		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
 		err = -ENODEV;
-		if (nh->nh_dev == NULL)
+		if (!nh->nh_dev)
 			goto failure;
 	} else {
 		change_nexthops(fi) {
@@ -995,7 +995,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	struct rtmsg *rtm;
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*rtm), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
@@ -1045,12 +1045,12 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		struct nlattr *mp;
 
 		mp = nla_nest_start(skb, RTA_MULTIPATH);
-		if (mp == NULL)
+		if (!mp)
 			goto nla_put_failure;
 
 		for_nexthops(fi) {
 			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
-			if (rtnh == NULL)
+			if (!rtnh)
 				goto nla_put_failure;
 
 			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
@@ -1093,7 +1093,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 	struct hlist_head *head = &fib_info_laddrhash[hash];
 	struct fib_info *fi;
 
-	if (fib_info_laddrhash == NULL || local == 0)
+	if (!fib_info_laddrhash || local == 0)
 		return 0;
 
 	hlist_for_each_entry(fi, head, fib_lhash) {
@@ -1182,7 +1182,7 @@ void fib_select_default(struct fib_result *res)
 
 		fib_alias_accessed(fa);
 
-		if (fi == NULL) {
+		if (!fi) {
 			if (next_fi != res->fi)
 				break;
 		} else if (!fib_detect_death(fi, order, &last_resort,
@@ -1195,7 +1195,7 @@ void fib_select_default(struct fib_result *res)
 		order++;
 	}
 
-	if (order <= 0 || fi == NULL) {
+	if (order <= 0 || !fi) {
 		tb->tb_default = -1;
 		goto out;
 	}
@@ -1251,7 +1251,7 @@ int fib_sync_up(struct net_device *dev)
 				alive++;
 				continue;
 			}
-			if (nexthop_nh->nh_dev == NULL ||
+			if (!nexthop_nh->nh_dev ||
 			    !(nexthop_nh->nh_dev->flags & IFF_UP))
 				continue;
 			if (nexthop_nh->nh_dev != dev ||
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2c7c299..9e4a3e3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -391,9 +391,9 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	BUG_ON(i >= child_length(tn));
 
 	/* update emptyChildren, overflow into fullChildren */
-	if (n == NULL && chi != NULL)
+	if (!n && chi != NULL)
 		empty_child_inc(tn);
-	if (n != NULL && chi == NULL)
+	if (n != NULL && !chi)
 		empty_child_dec(tn);
 
 	/* update fullChildren */
@@ -528,7 +528,7 @@ static struct key_vector *inflate(struct trie *t,
 		unsigned long j, k;
 
 		/* An empty child */
-		if (inode == NULL)
+		if (!inode)
 			continue;
 
 		/* A leaf or an internal node with skipped bits */
@@ -1154,7 +1154,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			}
 			err = -ENOBUFS;
 			new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
-			if (new_fa == NULL)
+			if (!new_fa)
 				goto out;
 
 			fi_drop = fa->fa_info;
@@ -1204,7 +1204,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	err = -ENOBUFS;
 	new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
-	if (new_fa == NULL)
+	if (!new_fa)
 		goto out;
 
 	new_fa->fa_info = fi;
@@ -1975,7 +1975,7 @@ struct fib_table *fib_trie_table(u32 id, struct fib_table *alias)
 		sz += sizeof(struct trie);
 
 	tb = kzalloc(sz, GFP_KERNEL);
-	if (tb == NULL)
+	if (!tb)
 		return NULL;
 
 	tb->tb_id = id;
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5a4828b..a7d8be3 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -196,7 +196,7 @@ static struct sk_buff **geneve_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	ptype = gro_find_receive_by_type(type);
-	if (ptype == NULL) {
+	if (!ptype) {
 		flush = 1;
 		goto out_unlock;
 	}
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 51973dd..9358f11 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -149,7 +149,7 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	ptype = gro_find_receive_by_type(type);
-	if (ptype == NULL)
+	if (!ptype)
 		goto out_unlock;
 
 	grehlen = GRE_HEADER_SECTION;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5e56401..f5203fb 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -399,7 +399,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 		return;
 
 	sk = icmp_xmit_lock(net);
-	if (sk == NULL)
+	if (!sk)
 		return;
 	inet = inet_sk(sk);
 
@@ -609,7 +609,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 						 skb_in->data,
 						 sizeof(_inner_type),
 						 &_inner_type);
-			if (itp == NULL)
+			if (!itp)
 				goto out;
 
 			/*
@@ -627,7 +627,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		return;
 
 	sk = icmp_xmit_lock(net);
-	if (sk == NULL)
+	if (!sk)
 		goto out_free;
 
 	/*
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index ad09213..27d204b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -692,7 +692,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
 	skb = alloc_skb(IGMP_SIZE + hlen + tlen, GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		ip_rt_put(rt);
 		return -1;
 	}
@@ -981,7 +981,7 @@ int igmp_rcv(struct sk_buff *skb)
 	int len = skb->len;
 	bool dropped = true;
 
-	if (in_dev == NULL)
+	if (!in_dev)
 		goto drop;
 
 	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
@@ -1888,7 +1888,7 @@ int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 	if (count >= sysctl_igmp_max_memberships)
 		goto done;
 	iml = sock_kmalloc(sk, sizeof(*iml), GFP_KERNEL);
-	if (iml == NULL)
+	if (!iml)
 		goto done;
 
 	memcpy(&iml->multi, imr, sizeof(*imr));
@@ -1909,7 +1909,7 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 	struct ip_sf_socklist *psf = rtnl_dereference(iml->sflist);
 	int err;
 
-	if (psf == NULL) {
+	if (!psf) {
 		/* any-source empty exclude case */
 		return ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
 			iml->sfmode, 0, NULL, 0);
@@ -2360,7 +2360,7 @@ void ip_mc_drop_socket(struct sock *sk)
 	struct ip_mc_socklist *iml;
 	struct net *net = sock_net(sk);
 
-	if (inet->mc_list == NULL)
+	if (!inet->mc_list)
 		return;
 
 	rtnl_lock();
@@ -2587,7 +2587,7 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *idev;
 		idev = __in_dev_get_rcu(state->dev);
-		if (unlikely(idev == NULL))
+		if (unlikely(!idev))
 			continue;
 		im = rcu_dereference(idev->mc_list);
 		if (likely(im != NULL)) {
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e792035..5e346a0 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -385,7 +385,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	}
 
 	q = kmem_cache_zalloc(f->frags_cachep, GFP_ATOMIC);
-	if (q == NULL)
+	if (!q)
 		return NULL;
 
 	q->net = nf;
@@ -406,7 +406,7 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 	struct inet_frag_queue *q;
 
 	q = inet_frag_alloc(nf, f, arg);
-	if (q == NULL)
+	if (!q)
 		return NULL;
 
 	return inet_frag_intern(nf, q, f, arg);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 145a50c..5a6cf86 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -372,7 +372,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 		goto err;
 
 	err = -ENOMEM;
-	if (pskb_pull(skb, ihl) == NULL)
+	if (!pskb_pull(skb, ihl))
 		goto err;
 
 	err = pskb_trim_rcsum(skb, end - offset);
@@ -537,7 +537,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		qp->q.fragments = head;
 	}
 
-	WARN_ON(head == NULL);
+	WARN_ON(!head);
 	WARN_ON(FRAG_CB(head)->offset != 0);
 
 	/* Allocate a new buffer for the datagram. */
@@ -559,7 +559,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 		struct sk_buff *clone;
 		int i, plen = 0;
 
-		if ((clone = alloc_skb(0, GFP_ATOMIC)) == NULL)
+		clone = alloc_skb(0, GFP_ATOMIC);
+		if (!clone)
 			goto out_nomem;
 		clone->next = head->next;
 		head->next = clone;
@@ -754,7 +755,7 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 	table = ip4_frags_ns_ctl_table;
 	if (!net_eq(net, &init_net)) {
 		table = kmemdup(table, sizeof(ip4_frags_ns_ctl_table), GFP_KERNEL);
-		if (table == NULL)
+		if (!table)
 			goto err_alloc;
 
 		table[0].data = &net->ipv4.frags.high_thresh;
@@ -770,7 +771,7 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 	}
 
 	hdr = register_net_sysctl(net, "net/ipv4", table);
-	if (hdr == NULL)
+	if (!hdr)
 		goto err_reg;
 
 	net->ipv4.frags_hdr = hdr;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0eb2a04..684abec 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -182,7 +182,7 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
 			     iph->daddr, iph->saddr, tpi->key);
 
-	if (t == NULL)
+	if (!t)
 		return PACKET_REJECT;
 
 	if (t->parms.iph.daddr == 0 ||
@@ -423,7 +423,7 @@ static int ipgre_open(struct net_device *dev)
 			return -EADDRNOTAVAIL;
 		dev = rt->dst.dev;
 		ip_rt_put(rt);
-		if (__in_dev_get_rtnl(dev) == NULL)
+		if (!__in_dev_get_rtnl(dev))
 			return -EADDRNOTAVAIL;
 		t->mlink = dev->ifindex;
 		ip_mc_inc_group(__in_dev_get_rtnl(dev), t->parms.iph.daddr);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3d4da2c..00bed6f 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -314,7 +314,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
-	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
+	if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
@@ -387,7 +387,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb) {
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8259e77..561d67b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -182,7 +182,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		struct sk_buff *skb2;
 
 		skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
-		if (skb2 == NULL) {
+		if (!skb2) {
 			kfree_skb(skb);
 			return -ENOMEM;
 		}
@@ -381,7 +381,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 
 	/* Make sure we can route this packet. */
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
-	if (rt == NULL) {
+	if (!rt) {
 		__be32 daddr;
 
 		/* Use correct destination address if we have options. */
@@ -790,12 +790,13 @@ static inline int ip_ufo_append_data(struct sock *sk,
 	 * device, so create one single skb packet containing complete
 	 * udp datagram
 	 */
-	if ((skb = skb_peek_tail(queue)) == NULL) {
+	skb = skb_peek_tail(queue);
+	if (!skb) {
 		skb = sock_alloc_send_skb(sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
 			(flags & MSG_DONTWAIT), &err);
 
-		if (skb == NULL)
+		if (!skb)
 			return err;
 
 		/* reserve space for Hardware header */
@@ -961,10 +962,10 @@ alloc_new_skb:
 					skb = sock_wmalloc(sk,
 							   alloclen + hh_len + 15, 1,
 							   sk->sk_allocation);
-				if (unlikely(skb == NULL))
+				if (unlikely(!skb))
 					err = -ENOBUFS;
 			}
-			if (skb == NULL)
+			if (!skb)
 				goto error;
 
 			/*
@@ -1088,10 +1089,10 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	 */
 	opt = ipc->opt;
 	if (opt) {
-		if (cork->opt == NULL) {
+		if (!cork->opt) {
 			cork->opt = kmalloc(sizeof(struct ip_options) + 40,
 					    sk->sk_allocation);
-			if (unlikely(cork->opt == NULL))
+			if (unlikely(!cork->opt))
 				return -ENOBUFS;
 		}
 		memcpy(cork->opt, &opt->opt, sizeof(struct ip_options) + opt->opt.optlen);
@@ -1198,7 +1199,8 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		return -EMSGSIZE;
 	}
 
-	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
+	skb = skb_peek_tail(&sk->sk_write_queue);
+	if (!skb)
 		return -EINVAL;
 
 	cork->length += size;
@@ -1329,7 +1331,8 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	__be16 df = 0;
 	__u8 ttl;
 
-	if ((skb = __skb_dequeue(queue)) == NULL)
+	skb = __skb_dequeue(queue);
+	if (!skb)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index f6a0d54..f64b1b2 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -351,7 +351,7 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 			return 0;
 		}
 	}
-	if (new_ra == NULL) {
+	if (!new_ra) {
 		spin_unlock_bh(&ip_ra_lock);
 		return -ENOBUFS;
 	}
@@ -482,7 +482,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	err = -EAGAIN;
 	skb = sock_dequeue_err_skb(sk);
-	if (skb == NULL)
+	if (!skb)
 		goto out;
 
 	copied = skb->len;
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 2cd0828..4356a1d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -655,7 +655,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	if (dst == 0) {
 		/* NBMA tunnel */
 
-		if (skb_dst(skb) == NULL) {
+		if (!skb_dst(skb)) {
 			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
@@ -673,7 +673,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 			neigh = dst_neigh_lookup(skb_dst(skb),
 						 &ipv6_hdr(skb)->daddr);
-			if (neigh == NULL)
+			if (!neigh)
 				goto tx_error;
 
 			addr6 = (const struct in6_addr *)&neigh->primary_key;
@@ -844,7 +844,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 	case SIOCGETTUNNEL:
 		if (dev == itn->fb_tunnel_dev) {
 			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
-			if (t == NULL)
+			if (!t)
 				t = netdev_priv(dev);
 		}
 		memcpy(p, &t->parms, sizeof(*p));
@@ -915,7 +915,7 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 		if (dev == itn->fb_tunnel_dev) {
 			err = -ENOENT;
 			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
-			if (t == NULL)
+			if (!t)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(itn->fb_tunnel_dev))
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index c0855d5..d97f4f2 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -63,7 +63,7 @@ static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 	struct xfrm_state *t;
 
 	t = xfrm_state_alloc(net);
-	if (t == NULL)
+	if (!t)
 		goto out;
 
 	t->id.proto = IPPROTO_IPIP;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index b26376e..8e7328c 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -504,7 +504,8 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
 		return NET_RX_DROP;
 
 	if (!pskb_may_pull(skb, sizeof(struct arphdr)))
@@ -958,7 +959,8 @@ static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, str
 	if (skb->pkt_type == PACKET_OTHERHOST)
 		goto drop;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
 		return NET_RX_DROP;
 
 	if (!pskb_may_pull(skb,
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfbcc85..7d361ca 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -144,7 +144,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			     iph->daddr, iph->saddr, 0);
-	if (t == NULL)
+	if (!t)
 		goto out;
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b4a545d..7e15ef6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -189,7 +189,7 @@ static int ipmr_rule_action(struct fib_rule *rule, struct flowi *flp,
 	}
 
 	mrt = ipmr_get_table(rule->fr_net, rule->table);
-	if (mrt == NULL)
+	if (!mrt)
 		return -EAGAIN;
 	res->mrt = mrt;
 	return 0;
@@ -253,7 +253,7 @@ static int __net_init ipmr_rules_init(struct net *net)
 	INIT_LIST_HEAD(&net->ipv4.mr_tables);
 
 	mrt = ipmr_new_table(net, RT_TABLE_DEFAULT);
-	if (mrt == NULL) {
+	if (!mrt) {
 		err = -ENOMEM;
 		goto err1;
 	}
@@ -320,7 +320,7 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 		return mrt;
 
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
-	if (mrt == NULL)
+	if (!mrt)
 		return NULL;
 	write_pnet(&mrt->net, net);
 	mrt->id = id;
@@ -422,7 +422,7 @@ struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 			dev->flags |= IFF_MULTICAST;
 
 			in_dev = __in_dev_get_rtnl(dev);
-			if (in_dev == NULL)
+			if (!in_dev)
 				goto failure;
 
 			ipv4_devconf_setall(in_dev);
@@ -500,7 +500,7 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 
 	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
 
-	if (dev == NULL)
+	if (!dev)
 		return NULL;
 
 	dev_net_set(dev, net);
@@ -757,7 +757,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	case 0:
 		if (vifc->vifc_flags == VIFF_USE_IFINDEX) {
 			dev = dev_get_by_index(net, vifc->vifc_lcl_ifindex);
-			if (dev && __in_dev_get_rtnl(dev) == NULL) {
+			if (dev && !__in_dev_get_rtnl(dev)) {
 				dev_put(dev);
 				return -EADDRNOTAVAIL;
 			}
@@ -1003,7 +1003,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 	rcu_read_lock();
 	mroute_sk = rcu_dereference(mrt->mroute_sk);
-	if (mroute_sk == NULL) {
+	if (!mroute_sk) {
 		rcu_read_unlock();
 		kfree_skb(skb);
 		return -EINVAL;
@@ -1156,7 +1156,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		return -EINVAL;
 
 	c = ipmr_cache_alloc();
-	if (c == NULL)
+	if (!c)
 		return -ENOMEM;
 
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
@@ -1278,7 +1278,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return -EOPNOTSUPP;
 
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	if (optname != MRT_INIT) {
@@ -1441,7 +1441,7 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 		return -EOPNOTSUPP;
 
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	if (optname != MRT_VERSION &&
@@ -1487,7 +1487,7 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 	struct mr_table *mrt;
 
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	switch (cmd) {
@@ -1561,7 +1561,7 @@ int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 	struct mr_table *mrt;
 
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	switch (cmd) {
@@ -1696,7 +1696,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	struct flowi4 fl4;
 	int    encap = 0;
 
-	if (vif->dev == NULL)
+	if (!vif->dev)
 		goto out_free;
 
 #ifdef CONFIG_IP_PIMSM
@@ -1987,7 +1987,7 @@ int ip_mr_input(struct sk_buff *skb)
 
 	/* already under rcu_read_lock() */
 	cache = ipmr_cache_find(mrt, ip_hdr(skb)->saddr, ip_hdr(skb)->daddr);
-	if (cache == NULL) {
+	if (!cache) {
 		int vif = ipmr_find_vif(mrt, skb->dev);
 
 		if (vif >= 0)
@@ -1998,13 +1998,13 @@ int ip_mr_input(struct sk_buff *skb)
 	/*
 	 *	No usable cache entry
 	 */
-	if (cache == NULL) {
+	if (!cache) {
 		int vif;
 
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 			ip_local_deliver(skb);
-			if (skb2 == NULL)
+			if (!skb2)
 				return -ENOBUFS;
 			skb = skb2;
 		}
@@ -2063,7 +2063,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 		reg_dev = mrt->vif_table[mrt->mroute_reg_vif_num].dev;
 	read_unlock(&mrt_lock);
 
-	if (reg_dev == NULL)
+	if (!reg_dev)
 		return 1;
 
 	skb->mac_header = skb->network_header;
@@ -2193,18 +2193,18 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 	int err;
 
 	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return -ENOENT;
 
 	rcu_read_lock();
 	cache = ipmr_cache_find(mrt, saddr, daddr);
-	if (cache == NULL && skb->dev) {
+	if (!cache && skb->dev) {
 		int vif = ipmr_find_vif(mrt, skb->dev);
 
 		if (vif >= 0)
 			cache = ipmr_cache_find_any(mrt, daddr, vif);
 	}
-	if (cache == NULL) {
+	if (!cache) {
 		struct sk_buff *skb2;
 		struct iphdr *iph;
 		struct net_device *dev;
@@ -2262,7 +2262,7 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	int err;
 
 	nlh = nlmsg_put(skb, portid, seq, cmd, sizeof(*rtm), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
@@ -2327,7 +2327,7 @@ static void mroute_netlink_event(struct mr_table *mrt, struct mfc_cache *mfc,
 
 	skb = nlmsg_new(mroute_msgsize(mfc->mfc_parent >= MAXVIFS, mrt->maxvif),
 			GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = ipmr_fill_mroute(mrt, skb, 0, 0, mfc, cmd, 0);
@@ -2442,7 +2442,7 @@ static void *ipmr_vif_seq_start(struct seq_file *seq, loff_t *pos)
 	struct mr_table *mrt;
 
 	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return ERR_PTR(-ENOENT);
 
 	iter->mrt = mrt;
@@ -2561,7 +2561,7 @@ static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 	struct mr_table *mrt;
 
 	mrt = ipmr_get_table(net, RT_TABLE_DEFAULT);
-	if (mrt == NULL)
+	if (!mrt)
 		return ERR_PTR(-ENOENT);
 
 	it->mrt = mrt;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 344e7cd..2dcd2e6 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -516,7 +516,7 @@ void ping_err(struct sk_buff *skb, int offset, u32 info)
 		 ntohs(icmph->un.echo.sequence));
 
 	sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
-	if (sk == NULL) {
+	if (!sk) {
 		pr_debug("no socket, dropping\n");
 		return;	/* No socket for error */
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 56946f4..46a7820 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -363,7 +363,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 	skb = sock_alloc_send_skb(sk,
 				  length + hlen + tlen + 15,
 				  flags & MSG_DONTWAIT, &err);
-	if (skb == NULL)
+	if (!skb)
 		goto error;
 	skb_reserve(skb, hlen);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 652b92e..26a1cb3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1056,7 +1056,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
 
 	rt = (struct rtable *)odst;
-	if (odst->obsolete && odst->ops->check(odst, 0) == NULL) {
+	if (odst->obsolete && !odst->ops->check(odst, 0)) {
 		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
@@ -1450,7 +1450,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	/* Primary sanity checks. */
 
-	if (in_dev == NULL)
+	if (!in_dev)
 		return -EINVAL;
 
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
@@ -1553,7 +1553,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	/* get a working reference to the output device */
 	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
-	if (out_dev == NULL) {
+	if (!out_dev) {
 		net_crit_ratelimited("Bug in ip_route_input_slow(). Please report.\n");
 		return -EINVAL;
 	}
@@ -2054,7 +2054,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		     ipv4_is_lbcast(fl4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 			dev_out = __ip_dev_find(net, fl4->saddr, false);
-			if (dev_out == NULL)
+			if (!dev_out)
 				goto out;
 
 			/* Special hack: user can direct multicasts
@@ -2087,7 +2087,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	if (fl4->flowi4_oif) {
 		dev_out = dev_get_by_index_rcu(net, fl4->flowi4_oif);
 		rth = ERR_PTR(-ENODEV);
-		if (dev_out == NULL)
+		if (!dev_out)
 			goto out;
 
 		/* RACE: Check return value of inet_select_addr instead. */
@@ -2299,7 +2299,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	u32 metrics[RTAX_MAX];
 
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	r = nlmsg_data(nlh);
@@ -2421,7 +2421,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	rtm = nlmsg_data(nlh);
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (skb == NULL) {
+	if (!skb) {
 		err = -ENOBUFS;
 		goto errout;
 	}
@@ -2452,7 +2452,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		struct net_device *dev;
 
 		dev = __dev_get_by_index(net, iif);
-		if (dev == NULL) {
+		if (!dev) {
 			err = -ENODEV;
 			goto errout_free;
 		}
@@ -2651,7 +2651,7 @@ static __net_init int sysctl_route_net_init(struct net *net)
 	tbl = ipv4_route_flush_table;
 	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(tbl, sizeof(ipv4_route_flush_table), GFP_KERNEL);
-		if (tbl == NULL)
+		if (!tbl)
 			goto err_dup;
 
 		/* Don't export sysctls to unprivileged users */
@@ -2661,7 +2661,7 @@ static __net_init int sysctl_route_net_init(struct net *net)
 	tbl[0].extra1 = net;
 
 	net->ipv4.route_hdr = register_net_sysctl(net, "net/ipv4/route", tbl);
-	if (net->ipv4.route_hdr == NULL)
+	if (!net->ipv4.route_hdr)
 		goto err_reg;
 	return 0;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fdf8991..c3852a7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -909,7 +909,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		int i;
 
 		table = kmemdup(table, sizeof(ipv4_net_table), GFP_KERNEL);
-		if (table == NULL)
+		if (!table)
 			goto err_alloc;
 
 		/* Update the variables to point into the current struct net */
@@ -918,7 +918,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	}
 
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
-	if (net->ipv4.ipv4_hdr == NULL)
+	if (!net->ipv4.ipv4_hdr)
 		goto err_reg;
 
 	net->ipv4.sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
@@ -956,7 +956,7 @@ static __init int sysctl_ipv4_init(void)
 	struct ctl_table_header *hdr;
 
 	hdr = register_net_sysctl(&init_net, "net/ipv4", ipv4_table);
-	if (hdr == NULL)
+	if (!hdr)
 		return -ENOMEM;
 
 	if (register_pernet_subsys(&ipv4_sysctl_ops)) {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dbd51ce..5bd809b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1047,7 +1047,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 
 	tp->fastopen_req = kzalloc(sizeof(struct tcp_fastopen_request),
 				   sk->sk_allocation);
-	if (unlikely(tp->fastopen_req == NULL))
+	if (unlikely(!tp->fastopen_req))
 		return -ENOBUFS;
 	tp->fastopen_req->data = msg;
 	tp->fastopen_req->size = size;
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 2eb887e..5da55e2 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -141,7 +141,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	req->sk = NULL;
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
-	if (child == NULL)
+	if (!child)
 		return false;
 
 	spin_lock(&queue->fastopenq->lock);
@@ -214,7 +214,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	sk->sk_data_ready(sk);
 	bh_unlock_sock(child);
 	sock_put(child);
-	WARN_ON(req->sk == NULL);
+	WARN_ON(!req->sk);
 	return true;
 }
 
@@ -233,7 +233,7 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
 	 * temporarily vs a server not supporting Fast Open at all.
 	 */
 	fastopenq = inet_csk(sk)->icsk_accept_queue.fastopenq;
-	if (fastopenq == NULL || fastopenq->max_qlen == 0)
+	if (!fastopenq || fastopenq->max_qlen == 0)
 		return false;
 
 	if (fastopenq->qlen >= fastopenq->max_qlen) {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 18b80e8..1fd2836 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -866,7 +866,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 /* This must be called before lost_out is incremented */
 static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_buff *skb)
 {
-	if ((tp->retransmit_skb_hint == NULL) ||
+	if (!tp->retransmit_skb_hint ||
 	    before(TCP_SKB_CB(skb)->seq,
 		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
 		tp->retransmit_skb_hint = skb;
@@ -1614,7 +1614,7 @@ static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
 						struct tcp_sacktag_state *state,
 						u32 skip_to_seq)
 {
-	if (next_dup == NULL)
+	if (!next_dup)
 		return skb;
 
 	if (before(next_dup->start_seq, skip_to_seq)) {
@@ -1783,7 +1783,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 			if (tcp_highest_sack_seq(tp) == cache->end_seq) {
 				/* ...but better entrypoint exists! */
 				skb = tcp_highest_sack(sk);
-				if (skb == NULL)
+				if (!skb)
 					break;
 				state.fack_count = tp->fackets_out;
 				cache++;
@@ -1798,7 +1798,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 
 		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
 			skb = tcp_highest_sack(sk);
-			if (skb == NULL)
+			if (!skb)
 				break;
 			state.fack_count = tp->fackets_out;
 		}
@@ -3698,7 +3698,7 @@ void tcp_parse_options(const struct sk_buff *skb,
 				 */
 				if (opsize < TCPOLEN_EXP_FASTOPEN_BASE ||
 				    get_unaligned_be16(ptr) != TCPOPT_FASTOPEN_MAGIC ||
-				    foc == NULL || !th->syn || (opsize & 1))
+				    !foc || !th->syn || (opsize & 1))
 					break;
 				foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
 				if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
@@ -4669,7 +4669,7 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 	struct sk_buff *head;
 	u32 start, end;
 
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 	start = TCP_SKB_CB(skb)->seq;
@@ -5124,7 +5124,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (unlikely(sk->sk_rx_dst == NULL))
+	if (unlikely(!sk->sk_rx_dst))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
 	/*
 	 *	Header prediction.
@@ -5694,7 +5694,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		WARN_ON_ONCE(sk->sk_state != TCP_SYN_RECV &&
 		    sk->sk_state != TCP_FIN_WAIT1);
 
-		if (tcp_check_req(sk, skb, req, true) == NULL)
+		if (!tcp_check_req(sk, skb, req, true))
 			goto discard;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5aababa..8018f17 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -122,7 +122,7 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 	   and use initial timestamp retrieved from peer table.
 	 */
 	if (tcptw->tw_ts_recent_stamp &&
-	    (twp == NULL || (sysctl_tcp_tw_reuse &&
+	    (!twp || (sysctl_tcp_tw_reuse &&
 			     get_seconds() - tcptw->tw_ts_recent_stamp > 1))) {
 		tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
 		if (tp->write_seq == 0)
@@ -494,7 +494,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		/* Only in fast or simultaneous open. If a fast open socket is
 		 * is already accepted it is treated as a connected one below.
 		 */
-		if (fastopen && fastopen->sk == NULL)
+		if (fastopen && !fastopen->sk)
 			break;
 
 		if (!sock_owned_by_user(sk)) {
@@ -1390,7 +1390,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		sk_mark_napi_id(sk, skb);
 		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
-			    dst->ops->check(dst, 0) == NULL) {
+			    !dst->ops->check(dst, 0)) {
 				dst_release(dst);
 				sk->sk_rx_dst = NULL;
 			}
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 71ec14c..78ecc4a 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -505,7 +505,7 @@ void tcp_init_metrics(struct sock *sk)
 	struct tcp_metrics_block *tm;
 	u32 val, crtt = 0; /* cached RTT scaled by 8 */
 
-	if (dst == NULL)
+	if (!dst)
 		goto reset;
 
 	dst_confirm(dst);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 274e96f..f0db159 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -763,7 +763,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * socket is created, wait for troubles.
 	 */
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
-	if (child == NULL)
+	if (!child)
 		goto listen_overflow;
 
 	inet_csk_reqsk_queue_unlink(sk, req);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2e69b8d..bdc8073 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -565,7 +565,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	opts->mss = tcp_advertise_mss(sk);
 	remaining -= TCPOLEN_MSS_ALIGNED;
 
-	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
+	if (likely(sysctl_tcp_timestamps && !*md5)) {
 		opts->options |= OPTION_TS;
 		opts->tsval = tcp_skb_timestamp(skb) + tp->tsoffset;
 		opts->tsecr = tp->rx_opt.ts_recent;
@@ -1148,7 +1148,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 
 	/* Get a new skb... force flag on. */
 	buff = sk_stream_alloc_skb(sk, nsize, gfp);
-	if (buff == NULL)
+	if (!buff)
 		return -ENOMEM; /* We'll just try again later. */
 
 	sk->sk_wmem_queued += buff->truesize;
@@ -1707,7 +1707,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 		return tcp_fragment(sk, skb, len, mss_now, gfp);
 
 	buff = sk_stream_alloc_skb(sk, 0, gfp);
-	if (unlikely(buff == NULL))
+	if (unlikely(!buff))
 		return -ENOMEM;
 
 	sk->sk_wmem_queued += buff->truesize;
@@ -1925,7 +1925,8 @@ static int tcp_mtu_probe(struct sock *sk)
 	}
 
 	/* We're allowed to probe.  Build it now. */
-	if ((nskb = sk_stream_alloc_skb(sk, probe_size, GFP_ATOMIC)) == NULL)
+	nskb = sk_stream_alloc_skb(sk, probe_size, GFP_ATOMIC);
+	if (!nskb)
 		return -1;
 	sk->sk_wmem_queued += nskb->truesize;
 	sk_mem_charge(sk, nskb->truesize);
@@ -2733,7 +2734,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		if (skb == tcp_send_head(sk))
 			break;
 		/* we could do better than to assign each time */
-		if (hole == NULL)
+		if (!hole)
 			tp->retransmit_skb_hint = skb;
 
 		/* Assume this retransmit will generate
@@ -2765,7 +2766,7 @@ begin_fwd:
 			goto begin_fwd;
 
 		} else if (!(sacked & TCPCB_LOST)) {
-			if (hole == NULL && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
+			if (!hole && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACKED_ACKED)))
 				hole = skb;
 			continue;
 
@@ -2868,14 +2869,14 @@ int tcp_send_synack(struct sock *sk)
 	struct sk_buff *skb;
 
 	skb = tcp_write_queue_head(sk);
-	if (skb == NULL || !(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
+	if (!skb || !(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
 		pr_debug("%s: wrong queue state\n", __func__);
 		return -EFAULT;
 	}
 	if (!(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_ACK)) {
 		if (skb_cloned(skb)) {
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
-			if (nskb == NULL)
+			if (!nskb)
 				return -ENOMEM;
 			tcp_unlink_write_queue(skb, sk);
 			__skb_header_release(nskb);
@@ -3300,7 +3301,7 @@ void tcp_send_ack(struct sock *sk)
 	 * sock.
 	 */
 	buff = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
-	if (buff == NULL) {
+	if (!buff) {
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
@@ -3344,7 +3345,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 
 	/* We don't queue it, tcp_transmit_skb() sets ownership. */
 	skb = alloc_skb(MAX_TCP_HEADER, sk_gfp_atomic(sk, GFP_ATOMIC));
-	if (skb == NULL)
+	if (!skb)
 		return -1;
 
 	/* Reserve space for headers and set control bits. */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 294af16..9f525a2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -633,7 +633,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
-	if (sk == NULL) {
+	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
 	}
@@ -1011,7 +1011,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (connected)
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
-	if (rt == NULL) {
+	if (!rt) {
 		struct net *net = sock_net(sk);
 
 		fl4 = &fl4_stack;
@@ -1619,7 +1619,7 @@ static void flush_stack(struct sock **stack, unsigned int count,
 
 	for (i = 0; i < count; i++) {
 		sk = stack[i];
-		if (likely(skb1 == NULL))
+		if (likely(!skb1))
 			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 
 		if (!skb1) {
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 2dbfc1f..b763c39 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -58,7 +58,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out_nosk;
 
 	err = -ENOENT;
-	if (sk == NULL)
+	if (!sk)
 		goto out_nosk;
 
 	err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index aac6197..cac7468 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -24,7 +24,7 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
-	if (skb_dst(skb) == NULL) {
+	if (!skb_dst(skb)) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (ip_route_input_noref(skb, iph->daddr, iph->saddr,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c224c85..bff6974 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -298,7 +298,7 @@ static void __net_exit xfrm4_net_exit(struct net *net)
 {
 	struct ctl_table *table;
 
-	if (net->ipv4.xfrm4_hdr == NULL)
+	if (!net->ipv4.xfrm4_hdr)
 		return;
 
 	table = net->ipv4.xfrm4_hdr->ctl_table_arg;
-- 
1.9.1
