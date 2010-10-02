From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 4/4] ipmr: cleanups
Date: Sat, 02 Oct 2010 04:15:29 +0200
Message-ID: <1285985729.2582.525.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54582 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab0JBCPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 22:15:34 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so992146fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 19:15:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various code style cleanups

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipmr.c |  238 +++++++++++++++++++++++-----------------------
 1 file changed, 124 insertions(+), 114 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index cbb6dab..86dd569 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -98,7 +98,7 @@ struct ipmr_result {
 };
 
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
-   Note that the changes are semaphored via rtnl_lock.
+ * Note that the changes are semaphored via rtnl_lock.
  */
 
 static DEFINE_RWLOCK(mrt_lock);
@@ -113,11 +113,11 @@ static DEFINE_RWLOCK(mrt_lock);
 static DEFINE_SPINLOCK(mfc_unres_lock);
 
 /* We return to original Alan's scheme. Hash table of resolved
-   entries is changed only in process context and protected
-   with weak lock mrt_lock. Queue of unresolved entries is protected
-   with strong spinlock mfc_unres_lock.
-
-   In this case data path is free of exclusive locks at all.
+ * entries is changed only in process context and protected
+ * with weak lock mrt_lock. Queue of unresolved entries is protected
+ * with strong spinlock mfc_unres_lock.
+ *
+ * In this case data path is free of exclusive locks at all.
  */
 
 static struct kmem_cache *mrt_cachep __read_mostly;
@@ -396,9 +396,9 @@ struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 			set_fs(KERNEL_DS);
 			err = ops->ndo_do_ioctl(dev, &ifr, SIOCADDTUNNEL);
 			set_fs(oldfs);
-		} else
+		} else {
 			err = -EOPNOTSUPP;
-
+		}
 		dev = NULL;
 
 		if (err == 0 &&
@@ -495,7 +495,8 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 	dev->iflink = 0;
 
 	rcu_read_lock();
-	if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
+	in_dev = __in_dev_get_rcu(dev);
+	if (!in_dev) {
 		rcu_read_unlock();
 		goto failure;
 	}
@@ -552,9 +553,10 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 		mrt->mroute_reg_vif_num = -1;
 #endif
 
-	if (vifi+1 == mrt->maxvif) {
+	if (vifi + 1 == mrt->maxvif) {
 		int tmp;
-		for (tmp=vifi-1; tmp>=0; tmp--) {
+
+		for (tmp = vifi - 1; tmp >= 0; tmp--) {
 			if (VIF_EXISTS(mrt, tmp))
 				break;
 		}
@@ -565,12 +567,13 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 
 	dev_set_allmulti(dev, -1);
 
-	if ((in_dev = __in_dev_get_rtnl(dev)) != NULL) {
+	in_dev = __in_dev_get_rtnl(dev);
+	if (in_dev) {
 		IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)--;
 		ip_rt_multicast_event(in_dev);
 	}
 
-	if (v->flags&(VIFF_TUNNEL|VIFF_REGISTER) && !notify)
+	if (v->flags & (VIFF_TUNNEL | VIFF_REGISTER) && !notify)
 		unregister_netdevice_queue(dev, head);
 
 	dev_put(dev);
@@ -590,7 +593,7 @@ static inline void ipmr_cache_free(struct mfc_cache *c)
 }
 
 /* Destroy an unresolved cache entry, killing queued skbs
-   and reporting error to netlink readers.
+ * and reporting error to netlink readers.
  */
 
 static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
@@ -612,8 +615,9 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 			memset(&e->msg, 0, sizeof(e->msg));
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
-		} else
+		} else {
 			kfree_skb(skb);
+		}
 	}
 
 	ipmr_cache_free(c);
@@ -735,9 +739,9 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 				dev_put(dev);
 				return -EADDRNOTAVAIL;
 			}
-		} else
+		} else {
 			dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
-
+		}
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		err = dev_set_allmulti(dev, 1);
@@ -750,16 +754,16 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		return -EINVAL;
 	}
 
