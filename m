From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: use IS_ENABLED()
Date: Tue, 30 Oct 2012 10:23:10 +0800
Message-ID: <1351563790-10445-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401Ab2J3CXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 22:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

#if defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)

can be replaced by

#if IS_ENABLED(CONFIG_FOO)

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 net/ipv6/addrconf.c                            |   20 ++++++++++----------
 net/ipv6/ah6.c                                 |   10 +++++-----
 net/ipv6/datagram.c                            |    2 +-
 net/ipv6/exthdrs.c                             |   18 +++++++++---------
 net/ipv6/icmp.c                                |    2 +-
 net/ipv6/ip6_output.c                          |    5 ++---
 net/ipv6/ipv6_sockglue.c                       |    2 +-
 net/ipv6/netfilter/ip6_tables.c                |    6 ++----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |    6 +++---
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c       |    2 +-
 net/ipv6/raw.c                                 |    6 +++---
 net/ipv6/xfrm6_policy.c                        |    4 ++--
 net/ipv6/xfrm6_state.c                         |    4 ++--
 15 files changed, 46 insertions(+), 49 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..387b813 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -402,7 +402,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
 		ndev->cnf.accept_dad = -1;
 
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
 		pr_info("%s: Disabled Multicast RS\n", dev->name);
 		ndev->cnf.rtr_solicits = 0;
@@ -1838,7 +1838,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 	   This thing is done here expecting that the whole
 	   class of non-broadcast devices need not cloning.
 	 */
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 	if (dev->type == ARPHRD_SIT && (dev->flags & IFF_POINTOPOINT))
 		cfg.fc_flags |= RTF_NONEXTHOP;
 #endif
@@ -1898,7 +1898,7 @@ static void addrconf_add_mroute(struct net_device *dev)
 	ip6_route_add(&cfg);
 }
 
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 static void sit_route_add(struct net_device *dev)
 {
 	struct fib6_config cfg = {
@@ -2250,7 +2250,7 @@ int addrconf_set_dstaddr(struct net *net, void __user *arg)
 	if (dev == NULL)
 		goto err_exit;
 
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 	if (dev->type == ARPHRD_SIT) {
 		const struct net_device_ops *ops = dev->netdev_ops;
 		struct ifreq ifr;
@@ -2461,7 +2461,7 @@ static void add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	}
 }
 
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 static void sit_add_v4_addrs(struct inet6_dev *idev)
 {
 	struct in6_addr addr;
@@ -2580,7 +2580,7 @@ static void addrconf_dev_config(struct net_device *dev)
 		addrconf_add_linklocal(idev, &addr);
 }
 
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 static void addrconf_sit_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -2617,7 +2617,7 @@ static void addrconf_sit_config(struct net_device *dev)
 }
 #endif
 
