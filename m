From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next v4] net: ipv6: fix code style error and warning of ndisc.c
Date: Sat, 20 May 2017 21:57:30 +0800
Message-ID: <1495288650-17072-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:34995 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755431AbdETN61 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 May 2017 09:58:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv6/ndisc.c | 310 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 163 insertions(+), 147 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc4..df31f29 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -12,8 +12,7 @@
  *      2 of the License, or (at your option) any later version.
  */
 
-/*
- *	Changes:
+/*	Changes:
  *
  *	Alexey I. Froloff		:	RFC6106 (DNSSL) support
  *	Pierre Ynard			:	export userland ND options
@@ -99,7 +98,6 @@ static const struct neigh_ops ndisc_hh_ops = {
 	.connected_output =	neigh_resolve_output,
 };
 
-
 static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
 	.output =		neigh_direct_output,
@@ -147,13 +145,13 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
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
@@ -182,6 +180,7 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
 					    struct nd_opt_hdr *end)
 {
 	int type;
+
 	if (!cur || !end || cur >= end)
 		return NULL;
 	type = cur->nd_opt_type;
@@ -222,6 +221,7 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 	memset(ndopts, 0, sizeof(*ndopts));
 	while (opt_len) {
 		int l;
+
 		if (opt_len < sizeof(struct nd_opt_hdr))
 			return NULL;
 		l = nd_opt->nd_opt_len << 3;
@@ -240,13 +240,15 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 					  "%s: duplicated ND6 option found: type=%d\n",
 					  __func__, nd_opt->nd_opt_type);
 			} else {
-				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
+				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
+					nd_opt;
 			}
 			break;
 		case ND_OPT_PREFIX_INFO:
 			ndopts->nd_opts_pi_end = nd_opt;
 			if (!ndopts->nd_opt_array[nd_opt->nd_opt_type])
-				ndopts->nd_opt_array[nd_opt->nd_opt_type] = nd_opt;
+				ndopts->nd_opt_array[nd_opt->nd_opt_type] =
+					nd_opt;
 			break;
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		case ND_OPT_ROUTE_INFO:
@@ -261,8 +263,7 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 				if (!ndopts->nd_useropts)
 					ndopts->nd_useropts = nd_opt;
 			} else {
-				/*
-				 * Unknown options must be silently ignored,
+				/* Unknown options must be silently ignored,
 				 * to accommodate future extension to the
 				 * protocol.
 				 */
@@ -280,7 +281,8 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 	return ndopts;
 }
 
-int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev, int dir)
+int ndisc_mc_map(const struct in6_addr *addr, char *buf,
+		 struct net_device *dev, int dir)
 {
 	switch (dev->type) {
 	case ARPHRD_ETHER:
@@ -327,9 +329,8 @@ static int ndisc_constructor(struct neighbour *neigh)
 	bool is_multicast = ipv6_addr_is_multicast(addr);
 
 	in6_dev = in6_dev_get(dev);
-	if (!in6_dev) {
+	if (!in6_dev)
 		return -EINVAL;
-	}
 
 	parms = in6_dev->nd_parms;
 	__neigh_parms_put(neigh->parms);
@@ -344,12 +345,12 @@ static int ndisc_constructor(struct neighbour *neigh)
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
@@ -357,7 +358,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 			neigh->ops = &ndisc_hh_ops;
 		else
 			neigh->ops = &ndisc_generic_ops;
-		if (neigh->nud_state&NUD_VALID)
+		if (neigh->nud_state & NUD_VALID)
 			neigh->output = neigh->ops->connected_output;
 		else
 			neigh->output = neigh->ops->output;
@@ -512,7 +513,8 @@ void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
-				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
+				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->
+						srcprefs,
 				       &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
@@ -580,7 +582,7 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 
 	if (!saddr) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
-				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
+				    (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)))
 			return;
 		saddr = &addr_buf;
 	}
