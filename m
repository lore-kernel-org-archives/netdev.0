From: Ian Morris <ipm@chirality.org.uk>
Subject: RFC : [PATCH] IPV6: checkpatch whitespace corrections
Date: Wed, 13 Aug 2014 21:02:47 +0100
Message-ID: <1407960167-9437-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:54093 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752754AbaHMUIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 16:08:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I started looking at the ipv6 code to educate myself but in the process
noticed a fair few trivial checkpatch issues. There are some more interesting
ones also present but before tackling those I decided to try to reduce the 
volume of output from checkpatch by fixing whitespace issues. Question is 
are such patches wanted?

Patch comment:

No actual changes to logic just whitespace adjustments to coding
style as indicated by checkpatch.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/addrconf.c              |   26 ++++++---
 net/ipv6/addrlabel.c             |    2 +
 net/ipv6/af_inet6.c              |   15 +++---
 net/ipv6/ah6.c                   |   21 ++++----
 net/ipv6/anycast.c               |    2 +
 net/ipv6/datagram.c              |   20 +++++--
 net/ipv6/esp6.c                  |   16 +++---
 net/ipv6/exthdrs.c               |    3 +-
 net/ipv6/exthdrs_core.c          |    2 +
 net/ipv6/icmp.c                  |   11 ++--
 net/ipv6/inet6_connection_sock.c |    6 +--
 net/ipv6/inet6_hashtables.c      |    5 +-
 net/ipv6/ip6_fib.c               |    3 ++
 net/ipv6/ip6_flowlabel.c         |   28 ++++++----
 net/ipv6/ip6_gre.c               |    3 ++
 net/ipv6/ip6_icmp.c              |    2 +-
 net/ipv6/ip6_input.c             |    6 +--
 net/ipv6/ip6_offload.c           |    2 +-
 net/ipv6/ip6_output.c            |   27 ++++++----
 net/ipv6/ip6_tunnel.c            |   43 ++++++++-------
 net/ipv6/ip6mr.c                 |   16 ++++--
 net/ipv6/ipcomp6.c               |    6 +--
 net/ipv6/ipv6_sockglue.c         |   34 ++++++------
 net/ipv6/mcast.c                 |  110 ++++++++++++++++++++------------------
 net/ipv6/mip6.c                  |   11 ++--
 net/ipv6/ndisc.c                 |   27 ++++++----
 net/ipv6/netfilter.c             |    1 +
 net/ipv6/output_core.c           |    3 +-
 net/ipv6/ping.c                  |    3 ++
 net/ipv6/proc.c                  |    3 +-
 net/ipv6/raw.c                   |   13 +++--
 net/ipv6/reassembly.c            |   13 +++--
 net/ipv6/route.c                 |   38 ++++++++-----
 net/ipv6/sit.c                   |   18 ++++---
 net/ipv6/syncookies.c            |    2 +
 net/ipv6/tcp_ipv6.c              |    5 ++
 net/ipv6/tunnel6.c               |    4 +-
 net/ipv6/udp.c                   |   26 +++++----
 net/ipv6/xfrm6_input.c           |    6 +--
 net/ipv6/xfrm6_output.c          |    1 -
 net/ipv6/xfrm6_policy.c          |   25 +++++----
 net/ipv6/xfrm6_state.c           |   16 +++---
 net/ipv6/xfrm6_tunnel.c          |   13 ++---
 43 files changed, 377 insertions(+), 260 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc..8f4df4d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -180,7 +180,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
 	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
 	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-	.use_tempaddr 		= 0,
+	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
@@ -284,6 +284,7 @@ static int snmp6_alloc_dev(struct inet6_dev *idev)
 
 	for_each_possible_cpu(i) {
 		struct ipstats_mib *addrconf_stats;
+
 		addrconf_stats = per_cpu_ptr(idev->stats.ipv6, i);
 		u64_stats_init(&addrconf_stats->syncp);
 	}
@@ -703,6 +704,7 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.forwarding) ^ (!newf);
+
 			idev->cnf.forwarding = newf;
 			if (changed)
 				dev_forward_change(idev);
@@ -1105,8 +1107,8 @@ retry:
 	spin_unlock_bh(&ifp->lock);
 
 	regen_advance = idev->cnf.regen_max_retry *