-	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL) {
+	in_dev = __in_dev_get_rtnl(dev);
+	if (!in_dev) {
 		dev_put(dev);
 		return -EADDRNOTAVAIL;
 	}
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
 	ip_rt_multicast_event(in_dev);
 
-	/*
-	 *	Fill in the VIF structures
-	 */
+	/* Fill in the VIF structures */
+
 	v->rate_limit = vifc->vifc_rate_limit;
 	v->local = vifc->vifc_lcl_addr.s_addr;
 	v->remote = vifc->vifc_rmt_addr.s_addr;
@@ -772,14 +776,14 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	v->pkt_in = 0;
 	v->pkt_out = 0;
 	v->link = dev->ifindex;
-	if (v->flags&(VIFF_TUNNEL|VIFF_REGISTER))
+	if (v->flags & (VIFF_TUNNEL | VIFF_REGISTER))
 		v->link = dev->iflink;
 
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
 	v->dev = dev;
 #ifdef CONFIG_IP_PIMSM
-	if (v->flags&VIFF_REGISTER)
+	if (v->flags & VIFF_REGISTER)
 		mrt->mroute_reg_vif_num = vifi;
 #endif
 	if (vifi+1 > mrt->maxvif)
@@ -836,17 +840,15 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
 
-	/*
-	 *	Play the pending entries through our router
-	 */
+	/* Play the pending entries through our router */
 
 	while ((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ip_hdr(skb)->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
 			if (__ipmr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
-				nlh->nlmsg_len = (skb_tail_pointer(skb) -
-						  (u8 *)nlh);
+				nlh->nlmsg_len = skb_tail_pointer(skb) -
+						 (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
 				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
@@ -857,8 +859,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 			}
 
 			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
-		} else
+		} else {
 			ip_mr_forward(net, mrt, skb, c, 0);
+		}
 	}
 }
 