@@ -629,8 +631,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	int optlen = 0;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-	/*
-	 * According to section 2.2 of RFC 4429, we must not
+	/* According to section 2.2 of RFC 4429, we must not
 	 * send router solicitations with a sllao from
 	 * optimistic addresses, but we may send the solicitation
 	 * if we don't include the sllao.  So here we check
@@ -641,9 +642,8 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
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
@@ -672,11 +672,9 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
-
 static void ndisc_error_report(struct neighbour *neigh, struct sk_buff *skb)
 {
-	/*
-	 *	"The sender MUST return an ICMP
+	/*	"The sender MUST return an ICMP
 	 *	 destination unreachable"
 	 */
 	dst_link_failure(skb);
@@ -695,7 +693,7 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	if (skb && ipv6_chk_addr_and_flags(dev_net(dev), &ipv6_hdr(skb)->saddr,
 					   dev, 1,
-					   IFA_F_TENTATIVE|IFA_F_OPTIMISTIC))
+					   IFA_F_TENTATIVE | IFA_F_OPTIMISTIC))
 		saddr = &ipv6_hdr(skb)->saddr;
 	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
 	if (probes < 0) {
@@ -705,11 +703,14 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  __func__, target);
 		}
 		ndisc_send_ns(dev, target, target, saddr, 0);
-	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
-		neigh_app_ns(neigh);
 	} else {
-		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, target, &mcaddr, saddr, 0);
+		probes -= NEIGH_VAR(neigh->parms, APP_PROBES);
+		if (probes < 0) {
+			neigh_app_ns(neigh);
+		} else {
+			addrconf_addr_solict_mult(target, &mcaddr);
+			ndisc_send_ns(dev, target, &mcaddr, saddr, 0);
+		}
 	}
 }
 
@@ -765,8 +766,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		return;
 	}
 
-	/*
-	 * RFC2461 7.1.1:
+	/* RFC2461 7.1.1:
 	 * DAD has to be destined for solicited node multicast address.
 	 */
 	if (dad && !ipv6_addr_is_solict_mult(daddr)) {
@@ -806,7 +806,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	ifp = ipv6_get_ifaddr(dev_net(dev), &msg->target, dev, 1);
 	if (ifp) {
 have_ifp:
-		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
+		if (ifp->flags & (IFA_F_TENTATIVE | IFA_F_OPTIMISTIC)) {
 			if (dad) {
 				if (nonce != 0 && ifp->dad_nonce == nonce) {
 					u8 *np = (u8 *)&nonce;
@@ -817,28 +817,27 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 						  &ifp->addr, np);
 					goto out;
 				}
-				/*
-				 * We are colliding with another node
+				/* We are colliding with another node
 				 * who is doing DAD
 				 * so fail our DAD process
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
+
+			/* This is not a dad solicitation.
+			 * If we are an optimistic node,
+			 * we should respond.
+			 * Otherwise, we should ignore it.
+			 */
+			if (!(ifp->flags & IFA_F_OPTIMISTIC))
+				goto out;
 		}
 
 		idev = ifp->idev;
 	} else {
 		struct net *net = dev_net(dev);
+		bool is_acast_proxy = false;
 
 		/* perhaps an address on the master device */
 		if (netif_is_l3_slave(dev)) {
@@ -846,7 +845,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 			mdev = netdev_master_upper_dev_get_rcu(dev);
 			if (mdev) {
-				ifp = ipv6_get_ifaddr(net, &msg->target, mdev, 1);
+				ifp = ipv6_get_ifaddr(net, &msg->target,
+						      mdev, 1);
 				if (ifp)
 					goto have_ifp;
 			}
@@ -858,28 +858,36 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			return;
 		}
 
-		if (ipv6_chk_acast_addr(net, dev, &msg->target) ||
-		    (idev->cnf.forwarding &&
-		     (net->ipv6.devconf_all->proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
+		if (ipv6_chk_acast_addr(net, dev, &msg->target)) {
+			is_acast_proxy = true;
+		} else if (idev->cnf.forwarding &&
+			   (net->ipv6.devconf_all->proxy_ndp ||
+			    idev->cnf.proxy_ndp)) {
+			is_router = pndisc_is_router(&msg->target, dev);
+			if (is_router >= 0)
+				is_acast_proxy = true;
+		}
+		if (is_acast_proxy) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc &&
 			    NEIGH_VAR(idev->nd_parms, PROXY_DELAY) != 0) {
-				/*
-				 * for anycast or proxy,
+				/* for anycast or proxy,
 				 * sender should delay its response
 				 * by a random time between 0 and
 				 * MAX_ANYCAST_DELAY_TIME seconds.
 				 * (RFC2461) -- yoshfuji
 				 */
 				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
+
 				if (n)
-					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
+					pneigh_enqueue(&nd_tbl,
+						       idev->nd_parms, n);
 				goto out;
 			}
-		} else
+		} else {
 			goto out;
+		}
 	}
 
 	if (is_router < 0)
@@ -887,7 +895,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 	if (dad) {
 		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &msg->target,
-			      !!is_router, false, (ifp != NULL), true);
+			      !!is_router, false, ifp, true);
 		goto out;
 	}
 
