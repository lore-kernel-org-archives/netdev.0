From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next v1 1/2] net: ndisc.c: fix coding style issue
Date: Fri, 26 May 2017 21:47:08 +0800
Message-ID: <1495806428-5632-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>, David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:59534 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753101AbdEZNrp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 09:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv6/ndisc.c | 109 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 55 insertions(+), 54 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc4..292c827 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -99,7 +99,6 @@ static const struct neigh_ops ndisc_hh_ops = {
 	.connected_output =	neigh_resolve_output,
 };
 
-
 static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
 	.output =		neigh_direct_output,
@@ -147,13 +146,13 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
 	u8 *opt = skb_put(skb, space);
 
 	opt[0] = type;
-	opt[1] = space>>3;
+	opt[1] = space >> 3;
 
 	memset(opt + 2, 0, pad);
 	opt   += pad;
 	space -= pad;
 
-	memcpy(opt+2, data, data_len);
+	memcpy(opt + 2, data, data_len);
 	data_len += 2;
 	opt += data_len;
 	space -= data_len;
@@ -182,6 +181,7 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 					    struct nd_opt_hdr *end)
 {
 	int type;
+
 	if (!cur || !end || cur >= end)
 		return NULL;
 	type = cur->nd_opt_type;
@@ -222,6 +222,7 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 	memset(ndopts, 0, sizeof(*ndopts));
 	while (opt_len) {
 		int l;
+
 		if (opt_len < sizeof(struct nd_opt_hdr))
 			return NULL;
 		l = nd_opt->nd_opt_len << 3;
@@ -327,9 +328,8 @@ static int ndisc_constructor(struct neighbour *neigh)
 	bool is_multicast = ipv6_addr_is_multicast(addr);
 
 	in6_dev = in6_dev_get(dev);
-	if (!in6_dev) {
+	if (!in6_dev)
 		return -EINVAL;
-	}
 
 	parms = in6_dev->nd_parms;
 	__neigh_parms_put(neigh->parms);
@@ -344,12 +344,12 @@ static int ndisc_constructor(struct neighbour *neigh)
 		if (is_multicast) {
 			neigh->nud_state = NUD_NOARP;
 			ndisc_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+		} else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
-			if (dev->flags&IFF_LOOPBACK)
+			if (dev->flags & IFF_LOOPBACK)
 				neigh->type = RTN_LOCAL;
-		} else if (dev->flags&IFF_POINTOPOINT) {
+		} else if (dev->flags & IFF_POINTOPOINT) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
@@ -357,7 +357,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 			neigh->ops = &ndisc_hh_ops;
 		else
 			neigh->ops = &ndisc_generic_ops;
-		if (neigh->nud_state&NUD_VALID)
+		if (neigh->nud_state & NUD_VALID)
 			neigh->output = neigh->ops->connected_output;
 		else
 			neigh->output = neigh->ops->output;
@@ -580,7 +580,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 
 	if (!saddr) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
-				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
+				   (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)))
 			return;
 		saddr = &addr_buf;
 	}
@@ -641,9 +641,8 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev_net(dev), saddr,
 							   dev, 1);
 		if (ifp) {
-			if (ifp->flags & IFA_F_OPTIMISTIC)  {
+			if (ifp->flags & IFA_F_OPTIMISTIC)
 				send_sllao = 0;
-			}
 			in6_ifa_put(ifp);
 		} else {
 			send_sllao = 0;
@@ -672,7 +671,6 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
-
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb)
 {
 	/*
@@ -695,7 +693,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (skb && ipv6_chk_addr_and_flags(dev_net(dev), &ipv6_hdr(skb)->saddr,
 					   dev, 1,
-					   IFA_F_TENTATIVE|IFA_F_OPTIMISTIC))
+					   IFA_F_TENTATIVE | IFA_F_OPTIMISTIC))
 		saddr = &ipv6_hdr(skb)->saddr;
 	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
 	if (probes < 0) {
@@ -806,7 +804,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
 have_ifp:
-		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
+		if (ifp->flags & (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)) {
 			if (dad) {
 				if (nonce != 0 && ifp->dad_nonce == nonce) {
 					u8 *np = (u8 *)&nonce;
@@ -824,16 +822,15 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 				 */
 				addrconf_dad_failure(ifp);
 				return;
-			} else {
-				/*
-				 * This is not a dad solicitation.
-				 * If we are an optimistic node,
-				 * we should respond.
-				 * Otherwise, we should ignore it.
-				 */
-				if (!(ifp->flags & IFA_F_OPTIMISTIC))
-					goto out;
 			}
+			/*
+			 * This is not a dad solicitation.
+			 * If we are an optimistic node,
+			 * we should respond.
+			 * Otherwise, we should ignore it.
+			 */
+			if (!(ifp->flags & IFA_F_OPTIMISTIC))
+				goto out;
 		}
 
 		idev = ifp->idev;
@@ -874,6 +871,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 				 * (RFC2461) -- yoshfuji
 				 */
 				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
+
 				if (n)
 					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
 				goto out;
@@ -904,7 +902,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			       !inc || lladdr || !dev->addr_len);
 	if (neigh)
 		ndisc_update(dev, neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
 			     NEIGH_UPDATE_F_OVERRIDE,
 			     NDISC_NEIGHBOUR_SOLICITATION, &ndopts);
 	if (neigh || !dev->header_ops) {
@@ -973,10 +971,10 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	}
 	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