-#if defined(CONFIG_NET_IPGRE) || defined(CONFIG_NET_IPGRE_MODULE)
+#if IS_ENABLED(CONFIG_NET_IPGRE)
 static void addrconf_gre_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -2747,12 +2747,12 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		}
 
 		switch (dev->type) {
-#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_SIT)
 		case ARPHRD_SIT:
 			addrconf_sit_config(dev);
 			break;
 #endif
-#if defined(CONFIG_NET_IPGRE) || defined(CONFIG_NET_IPGRE_MODULE)
+#if IS_ENABLED(CONFIG_NET_IPGRE)
 		case ARPHRD_IPGRE:
 			addrconf_gre_config(dev);
 			break;
@@ -3340,7 +3340,7 @@ void if6_proc_exit(void)
 }
 #endif	/* CONFIG_PROC_FS */
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 /* Check if address is a home address configured on any interface. */
 int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 {
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 7e61395..ecc35b9 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -44,7 +44,7 @@
 #define IPV6HDR_BASELEN 8
 
 struct tmp_ext {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		struct in6_addr saddr;
 #endif
 		struct in6_addr daddr;
@@ -152,7 +152,7 @@ bad:
 	return false;
 }
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 /**
  *	ipv6_rearrange_destopt - rearrange IPv6 destination options header
  *	@iph: IPv6 header
@@ -320,7 +320,7 @@ static void ah6_output_done(struct crypto_async_request *base, int err)
 	memcpy(top_iph, iph_base, IPV6HDR_BASELEN);
 
 	if (extlen) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		memcpy(&top_iph->saddr, iph_ext, extlen);
 #else
 		memcpy(&top_iph->daddr, iph_ext, extlen);
@@ -385,7 +385,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	memcpy(iph_base, top_iph, IPV6HDR_BASELEN);
 
 	if (extlen) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		memcpy(iph_ext, &top_iph->saddr, extlen);
 #else
 		memcpy(iph_ext, &top_iph->daddr, extlen);
@@ -434,7 +434,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	memcpy(top_iph, iph_base, IPV6HDR_BASELEN);
 
 	if (extlen) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		memcpy(&top_iph->saddr, iph_ext, extlen);
 #else
 		memcpy(&top_iph->daddr, iph_ext, extlen);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index be2b67d6..93cbad2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -769,7 +769,7 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 			rthdr = (struct ipv6_rt_hdr *)CMSG_DATA(cmsg);
 
 			switch (rthdr->type) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 			case IPV6_SRCRT_TYPE_2:
 				if (rthdr->hdrlen != 2 ||
 				    rthdr->segments_left != 1) {
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index fa3d9c3..f005acc 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -43,7 +43,7 @@
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/xfrm.h>
 #endif
 
@@ -224,7 +224,7 @@ bad:
   Destination options header.
  *****************************/
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 {
 	struct ipv6_destopt_hao *hao;
@@ -288,7 +288,7 @@ static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 #endif
 
 static const struct tlvtype_proc tlvprocdestopt_lst[] = {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	{
 		.type	= IPV6_TLV_HAO,
 		.func	= ipv6_dest_hao,
@@ -300,7 +300,7 @@ static const struct tlvtype_proc tlvprocdestopt_lst[] = {
 static int ipv6_destopt_rcv(struct sk_buff *skb)
 {
 	struct inet6_skb_parm *opt = IP6CB(skb);
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	__u16 dstbuf;
 #endif
 	struct dst_entry *dst = skb_dst(skb);
@@ -315,14 +315,14 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	}
 
 	opt->lastopt = opt->dst1 = skb_network_header_len(skb);
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	dstbuf = opt->dst1;
 #endif
 
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
 		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
 		opt = IP6CB(skb);
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		opt->nhoff = dstbuf;
 #else
 		opt->nhoff = opt->dst1;
@@ -378,7 +378,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 looped_back:
 	if (hdr->segments_left == 0) {
 		switch (hdr->type) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPV6_SRCRT_TYPE_2:
 			/* Silently discard type 2 header unless it was
 			 * processed by own
@@ -404,7 +404,7 @@ looped_back:
 	}
 
 	switch (hdr->type) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	case IPV6_SRCRT_TYPE_2:
 		if (accept_source_route < 0)
 			goto unknown_rh;
@@ -461,7 +461,7 @@ looped_back:
 	addr += i - 1;
 
 	switch (hdr->type) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	case IPV6_SRCRT_TYPE_2:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&ipv6_hdr(skb)->saddr,
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 24d69db..b4a9fd5 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -280,7 +280,7 @@ static int icmpv6_getfrag(void *from, char *to, int offset, int len, int odd, st
 	return 0;
 }
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 static void mip6_addr_swap(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index aece3e7..e10c77b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -538,8 +538,7 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	to->nf_trace = from->nf_trace;
 #endif
 	skb_copy_secmark(to, from);
@@ -564,7 +563,7 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 			found_rhdr = 1;
 			break;
 		case NEXTHDR_DEST:
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
 				break;
 #endif
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ba6d13d..a7bee6a 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -397,7 +397,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
 			switch (rthdr->type) {
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 			case IPV6_SRCRT_TYPE_2:
 				if (rthdr->hdrlen != 2 ||
 				    rthdr->segments_left != 1)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d7cb045..10ce76a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -207,8 +207,7 @@ ip6t_get_target_c(const struct ip6t_entry *e)
 	return ip6t_get_target((struct ip6t_entry *)e);
 }
 
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 /* This cries for unification! */
 static const char *const hooknames[] = {
 	[NF_INET_PRE_ROUTING]		= "PREROUTING",
@@ -381,8 +380,7 @@ ip6t_do_table(struct sk_buff *skb,
 		t = ip6t_get_target_c(e);
 		IP_NF_ASSERT(t->u.kernel.target);
 
-#if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
-    defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 		/* The packet is traced: log it */
 		if (unlikely(skb->nf_trace))
 			trace_packet(skb, hook, in, out,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 8860d23..ccb5cbe 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -295,7 +295,7 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 	},
 };
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -346,7 +346,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.invert_tuple		= ipv6_invert_tuple,
 	.print_tuple		= ipv6_print_tuple,
 	.get_l4proto		= ipv6_get_l4proto,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	= ipv6_tuple_to_nlattr,
 	.nlattr_tuple_size	= ipv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 2d54b20..24df3dd 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -232,7 +232,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	return icmpv6_error_message(net, tmpl, skb, dataoff, ctinfo, hooknum);
 }
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -375,7 +375,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.get_timeouts		= icmpv6_get_timeouts,
 	.new			= icmpv6_new,
 	.error			= icmpv6_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	= icmpv6_tuple_to_nlattr,
 	.nlattr_tuple_size	= icmpv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmpv6_nlattr_to_tuple,
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index cdd6d04..aacd121 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -19,7 +19,7 @@
 
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_bridge.h>
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -35,7 +35,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
@@ -60,7 +60,7 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 {
 	struct sk_buff *reasm;
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Previously seen (loopback)?	*/
 	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
 		return NF_ACCEPT;
diff --git a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
index 5d6da78..61aaf70 100644
--- a/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_nat_proto_icmpv6.c
@@ -84,7 +84,7 @@ const struct nf_nat_l4proto nf_nat_l4proto_icmpv6 = {
 	.manip_pkt		= icmpv6_manip_pkt,
 	.in_range		= icmpv6_in_range,
 	.unique_tuple		= icmpv6_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d8e95c7..6cd29b1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -50,7 +50,7 @@
 #include <net/udp.h>
 #include <net/inet_common.h>
 #include <net/tcp_states.h>
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/mip6.h>
 #endif
 #include <linux/mroute6.h>
@@ -123,7 +123,7 @@ static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
 	return 1;
 }
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 typedef int mh_filter_t(struct sock *sock, struct sk_buff *skb);
 
 static mh_filter_t __rcu *mh_filter __read_mostly;
@@ -184,7 +184,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 			filtered = icmpv6_filter(sk, skb);
 			break;
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPPROTO_MH:
 		{
 			/* XXX: To validate MH only once for each packet,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f8c4c08..f3ed8ca 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -20,7 +20,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/mip6.h>
 #endif
 
@@ -182,7 +182,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			fl6->flowi6_proto = nexthdr;
 			return;
 
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 		case IPPROTO_MH:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 3 - skb->data)) {
 				struct ip6_mh *mh;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3f2f7c4..d8c70b8 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -101,7 +101,7 @@ static int __xfrm6_state_sort_cmp(void *p)
 			return 1;
 		else
 			return 3;
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	case XFRM_MODE_ROUTEOPTIMIZATION:
 	case XFRM_MODE_IN_TRIGGER:
 		return 2;
@@ -134,7 +134,7 @@ static int __xfrm6_tmpl_sort_cmp(void *p)
 	switch (v->mode) {
 	case XFRM_MODE_TRANSPORT:
 		return 1;
-#if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
+#if IS_ENABLED(CONFIG_IPV6_MIP6)
 	case XFRM_MODE_ROUTEOPTIMIZATION:
 	case XFRM_MODE_IN_TRIGGER:
 		return 2;