@@ -896,20 +904,19 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	else
 		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
 
-	/*
-	 *	update / create cache entry
+	/*	update / create cache entry
 	 *	for the source address
 	 */
 	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
 			       !inc || lladdr || !dev->addr_len);
 	if (neigh)
 		ndisc_update(dev, neigh, lladdr, NUD_STALE,
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
 			     NEIGH_UPDATE_F_OVERRIDE,
 			     NDISC_NEIGHBOUR_SOLICITATION, &ndopts);
 	if (neigh || !dev->header_ops) {
 		ndisc_send_na(dev, saddr, &msg->target, !!is_router,
-			      true, (ifp != NULL && inc), inc);
+			      true, (ifp && inc), inc);
 		if (neigh)
 			neigh_release(neigh);
 	}
@@ -973,19 +980,19 @@ static void ndisc_recv_na(struct sk_buff *skb)
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
-		   is invalid, but ndisc specs say nothing
-		   about it. It could be misconfiguration, or
-		   an smart proxy agent tries to help us :-)
-
-		   We should not print the error if NA has been
-		   received from loopback - it is just our own
-		   unsolicited advertisement.
+		 * is invalid, but ndisc specs say nothing
+		 * about it. It could be misconfiguration, or
+		 * an smart proxy agent tries to help us :-)
+		 *
+		 * We should not print the error if NA has been
+		 * received from loopback - it is just our own
+		 * unsolicited advertisement.
 		 */
 		if (skb->pkt_type != PACKET_LOOPBACK)
 			ND_PRINTK(1, warn,
@@ -1003,30 +1010,31 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		if (neigh->nud_state & NUD_FAILED)
 			goto out;
 
-		/*
-		 * Don't update the neighbor cache entry on a proxy NA from
+		/* Don't update the neighbor cache entry on a proxy NA from
 		 * ourselves because either the proxied node is off link or it
 		 * has already sent a NA to us.
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
-		    net->ipv6.devconf_all->forwarding && net->ipv6.devconf_all->proxy_ndp &&
+		    net->ipv6.devconf_all->forwarding &&
+		    net->ipv6.devconf_all->proxy_ndp &&
 		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.proxy_ndp */
 			goto out;
 		}
 
 		ndisc_update(dev, neigh, lladdr,
-			     msg->icmph.icmp6_solicited ? NUD_REACHABLE : NUD_STALE,
-			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
-			     (msg->icmph.icmp6_override ? NEIGH_UPDATE_F_OVERRIDE : 0)|
-			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER|
-			     (msg->icmph.icmp6_router ? NEIGH_UPDATE_F_ISROUTER : 0),
+			     msg->icmph.icmp6_solicited ?
+				NUD_REACHABLE : NUD_STALE,
+			     NEIGH_UPDATE_F_WEAK_OVERRIDE |
+			     (msg->icmph.icmp6_override ?
+				NEIGH_UPDATE_F_OVERRIDE : 0) |
+			     NEIGH_UPDATE_F_OVERRIDE_ISROUTER |
+			     (msg->icmph.icmp6_router ?
+				NEIGH_UPDATE_F_ISROUTER : 0),
 			     NDISC_NEIGHBOUR_ADVERTISEMENT, &ndopts);
 
 		if ((old_flags & ~neigh->flags) & NTF_ROUTER) {
-			/*
-			 * Change: router to host
-			 */
+			/* Change: router to host */
 			rt6_clean_tohost(dev_net(dev),  saddr);
 		}
 