-		if (skb->pkt_type != PACKET_LOOPBACK
-		    && (ifp->flags & IFA_F_TENTATIVE)) {
-				addrconf_dad_failure(ifp);
-				return;
+		if (skb->pkt_type != PACKET_LOOPBACK &&
+		    (ifp->flags & IFA_F_TENTATIVE)) {
+			addrconf_dad_failure(ifp);
+			return;
 		}
 		/* What should we make now? The advertisement
 		   is invalid, but ndisc specs say nothing
@@ -1081,8 +1079,8 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 	neigh = __neigh_lookup(&nd_tbl, saddr, skb->dev, 1);
 	if (neigh) {
 		ndisc_update(skb->dev, neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
+			     NEIGH_UPDATE_F_OVERRIDE |
 			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER,
 			     NDISC_ROUTER_SOLICITATION, &ndopts);
 		neigh_release(neigh);
@@ -1110,9 +1108,8 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 	}
 
 	nlh = nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, base_size, 0);
-	if (!nlh) {
+	if (!nlh)
 		goto nla_put_failure;
-	}
 
 	ndmsg = nlmsg_data(nlh);
 	ndmsg->nduseropt_family = AF_INET6;
@@ -1325,21 +1322,21 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (in6_dev->nd_parms) {
 		unsigned long rtime = ntohl(ra_msg->retrans_timer);
 
-		if (rtime && rtime/1000 < MAX_SCHEDULE_TIMEOUT/HZ) {
-			rtime = (rtime*HZ)/1000;
-			if (rtime < HZ/10)
-				rtime = HZ/10;
+		if (rtime && rtime / 1000 < MAX_SCHEDULE_TIMEOUT / HZ) {
+			rtime = (rtime * HZ) / 1000;
+			if (rtime < HZ / 10)
+				rtime = HZ / 10;
 			NEIGH_VAR_SET(in6_dev->nd_parms, RETRANS_TIME, rtime);
 			in6_dev->tstamp = jiffies;
 			send_ifinfo_notify = true;
 		}
 
 		rtime = ntohl(ra_msg->reachable_time);
-		if (rtime && rtime/1000 < MAX_SCHEDULE_TIMEOUT/(3*HZ)) {
-			rtime = (rtime*HZ)/1000;
+		if (rtime && rtime / 1000 < MAX_SCHEDULE_TIMEOUT / (3 * HZ)) {
+			rtime = (rtime * HZ) / 1000;
 
-			if (rtime < HZ/10)
-				rtime = HZ/10;
+			if (rtime < HZ / 10)
+				rtime = HZ / 10;
 
 			if (rtime != NEIGH_VAR(in6_dev->nd_parms, BASE_REACHABLE_TIME)) {
 				NEIGH_VAR_SET(in6_dev->nd_parms,
@@ -1370,6 +1367,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				       skb->dev, 1);
 	if (neigh) {
 		u8 *lladdr = NULL;
+
 		if (ndopts.nd_opts_src_lladdr) {
 			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
 						     skb->dev);
@@ -1380,9 +1378,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			}
 		}
 		ndisc_update(skb->dev, neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE|
-			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
+			     NEIGH_UPDATE_F_OVERRIDE |
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER |
 			     NEIGH_UPDATE_F_ISROUTER,
 			     NDISC_ROUTER_ADVERTISEMENT, &ndopts);
 	}
@@ -1406,6 +1404,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_ri;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_ri_end)) {
@@ -1442,6 +1441,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_pi;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
@@ -1455,7 +1455,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		__be32 n;
 		u32 mtu;
 
-		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
+		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu + 1)) + 2, sizeof(mtu));
 		mtu = ntohl(n);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
@@ -1472,6 +1472,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (ndopts.nd_useropts) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_useropts;
 		     p;
 		     p = ndisc_next_useropt(skb->dev, p,
@@ -1480,9 +1481,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		}
 	}
 
-	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
+	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh)
 		ND_PRINTK(2, warn, "RA: invalid RA options\n");
-	}
 out:
 	ip6_rt_put(rt);
 	if (neigh)
@@ -1518,7 +1518,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 
 	if (!ndopts.nd_opts_rh) {
 		ip6_redirect_no_header(skb, dev_net(skb->dev),
-					skb->dev->ifindex, 0);
+				       skb->dev->ifindex, 0);
 		return;
 	}
 
@@ -1569,7 +1569,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	}
 
 	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
-	    ipv6_addr_type(target) != (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
+	    ipv6_addr_type(target) != (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK(2, warn,
 			  "Redirect: target address is not link-local unicast\n");
 		return;
@@ -1587,7 +1587,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (IS_ERR(dst))
 		return;
 
-	rt = (struct rt6_info *) dst;
+	rt = (struct rt6_info *)dst;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
 		ND_PRINTK(2, warn,
@@ -1595,7 +1595,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		goto release;
 	}
 	peer = inet_getpeer_v6(net->ipv6.peers, &ipv6_hdr(skb)->saddr, 1);
-	ret = inet_peer_xrlim_allow(peer, 1*HZ);
+	ret = inet_peer_xrlim_allow(peer, 1 * HZ);
 	if (peer)
 		inet_putpeer(peer);
 	if (!ret)
@@ -1603,6 +1603,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	if (dev->addr_len) {
 		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
+
 		if (!neigh) {
 			ND_PRINTK(2, warn,
 				  "Redirect: no neigh for target address\n");
@@ -1787,6 +1788,7 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 {
 	static char warncomm[TASK_COMM_LEN];
 	static int warned;
+
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm, current->comm);
 		pr_warn("process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead\n",
@@ -1797,7 +1799,8 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 	}
 }
 
-int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *buffer, size_t *lenp, loff_t *ppos)
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write,
+			       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
@@ -1831,8 +1834,6 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 	}
 	return ret;
 }
-
-
 #endif
 
 static int __net_init ndisc_net_init(struct net *net)
-- 
2.7.4