@@ -892,9 +895,9 @@ static int ipmr_cache_report(struct mr_table *mrt,
 #ifdef CONFIG_IP_PIMSM
 	if (assert == IGMPMSG_WHOLEPKT) {
 		/* Ugly, but we have no choice with this interface.
-		   Duplicate old header, fix ihl, length etc.
-		   And all this only to mangle msg->im_msgtype and
-		   to set msg->im_mbz to "mbz" :-)
+		 * Duplicate old header, fix ihl, length etc.
+		 * And all this only to mangle msg->im_msgtype and
+		 * to set msg->im_mbz to "mbz" :-)
 		 */
 		skb_push(skb, sizeof(struct iphdr));
 		skb_reset_network_header(skb);
@@ -911,27 +914,23 @@ static int ipmr_cache_report(struct mr_table *mrt,
 #endif
 	{
 
-	/*
-	 *	Copy the IP header
-	 */
+	/* Copy the IP header */
 
 	skb->network_header = skb->tail;
 	skb_put(skb, ihl);
 	skb_copy_to_linear_data(skb, pkt->data, ihl);
-	ip_hdr(skb)->protocol = 0;			/* Flag to the kernel this is a route add */
+	ip_hdr(skb)->protocol = 0;	/* Flag to the kernel this is a route add */
 	msg = (struct igmpmsg *)skb_network_header(skb);
 	msg->im_vif = vifi;
 	skb_dst_set(skb, dst_clone(skb_dst(pkt)));
 
-	/*
-	 *	Add our header
-	 */
+	/* Add our header */
 
-	igmp=(struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
+	igmp = (struct igmphdr *)skb_put(skb, sizeof(struct igmphdr));
 	igmp->type	=
 	msg->im_msgtype = assert;
-	igmp->code 	=	0;
-	ip_hdr(skb)->tot_len = htons(skb->len);			/* Fix the length */
+	igmp->code	= 0;
+	ip_hdr(skb)->tot_len = htons(skb->len);		/* Fix the length */
 	skb->transport_header = skb->network_header;
 	}
 
@@ -943,9 +942,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
 		return -EINVAL;
 	}
 
-	/*
-	 *	Deliver to mrouted
-	 */
+	/* Deliver to mrouted */
+
 	ret = sock_queue_rcv_skb(mroute_sk, skb);
 	rcu_read_unlock();
 	if (ret < 0) {
@@ -979,9 +977,7 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 	}
 
 	if (!found) {
-		/*
-		 *	Create a new entry if allowable
-		 */
+		/* Create a new entry if allowable */
 
 		if (atomic_read(&mrt->cache_resolve_queue_len) >= 10 ||
 		    (c = ipmr_cache_alloc_unres()) == NULL) {
@@ -991,16 +987,14 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 			return -ENOBUFS;
 		}
 
-		/*
-		 *	Fill in the new cache entry
-		 */
+		/* Fill in the new cache entry */
+
 		c->mfc_parent	= -1;
 		c->mfc_origin	= iph->saddr;
 		c->mfc_mcastgrp	= iph->daddr;
 
-		/*
-		 *	Reflect first query at mrouted.
-		 */
+		/* Reflect first query at mrouted. */
+
 		err = ipmr_cache_report(mrt, skb, vifi, IGMPMSG_NOCACHE);
 		if (err < 0) {
 			/* If the report failed throw the cache entry
@@ -1020,10 +1014,9 @@ ipmr_cache_unresolved(struct mr_table *mrt, vifi_t vifi, struct sk_buff *skb)
 			mod_timer(&mrt->ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
 
-	/*
-	 *	See if we can append the packet
-	 */
-	if (c->mfc_un.unres.unresolved.qlen>3) {
+	/* See if we can append the packet */
+
+	if (c->mfc_un.unres.unresolved.qlen > 3) {
 		kfree_skb(skb);
 		err = -ENOBUFS;
 	} else {
@@ -1140,18 +1133,16 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	LIST_HEAD(list);
 	struct mfc_cache *c, *next;
 
-	/*
-	 *	Shut down all active vif entries
-	 */
+	/* Shut down all active vif entries */
+
 	for (i = 0; i < mrt->maxvif; i++) {
-		if (!(mrt->vif_table[i].flags&VIFF_STATIC))
+		if (!(mrt->vif_table[i].flags & VIFF_STATIC))
 			vif_delete(mrt, i, 0, &list);
 	}
 	unregister_netdevice_many(&list);
 
-	/*
-	 *	Wipe the cache
-	 */
+	/* Wipe the cache */
+
 	for (i = 0; i < MFC_LINES; i++) {
 		list_for_each_entry_safe(c, next, &mrt->mfc_cache_array[i], list) {
 			if (c->mfc_flags & MFC_STATIC)
@@ -1282,7 +1273,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	case MRT_ASSERT:
 	{
 		int v;
-		if (get_user(v,(int __user *)optval))
+		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
 		mrt->mroute_do_assert = (v) ? 1 : 0;
 		return 0;
@@ -1292,7 +1283,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	{
 		int v;
 
-		if (get_user(v,(int __user *)optval))
+		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
 		v = (v) ? 1 : 0;
 
@@ -1355,9 +1346,9 @@ int ip_mroute_getsockopt(struct sock *sk, int optname, char __user *optval, int
 
 	if (optname != MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
-	   optname!=MRT_PIM &&
+	   optname != MRT_PIM &&
 #endif
-	   optname!=MRT_ASSERT)
+	   optname != MRT_ASSERT)
 		return -ENOPROTOOPT;
 
 	if (get_user(olr, optlen))
@@ -1473,7 +1464,7 @@ static struct notifier_block ip_mr_notifier = {
 };
 
 /*
- * 	Encapsulate a packet by attaching a valid IPIP header to it.
+ *	Encapsulate a packet by attaching a valid IPIP header to it.
  *	This avoids tunnel drivers and other mess and gives us the speed so
  *	important for multicast video.
  */
@@ -1488,7 +1479,7 @@ static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 	skb_reset_network_header(skb);
 	iph = ip_hdr(skb);
 
-	iph->version	= 	4;
+	iph->version	=	4;
 	iph->tos	=	old_iph->tos;
 	iph->ttl	=	old_iph->ttl;
 	iph->frag_off	=	0;
@@ -1506,7 +1497,7 @@ static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 
 static inline int ipmr_forward_finish(struct sk_buff *skb)
 {
-	struct ip_options * opt	= &(IPCB(skb)->opt);
+	struct ip_options *opt = &(IPCB(skb)->opt);
 
 	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
@@ -1543,22 +1534,34 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	}
 #endif
 
-	if (vif->flags&VIFF_TUNNEL) {
-		struct flowi fl = { .oif = vif->link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = vif->remote,
-						.saddr = vif->local,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_IPIP };
+	if (vif->flags & VIFF_TUNNEL) {
+		struct flowi fl = {
+			.oif = vif->link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = vif->remote,
+					.saddr = vif->local,
+					.tos = RT_TOS(iph->tos)
+				}
+			},
+			.proto = IPPROTO_IPIP
+		};
+
 		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
-		struct flowi fl = { .oif = vif->link,
-				    .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.tos = RT_TOS(iph->tos) } },
-				    .proto = IPPROTO_IPIP };
+		struct flowi fl = {
+			.oif = vif->link,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = iph->daddr,
+					.tos = RT_TOS(iph->tos)
+				}
+			},
+			.proto = IPPROTO_IPIP
+		};
+
 		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
 	}
@@ -1567,8 +1570,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 
 	if (skb->len+encap > dst_mtu(&rt->dst) && (ntohs(iph->frag_off) & IP_DF)) {
 		/* Do not fragment multicasts. Alas, IPv4 does not
-		   allow to send ICMP, so that packets will disappear
-		   to blackhole.
+		 * allow to send ICMP, so that packets will disappear
+		 * to blackhole.
 		 */
 
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
@@ -1591,7 +1594,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	ip_decrease_ttl(ip_hdr(skb));
 
 	/* FIXME: forward and output firewalls used to be called here.
-	 * What do we do with netfilter? -- RR */
+	 * What do we do with netfilter? -- RR
+	 */
 	if (vif->flags & VIFF_TUNNEL) {
 		ip_encap(skb, vif->local, vif->remote);
 		/* FIXME: extra output firewall step used to be here. --RR */
@@ -1652,15 +1656,15 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 
 		if (skb_rtable(skb)->fl.iif == 0) {
 			/* It is our own packet, looped back.
-			   Very complicated situation...
-
-			   The best workaround until routing daemons will be
-			   fixed is not to redistribute packet, if it was
-			   send through wrong interface. It means, that
-			   multicast applications WILL NOT work for
-			   (S,G), which have default multicast route pointing
-			   to wrong oif. In any case, it is not a good
-			   idea to use multicasting applications on router.
+			 * Very complicated situation...
+			 *
+			 * The best workaround until routing daemons will be
+			 * fixed is not to redistribute packet, if it was
+			 * send through wrong interface. It means, that
+			 * multicast applications WILL NOT work for
+			 * (S,G), which have default multicast route pointing
+			 * to wrong oif. In any case, it is not a good
+			 * idea to use multicasting applications on router.
 			 */
 			goto dont_forward;
 		}
@@ -1670,9 +1674,9 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 
 		if (true_vifi >= 0 && mrt->mroute_do_assert &&
 		    /* pimsm uses asserts, when switching from RPT to SPT,
-		       so that we cannot check that packet arrived on an oif.
-		       It is bad, but otherwise we would need to move pretty
-		       large chunk of pimd to kernel. Ough... --ANK
+		     * so that we cannot check that packet arrived on an oif.
+		     * It is bad, but otherwise we would need to move pretty
+		     * large chunk of pimd to kernel. Ough... --ANK
 		     */
 		    (mrt->mroute_do_pim ||
 		     cache->mfc_un.res.ttls[true_vifi] < 255) &&
@@ -1690,10 +1694,12 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 	/*
 	 *	Forward the frame
 	 */
-	for (ct = cache->mfc_un.res.maxvif-1; ct >= cache->mfc_un.res.minvif; ct--) {
+	for (ct = cache->mfc_un.res.maxvif - 1;
+	     ct >= cache->mfc_un.res.minvif; ct--) {
 		if (ip_hdr(skb)->ttl > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 				if (skb2)
 					ipmr_queue_xmit(net, mrt, skb2, cache,
 							psend);
@@ -1704,6 +1710,7 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 	if (psend != -1) {
 		if (local) {
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 			if (skb2)
 				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
 		} else {
@@ -1733,7 +1740,7 @@ int ip_mr_input(struct sk_buff *skb)
 	int err;
 
 	/* Packet is looped back after forward, it should not be
-	   forwarded second time, but still can be delivered locally.
+	 * forwarded second time, but still can be delivered locally.
 	 */
 	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
@@ -1822,10 +1829,10 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
-	   Check that:
-	   a. packet is really destinted to a multicast group
-	   b. packet is not a NULL-REGISTER
-	   c. packet is not truncated
+	 * Check that:
+	 * a. packet is really sent to a multicast group
+	 * b. packet is not a NULL-REGISTER
+	 * c. packet is not truncated
 	 */
 	if (!ipv4_is_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
@@ -1860,7 +1867,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
  * Handle IGMP messages of PIMv1
  */
 
-int pim_rcv_v1(struct sk_buff * skb)
+int pim_rcv_v1(struct sk_buff *skb)
 {
 	struct igmphdr *pim;
 	struct net *net = dev_net(skb->dev);
@@ -1887,7 +1894,7 @@ drop:
 #endif
 
 #ifdef CONFIG_IP_PIMSM_V2
-static int pim_rcv(struct sk_buff * skb)
+static int pim_rcv(struct sk_buff *skb)
 {
 	struct pimreghdr *pim;
 	struct net *net = dev_net(skb->dev);
@@ -1897,8 +1904,8 @@ static int pim_rcv(struct sk_buff * skb)
 		goto drop;
 
 	pim = (struct pimreghdr *)skb_transport_header(skb);
-	if (pim->type != ((PIM_VERSION<<4)|(PIM_REGISTER)) ||
-	    (pim->flags&PIM_NULL_REGISTER) ||
+	if (pim->type != ((PIM_VERSION << 4) | (PIM_REGISTER)) ||
+	    (pim->flags & PIM_NULL_REGISTER) ||
 	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
@@ -1971,7 +1978,7 @@ int ipmr_get_route(struct net *net,
 		struct sk_buff *skb2;
 		struct iphdr *iph;
 		struct net_device *dev;
-		int vif;
+		int vif = -1;
 
 		if (nowait) {
 			rcu_read_unlock();
@@ -1980,7 +1987,9 @@ int ipmr_get_route(struct net *net,
 
 		dev = skb->dev;
 		read_lock(&mrt_lock);
-		if (dev == NULL || (vif = ipmr_find_vif(mrt, dev)) < 0) {
+		if (dev)
+			vif = ipmr_find_vif(mrt, dev);
+		if (vif < 0) {
 			read_unlock(&mrt_lock);
 			rcu_read_unlock();
 			return -ENODEV;
@@ -2098,7 +2107,8 @@ done:
 
 #ifdef CONFIG_PROC_FS
 /*
- *	The /proc interfaces to multicast routing /proc/ip_mr_cache /proc/ip_mr_vif
+ *	The /proc interfaces to multicast routing :
+ *	/proc/net/ip_mr_cache & /proc/net/ip_mr_vif
  */
 struct ipmr_vif_iter {
 	struct seq_net_private p;
@@ -2294,7 +2304,7 @@ static void *ipmr_mfc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (!list_empty(it->cache))
 		return list_first_entry(it->cache, struct mfc_cache, list);
 
- end_of_list:
+end_of_list:
 	spin_unlock_bh(&mfc_unres_lock);
 	it->cache = NULL;
 
@@ -2335,7 +2345,7 @@ static int ipmr_mfc_seq_show(struct seq_file *seq, void *v)
 				   mfc->mfc_un.res.bytes,
 				   mfc->mfc_un.res.wrong_if);
 			for (n = mfc->mfc_un.res.minvif;
-			     n < mfc->mfc_un.res.maxvif; n++ ) {
+			     n < mfc->mfc_un.res.maxvif; n++) {
 				if (VIF_EXISTS(mrt, n) &&
 				    mfc->mfc_un.res.ttls[n] < 255)
 					seq_printf(seq,