@@ -1058,8 +1066,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 	if (!idev->cnf.forwarding)
 		goto out;
 
-	/*
-	 * Don't update NCE if src = ::;
+	/* Don't update NCE if src = ::;
 	 * this implies that the source node has no ip address assigned yet.
 	 */
 	if (ipv6_addr_any(saddr))
@@ -1081,8 +1088,8 @@ static void ndisc_recv_rs(struct sk_buff *skb)
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
@@ -1110,9 +1117,8 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 	}
 
 	nlh = nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, base_size, 0);
-	if (!nlh) {
+	if (!nlh)
 		goto nla_put_failure;
-	}
 
 	ndmsg = nlmsg_data(nlh);
 	ndmsg->nduseropt_family = AF_INET6;
@@ -1174,9 +1180,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	}
 #endif
 
-	/*
-	 *	set the RA_RECV flag in the interface
-	 */
+	/* set the RA_RECV flag in the interface */
 
 	in6_dev = __in6_dev_get(skb->dev);
 	if (!in6_dev) {
@@ -1208,15 +1212,13 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 #endif
 
 	if (in6_dev->if_flags & IF_RS_SENT) {
-		/*
-		 *	flag that an RA was received after an RS was sent
+		/*	flag that an RA was received after an RS was sent
 		 *	out on this interface.
 		 */
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}
 
-	/*
-	 * Remember the managed/otherconf flags from most recently
+	/* Remember the managed/otherconf flags from most recently
 	 * received RA message (RFC 2462) -- yoshfuji
 	 */
 	old_if_flags = in6_dev->if_flags;
@@ -1299,77 +1301,79 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		}
 		neigh->flags |= NTF_ROUTER;
 	} else if (rt) {
-		rt->rt6i_flags = (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
+		rt->rt6i_flags =
+			(rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
 	}
 
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
 	if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
 	    ra_msg->icmph.icmp6_hop_limit) {
-		if (in6_dev->cnf.accept_ra_min_hop_limit <= ra_msg->icmph.icmp6_hop_limit) {
+		if (in6_dev->cnf.accept_ra_min_hop_limit <=
+		    ra_msg->icmph.icmp6_hop_limit) {
 			in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
 			if (rt)
 				dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
 					       ra_msg->icmph.icmp6_hop_limit);
 		} else {
-			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than minimum\n");
+			ND_PRINTK(2, warn,
+				  "RA: Got route advertisement with lower hop_limit than minimum\n");
 		}
 	}
 
 skip_defrtr:
 
-	/*
-	 *	Update Reachable Time and Retrans Timer
-	 */
+	/* Update Reachable Time and Retrans Timer */
 
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
 
-			if (rtime != NEIGH_VAR(in6_dev->nd_parms, BASE_REACHABLE_TIME)) {
+			if (rtime != NEIGH_VAR(in6_dev->nd_parms,
+					       BASE_REACHABLE_TIME)) {
 				NEIGH_VAR_SET(in6_dev->nd_parms,
 					      BASE_REACHABLE_TIME, rtime);
 				NEIGH_VAR_SET(in6_dev->nd_parms,
 					      GC_STALETIME, 3 * rtime);
-				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
+				in6_dev->nd_parms->reachable_time =
+					neigh_rand_reach_time(rtime);
 				in6_dev->tstamp = jiffies;
 				send_ifinfo_notify = true;
 			}
 		}
 	}
 