-	                idev->cnf.dad_transmits *
-	                NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
+			idev->cnf.dad_transmits *
+			NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
 	write_unlock_bh(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
@@ -1266,6 +1268,7 @@ static int ipv6_get_saddr_eval(struct net *net,
 	    {
 		/* Rule 4: Prefer home address */
 		int prefhome = !(dst->prefs & IPV6_PREFER_SRC_COA);
+
 		ret = !(score->ifa->flags & IFA_F_HOMEADDRESS) ^ prefhome;
 		break;
 	    }
@@ -1289,6 +1292,7 @@ static int ipv6_get_saddr_eval(struct net *net,
 		int preftmp = dst->prefs & (IPV6_PREFER_SRC_PUBLIC|IPV6_PREFER_SRC_TMP) ?
 				!!(dst->prefs & IPV6_PREFER_SRC_TMP) :
 				score->ifa->idev->cnf.use_tempaddr >= 2;
+
 		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ preftmp;
 		break;
 	    }
@@ -1624,6 +1628,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 		in6_ifa_put(ifp);
 	} else if (ifp->flags&IFA_F_TEMPORARY) {
 		struct inet6_ifaddr *ifpub;
+
 		spin_lock_bh(&ifp->lock);
 		ifpub = ifp->ifpub;
 		if (ifpub) {
@@ -2227,6 +2232,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 		} else if (valid_lft) {
 			clock_t expires = 0;
 			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
+
 			if (addrconf_finite_timeout(rt_expires)) {
 				/* not infinity */
 				flags |= RTF_EXPIRES;
@@ -2634,6 +2640,7 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev = __in_dev_get_rtnl(dev);
+
 		if (in_dev && (dev->flags & IFF_UP)) {
 			struct in_ifaddr *ifa;
 
@@ -2989,6 +2996,7 @@ static struct notifier_block ipv6_dev_notf = {
 static void addrconf_type_change(struct net_device *dev, unsigned long event)
 {
 	struct inet6_dev *idev;
+
 	ASSERT_RTNL();
 
 	idev = __in6_dev_get(dev);
@@ -3035,7 +3043,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		struct hlist_head *h = &inet6_addr_lst[i];
 
 		spin_lock_bh(&addrconf_hash_lock);
-	restart:
+restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
 				hlist_del_init_rcu(&ifa->addr_lst);
@@ -3503,6 +3511,7 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
+
 	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
@@ -3547,8 +3556,8 @@ static void __net_exit if6_proc_net_exit(struct net *net)
 }
 
 static struct pernet_operations if6_proc_net_ops = {
-       .init = if6_proc_net_init,
-       .exit = if6_proc_net_exit,
+	.init = if6_proc_net_init,
+	.exit = if6_proc_net_exit,
 };
 
 int __init if6_proc_init(void)
@@ -3659,6 +3668,7 @@ restart:
 
 				if (age >= ifp->prefered_lft - regen_advance) {
 					struct inet6_ifaddr *ifpub = ifp->ifpub;
+
 					if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))
 						next = ifp->tstamp + ifp->prefered_lft * HZ;
 					if (!ifp->regen_count && ifpub) {
@@ -3982,6 +3992,7 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
+
 			if (preferred > tval)
 				preferred -= tval;
 			else
@@ -4367,6 +4378,7 @@ static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
 {
 	int i;
 	int pad = bytes - sizeof(u64) * items;
+
 	BUG_ON(pad < 0);
 
 	/* Use put_unaligned() because stats may not be aligned for u64. */
@@ -4382,6 +4394,7 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
 {
 	int i;
 	int pad = bytes - sizeof(u64) * items;
+
 	BUG_ON(pad < 0);
 
 	/* Use put_unaligned() because stats may not be aligned for u64. */
@@ -4853,6 +4866,7 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.disable_ipv6) ^ (!newf);
+
 			idev->cnf.disable_ipv6 = newf;
 			if (changed)
 				dev_disable_change(idev);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index fd0dc47..c6c7d0c 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -173,6 +173,7 @@ static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
 						  int type, int ifindex)
 {
 	struct ip6addrlbl_entry *p;
+
 	hlist_for_each_entry_rcu(p, &ip6addrlbl_table.head, list) {
 		if (__ip6addrlbl_match(net, p, addr, type, ifindex))
 			return p;
@@ -464,6 +465,7 @@ static void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
 			      int prefixlen, int ifindex, u32 lseq)
 {
 	struct ifaddrlblmsg *ifal = nlmsg_data(nlh);
+
 	ifal->ifal_family = AF_INET6;
 	ifal->ifal_prefixlen = prefixlen;
 	ifal->ifal_flags = 0;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 2daa3a1..1650014 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -7,15 +7,15 @@
  *
  *	Adapted from linux/net/ipv4/af_inet.c
  *
- * 	Fixes:
+ *	Fixes:
  *	piggy, Karl Knutson	:	Socket protocol table
- * 	Hideaki YOSHIFUJI	:	sin6_scope_id support
- * 	Arnaldo Melo		: 	check proc_net_create return, cleanups
+ *	Hideaki YOSHIFUJI	:	sin6_scope_id support
+ *	Arnaldo Melo		:	check proc_net_create return, cleanups
  *
  *	This program is free software; you can redistribute it and/or
- *      modify it under the terms of the GNU General Public License
- *      as published by the Free Software Foundation; either version
- *      2 of the License, or (at your option) any later version.
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -724,11 +724,11 @@ static int __net_init ipv6_init_mibs(struct net *net)
 
 	for_each_possible_cpu(i) {
 		struct ipstats_mib *af_inet6_stats;
+
 		af_inet6_stats = per_cpu_ptr(net->mib.ipv6_statistics, i);
 		u64_stats_init(&af_inet6_stats->syncp);
 	}
 
-
 	net->mib.icmpv6_statistics = alloc_percpu(struct icmpv6_mib);
 	if (!net->mib.icmpv6_statistics)
 		goto err_icmp_mib;
@@ -736,6 +736,7 @@ static int __net_init ipv6_init_mibs(struct net *net)
 						GFP_KERNEL);
 	if (!net->mib.icmpv6msg_statistics)
 		goto err_icmpmsg_mib;
+
 	return 0;
 
 err_icmpmsg_mib:
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 72a4930..fcffd4e 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -17,10 +17,10 @@
  * Authors
  *
  *	Mitsuru KANDA @USAGI       : IPv6 Support
- * 	Kazunori MIYAZAWA @USAGI   :
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI   :
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *
- * 	This file is derived from net/ipv4/ah.c.
+ *	This file is derived from net/ipv4/ah.c.
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -284,7 +284,7 @@ static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 			ipv6_rearrange_rthdr(iph, exthdr.rth);
 			break;
 
-		default :
+		default:
 			return 0;
 		}
 
@@ -478,7 +478,7 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	auth_data = ah_tmp_auth(work_iph, hdr_len);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out;
 
@@ -622,7 +622,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out_free;
 	}
 
-	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG: 0;
+	err = memcmp(icv, auth_data, ahp->icv_trunc_len) ? -EBADMSG : 0;
 	if (err)
 		goto out_free;
 
@@ -647,8 +647,8 @@ static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		   u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
-	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
-	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
+	struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
+	struct ip_auth_hdr *ah = (struct ip_auth_hdr *)(skb->data+offset);
 	struct xfrm_state *x;
 
 	if (type != ICMPV6_PKT_TOOBIG &&
@@ -755,11 +755,10 @@ static int ah6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type ah6_type =
-{
+static const struct xfrm_type ah6_type = {
 	.description	= "AH6",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_AH,
+	.proto		= IPPROTO_AH,
 	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= ah6_init_state,
 	.destructor	= ah6_destroy,
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 2101832..0fa178c 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -413,6 +413,7 @@ static inline struct ifacaddr6 *ac6_get_first(struct seq_file *seq)
 	state->idev = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
+
 		idev = __in6_dev_get(state->dev);
 		if (!idev)
 			continue;
@@ -453,6 +454,7 @@ static struct ifacaddr6 *ac6_get_next(struct seq_file *seq, struct ifacaddr6 *im
 static struct ifacaddr6 *ac6_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct ifacaddr6 *im = ac6_get_first(seq);
+
 	if (im)
 		while (pos && (im = ac6_get_next(seq, im)) != NULL)
 			--pos;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2753319..d86e5d3 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -43,13 +43,13 @@ static bool ipv6_mapped_addr_any(const struct in6_addr *a)
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
 	struct sockaddr_in6	*usin = (struct sockaddr_in6 *) uaddr;
-	struct inet_sock      	*inet = inet_sk(sk);
-	struct ipv6_pinfo      	*np = inet6_sk(sk);
-	struct in6_addr		*daddr, *final_p, final;
+	struct inet_sock	*inet = inet_sk(sk);
+	struct ipv6_pinfo	*np = inet6_sk(sk);
+	struct in6_addr	*daddr, *final_p, final;
 	struct dst_entry	*dst;
 	struct flowi6		fl6;
 	struct ip6_flowlabel	*flowlabel = NULL;
-	struct ipv6_txoptions   *opt;
+	struct ipv6_txoptions	*opt;
 	int			addr_type;
 	int			err;
 
@@ -210,6 +210,7 @@ int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *uaddr,
 				 int addr_len)
 {
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, uaddr);
+
 	if (sin6->sin6_family != AF_INET6)
 		return -EAFNOSUPPORT;
 	return ip6_datagram_connect(sk, uaddr, addr_len);
@@ -361,6 +362,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	if (sin) {
 		const unsigned char *nh = skb_network_header(skb);
+
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = serr->port;
@@ -515,16 +517,19 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 
 	if (np->rxopt.bits.rxhlim) {
 		int hlim = ipv6_hdr(skb)->hop_limit;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), &hlim);
 	}
 
 	if (np->rxopt.bits.rxtclass) {
 		int tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+
 		put_cmsg(msg, SOL_IPV6, IPV6_TCLASS, sizeof(tclass), &tclass);
 	}
 
 	if (np->rxopt.bits.rxflow) {
 		__be32 flowinfo = ip6_flowinfo((struct ipv6hdr *)nh);
+
 		if (flowinfo)
 			put_cmsg(msg, SOL_IPV6, IPV6_FLOWINFO, sizeof(flowinfo), &flowinfo);
 	}
@@ -532,6 +537,7 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 	/* HbH is allowed only once */
 	if (np->rxopt.bits.hopopts && opt->hop) {
 		u8 *ptr = nh + opt->hop;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
 	}
 
@@ -590,22 +596,27 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 	}
 	if (np->rxopt.bits.rxohlim) {
 		int hlim = ipv6_hdr(skb)->hop_limit;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
 	}
 	if (np->rxopt.bits.ohopopts && opt->hop) {
 		u8 *ptr = nh + opt->hop;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_2292HOPOPTS, (ptr[1]+1)<<3, ptr);
 	}
 	if (np->rxopt.bits.odstopts && opt->dst0) {
 		u8 *ptr = nh + opt->dst0;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_2292DSTOPTS, (ptr[1]+1)<<3, ptr);
 	}
 	if (np->rxopt.bits.osrcrt && opt->srcrt) {
 		struct ipv6_rt_hdr *rthdr = (struct ipv6_rt_hdr *)(nh + opt->srcrt);
+
 		put_cmsg(msg, SOL_IPV6, IPV6_2292RTHDR, (rthdr->hdrlen+1) << 3, rthdr);
 	}
 	if (np->rxopt.bits.odstopts && opt->dst1) {
 		u8 *ptr = nh + opt->dst1;
+
 		put_cmsg(msg, SOL_IPV6, IPV6_2292DSTOPTS, (ptr[1]+1)<<3, ptr);
 	}
 	if (np->rxopt.bits.rxorigdstaddr) {
@@ -698,6 +709,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
+
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0) &&
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index d15da13..7e1c48a 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -17,10 +17,10 @@
  * Authors
  *
  *	Mitsuru KANDA @USAGI       : IPv6 Support
- * 	Kazunori MIYAZAWA @USAGI   :
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI   :
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *
- * 	This file is derived from net/ipv4/esp.c
+ *	This file is derived from net/ipv4/esp.c
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -216,6 +216,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 	do {
 		int i;
+
 		for (i = 0; i < plen - 2; i++)
 			tail[i] = i + 1;
 	} while (0);
@@ -598,7 +599,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	case XFRM_MODE_BEET:
 		if (x->sel.family != AF_INET6)
 			x->props.header_len += IPV4_BEET_PHMAXLEN +
-				               (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+					       (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
 		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
@@ -621,11 +622,10 @@ static int esp6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type esp6_type =
-{
+static const struct xfrm_type esp6_type = {
 	.description	= "ESP6",
-	.owner	     	= THIS_MODULE,
-	.proto	     	= IPPROTO_ESP,
+	.owner		= THIS_MODULE,
+	.proto		= IPPROTO_ESP,
 	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= esp6_init_state,
 	.destructor	= esp6_destroy,
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8d67900..77ceabf 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -142,7 +142,7 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 		default: /* Other TLV code so scan list */
 			if (optlen > len)
 				goto bad;
-			for (curr=procs; curr->type >= 0; curr++) {
+			for (curr = procs; curr->type >= 0; curr++) {
 				if (curr->type == nh[off]) {
 					/* type specific length/alignment
 					   checks will be performed in the
@@ -718,6 +718,7 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
 	opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
 	if (opt2) {
 		long dif = (char *)opt2 - (char *)opt;
+
 		memcpy(opt2, opt, opt->tot_len);
 		if (opt2->hopopt)
 			*((char **)&opt2->hopopt) += dif;
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 8af3eb5..649f010 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -86,6 +86,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 			return -1;
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			__be16 _frag_off, *fp;
+
 			fp = skb_header_pointer(skb,
 						start+offsetof(struct frag_hdr,
 							       frag_off),
@@ -209,6 +210,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 	do {
 		struct ipv6_opt_hdr _hdr, *hp;
 		unsigned int hdrlen;
+
 		found = (nexthdr == target);
 
 		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 06ba3e5..db1e6cc 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -157,6 +157,7 @@ static bool is_ineligible(const struct sk_buff *skb)
 		return false;
 	if (nexthdr == IPPROTO_ICMPV6) {
 		u8 _type, *tp;
+
 		tp = skb_header_pointer(skb,
 			ptr+offsetof(struct icmp6hdr, icmp6_type),
 			sizeof(_type), &_type);
@@ -503,7 +504,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	msg.type = type;
 
 	len = skb->len - msg.offset;
-	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) -sizeof(struct icmp6hdr));
+	len = min_t(unsigned int, len, IPV6_MIN_MTU - sizeof(struct ipv6hdr) - sizeof(struct icmp6hdr));
 	if (len < 0) {
 		LIMIT_NETDEBUG(KERN_DEBUG "icmp: len problem\n");
 		goto out_dst_release;
@@ -636,7 +637,7 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 		/* now skip over extension headers */
 		inner_offset = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr),
 						&nexthdr, &frag_off);
-		if (inner_offset<0)
+		if (inner_offset < 0)
 			goto out;
 	} else {
 		inner_offset = sizeof(struct ipv6hdr);
@@ -808,7 +809,7 @@ void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->saddr = *saddr;
 	fl6->daddr = *daddr;
-	fl6->flowi6_proto 	= IPPROTO_ICMPV6;
+	fl6->flowi6_proto	= IPPROTO_ICMPV6;
 	fl6->fl6_icmp_type	= type;
 	fl6->fl6_icmp_code	= 0;
 	fl6->flowi6_oif		= oif;
@@ -875,8 +876,8 @@ static void __net_exit icmpv6_sk_exit(struct net *net)
 }
 
 static struct pernet_operations icmpv6_sk_ops = {
-       .init = icmpv6_sk_init,
-       .exit = icmpv6_sk_exit,
+	.init = icmpv6_sk_init,
+	.exit = icmpv6_sk_exit,
 };
 
 int __init icmpv6_init(void)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index a245e5d..29b3220 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -63,7 +63,6 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 
 	return sk2 != NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
 struct dst_entry *inet6_csk_route_req(struct sock *sk,
@@ -144,7 +143,6 @@ struct request_sock *inet6_csk_search_req(const struct sock *sk,
 
 	return NULL;
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_search_req);
 
 void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
@@ -160,10 +158,9 @@ void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
 	inet_csk_reqsk_queue_added(sk, timeout);
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
 
-void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
+void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 {
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
 
@@ -175,7 +172,6 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 	sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
 						  sk->sk_bound_dev_if);
 }
-
 EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
 
 static inline
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 262e13c..22dfc36 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -6,7 +6,7 @@
  *		Generic INET6 transport hashtables
  *
  * Authors:	Lotsa people, from code originally in tcp, generalised here
- * 		by Arnaldo Carvalho de Melo <acme@mandriva.com>
+ *		by Arnaldo Carvalho de Melo <acme@mandriva.com>
  *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
@@ -222,7 +222,6 @@ begin:
 	rcu_read_unlock();
 	return result;
 }
-
 EXPORT_SYMBOL_GPL(inet6_lookup_listener);
 
 struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
@@ -238,7 +237,6 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 
 	return sk;
 }
-
 EXPORT_SYMBOL_GPL(inet6_lookup);
 
 static int __inet6_check_established(struct inet_timewait_death_row *death_row,
@@ -324,5 +322,4 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 	return __inet_hash_connect(death_row, sk, inet6_sk_port_offset(sk),
 			__inet6_check_established, __inet6_hash);
 }
-
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index cb4459b..42b5277 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -107,6 +107,7 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 static __inline__ u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
+
 	if ((__s32)n <= 0)
 		rt_sernum = n = 1;
 	return n;
@@ -1031,6 +1032,7 @@ static struct fib6_node *fib6_lookup_1(struct fib6_node *root,
 #ifdef CONFIG_IPV6_SUBTREES
 				if (fn->subtree) {
 					struct fib6_node *sfn;
+
 					sfn = fib6_lookup_1(fn->subtree,
 							    args + 1);
 					if (!sfn)
@@ -1961,6 +1963,7 @@ static void *ipv6_route_seq_start(struct seq_file *seq, loff_t *pos)
 static bool ipv6_route_iter_active(struct ipv6_route_iter *iter)
 {
 	struct fib6_walker_t *w = &iter->w;
+
 	return w->node && !(w->state == FWS_U && w->node == w->root);
 }
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 4052694..17d3f4f 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -113,11 +113,13 @@ static void fl_release(struct ip6_flowlabel *fl)
 	fl->lastuse = jiffies;
 	if (atomic_dec_and_test(&fl->users)) {
 		unsigned long ttd = fl->lastuse + fl->linger;
+
 		if (time_after(ttd, fl->expires))
 			fl->expires = ttd;
 		ttd = fl->expires;
 		if (fl->opt && fl->share == IPV6_FL_S_EXCL) {
 			struct ipv6_txoptions *opt = fl->opt;
+
 			fl->opt = NULL;
 			kfree(opt);
 		}
@@ -136,7 +138,7 @@ static void ip6_fl_gc(unsigned long dummy)
 
 	spin_lock(&ip6_fl_lock);
 
-	for (i=0; i<=FL_HASH_MASK; i++) {
+	for (i = 0; i <= FL_HASH_MASK; i++) {
 		struct ip6_flowlabel *fl;
 		struct ip6_flowlabel __rcu **flp;
 
@@ -145,6 +147,7 @@ static void ip6_fl_gc(unsigned long dummy)
 						       lockdep_is_held(&ip6_fl_lock))) != NULL) {
 			if (atomic_read(&fl->users) == 0) {
 				unsigned long ttd = fl->lastuse + fl->linger;
+
 				if (time_after(ttd, fl->expires))
 					fl->expires = ttd;
 				ttd = fl->expires;
@@ -239,7 +242,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 
 /* Socket flowlabel lists */
 
-struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
+struct ip6_flowlabel *fl6_sock_lookup(struct sock *sk, __be32 label)
 {
 	struct ipv6_fl_socklist *sfl;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -249,6 +252,7 @@ struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
 	rcu_read_lock_bh();
 	for_each_sk_fl_rcu(np, sfl) {
 		struct ip6_flowlabel *fl = sfl->fl;
+
 		if (fl->label == label) {
 			fl->lastuse = jiffies;
 			atomic_inc(&fl->users);
@@ -259,7 +263,6 @@ struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
 	rcu_read_unlock_bh();
 	return NULL;
 }
-
 EXPORT_SYMBOL_GPL(fl6_sock_lookup);
 
 void fl6_free_socklist(struct sock *sk)
@@ -293,11 +296,11 @@ void fl6_free_socklist(struct sock *sk)
    following rthdr.
  */
 
-struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
-					 struct ip6_flowlabel * fl,
-					 struct ipv6_txoptions * fopt)
+struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
+					 struct ip6_flowlabel *fl,
+					 struct ipv6_txoptions *fopt)
 {
-	struct ipv6_txoptions * fl_opt = fl->opt;
+	struct ipv6_txoptions *fl_opt = fl->opt;
 
 	if (fopt == NULL || fopt->opt_flen == 0)
 		return fl_opt;
@@ -388,7 +391,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 			goto done;
 
 		msg.msg_controllen = olen;
-		msg.msg_control = (void*)(fl->opt+1);
+		msg.msg_control = (void *)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
 
 		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
@@ -517,7 +520,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_flowlabel_req freq;
-	struct ipv6_fl_socklist *sfl1=NULL;
+	struct ipv6_fl_socklist *sfl1 = NULL;
 	struct ipv6_fl_socklist *sfl;
 	struct ipv6_fl_socklist __rcu **sflp;
 	struct ip6_flowlabel *fl, *fl1 = NULL;
@@ -542,7 +545,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 		}
 		spin_lock_bh(&ip6_sk_fl_lock);
 		for (sflp = &np->ipv6_fl_list;
-		     (sfl = rcu_dereference(*sflp))!=NULL;
+		     (sfl = rcu_dereference(*sflp)) != NULL;
 		     sflp = &sfl->next) {
 			if (sfl->fl->label == freq.flr_label) {
 				if (freq.flr_label == (np->flow_label&IPV6_FLOWLABEL_MASK))
@@ -582,6 +585,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
 	case IPV6_FL_A_GET:
 		if (freq.flr_flags & IPV6_FL_F_REFLECT) {
 			struct net *net = sock_net(sk);
+
 			if (net->ipv6.sysctl.flowlabel_consistency) {
 				net_info_ratelimited("Can not set IPV6_FL_F_REFLECT if flowlabel_consistency sysctl is enable\n");
 				return -EPERM;
@@ -736,6 +740,7 @@ out:
 static struct ip6_flowlabel *ip6fl_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct ip6_flowlabel *fl = ip6fl_get_first(seq);
+
 	if (fl)
 		while (pos && (fl = ip6fl_get_next(seq, fl)) != NULL)
 			--pos;
@@ -770,11 +775,13 @@ static void ip6fl_seq_stop(struct seq_file *seq, void *v)
 static int ip6fl_seq_show(struct seq_file *seq, void *v)
 {
 	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
+
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
 			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
 	else {
 		struct ip6_flowlabel *fl = v;
+
 		seq_printf(seq,
 			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
 			   (unsigned int)ntohl(fl->label),
@@ -823,6 +830,7 @@ static int ip6fl_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
 	struct ip6fl_iter_state *state = ip6fl_seq_private(seq);
+
 	put_pid_ns(state->pid_ns);
 	return seq_release_net(inode, file);
 }
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 5f19dfb..dd44635 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -819,6 +819,7 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
 	if (offset > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
+
 		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
 		if (tel->encap_limit == 0) {
 			icmpv6_send(skb, ICMPV6_PARAMPROB,
@@ -1262,6 +1263,7 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 
 	for_each_possible_cpu(i) {
 		struct pcpu_sw_netstats *ip6gre_tunnel_stats;
+
 		ip6gre_tunnel_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ip6gre_tunnel_stats->syncp);
 	}
@@ -1303,6 +1305,7 @@ static void ip6gre_destroy_tunnels(struct net *net, struct list_head *head)
 
 	for (prio = 0; prio < 4; prio++) {
 		int h;
+
 		for (h = 0; h < HASH_SIZE; h++) {
 			struct ip6_tnl *t;
 
diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
index 4578e23..14dacc5 100644
--- a/net/ipv6/ip6_icmp.c
+++ b/net/ipv6/ip6_icmp.c
@@ -13,7 +13,7 @@ static ip6_icmp_send_t __rcu *ip6_icmp_send;
 int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
 {
 	return (cmpxchg((ip6_icmp_send_t **)&ip6_icmp_send, NULL, fn) == NULL) ?
-	        0 : -EBUSY;
+		0 : -EBUSY;
 }
 EXPORT_SYMBOL(inet6_register_icmp_sender);
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 51d54dc..a3084ab 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -15,8 +15,8 @@
  */
 /* Changes
  *
- * 	Mitsuru KANDA @USAGI and
- * 	YOSHIFUJI Hideaki @USAGI: Remove ipv6_parse_exthdrs().
+ *	Mitsuru KANDA @USAGI and
+ *	YOSHIFUJI Hideaki @USAGI: Remove ipv6_parse_exthdrs().
  */
 
 #include <linux/errno.h>
@@ -65,7 +65,7 @@ int ip6_rcv_finish(struct sk_buff *skb)
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	const struct ipv6hdr *hdr;
-	u32 		pkt_len;
+	u32 pkt_len;
 	struct inet6_dev *idev;
 	struct net *net = dev_net(skb->dev);
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 65eda2a..5bcda33 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -244,7 +244,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 			continue;
 
 		iph2 = (struct ipv6hdr *)(p->data + off);
-		first_word = *(__be32 *)iph ^ *(__be32 *)iph2 ;
+		first_word = *(__be32 *)iph ^ *(__be32 *)iph2;
 
 		/* All fields must match except length and Traffic Class.
 		 * XXX skbs on the gro_list have all been parsed and pulled
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 315a55d..45b451a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -20,7 +20,7 @@
  *				etc.
  *
  *      H. von Brand    :       Added missing #include <linux/string.h>
- *	Imran Patel	: 	frag id should be in NBO
+ *	Imran Patel	:	frag id should be in NBO
  *      Kazunori MIYAZAWA @USAGI
  *			:       add ip6_append_data and related functions
  *				for datagram xmit
@@ -136,6 +136,7 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
+
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(dev_net(dev), idev,
 			      IPSTATS_MIB_OUTDISCARDS);
@@ -177,6 +178,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
+
 			if (skb2 == NULL) {
 				IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
 					      IPSTATS_MIB_OUTDISCARDS);
@@ -233,7 +235,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
-
 EXPORT_SYMBOL(ip6_xmit);
 
 static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
@@ -244,11 +245,13 @@ static int ip6_call_ra_chain(struct sk_buff *skb, int sel)
 	read_lock(&ip6_ra_lock);
 	for (ra = ip6_ra_chain; ra; ra = ra->next) {
 		struct sock *sk = ra->sk;
+
 		if (sk && ra->sel == sel &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == skb->dev->ifindex)) {
 			if (last) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 				if (skb2)
 					rawv6_rcv(last, skb2);
 			}
@@ -422,6 +425,7 @@ int ip6_forward(struct sk_buff *skb)
 	if (net->ipv6.devconf_all->proxy_ndp &&
 	    pneigh_lookup(&nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
+
 		if (proxied > 0)
 			return ip6_input(skb);
 		else if (proxied < 0) {
@@ -555,14 +559,14 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
-	struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
 	int hroom, troom;
 	__be32 frag_id = 0;
-	int ptr, offset = 0, err=0;
+	int ptr, offset = 0, err = 0;
 	u8 *prevhdr, nexthdr = 0;
 	struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -637,7 +641,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		__skb_pull(skb, hlen);
-		fh = (struct frag_hdr*)__skb_push(skb, sizeof(struct frag_hdr));
+		fh = (struct frag_hdr *)__skb_push(skb, sizeof(struct frag_hdr));
 		__skb_push(skb, hlen);
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
@@ -662,7 +666,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			if (frag) {
 				frag->ip_summed = CHECKSUM_NONE;
 				skb_reset_transport_header(frag);
-				fh = (struct frag_hdr*)__skb_push(frag, sizeof(struct frag_hdr));
+				fh = (struct frag_hdr *)__skb_push(frag, sizeof(struct frag_hdr));
 				__skb_push(frag, hlen);
 				skb_reset_network_header(frag);
 				memcpy(skb_network_header(frag), tmp_hdr,
@@ -681,7 +685,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			}
 
 			err = output(skb);
-			if(!err)
+			if (!err)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
 
@@ -742,7 +746,7 @@ slow_path:
 	/*
 	 *	Keep copying data until we run out.
 	 */
-	while(left > 0)	{
+	while (left > 0)	{
 		len = left;
 		/* IF: it doesn't fit, use 'mtu' - the data space left */
 		if (len > mtu)
@@ -865,7 +869,7 @@ static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 	/* Yes, checking route validity in not connected
 	 * case is not very simple. Take into account,
 	 * that we do not support routing by source, TOS,
-	 * and MSG_DONTROUTE 		--ANK (980726)
+	 * and MSG_DONTROUTE		--ANK (980726)
 	 *
 	 * 1. ip6_rt_check(): If route was host route,
 	 *    check that cached destination is current.
@@ -910,6 +914,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 
 	if (ipv6_addr_any(&fl6->saddr)) {
 		struct rt6_info *rt = (struct rt6_info *) *dst;
+
 		err = ip6_route_get_saddr(net, rt, &fl6->daddr,
 					  sk ? inet6_sk(sk)->srcprefs : 0,
 					  &fl6->saddr);
@@ -1049,7 +1054,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu,unsigned int flags,
+			int transhdrlen, int mtu, unsigned int flags,
 			struct rt6_info *rt)
 
 {
@@ -1072,7 +1077,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb_reserve(skb, hh_len);
 
 		/* create space for UDP/IP header */
-		skb_put(skb,fragheaderlen + transhdrlen);
+		skb_put(skb, fragheaderlen + transhdrlen);
 
 		/* initialize network header pointer */
 		skb_reset_network_header(skb);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f9de5a6..fe4f516 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -67,7 +67,7 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 #ifdef IP6_TNL_DEBUG
 #define IP6_TNL_TRACE(x...) pr_debug("%s:" x "\n", __func__)
 #else
-#define IP6_TNL_TRACE(x...) do {;} while(0)
+#define IP6_TNL_TRACE(x...) do {; } while (0)
 #endif
 
 #define HASH_SIZE_SHIFT  5
@@ -157,6 +157,7 @@ EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
+
 	t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 	dst_release(t->dst_cache);
 	t->dst_cache = dst;
@@ -408,18 +409,20 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 {
 	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
 	__u8 nexthdr = ipv6h->nexthdr;
-	__u16 off = sizeof (*ipv6h);
+	__u16 off = sizeof(*ipv6h);
 
 	while (ipv6_ext_hdr(nexthdr) && nexthdr != NEXTHDR_NONE) {
 		__u16 optlen = 0;
 		struct ipv6_opt_hdr *hdr;
-		if (raw + off + sizeof (*hdr) > skb->data &&
-		    !pskb_may_pull(skb, raw - skb->data + off + sizeof (*hdr)))
+
+		if (raw + off + sizeof(*hdr) > skb->data &&
+		    !pskb_may_pull(skb, raw - skb->data + off + sizeof(*hdr)))
 			break;
 
 		hdr = (struct ipv6_opt_hdr *) (raw + off);
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			struct frag_hdr *frag_hdr = (struct frag_hdr *) hdr;
+
 			if (frag_hdr->frag_off)
 				break;
 			optlen = 8;
@@ -430,11 +433,12 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 		}
 		if (nexthdr == NEXTHDR_DEST) {
 			__u16 i = off + 2;
+
 			while (1) {
 				struct ipv6_tlv_tnl_enc_lim *tel;
 
 				/* No more room for encapsulation limit */
-				if (i + sizeof (*tel) > off + optlen)
+				if (i + sizeof(*tel) > off + optlen)
 					break;
 
 				tel = (struct ipv6_tlv_tnl_enc_lim *) &raw[i];
@@ -530,7 +534,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
 
-		if ((len = sizeof (*ipv6h) + ntohs(ipv6h->payload_len)) > mtu) {
+		if ((len = sizeof(*ipv6h) + ntohs(ipv6h->payload_len)) > mtu) {
 			rel_type = ICMPV6_PKT_TOOBIG;
 			rel_code = 0;
 			rel_info = mtu;
@@ -991,7 +995,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 				     t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_mtu(dst) - sizeof (*ipv6h);
+	mtu = dst_mtu(dst) - sizeof(*ipv6h);
 	if (encap_limit >= 0) {
 		max_headroom += 8;
 		mtu -= 8;
@@ -1083,7 +1087,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_IPIP;
 
 	dsfield = ipv4_get_dsfield(iph);
@@ -1125,6 +1129,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
 	if (offset > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
+
 		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
 		if (tel->encap_limit == 0) {
 			icmpv6_send(skb, ICMPV6_PARAMPROB,
@@ -1135,7 +1140,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		encap_limit = t->parms.encap_limit;
 
-	memcpy(&fl6, &t->fl.u.ip6, sizeof (fl6));
+	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_IPV6;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
@@ -1229,11 +1234,11 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 
 		if (rt->dst.dev) {
 			dev->hard_header_len = rt->dst.dev->hard_header_len +
-				sizeof (struct ipv6hdr);
+				sizeof(struct ipv6hdr);
 
-			dev->mtu = rt->dst.dev->mtu - sizeof (struct ipv6hdr);
+			dev->mtu = rt->dst.dev->mtu - sizeof(struct ipv6hdr);
 			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-				dev->mtu-=8;
+				dev->mtu -= 8;
 
 			if (dev->mtu < IPV6_MIN_MTU)
 				dev->mtu = IPV6_MIN_MTU;
@@ -1350,7 +1355,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		if (dev == ip6n->fb_tnl_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
 			}
@@ -1362,7 +1367,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			memset(&p, 0, sizeof(p));
 		}
 		ip6_tnl_parm_to_user(&p, &t->parms);
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof (p))) {
+		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p))) {
 			err = -EFAULT;
 		}
 		break;
@@ -1372,7 +1377,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
 		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
+		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 			break;
 		err = -EINVAL;
 		if (p.proto != IPPROTO_IPV6 && p.proto != IPPROTO_IPIP &&
@@ -1407,7 +1412,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		if (dev == ip6n->fb_tnl_dev) {
 			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
+			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				break;
 			err = -ENOENT;
 			ip6_tnl_parm_from_user(&p1, &p);
@@ -1482,11 +1487,11 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->destructor = ip6_dev_free;
 
 	dev->type = ARPHRD_TUNNEL6;
-	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
-	dev->mtu = ETH_DATA_LEN - sizeof (struct ipv6hdr);
+	dev->hard_header_len = LL_MAX_HEADER + sizeof(struct ipv6hdr);
+	dev->mtu = ETH_DATA_LEN - sizeof(struct ipv6hdr);
 	t = netdev_priv(dev);
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		dev->mtu-=8;
+		dev->mtu -= 8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f9a3fd3..f80651b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -803,6 +803,7 @@ static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
 
 	if (vifi + 1 == mrt->maxvif) {
 		int tmp;
+
 		for (tmp = vifi - 1; tmp >= 0; tmp--) {
 			if (MIF_EXISTS(mrt, tmp))
 				break;
@@ -845,9 +846,10 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 
 	atomic_dec(&mrt->cache_resolve_queue_len);
 
-	while((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
+	while ((skb = skb_dequeue(&c->mfc_un.unres.unresolved)) != NULL) {
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
+
 			nlh->nlmsg_type = NLMSG_ERROR;
 			nlh->nlmsg_len = nlmsg_msg_size(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
@@ -873,6 +875,7 @@ static void ipmr_do_expire_process(struct mr6_table *mrt)
 		if (time_after(c->mfc_un.unres.expires, now)) {
 			/* not yet... */
 			unsigned long interval = c->mfc_un.unres.expires - now;
+
 			if (interval < expires)
 				expires = interval;
 			continue;
@@ -1074,6 +1077,7 @@ skip:
 static struct mfc6_cache *ip6mr_cache_alloc(void)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
+
 	if (c == NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXMIFS;
@@ -1083,6 +1087,7 @@ static struct mfc6_cache *ip6mr_cache_alloc(void)
 static struct mfc6_cache *ip6mr_cache_alloc_unres(void)
 {
 	struct mfc6_cache *c = kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
+
 	if (c == NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
@@ -1103,7 +1108,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 	 *	Play the pending entries through our router
 	 */
 
-	while((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
+	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ipv6_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
@@ -1591,9 +1596,10 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
 					     NETCONFA_IFINDEX_ALL,
 					     net->ipv6.devconf_all);
-	}
-	else
+	} else {
 		err = -EADDRINUSE;
+	}
+
 	write_unlock_bh(&mrt_lock);
 
 	rtnl_unlock();
@@ -2149,6 +2155,7 @@ forward:
 		    ipv6_hdr(skb)->hop_limit > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 				if (skb2)
 					ip6mr_forward2(net, mrt, skb2, cache, psend);
 			}
@@ -2208,6 +2215,7 @@ int ip6_mr_input(struct sk_buff *skb)
 		vif = ip6mr_find_vif(mrt, skb->dev);
 		if (vif >= 0) {
 			int err = ip6mr_cache_unresolved(mrt, vif, skb);
+
 			read_unlock(&mrt_lock);
 
 			return err;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index d1c793c..1b9316e 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -181,8 +181,7 @@ static int ipcomp6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type ipcomp6_type =
-{
+static const struct xfrm_type ipcomp6_type = {
 	.description	= "IPCOMP6",
 	.owner		= THIS_MODULE,
 	.proto		= IPPROTO_COMP,
@@ -193,8 +192,7 @@ static const struct xfrm_type ipcomp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static struct xfrm6_protocol ipcomp6_protocol =
-{
+static struct xfrm6_protocol ipcomp6_protocol = {
 	.handler	= xfrm6_rcv,
 	.cb_handler	= ipcomp6_rcv_cb,
 	.err_handler	= ipcomp6_err,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 0c28998..9a77da2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -66,12 +66,12 @@ int ip6_ra_control(struct sock *sk, int sel)
 	if (sk->sk_type != SOCK_RAW || inet_sk(sk)->inet_num != IPPROTO_RAW)
 		return -ENOPROTOOPT;
 
-	new_ra = (sel>=0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
+	new_ra = (sel >= 0) ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
 	write_lock_bh(&ip6_ra_lock);
-	for (rap = &ip6_ra_chain; (ra=*rap) != NULL; rap = &ra->next) {
+	for (rap = &ip6_ra_chain; (ra = *rap) != NULL; rap = &ra->next) {
 		if (ra->sk == sk) {
-			if (sel>=0) {
+			if (sel >= 0) {
 				write_unlock_bh(&ip6_ra_lock);
 				kfree(new_ra);
 				return -EADDRINUSE;
@@ -107,6 +107,7 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 		    !((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
 		    inet_sk(sk)->inet_daddr != LOOPBACK4_IPV6) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
+
 			icsk->icsk_ext_hdr_len = opt->opt_flen + opt->opt_nflen;
 			icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		}
@@ -130,7 +131,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	int retv = -ENOPROTOOPT;
 
 	if (optval == NULL)
-		val=0;
+		val = 0;
 	else {
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
@@ -139,7 +140,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			val = 0;
 	}
 
-	valbool = (val!=0);
+	valbool = (val != 0);
 
 	if (ip6_mroute_opt(optname))
 		return ip6_mroute_setsockopt(sk, optname, optval, optlen);
@@ -161,6 +162,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			if (sk->sk_protocol == IPPROTO_UDP ||
 			    sk->sk_protocol == IPPROTO_UDPLITE) {
 				struct udp_sock *up = udp_sk(sk);
+
 				if (up->pending == AF_INET6) {
 					retv = -EBUSY;
 					break;
@@ -191,6 +193,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 			if (sk->sk_protocol == IPPROTO_TCP) {
 				struct inet_connection_sock *icsk = inet_csk(sk);
+
 				local_bh_disable();
 				sock_prot_inuse_add(net, sk->sk_prot, -1);
 				sock_prot_inuse_add(net, &tcp_prot, 1);
@@ -397,6 +400,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = -EINVAL;
 		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
+
 			switch (rthdr->type) {
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 			case IPV6_SRCRT_TYPE_2:
@@ -474,7 +478,7 @@ sticky_done:
 			goto done;
 
 		msg.msg_controllen = optlen;
-		msg.msg_control = (void*)(opt+1);
+		msg.msg_control = (void *)(opt+1);
 
 		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
 					     &junk, &junk);
@@ -687,7 +691,7 @@ done:
 			retv = -ENOBUFS;
 			break;
 		}
-		gsf = kmalloc(optlen,GFP_KERNEL);
+		gsf = kmalloc(optlen, GFP_KERNEL);
 		if (!gsf) {
 			retv = -ENOBUFS;
 			break;
@@ -873,7 +877,6 @@ int ipv6_setsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(ipv6_setsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -909,7 +912,6 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ipv6_setsockopt);
 #endif
 
@@ -921,7 +923,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	if (!opt)
 		return 0;
 
-	switch(optname) {
+	switch (optname) {
 	case IPV6_HOPOPTS:
 		hdr = opt->hopopt;
 		break;
@@ -1011,6 +1013,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		} else {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
+
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
 				src_info.ipi6_addr = np->mcast_oif ? sk->sk_v6_daddr : np->sticky_pktinfo.ipi6_addr;
@@ -1018,6 +1021,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxhlim) {
 				int hlim = np->mcast_hops;
+
 				put_cmsg(&msg, SOL_IPV6, IPV6_HOPLIMIT, sizeof(hlim), &hlim);
 			}
 			if (np->rxopt.bits.rxtclass) {
@@ -1027,6 +1031,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxoinfo) {
 				struct in6_pktinfo src_info;
+
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
 				src_info.ipi6_addr = np->mcast_oif ? sk->sk_v6_daddr :
@@ -1035,6 +1040,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			}
 			if (np->rxopt.bits.rxohlim) {
 				int hlim = np->mcast_hops;
+
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
 			}
 			if (np->rxopt.bits.rxflow) {
@@ -1284,9 +1290,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		return -ENOPROTOOPT;
 	}
 	len = min_t(unsigned int, sizeof(int), len);
-	if(put_user(len, optlen))
+	if (put_user(len, optlen))
 		return -EFAULT;
-	if(copy_to_user(optval,&val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
@@ -1299,7 +1305,7 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if (level == SOL_IP && sk->sk_type != SOCK_RAW)
 		return udp_prot.getsockopt(sk, level, optname, optval, optlen);
 
-	if(level != SOL_IPV6)
+	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen, 0);
@@ -1321,7 +1327,6 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(ipv6_getsockopt);
 
 #ifdef CONFIG_COMPAT
@@ -1364,7 +1369,6 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ipv6_getsockopt);
 #endif
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 617f095..66ca147 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -175,6 +175,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
+
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->dst.dev;
@@ -232,7 +233,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rcu_dereference_protected(*lnk,
-			lockdep_is_held(&ipv6_sk_mc_lock))) !=NULL ;
+			lockdep_is_held(&ipv6_sk_mc_lock))) != NULL;
 	      lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
@@ -390,7 +391,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 			if (rv == 0)
 				break;
@@ -407,7 +408,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		/* update the interface filter */
 		ip6_mc_del_src(idev, group, omode, 1, source, 1);
 
-		for (j=i+1; j<psl->sl_count; j++)
+		for (j = i+1; j < psl->sl_count; j++)
 			psl->sl_addr[j-1] = psl->sl_addr[j];
 		psl->sl_count--;
 		err = 0;
@@ -433,19 +434,19 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		newpsl->sl_max = count;
 		newpsl->sl_count = count - IP6_SFBLOCK;
 		if (psl) {
-			for (i=0; i<psl->sl_count; i++)
+			for (i = 0; i < psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 		}
 		pmc->sflist = psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
-	for (i=0; i<psl->sl_count; i++) {
+	for (i = 0; i < psl->sl_count; i++) {
 		rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
 		if (rv == 0) /* There is an error in the address. */
 			goto done;
 	}
-	for (j=psl->sl_count-1; j>=i; j--)
+	for (j = psl->sl_count-1; j >= i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;
 	psl->sl_count++;
@@ -514,7 +515,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 			goto done;
 		}
 		newpsl->sl_max = newpsl->sl_count = gsf->gf_numsrc;
-		for (i=0; i<newpsl->sl_count; ++i) {
+		for (i = 0; i < newpsl->sl_count; ++i) {
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&gsf->gf_slist[i];
@@ -606,7 +607,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
 	 * have the socket lock, so reading here is safe.
 	 */
-	for (i=0; i<copycount; i++) {
+	for (i = 0; i < copycount; i++) {
 		struct sockaddr_in6 *psin6;
 		struct sockaddr_storage ss;
 
@@ -648,7 +649,7 @@ bool inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	} else {
 		int i;
 
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			if (ipv6_addr_equal(&psl->sl_addr[i], src_addr))
 				break;
 		}
@@ -762,7 +763,7 @@ static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 		pmc->mca_tomb = im->mca_tomb;
 		pmc->mca_sources = im->mca_sources;
 		im->mca_tomb = im->mca_sources = NULL;
-		for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = pmc->mca_crcount;
 	}
 	spin_unlock_bh(&im->mca_lock);
@@ -780,7 +781,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 
 	spin_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(&pmc->mca_addr, pmca))
 			break;
 		pmc_prev = pmc;
@@ -794,7 +795,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 	spin_unlock_bh(&idev->mc_lock);
 
 	if (pmc) {
-		for (psf=pmc->mca_tomb; psf; psf=psf_next) {
+		for (psf = pmc->mca_tomb; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -821,14 +822,14 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 
 	/* clear dead sources, too */
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		struct ip6_sf_list *psf, *psf_next;
 
 		spin_lock_bh(&pmc->mca_lock);
 		psf = pmc->mca_tomb;
 		pmc->mca_tomb = NULL;
 		spin_unlock_bh(&pmc->mca_lock);
-		for (; psf; psf=psf_next) {
+		for (; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -917,7 +918,7 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 	struct ifmcaddr6 *ma, **map;
 
 	write_lock_bh(&idev->lock);
-	for (map = &idev->mc_list; (ma=*map) != NULL; map = &ma->next) {
+	for (map = &idev->mc_list; (ma = *map) != NULL; map = &ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
 			if (--ma->mca_users == 0) {
 				*map = ma->next;
@@ -968,7 +969,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
-		for (mc = idev->mc_list; mc; mc=mc->next) {
+		for (mc = idev->mc_list; mc; mc = mc->next) {
 			if (ipv6_addr_equal(&mc->mca_addr, group))
 				break;
 		}
@@ -977,7 +978,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 				struct ip6_sf_list *psf;
 
 				spin_lock_bh(&mc->mca_lock);
-				for (psf=mc->mca_sources;psf;psf=psf->sf_next) {
+				for (psf = mc->mca_sources; psf; psf = psf->sf_next) {
 					if (ipv6_addr_equal(&psf->sf_addr, src_addr))
 						break;
 				}
@@ -986,7 +987,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 						psf->sf_count[MCAST_EXCLUDE] !=
 						mc->mca_sfcount[MCAST_EXCLUDE];
 				else
-					rv = mc->mca_sfcount[MCAST_EXCLUDE] !=0;
+					rv = mc->mca_sfcount[MCAST_EXCLUDE] != 0;
 				spin_unlock_bh(&mc->mca_lock);
 			} else
 				rv = true; /* don't filter unspecified source */
@@ -1077,10 +1078,10 @@ static bool mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 	int i, scount;
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			/* skip inactive filters */
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
@@ -1110,10 +1111,10 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	/* mark INCLUDE-mode sources */
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				psf->sf_gsresp = 1;
 				scount++;
@@ -1364,13 +1365,13 @@ int igmp6_event_query(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	if (group_type == IPV6_ADDR_ANY) {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			spin_lock_bh(&ma->mca_lock);
 			igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 		}
 	} else {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			if (!ipv6_addr_equal(group, &ma->mca_addr))
 				continue;
 			spin_lock_bh(&ma->mca_lock);
@@ -1434,7 +1435,7 @@ int igmp6_event_report(struct sk_buff *skb)
 	 */
 
 	read_lock_bh(&idev->lock);
-	for (ma = idev->mc_list; ma; ma=ma->next) {
+	for (ma = idev->mc_list; ma; ma = ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
@@ -1498,7 +1499,7 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 	struct ip6_sf_list *psf;
 	int scount = 0;
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (!is_in(pmc, psf, type, gdeleted, sdeleted))
 			continue;
 		scount++;
@@ -1646,7 +1647,8 @@ err_out:
 
 static int grec_size(struct ifmcaddr6 *pmc, int type, int gdel, int sdel)
 {
-	return sizeof(struct mld2_grec) + 16 * mld_scount(pmc,type,gdel,sdel);
+	return sizeof(struct mld2_grec) +
+		16 * mld_scount(pmc, type, gdel, sdel);
 }
 
 static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
@@ -1712,7 +1714,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	}
 	first = 1;
 	psf_prev = NULL;
-	for (psf=*psf_list; psf; psf=psf_next) {
+	for (psf = *psf_list; psf; psf = psf_next) {
 		struct in6_addr *psrc;
 
 		psf_next = psf->sf_next;
@@ -1791,7 +1793,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 
 	read_lock_bh(&idev->lock);
 	if (!pmc) {
-		for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+		for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 			if (pmc->mca_flags & MAF_NOREPORT)
 				continue;
 			spin_lock_bh(&pmc->mca_lock);
@@ -1824,7 +1826,7 @@ static void mld_clear_zeros(struct ip6_sf_list **ppsf)
 	struct ip6_sf_list *psf_prev, *psf_next, *psf;
 
 	psf_prev = NULL;
-	for (psf=*ppsf; psf; psf = psf_next) {
+	for (psf = *ppsf; psf; psf = psf_next) {
 		psf_next = psf->sf_next;
 		if (psf->sf_crcount == 0) {
 			if (psf_prev)
@@ -1848,7 +1850,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc_next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc_next) {
 		pmc_next = pmc->next;
 		if (pmc->mca_sfmode == MCAST_INCLUDE) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -1881,7 +1883,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 	spin_unlock(&idev->mc_lock);
 
 	/* change recs */
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -2018,7 +2020,7 @@ static void mld_send_initial_cr(struct inet6_dev *idev)
 
 	skb = NULL;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE])
 			type = MLD2_CHANGE_TO_EXCLUDE;
@@ -2063,7 +2065,7 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	int rv = 0;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -2104,7 +2106,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -2124,7 +2126,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfcount[sfmode]--;
 	}
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		int rv = ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
@@ -2140,7 +2142,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfmode = MCAST_INCLUDE;
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(pmc->idev);
 	} else if (sf_setstate(pmc) || changerec)
@@ -2159,7 +2161,7 @@ static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
 	struct ip6_sf_list *psf, *psf_prev;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -2184,7 +2186,7 @@ static void sf_markstate(struct ifmcaddr6 *pmc)
 	struct ip6_sf_list *psf;
 	int mca_xcount = pmc->mca_sfcount[MCAST_EXCLUDE];
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			psf->sf_oldin = mca_xcount ==
 				psf->sf_count[MCAST_EXCLUDE] &&
@@ -2201,7 +2203,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 	int new_in, rv;
 
 	rv = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			new_in = mca_xcount == psf->sf_count[MCAST_EXCLUDE] &&
 				!psf->sf_count[MCAST_INCLUDE];
@@ -2211,8 +2213,8 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			if (!psf->sf_oldin) {
 				struct ip6_sf_list *prev = NULL;
 
-				for (dpsf=pmc->mca_tomb; dpsf;
-				     dpsf=dpsf->sf_next) {
+				for (dpsf = pmc->mca_tomb; dpsf;
+				     dpsf = dpsf->sf_next) {
 					if (ipv6_addr_equal(&dpsf->sf_addr,
 					    &psf->sf_addr))
 						break;
@@ -2234,7 +2236,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			 * add or update "delete" records if an active filter
 			 * is now inactive
 			 */
-			for (dpsf=pmc->mca_tomb; dpsf; dpsf=dpsf->sf_next)
+			for (dpsf = pmc->mca_tomb; dpsf; dpsf = dpsf->sf_next)
 				if (ipv6_addr_equal(&dpsf->sf_addr,
 				    &psf->sf_addr))
 					break;
@@ -2268,7 +2270,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -2284,7 +2286,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!delta)
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
@@ -2294,7 +2296,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		if (!delta)
 			pmc->mca_sfcount[sfmode]--;
-		for (j=0; j<i; j++)
+		for (j = 0; j < i; j++)
 			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct ip6_sf_list *psf;
@@ -2308,7 +2310,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(idev);
 	} else if (sf_setstate(pmc))
@@ -2322,12 +2324,12 @@ static void ip6_mc_clear_src(struct ifmcaddr6 *pmc)
 {
 	struct ip6_sf_list *psf, *nextpsf;
 
-	for (psf=pmc->mca_tomb; psf; psf=nextpsf) {
+	for (psf = pmc->mca_tomb; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
 	pmc->mca_tomb = NULL;
-	for (psf=pmc->mca_sources; psf; psf=nextpsf) {
+	for (psf = pmc->mca_sources; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
@@ -2471,7 +2473,7 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	mld_gq_stop_timer(idev);
 	mld_dad_stop_timer(idev);
 
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_dropped(i);
 	read_unlock_bh(&idev->lock);
 
@@ -2488,7 +2490,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
 	/* Install multicast list, except for all-nodes (already installed) */
 
 	read_lock_bh(&idev->lock);
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_added(i);
 	read_unlock_bh(&idev->lock);
 }
@@ -2570,6 +2572,7 @@ static inline struct ifmcaddr6 *igmp6_mc_get_first(struct seq_file *seq)
 	state->idev = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
+
 		idev = __in6_dev_get(state->dev);
 		if (!idev)
 			continue;
@@ -2610,6 +2613,7 @@ static struct ifmcaddr6 *igmp6_mc_get_next(struct seq_file *seq, struct ifmcaddr
 static struct ifmcaddr6 *igmp6_mc_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct ifmcaddr6 *im = igmp6_mc_get_first(seq);
+
 	if (im)
 		while (pos && (im = igmp6_mc_get_next(seq, im)) != NULL)
 			--pos;
@@ -2700,6 +2704,7 @@ static inline struct ip6_sf_list *igmp6_mcf_get_first(struct seq_file *seq)
 	state->im = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct inet6_dev *idev;
+
 		idev = __in6_dev_get(state->dev);
 		if (unlikely(idev == NULL))
 			continue;
@@ -2755,6 +2760,7 @@ out:
 static struct ip6_sf_list *igmp6_mcf_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct ip6_sf_list *psf = igmp6_mcf_get_first(seq);
+
 	if (psf)
 		while (pos && (psf = igmp6_mcf_get_next(seq, psf)) != NULL)
 			--pos;
@@ -2771,6 +2777,7 @@ static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
 static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip6_sf_list *psf;
+
 	if (v == SEQ_START_TOKEN)
 		psf = igmp6_mcf_get_first(seq);
 	else
@@ -2783,6 +2790,7 @@ static void igmp6_mcf_seq_stop(struct seq_file *seq, void *v)
 	__releases(RCU)
 {
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+
 	if (likely(state->im != NULL)) {
 		spin_unlock_bh(&state->im->mca_lock);
 		state->im = NULL;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index db9b6cb..df4160e 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -336,11 +336,10 @@ static void mip6_destopt_destroy(struct xfrm_state *x)
 {
 }
 
-static const struct xfrm_type mip6_destopt_type =
-{
+static const struct xfrm_type mip6_destopt_type = {
 	.description	= "MIP6DESTOPT",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_DSTOPTS,
+	.proto		= IPPROTO_DSTOPTS,
 	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_LOCAL_COADDR,
 	.init_state	= mip6_destopt_init_state,
 	.destructor	= mip6_destopt_destroy,
@@ -418,6 +417,7 @@ static int mip6_rthdr_offset(struct xfrm_state *x, struct sk_buff *skb,
 		case NEXTHDR_ROUTING:
 			if (offset + 3 <= packet_len) {
 				struct ipv6_rt_hdr *rt;
+
 				rt = (struct ipv6_rt_hdr *)(nh + offset);
 				if (rt->type != 0)
 					return offset;
@@ -469,11 +469,10 @@ static void mip6_rthdr_destroy(struct xfrm_state *x)
 {
 }
 
-static const struct xfrm_type mip6_rthdr_type =
-{
+static const struct xfrm_type mip6_rthdr_type = {
 	.description	= "MIP6RT",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_ROUTING,
+	.proto		= IPPROTO_ROUTING,
 	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_REMOTE_COADDR,
 	.init_state	= mip6_rthdr_init_state,
 	.destructor	= mip6_rthdr_destroy,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 339078f..754e0ab 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -170,12 +170,13 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 					    struct nd_opt_hdr *end)
 {
 	int type;
+
 	if (!cur || !end || cur >= end)
 		return NULL;
 	type = cur->nd_opt_type;
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
-	} while(cur < end && cur->nd_opt_type != type);
+	} while (cur < end && cur->nd_opt_type != type);
 	return cur <= end && cur->nd_opt_type == type ? cur : NULL;
 }
 
@@ -192,7 +193,7 @@ static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
 		return NULL;
 	do {
 		cur = ((void *)cur) + (cur->nd_opt_len << 3);
-	} while(cur < end && !ndisc_is_useropt(cur));
+	} while (cur < end && !ndisc_is_useropt(cur));
 	return cur <= end && ndisc_is_useropt(cur) ? cur : NULL;
 }
 
@@ -206,6 +207,7 @@ struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 	memset(ndopts, 0, sizeof(*ndopts));
 	while (opt_len) {
 		int l;
+
 		if (opt_len < sizeof(struct nd_opt_hdr))
 			return NULL;
 		l = nd_opt->nd_opt_len << 3;
@@ -284,7 +286,6 @@ int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
 	}
 	return -EINVAL;
 }
-
 EXPORT_SYMBOL(ndisc_mc_map);
 
 static u32 ndisc_hash(const void *pkey,
@@ -296,7 +297,7 @@ static u32 ndisc_hash(const void *pkey,
 
 static int ndisc_constructor(struct neighbour *neigh)
 {
-	struct in6_addr *addr = (struct in6_addr*)&neigh->primary_key;
+	struct in6_addr *addr = (struct in6_addr *)&neigh->primary_key;
 	struct net_device *dev = neigh->dev;
 	struct inet6_dev *in6_dev;
 	struct neigh_parms *parms;
@@ -344,7 +345,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 
 static int pndisc_constructor(struct pneigh_entry *n)
 {
-	struct in6_addr *addr = (struct in6_addr*)&n->key;
+	struct in6_addr *addr = (struct in6_addr *)&n->key;
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
@@ -357,7 +358,7 @@ static int pndisc_constructor(struct pneigh_entry *n)
 
 static void pndisc_destructor(struct pneigh_entry *n)
 {
-	struct in6_addr *addr = (struct in6_addr*)&n->key;
+	struct in6_addr *addr = (struct in6_addr *)&n->key;
 	struct in6_addr maddr;
 	struct net_device *dev = n->dev;
 
@@ -801,6 +802,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 				 * (RFC2461) -- yoshfuji
 				 */
 				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
+
 				if (n)
 					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
 				goto out;
@@ -1065,7 +1067,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	int optlen;
 	unsigned int pref = 0;
 
-	__u8 * opt = (__u8 *)(ra_msg + 1);
+	__u8 *opt = (__u8 *)(ra_msg + 1);
 
 	optlen = (skb_tail_pointer(skb) - skb_transport_header(skb)) -
 		sizeof(struct ra_msg);
@@ -1270,6 +1272,7 @@ skip_linkparms:
 				       skb->dev, 1);
 	if (neigh) {
 		u8 *lladdr = NULL;
+
 		if (ndopts.nd_opts_src_lladdr) {
 			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
 						     skb->dev);
@@ -1305,10 +1308,12 @@ skip_linkparms:
 
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_ri;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_ri_end)) {
 			struct route_info *ri = (struct route_info *)p;
+
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 			if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT &&
 			    ri->prefix_len == 0)
@@ -1319,7 +1324,7 @@ skip_linkparms:
 				continue;
 			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
-			rt6_route_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3,
+			rt6_route_rcv(skb->dev, (u8 *)p, (p->nd_opt_len) << 3,
 				      &ipv6_hdr(skb)->saddr);
 		}
 	}
@@ -1339,6 +1344,7 @@ skip_routeinfo:
 
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_pi;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
@@ -1352,7 +1358,7 @@ skip_routeinfo:
 		__be32 n;
 		u32 mtu;
 
-		memcpy(&n, ((u8*)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
+		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
 		mtu = ntohl(n);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
@@ -1369,6 +1375,7 @@ skip_routeinfo:
 
 	if (ndopts.nd_useropts) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_useropts;
 		     p;
 		     p = ndisc_next_useropt(p, ndopts.nd_useropts_end)) {
@@ -1498,6 +1505,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	if (dev->addr_len) {
 		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
+
 		if (!neigh) {
 			ND_PRINTK(2, warn,
 				  "Redirect: no neigh for target address\n");
@@ -1671,6 +1679,7 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 {
 	static char warncomm[TASK_COMM_LEN];
 	static int warned;
+
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm, current->comm);
 		pr_warn("process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead\n",
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index d38e6a8..7a15d28 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -100,6 +100,7 @@ static int nf_ip6_reroute(struct sk_buff *skb,
 
 	if (entry->hook == NF_INET_LOCAL_OUT) {
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
+
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr) ||
 		    skb->mark != rt_info->mark)
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 5ec867e..33d6ffb 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -35,7 +35,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 			if (found_rhdr)
 				return offset;
 			break;
-		default :
+		default:
 			return offset;
 		}
 
@@ -53,6 +53,7 @@ EXPORT_SYMBOL(ip6_find_1stfragopt);
 int ip6_dst_hoplimit(struct dst_entry *dst)
 {
 	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
+
 	if (hoplimit == 0) {
 		struct net_device *dev = dst->dev;
 		struct inet6_dev *idev;
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 5b7a1ed..3a142b7 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -102,6 +102,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
+
 		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
 		    u->sin6_family != AF_INET6) {
 			return -EINVAL;
@@ -207,6 +208,7 @@ static int ping_v6_seq_show(struct seq_file *seq, void *v)
 		struct inet_sock *inet = inet_sk(v);
 		__u16 srcp = ntohs(inet->inet_sport);
 		__u16 destp = ntohs(inet->inet_dport);
+
 		ip6_dgram_sock_seq_show(seq, v, srcp, destp, bucket);
 	}
 	return 0;
@@ -244,6 +246,7 @@ int __init pingv6_init(void)
 {
 #ifdef CONFIG_PROC_FS
 	int ret = register_pernet_subsys(&ping_v6_net_ops);
+
 	if (ret)
 		return ret;
 #endif
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 2d6f860..93a7e65 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -8,7 +8,7 @@
  *		except it reports the sockets in the INET6 address family.
  *
  * Authors:	David S. Miller (davem@caip.rutgers.edu)
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -291,6 +291,7 @@ int snmp6_register_dev(struct inet6_dev *idev)
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
 	struct net *net = dev_net(idev->dev);
+
 	if (!net->mib.proc_net_devsnmp6)
 		return -ENOENT;
 	if (!idev->stats.proc_dir_entry)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 39d4422..36d413b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -344,6 +344,7 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 	}
 	if (np->recverr) {
 		u8 *payload = skb->data;
+
 		if (!inet->hdrincl)
 			payload += offset;
 		ipv6_icmp_error(sk, skb, err, 0, ntohl(info), payload);
@@ -370,6 +371,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 	if (sk != NULL) {
 		/* Note: ipv6_hdr(skb) != skb->data */
 		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
+
 		saddr = &ip6h->saddr;
 		daddr = &ip6h->daddr;
 		net = dev_net(skb->dev);
@@ -567,6 +569,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 		tmp_csum = skb->csum;
 	} else {
 		struct sk_buff *csum_skb = NULL;
+
 		tmp_csum = 0;
 
 		skb_queue_walk(&sk->sk_write_queue, skb) {
@@ -715,6 +718,7 @@ static int rawv6_probe_proto_opt(struct flowi6 *fl6, struct msghdr *msg)
 			/* check if type field is readable or not. */
 			if (iov->iov_len > 2 - len) {
 				u8 __user *p = iov->iov_base;
+
 				if (get_user(fl6->fl6_mh_type, &p[2 - len]))
 					return -EFAULT;
 				probed = 1;
@@ -889,7 +893,7 @@ back_from_confirm:
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
-			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info*)dst,
+			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info *)dst,
 			msg->msg_flags, dontfrag);
 
 		if (err)
@@ -902,7 +906,7 @@ done:
 	dst_release(dst);
 out:
 	fl6_sock_release(flowlabel);
-	return err<0?err:len;
+	return err < 0 ? err : len;
 do_confirm:
 	dst_confirm(dst);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
@@ -1045,7 +1049,7 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 	struct raw6_sock *rp = raw6_sk(sk);
 	int val, len;
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	switch (optname) {
@@ -1069,7 +1073,7 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval,&val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
@@ -1234,6 +1238,7 @@ static int raw6_seq_show(struct seq_file *seq, void *v)
 	} else {
 		struct sock *sp = v;
 		__u16 srcp  = inet_sk(sp)->inet_num;
+
 		ip6_dgram_sock_seq_show(seq, v, srcp, 0,
 					raw_seq_private(seq)->bucket);
 	}
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index c6557d9..eb8d55b 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -62,13 +62,12 @@
 
 static const char ip6_frag_cache_name[] = "ip6-frags";
 
-struct ip6frag_skb_cb
-{
+struct ip6frag_skb_cb {
 	struct inet6_skb_parm	h;
 	int			offset;
 };
 
-#define FRAG6_CB(skb)	((struct ip6frag_skb_cb*)((skb)->cb))
+#define FRAG6_CB(skb)	((struct ip6frag_skb_cb *)((skb)->cb))
 
 static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 {
@@ -232,6 +231,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		const unsigned char *nh = skb_network_header(skb);
+
 		skb->csum = csum_sub(skb->csum,
 				     csum_partial(nh, (u8 *)(fhdr + 1) - nh,
 						  0));
@@ -289,7 +289,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		goto found;
 	}
 	prev = NULL;
-	for(next = fq->q.fragments; next != NULL; next = next->next) {
+	for (next = fq->q.fragments; next != NULL; next = next->next) {
 		if (FRAG6_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -529,7 +529,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
-	if (hdr->payload_len==0)
+	if (hdr->payload_len == 0)
 		goto fail_hdr;
 
 	if (!pskb_may_pull(skb, (skb_transport_offset(skb) +
@@ -575,8 +575,7 @@ fail_hdr:
 	return -1;
 }
 
-static const struct inet6_protocol frag_protocol =
-{
+static const struct inet6_protocol frag_protocol = {
 	.handler	=	ipv6_frag_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..a70bc25 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -339,6 +339,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 
 	if (rt6_has_peer(rt)) {
 		struct inet_peer *peer = rt6_peer_ptr(rt);
+
 		inet_putpeer(peer);
 	}
 }
@@ -561,6 +562,7 @@ static inline void rt6_probe(struct rt6_info *rt)
 static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 {
 	struct net_device *dev = rt->dst.dev;
+
 	if (!oif || dev->ifindex == oif)
 		return 2;
 	if ((dev->flags & IFF_LOOPBACK) &&
@@ -613,6 +615,7 @@ static int rt6_score_route(struct rt6_info *rt, int oif,
 #endif
 	if (strict & RT6_LOOKUP_F_REACHABLE) {
 		int n = rt6_check_neigh(rt);
+
 		if (n < 0)
 			return n;
 	}
@@ -813,7 +816,7 @@ out:
 
 }
 
-struct dst_entry * ip6_route_lookup(struct net *net, struct flowi6 *fl6,
+struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 				    int flags)
 {
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_lookup);
@@ -843,7 +846,6 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 
 	return NULL;
 }
-
 EXPORT_SYMBOL(rt6_lookup);
 
 /* ip6_ins_rt is called with FREE table->tb6_lock.
@@ -1024,7 +1026,7 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
 	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
 }
 
-struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
+struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 				    struct flowi6 *fl6)
 {
 	int flags = 0;
@@ -1041,7 +1043,6 @@ struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
 
 	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
 }
-
 EXPORT_SYMBOL(ip6_route_output);
 
 struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
@@ -1149,7 +1150,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			       struct sk_buff *skb, u32 mtu)
 {
-	struct rt6_info *rt6 = (struct rt6_info*)dst;
+	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	dst_confirm(dst);
 	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
@@ -1158,6 +1159,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		rt6->rt6i_flags |= RTF_MODIFIED;
 		if (mtu < IPV6_MIN_MTU) {
 			u32 features = dst_metric(dst, RTAX_FEATURES);
+
 			mtu = IPV6_MIN_MTU;
 			features |= RTAX_FEATURE_ALLFRAG;
 			dst_metric_set(dst, RTAX_FEATURES, features);
@@ -1429,6 +1431,7 @@ static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
 	pprev = &icmp6_dst_gc_list;
 	while ((dst = *pprev) != NULL) {
 		struct rt6_info *rt = (struct rt6_info *) dst;
+
 		if (func(rt, arg)) {
 			*pprev = dst->next;
 			dst_free(dst);
@@ -1924,7 +1927,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
+	fn = fib6_locate(&table->tb6_root, prefix, prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
 
@@ -1983,7 +1986,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 		return NULL;
 
 	read_lock_bh(&table->tb6_lock);
-	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
+	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
@@ -2068,7 +2071,7 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	struct in6_rtmsg rtmsg;
 	int err;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2107,6 +2110,7 @@ static int ip6_pkt_drop(struct sk_buff *skb, u8 code, int ipstats_mib_noroutes)
 {
 	int type;
 	struct dst_entry *dst = skb_dst(skb);
+
 	switch (ipstats_mib_noroutes) {
 	case IPSTATS_MIB_INNOROUTES:
 		type = ipv6_addr_type(&ipv6_hdr(skb)->daddr);
@@ -2191,8 +2195,9 @@ int ip6_route_get_saddr(struct net *net,
 			unsigned int prefs,
 			struct in6_addr *saddr)
 {
-	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry*)rt);
+	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry *)rt);
 	int err = 0;
+
 	if (rt->rt6i_prefsrc.plen)
 		*saddr = rt->rt6i_prefsrc.addr;
 	else
@@ -2486,7 +2491,7 @@ beginning:
 	return last_err;
 }
 
-static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh)
+static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2501,7 +2506,7 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh)
 		return ip6_route_del(&cfg);
 }
 
-static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh)
+static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2580,8 +2585,7 @@ static int rt6_fill_node(struct net *net,
 			rtm->rtm_type = RTN_UNREACHABLE;
 			break;
 		}
-	}
-	else if (rt->rt6i_flags & RTF_LOCAL)
+	} else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
 	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
 		rtm->rtm_type = RTN_LOCAL;
@@ -2622,6 +2626,7 @@ static int rt6_fill_node(struct net *net,
 #ifdef CONFIG_IPV6_MROUTE
 		if (ipv6_addr_is_multicast(&rt->rt6i_dst.addr)) {
 			int err = ip6mr_get_route(net, skb, rtm, nowait);
+
 			if (err <= 0) {
 				if (!nowait) {
 					if (err == 0)
@@ -2638,6 +2643,7 @@ static int rt6_fill_node(struct net *net,
 				goto nla_put_failure;
 	} else if (dst) {
 		struct in6_addr saddr_buf;
+
 		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) == 0 &&
 		    nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
 			goto nla_put_failure;
@@ -2645,6 +2651,7 @@ static int rt6_fill_node(struct net *net,
 
 	if (rt->rt6i_prefsrc.plen) {
 		struct in6_addr saddr_buf;
+
 		saddr_buf = rt->rt6i_prefsrc.addr;
 		if (nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
 			goto nla_put_failure;
@@ -2683,6 +2690,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 
 	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
 		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
+
 		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
 	} else
 		prefix = 0;
@@ -2693,7 +2701,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		     prefix, 0, NLM_F_MULTI);
 }
 
-static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh)
+static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
@@ -2851,6 +2859,7 @@ static const struct file_operations ipv6_route_proc_fops = {
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
+
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
 		   net->ipv6.rt6_stats->fib_nodes,
 		   net->ipv6.rt6_stats->fib_route_nodes,
@@ -2885,6 +2894,7 @@ int ipv6_sysctl_rtcache_flush(struct ctl_table *ctl, int write,
 {
 	struct net *net;
 	int delay;
+
 	if (!write)
 		return -EINVAL;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2e9ba03..369ebf0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -183,6 +183,7 @@ static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 		t->ip6rd.relay_prefixlen = 0;
 	} else {
 		struct ip_tunnel *t0 = netdev_priv(sitn->fb_tunnel_dev);
+
 		memcpy(&t->ip6rd, &t0->ip6rd, sizeof(t->ip6rd));
 	}
 #endif
@@ -595,6 +596,7 @@ static inline bool is_spoofed_6rd(struct ip_tunnel *tunnel, const __be32 v4addr,
 				  const struct in6_addr *v6addr)
 {
 	__be32 v4embed = 0;
+
 	if (check_6rd(tunnel, v6addr, &v4embed) && v4addr != v4embed)
 		return true;
 	return false;
@@ -795,6 +797,7 @@ static inline __be32 try_6rd(struct ip_tunnel *tunnel,
 			     const struct in6_addr *v6dst)
 {
 	__be32 dst = 0;
+
 	check_6rd(tunnel, v6dst, &dst);
 	return dst;
 }
@@ -812,9 +815,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	const struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
 	__be16 df = tiph->frag_off;
-	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;		/* Device to other host */
-	unsigned int max_headroom;		/* The extra header space needed */
+	struct rtable *rt;		/* Route to the other host */
+	struct net_device *tdev;	/* Device to other host */
+	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst = tiph->daddr;
 	struct flowi4 fl4;
 	int    mtu;
@@ -952,6 +955,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
+
 		if (!new_skb) {
 			ip_rt_put(rt);
 			dev->stats.tx_dropped++;
@@ -1123,7 +1127,7 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 #endif
 
 static int
-ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
+ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip_tunnel_parm p;
@@ -1339,10 +1343,10 @@ static void ipip6_dev_free(struct net_device *dev)
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipip6_netdev_ops;
-	dev->destructor 	= ipip6_dev_free;
+	dev->destructor		= ipip6_dev_free;
 
 	dev->type		= ARPHRD_SIT;
-	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr);
+	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr);
 	dev->flags		= IFF_NOARP;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
@@ -1472,6 +1476,7 @@ static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
 				    struct ip_tunnel_6rd *ip6rd)
 {
 	bool ret = false;
+
 	memset(ip6rd, 0, sizeof(*ip6rd));
 
 	if (!data)
@@ -1701,6 +1706,7 @@ static void __net_exit sit_destroy_tunnels(struct net *net,
 
 	for (prio = 1; prio < 4; prio++) {
 		int h;
+
 		for (h = 0; h < HASH_SIZE; h++) {
 			struct ip_tunnel *t;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 83cea1d..1831831 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -90,6 +90,7 @@ static __u32 secure_tcp_syn_cookie(const struct in6_addr *saddr,
 				   __u32 data)
 {
 	u32 count = tcp_cookie_time();
+
 	return (cookie_hash(saddr, daddr, sport, dport, 0, 0) +
 		sseq + (count << COOKIEBITS) +
 		((cookie_hash(saddr, daddr, sport, dport, count, 1) + data)
@@ -238,6 +239,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	{
 		struct in6_addr *final_p, final;
 		struct flowi6 fl6;
+
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_TCP;
 		fl6.daddr = ireq->ir_v6_rmt_addr;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f2ce955..56de759 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -151,6 +151,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		IP6_ECN_flow_init(fl6.flowlabel);
 		if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
 			struct ip6_flowlabel *flowlabel;
+
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
@@ -634,6 +635,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 		daddr = &inet_rsk(req)->ir_v6_rmt_addr;
 	} else {
 		const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
 		saddr = &ip6h->saddr;
 		daddr = &ip6h->daddr;
 	}
@@ -1307,6 +1309,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_LISTEN) {
 		struct sock *nsk = tcp_v6_hnd_req(sk, skb);
+
 		if (!nsk)
 			goto discard;
 
@@ -1448,6 +1451,7 @@ process:
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
+
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
 			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
@@ -1516,6 +1520,7 @@ do_time_wait:
 					    ntohs(th->dest), inet6_iif(skb));
 		if (sk2 != NULL) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
+
 			inet_twsk_deschedule(tw, &tcp_death_row);
 			inet_twsk_put(tw);
 			sk = sk2;
diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 2c4e4c5..3c75800 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  */
 
 #define pr_fmt(fmt) "IPv6: " fmt
@@ -64,7 +64,6 @@ err:
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_register);
 
 int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
@@ -92,7 +91,6 @@ int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
 
 	return ret;
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_deregister);
 
 #define for_each_tunnel_rcu(head, handler)		\
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4836af8..f70bb13 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -373,8 +373,8 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
 
 /*
- * 	This should be easy, if there is something there we
- * 	return it, otherwise we block.
+ *	This should be easy, if there is something there we
+ *	return it, otherwise we block.
  */
 
 int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
@@ -460,6 +460,7 @@ try_again:
 	/* Copy the address. */
 	if (msg->msg_name) {
 		DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
+
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = udp_hdr(skb)->source;
 		sin6->sin6_flowinfo = 0;
@@ -530,7 +531,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
 	const struct in6_addr *saddr = &hdr->saddr;
 	const struct in6_addr *daddr = &hdr->daddr;
-	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
+	struct udphdr *uh = (struct udphdr *)(skb->data+offset);
 	struct sock *sk;
 	int err;
 	struct net *net = dev_net(skb->dev);
@@ -596,7 +597,7 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 static __inline__ void udpv6_err(struct sk_buff *skb,
 				 struct inet6_skb_parm *opt, u8 type,
-				 u8 code, int offset, __be32 info     )
+				 u8 code, int offset, __be32 info)
 {
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
@@ -960,10 +961,10 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 }
 
 /**
- * 	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
- * 	@sk: 	socket we are sending on
- * 	@skb: 	sk_buff containing the filled-in UDP header
- * 	        (checksum field must be zeroed out)
+ *	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
+ *	@sk:	socket we are sending on
+ *	@skb:	sk_buff containing the filled-in UDP header
+ *		(checksum field must be zeroed out)
  */
 static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 				 const struct in6_addr *saddr,
@@ -1123,6 +1124,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (daddr) {
 		if (ipv6_addr_v4mapped(daddr)) {
 			struct sockaddr_in sin;
+
 			sin.sin_family = AF_INET;
 			sin.sin_port = sin6 ? sin6->sin6_port : inet->inet_dport;
 			sin.sin_addr.s_addr = daddr->s6_addr32[3];
@@ -1294,7 +1296,7 @@ do_append_data:
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
-		(struct rt6_info*)dst,
+		(struct rt6_info *)dst,
 		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
@@ -1351,12 +1353,14 @@ do_confirm:
 void udpv6_destroy_sock(struct sock *sk)
 {
 	struct udp_sock *up = udp_sk(sk);
+
 	lock_sock(sk);
 	udp_v6_flush_pending_frames(sk);
 	release_sock(sk);
 
 	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
 		void (*encap_destroy)(struct sock *sk);
+
 		encap_destroy = ACCESS_ONCE(up->encap_destroy);
 		if (encap_destroy)
 			encap_destroy(sk);
@@ -1423,6 +1427,7 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 		struct inet_sock *inet = inet_sk(v);
 		__u16 srcp = ntohs(inet->inet_sport);
 		__u16 destp = ntohs(inet->inet_dport);
+
 		ip6_dgram_sock_seq_show(seq, v, srcp, destp, bucket);
 	}
 	return 0;
@@ -1451,7 +1456,8 @@ int __net_init udp6_proc_init(struct net *net)
 	return udp_proc_register(net, &udp6_seq_afinfo);
 }
 
-void udp6_proc_exit(struct net *net) {
+void udp6_proc_exit(struct net *net)
+{
 	udp_proc_unregister(net, &udp6_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..f48fbe4 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -3,8 +3,8 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
  *	YOSHIFUJI Hideaki @USAGI
  *		IPv6 support
  */
@@ -52,7 +52,6 @@ int xfrm6_rcv(struct sk_buff *skb)
 	return xfrm6_rcv_spi(skb, skb_network_header(skb)[IP6CB(skb)->nhoff],
 			     0);
 }
-
 EXPORT_SYMBOL(xfrm6_rcv);
 
 int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
@@ -142,5 +141,4 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 drop:
 	return -1;
 }
-
 EXPORT_SYMBOL(xfrm6_input_addr);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 433672d..ca3f29b 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -25,7 +25,6 @@ int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 {
 	return ip6_find_1stfragopt(skb, prevhdr);
 }
-
 EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 
 static int xfrm6_local_dontfrag(struct sk_buff *skb)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 2a0bbda..ce8fcb4 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -3,11 +3,11 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
- * 		IPv6 support
- * 	YOSHIFUJI Hideaki
- * 		Split up af-specific portion
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *		IPv6 support
+ *	YOSHIFUJI Hideaki
+ *		Split up af-specific portion
  *
  */
 
@@ -84,7 +84,8 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 			   int nfheader_len)
 {
 	if (dst->ops->family == AF_INET6) {
-		struct rt6_info *rt = (struct rt6_info*)dst;
+		struct rt6_info *rt = (struct rt6_info *)dst;
+
 		if (rt->rt6i_node)
 			path->path_cookie = rt->rt6i_node->fn_sernum;
 	}
@@ -97,7 +98,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 			  const struct flowi *fl)
 {
-	struct rt6_info *rt = (struct rt6_info*)xdst->route;
+	struct rt6_info *rt = (struct rt6_info *)xdst->route;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
@@ -192,6 +193,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_MH:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
+
 				mh = (struct ip6_mh *)exthdr;
 
 				fl6->fl6_mh_type = mh->ip6mh_type;
@@ -247,6 +249,7 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 	dst_destroy_metrics_generic(dst);
 	if (rt6_has_peer(&xdst->u.rt6)) {
 		struct inet_peer *peer = rt6_peer_ptr(&xdst->u.rt6);
+
 		inet_putpeer(peer);
 	}
 	xfrm_dst_destroy(xdst);
@@ -296,7 +299,7 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.family =		AF_INET6,
 	.dst_ops =		&xfrm6_dst_ops,
 	.dst_lookup =		xfrm6_dst_lookup,
-	.get_saddr = 		xfrm6_get_saddr,
+	.get_saddr =		xfrm6_get_saddr,
 	.decode_session =	_decode_session6,
 	.get_tos =		xfrm6_get_tos,
 	.init_dst =		xfrm6_init_dst,
@@ -319,9 +322,9 @@ static void xfrm6_policy_fini(void)
 static struct ctl_table xfrm6_policy_table[] = {
 	{
 		.procname       = "xfrm6_gc_thresh",
-		.data	   	= &init_net.xfrm.xfrm6_dst_ops.gc_thresh,
-		.maxlen	 	= sizeof(int),
-		.mode	   	= 0644,
+		.data		= &init_net.xfrm.xfrm6_dst_ops.gc_thresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
 		.proc_handler   = proc_dointvec,
 	},
 	{ }
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3fc9701..9bfc6b8 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -3,11 +3,11 @@
  *
  * Authors:
  *	Mitsuru KANDA @USAGI
- * 	Kazunori MIYAZAWA @USAGI
- * 	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
- * 		IPv6 support
- * 	YOSHIFUJI Hideaki @USAGI
- * 		Split up af-specific portion
+ *	Kazunori MIYAZAWA @USAGI
+ *	Kunihiro Ishiguro <kunihiro@ipinfusion.com>
+ *		IPv6 support
+ *	YOSHIFUJI Hideaki @USAGI
+ *		Split up af-specific portion
  *
  */
 
@@ -45,10 +45,10 @@ xfrm6_init_temprop(struct xfrm_state *x, const struct xfrm_tmpl *tmpl,
 		   const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
 	x->id = tmpl->id;
-	if (ipv6_addr_any((struct in6_addr*)&x->id.daddr))
+	if (ipv6_addr_any((struct in6_addr *)&x->id.daddr))
 		memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
 	memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
-	if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
+	if (ipv6_addr_any((struct in6_addr *)&x->props.saddr))
 		memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
 	x->props.mode = tmpl->mode;
 	x->props.reqid = tmpl->reqid;
@@ -67,6 +67,7 @@ __xfrm6_sort(void **dst, void **src, int n, int (*cmp)(void *p), int maxclass)
 
 	for (i = 0; i < n; i++) {
 		int c;
+
 		class[i] = c = cmp(src[i]);
 		count[c]++;
 	}
@@ -131,6 +132,7 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
 static int __xfrm6_tmpl_sort_cmp(void *p)
 {
 	struct xfrm_tmpl *v = p;
+
 	switch (v->mode) {
 	case XFRM_MODE_TRANSPORT:
 		return 1;
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 1c66465..b30eeac 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -15,7 +15,7 @@
  * along with this program; if not, see <http://www.gnu.org/licenses/>.
  *
  * Authors	Mitsuru KANDA  <mk@linux-ipv6.org>
- * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
+ *		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  *
  * Based on net/ipv4/xfrm4_tunnel.c
  *
@@ -110,7 +110,6 @@ __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr)
 	rcu_read_unlock_bh();
 	return htonl(spi);
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_spi_lookup);
 
 static int __xfrm6_tunnel_spi_check(struct net *net, u32 spi)
@@ -187,7 +186,6 @@ __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr)
 
 	return htonl(spi);
 }
-
 EXPORT_SYMBOL(xfrm6_tunnel_alloc_spi);
 
 static void x6spi_destroy_rcu(struct rcu_head *head)
@@ -270,9 +268,12 @@ static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		break;
 	case ICMPV6_PARAMPROB:
 		switch (code) {
-		case ICMPV6_HDR_FIELD: break;
-		case ICMPV6_UNK_NEXTHDR: break;
-		case ICMPV6_UNK_OPTION: break;
+		case ICMPV6_HDR_FIELD:
+			break;
+		case ICMPV6_UNK_NEXTHDR:
+			break;
+		case ICMPV6_UNK_OPTION:
+			break;
 		}
 		break;
 	default:
-- 
1.7.9.5