-	/*
-	 *	Send a notify if RA changed managed/otherconf flags or timer settings
+	/* Send a notify if RA changed managed/otherconf flags
+	 * or timer settings
 	 */
 	if (send_ifinfo_notify)
 		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 
 skip_linkparms:
 
-	/*
-	 *	Process options.
-	 */
+	/* Process options */
 
 	if (!neigh)
 		neigh = __neigh_lookup(&nd_tbl, &ipv6_hdr(skb)->saddr,
 				       skb->dev, 1);
 	if (neigh) {
 		u8 *lladdr = NULL;
+
 		if (ndopts.nd_opts_src_lladdr) {
 			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
 						     skb->dev);
@@ -1380,9 +1384,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
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
@@ -1406,6 +1410,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_ri;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_ri_end)) {
@@ -1418,9 +1423,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			if (ri->prefix_len == 0 &&
 			    !in6_dev->cnf.accept_ra_defrtr)
 				continue;
-			if (ri->prefix_len < in6_dev->cnf.accept_ra_rt_info_min_plen)
+			if (ri->prefix_len <
+				in6_dev->cnf.accept_ra_rt_info_min_plen)
 				continue;
-			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
+			if (ri->prefix_len >
+				in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
 			rt6_route_rcv(skb->dev, (u8 *)p, (p->nd_opt_len) << 3,
 				      &ipv6_hdr(skb)->saddr);
@@ -1442,12 +1449,13 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_opts_pi;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
 			addrconf_prefix_rcv(skb->dev, (u8 *)p,
 					    (p->nd_opt_len) << 3,
-					    ndopts.nd_opts_src_lladdr != NULL);
+					    ndopts.nd_opts_src_lladdr);
 		}
 	}
 
@@ -1455,7 +1463,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		__be32 n;
 		u32 mtu;
 
-		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu+1))+2, sizeof(mtu));
+		memcpy(&n, ((u8 *)(ndopts.nd_opts_mtu + 1)) + 2, sizeof(mtu));
 		mtu = ntohl(n);
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
@@ -1472,6 +1480,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	if (ndopts.nd_useropts) {
 		struct nd_opt_hdr *p;
+
 		for (p = ndopts.nd_useropts;
 		     p;
 		     p = ndisc_next_useropt(skb->dev, p,
@@ -1480,9 +1489,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		}
 	}
 
-	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
+	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh)
 		ND_PRINTK(2, warn, "RA: invalid RA options\n");
-	}
+
 out:
 	ip6_rt_put(rt);
 	if (neigh)
@@ -1518,7 +1527,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 
 	if (!ndopts.nd_opts_rh) {
 		ip6_redirect_no_header(skb, dev_net(skb->dev),
-					skb->dev->ifindex, 0);
+				       skb->dev->ifindex, 0);
 		return;
 	}
 
@@ -1569,7 +1578,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	}
 
 	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
-	    ipv6_addr_type(target) != (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
+	    ipv6_addr_type(target) !=
+		(IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK(2, warn,
 			  "Redirect: target address is not link-local unicast\n");
 		return;
@@ -1587,7 +1597,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (IS_ERR(dst))
 		return;
 
-	rt = (struct rt6_info *) dst;
+	rt = (struct rt6_info *)dst;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
 		ND_PRINTK(2, warn,
@@ -1595,14 +1605,16 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		goto release;
 	}
 	peer = inet_getpeer_v6(net->ipv6.peers, &ipv6_hdr(skb)->saddr, 1);
-	ret = inet_peer_xrlim_allow(peer, 1*HZ);
+	ret = inet_peer_xrlim_allow(peer, 1 * HZ);
 	if (peer)
 		inet_putpeer(peer);
 	if (!ret)
 		goto release;
 
 	if (dev->addr_len) {
-		struct neighbour *neigh = dst_neigh_lookup(skb_dst(skb), target);
+		struct neighbour *neigh =
+				dst_neigh_lookup(skb_dst(skb), target);
+
 		if (!neigh) {
 			ND_PRINTK(2, warn,
 				  "Redirect: no neigh for target address\n");
@@ -1617,14 +1629,16 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			optlen += ndisc_redirect_opt_addr_space(dev, neigh,
 								ops_data_buf,
 								&ops_data);
-		} else
+		} else {
 			read_unlock_bh(&neigh->lock);
+		}
 
 		neigh_release(neigh);
 	}
 
 	rd_len = min_t(unsigned int,
-		       IPV6_MIN_MTU - sizeof(struct ipv6hdr) - sizeof(*msg) - optlen,
+		       IPV6_MIN_MTU - sizeof(struct ipv6hdr) -
+				sizeof(*msg) - optlen,
 		       skb->len + 8);
 	rd_len &= ~0x7;
 	optlen += rd_len;
@@ -1642,16 +1656,12 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 		.dest = ipv6_hdr(skb)->daddr,
 	};
 
-	/*
-	 *	include target_address option
-	 */
+	/* include target_address option */
 
 	if (ha)
 		ndisc_fill_redirect_addr_option(buff, ha, ops_data);
 
-	/*
-	 *	build redirect option and copy skb over to the new packet.
-	 */
+	/* build redirect option and copy skb over to the new packet */
 
 	if (rd_len)
 		ndisc_fill_redirect_hdr_option(buff, skb, rd_len);
@@ -1737,7 +1747,8 @@ int ndisc_rcv(struct sk_buff *skb)
 	return 0;
 }
 
-static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+static int ndisc_netdev_event(struct notifier_block *this,
+			      unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct netdev_notifier_change_info *change_info;
@@ -1787,6 +1798,7 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 {
 	static char warncomm[TASK_COMM_LEN];
 	static int warned;
+
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm, current->comm);
 		pr_warn("process `%s' is using deprecated sysctl (%s) net.ipv6.neigh.%s.%s - use net.ipv6.neigh.%s.%s_ms instead\n",
@@ -1797,7 +1809,8 @@ static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
 	}
 }
 
-int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *buffer, size_t *lenp, loff_t *ppos)
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write,
+			       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
@@ -1805,7 +1818,8 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 
 	if ((strcmp(ctl->procname, "retrans_time") == 0) ||
 	    (strcmp(ctl->procname, "base_reachable_time") == 0))
-		ndisc_warn_deprecated_sysctl(ctl, "syscall", dev ? dev->name : "default");
+		ndisc_warn_deprecated_sysctl(ctl, "syscall",
+					     dev ? dev->name : "default");
 
 	if (strcmp(ctl->procname, "retrans_time") == 0)
 		ret = neigh_proc_dointvec(ctl, write, buffer, lenp, ppos);
@@ -1821,18 +1835,22 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 	else
 		ret = -1;
 
-	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
-		if (ctl->data == &NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME))
+	if (!write || ret || !dev)
+		return ret;
+
+	idev = in6_dev_get(dev);
+	if (idev) {
+		if (ctl->data ==
+		    &NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME))
 			idev->nd_parms->reachable_time =
-					neigh_rand_reach_time(NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME));
+			  neigh_rand_reach_time(
+			    NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME));
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 		in6_dev_put(idev);
 	}
 	return ret;
 }
-
-
 #endif
 
 static int __net_init ndisc_net_init(struct net *net)
@@ -1877,9 +1895,7 @@ int __init ndisc_init(void)
 	err = register_pernet_subsys(&ndisc_net_ops);
 	if (err)
 		return err;
-	/*
-	 * Initialize the neighbour table
-	 */
+	/* Initialize the neighbour table */
 	neigh_table_init(NEIGH_ND_TABLE, &nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-- 
2.7.4
