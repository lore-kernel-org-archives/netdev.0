From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/8] ipv4 cleanup
Date: Thu, 08 Mar 2007 12:52:19 -0800
Message-ID: <20070308205305.995605404@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35788 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933318AbXCHUyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:44 -0500
Content-Disposition: inline; filename=ip-cleanup
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add whitespace around keywords.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/af_inet.c           |    2 
 net/ipv4/arp.c               |    2 
 net/ipv4/cipso_ipv4.c        |    2 
 net/ipv4/devinet.c           |    4 
 net/ipv4/fib_trie.c          |   17 
 net/ipv4/ip_fragment.c       |   26 
 net/ipv4/ip_output.c         |    2 
 net/ipv4/ip_sockglue.c       | 1147 +++++++++++++++++++++----------------------
 net/ipv4/ipconfig.c          |    4 
 net/ipv4/ipmr.c              |  305 +++++------
 net/ipv4/xfrm4_mode_tunnel.c |    2 
 net/ipv4/xfrm4_policy.c      |    2 
 12 files changed, 755 insertions(+), 760 deletions(-)

--- net-2.6.22.orig/net/ipv4/af_inet.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/af_inet.c	2007-03-07 15:11:11.000000000 -0800
@@ -1336,7 +1336,7 @@
 	 *	Initialise per-cpu ipv4 mibs
 	 */
 
-	if(init_ipv4_mibs())
+	if (init_ipv4_mibs())
 		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n"); ;
 
 	ipv4_proc_init();
--- net-2.6.22.orig/net/ipv4/arp.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/arp.c	2007-03-07 15:11:11.000000000 -0800
@@ -1178,7 +1178,7 @@
 		goto out;
 	}
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCDARP:
 		err = arp_req_delete(&r, dev);
 		break;
--- net-2.6.22.orig/net/ipv4/devinet.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/devinet.c	2007-03-07 15:11:11.000000000 -0800
@@ -631,7 +631,7 @@
 	dev_load(ifr.ifr_name);
 #endif
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
 	case SIOCGIFBRDADDR:	/* Get the broadcast address */
 	case SIOCGIFDSTADDR:	/* Get the destination address */
@@ -706,7 +706,7 @@
 	if (!ifa && cmd != SIOCSIFADDR && cmd != SIOCSIFFLAGS)
 		goto done;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
 		sin->sin_addr.s_addr = ifa->ifa_local;
 		goto rarok;
--- net-2.6.22.orig/net/ipv4/fib_trie.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/fib_trie.c	2007-03-07 15:11:11.000000000 -0800
@@ -350,11 +350,10 @@
 
 static inline void tnode_free(struct tnode *tn)
 {
-	if(IS_LEAF(tn)) {
+	if (IS_LEAF(tn)) {
 		struct leaf *l = (struct leaf *) tn;
 		call_rcu_bh(&l->rcu, __leaf_free_rcu);
-	}
-	else
+	} else
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
 
@@ -553,7 +552,7 @@
 
 	/* Keep root node larger  */
 
-	if(!tn->parent)
+	if (!tn->parent)
 		inflate_threshold_use = inflate_threshold_root;
 	else
 		inflate_threshold_use = inflate_threshold;
@@ -584,7 +583,7 @@
 
 	/* Keep root node larger  */
 
-	if(!tn->parent)
+	if (!tn->parent)
 		halve_threshold_use = halve_threshold_root;
 	else
 		halve_threshold_use = halve_threshold;
@@ -2032,12 +2031,12 @@
 {
 	struct node *n ;
 
-	if(!t)
+	if (!t)
 		return NULL;
 
 	n = rcu_dereference(t->trie);
 
-	if(!iter)
+	if (!iter)
 		return NULL;
 
 	if (n) {
@@ -2077,7 +2076,7 @@
 			int i;
 
 			s->tnodes++;
-			if(tn->bits < MAX_STAT_DEPTH)
+			if (tn->bits < MAX_STAT_DEPTH)
 				s->nodesizes[tn->bits]++;
 
 			for (i = 0; i < (1<<tn->bits); i++)
@@ -2243,7 +2242,7 @@
 {
 	static char buf[32];
 
-	switch(s) {
+	switch (s) {
 	case RT_SCOPE_UNIVERSE: return "universe";
 	case RT_SCOPE_SITE:	return "site";
 	case RT_SCOPE_LINK:	return "link";
--- net-2.6.22.orig/net/ipv4/ip_fragment.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/ip_fragment.c	2007-03-07 15:11:11.000000000 -0800
@@ -184,7 +184,7 @@
 {
 	struct ipq *qp = kmalloc(sizeof(struct ipq), GFP_ATOMIC);
 
-	if(!qp)
+	if (!qp)
 		return NULL;
 	atomic_add(sizeof(struct ipq), &ip_frag_mem);
 	return qp;
@@ -321,11 +321,11 @@
 	 * promoted read lock to write lock.
 	 */
 	hlist_for_each_entry(qp, n, &ipq_hash[hash], list) {
-		if(qp->id == qp_in->id		&&
-		   qp->saddr == qp_in->saddr	&&
-		   qp->daddr == qp_in->daddr	&&
-		   qp->protocol == qp_in->protocol &&
-		   qp->user == qp_in->user) {
+		if (qp->id == qp_in->id		&&
+		    qp->saddr == qp_in->saddr	&&
+		    qp->daddr == qp_in->daddr	&&
+		    qp->protocol == qp_in->protocol &&
+		    qp->user == qp_in->user) {
 			atomic_inc(&qp->refcnt);
 			write_unlock(&ipfrag_lock);
 			qp_in->last_in |= COMPLETE;
@@ -398,11 +398,11 @@
 	read_lock(&ipfrag_lock);
 	hash = ipqhashfn(id, saddr, daddr, protocol);
 	hlist_for_each_entry(qp, n, &ipq_hash[hash], list) {
-		if(qp->id == id		&&
-		   qp->saddr == saddr	&&
-		   qp->daddr == daddr	&&
-		   qp->protocol == protocol &&
-		   qp->user == user) {
+		if (qp->id == id		&&
+		    qp->saddr == saddr	&&
+		    qp->daddr == daddr	&&
+		    qp->protocol == protocol &&
+		    qp->user == user) {
 			atomic_inc(&qp->refcnt);
 			read_unlock(&ipfrag_lock);
 			return qp;
@@ -524,7 +524,7 @@
 	 * this fragment, right?
 	 */
 	prev = NULL;
-	for(next = qp->fragments; next != NULL; next = next->next) {
+	for (next = qp->fragments; next != NULL; next = next->next) {
 		if (FRAG_CB(next)->offset >= offset)
 			break;	/* bingo! */
 		prev = next;
@@ -627,7 +627,7 @@
 	ihlen = head->nh.iph->ihl*4;
 	len = ihlen + qp->len;
 
-	if(len > 65535)
+	if (len > 65535)
 		goto out_oversize;
 
 	/* Head of list must not be cloned. */
--- net-2.6.22.orig/net/ipv4/ip_sockglue.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/ip_sockglue.c	2007-03-07 15:11:11.000000000 -0800
@@ -403,20 +403,20 @@
  */
 
 static int do_ip_setsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int optlen)
+			    int optname, char __user *optval, int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val=0,err;
 
 	if (((1<<optname) & ((1<<IP_PKTINFO) | (1<<IP_RECVTTL) |
-			    (1<<IP_RECVOPTS) | (1<<IP_RECVTOS) |
-			    (1<<IP_RETOPTS) | (1<<IP_TOS) |
-			    (1<<IP_TTL) | (1<<IP_HDRINCL) |
-			    (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
-			    (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
-			    (1<<IP_PASSSEC))) ||
-				optname == IP_MULTICAST_TTL ||
-				optname == IP_MULTICAST_LOOP) {
+			     (1<<IP_RECVOPTS) | (1<<IP_RECVTOS) |
+			     (1<<IP_RETOPTS) | (1<<IP_TOS) |
+			     (1<<IP_TTL) | (1<<IP_HDRINCL) |
+			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
+			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
+			     (1<<IP_PASSSEC))) ||
+	    optname == IP_MULTICAST_TTL ||
+	    optname == IP_MULTICAST_LOOP) {
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
@@ -440,444 +440,444 @@
 	lock_sock(sk);
 
 	switch (optname) {
-		case IP_OPTIONS:
-		{
-			struct ip_options * opt = NULL;
-			if (optlen > 40 || optlen < 0)
-				goto e_inval;
-			err = ip_options_get_from_user(&opt, optval, optlen);
-			if (err)
-				break;
-			if (inet->is_icsk) {
-				struct inet_connection_sock *icsk = inet_csk(sk);
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-				if (sk->sk_family == PF_INET ||
-				    (!((1 << sk->sk_state) &
-				       (TCPF_LISTEN | TCPF_CLOSE)) &&
-				     inet->daddr != LOOPBACK4_IPV6)) {
-#endif
-					if (inet->opt)
-						icsk->icsk_ext_hdr_len -= inet->opt->optlen;
-					if (opt)
-						icsk->icsk_ext_hdr_len += opt->optlen;
-					icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
+	case IP_OPTIONS:
+	{
+		struct ip_options * opt = NULL;
+		if (optlen > 40 || optlen < 0)
+			goto e_inval;
+		err = ip_options_get_from_user(&opt, optval, optlen);
+		if (err)
+			break;
+		if (inet->is_icsk) {
+			struct inet_connection_sock *icsk = inet_csk(sk);
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-				}
+			if (sk->sk_family == PF_INET ||
+			    (!((1 << sk->sk_state) &
+			       (TCPF_LISTEN | TCPF_CLOSE)) &&
+			     inet->daddr != LOOPBACK4_IPV6)) {
 #endif
+				if (inet->opt)
+					icsk->icsk_ext_hdr_len -= inet->opt->optlen;
+				if (opt)
+					icsk->icsk_ext_hdr_len += opt->optlen;
+				icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 			}
-			opt = xchg(&inet->opt, opt);
-			kfree(opt);
+#endif
+		}
+		opt = xchg(&inet->opt, opt);
+		kfree(opt);
+		break;
+	}
+	case IP_PKTINFO:
+		if (val)
+			inet->cmsg_flags |= IP_CMSG_PKTINFO;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_PKTINFO;
+		break;
+	case IP_RECVTTL:
+		if (val)
+			inet->cmsg_flags |=  IP_CMSG_TTL;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_TTL;
+		break;
+	case IP_RECVTOS:
+		if (val)
+			inet->cmsg_flags |=  IP_CMSG_TOS;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_TOS;
+		break;
+	case IP_RECVOPTS:
+		if (val)
+			inet->cmsg_flags |=  IP_CMSG_RECVOPTS;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_RECVOPTS;
+		break;
+	case IP_RETOPTS:
+		if (val)
+			inet->cmsg_flags |= IP_CMSG_RETOPTS;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_RETOPTS;
+		break;
+	case IP_PASSSEC:
+		if (val)
+			inet->cmsg_flags |= IP_CMSG_PASSSEC;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_PASSSEC;
+		break;
+	case IP_TOS:	/* This sets both TOS and Precedence */
+		if (sk->sk_type == SOCK_STREAM) {
+			val &= ~3;
+			val |= inet->tos & 3;
+		}
+		if (IPTOS_PREC(val) >= IPTOS_PREC_CRITIC_ECP &&
+		    !capable(CAP_NET_ADMIN)) {
+			err = -EPERM;
 			break;
 		}
-		case IP_PKTINFO:
-			if (val)
-				inet->cmsg_flags |= IP_CMSG_PKTINFO;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_PKTINFO;
-			break;
-		case IP_RECVTTL:
-			if (val)
-				inet->cmsg_flags |=  IP_CMSG_TTL;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_TTL;
-			break;
-		case IP_RECVTOS:
-			if (val)
-				inet->cmsg_flags |=  IP_CMSG_TOS;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_TOS;
-			break;
-		case IP_RECVOPTS:
-			if (val)
-				inet->cmsg_flags |=  IP_CMSG_RECVOPTS;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_RECVOPTS;
-			break;
-		case IP_RETOPTS:
-			if (val)
-				inet->cmsg_flags |= IP_CMSG_RETOPTS;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_RETOPTS;
-			break;
-		case IP_PASSSEC:
-			if (val)
-				inet->cmsg_flags |= IP_CMSG_PASSSEC;
-			else
-				inet->cmsg_flags &= ~IP_CMSG_PASSSEC;
-			break;
-		case IP_TOS:	/* This sets both TOS and Precedence */
-			if (sk->sk_type == SOCK_STREAM) {
-				val &= ~3;
-				val |= inet->tos & 3;
-			}
-			if (IPTOS_PREC(val) >= IPTOS_PREC_CRITIC_ECP &&
-			    !capable(CAP_NET_ADMIN)) {
-				err = -EPERM;
-				break;
-			}
-			if (inet->tos != val) {
-				inet->tos = val;
-				sk->sk_priority = rt_tos2priority(val);
-				sk_dst_reset(sk);
-			}
+		if (inet->tos != val) {
+			inet->tos = val;
+			sk->sk_priority = rt_tos2priority(val);
+			sk_dst_reset(sk);
+		}
+		break;
+	case IP_TTL:
+		if (optlen<1)
+			goto e_inval;
+		if (val != -1 && (val < 1 || val>255))
+			goto e_inval;
+		inet->uc_ttl = val;
+		break;
+	case IP_HDRINCL:
+		if (sk->sk_type != SOCK_RAW) {
+			err = -ENOPROTOOPT;
 			break;
-		case IP_TTL:
-			if (optlen<1)
-				goto e_inval;
-			if (val != -1 && (val < 1 || val>255))
-				goto e_inval;
-			inet->uc_ttl = val;
-			break;
-		case IP_HDRINCL:
-			if (sk->sk_type != SOCK_RAW) {
-				err = -ENOPROTOOPT;
+		}
+		inet->hdrincl = val ? 1 : 0;
+		break;
+	case IP_MTU_DISCOVER:
+		if (val<0 || val>2)
+			goto e_inval;
+		inet->pmtudisc = val;
+		break;
+	case IP_RECVERR:
+		inet->recverr = !!val;
+		if (!val)
+			skb_queue_purge(&sk->sk_error_queue);
+		break;
+	case IP_MULTICAST_TTL:
+		if (sk->sk_type == SOCK_STREAM)
+			goto e_inval;
+		if (optlen<1)
+			goto e_inval;
+		if (val==-1)
+			val = 1;
+		if (val < 0 || val > 255)
+			goto e_inval;
+		inet->mc_ttl = val;
+		break;
+	case IP_MULTICAST_LOOP:
+		if (optlen<1)
+			goto e_inval;
+		inet->mc_loop = !!val;
+		break;
+	case IP_MULTICAST_IF:
+	{
+		struct ip_mreqn mreq;
+		struct net_device *dev = NULL;
+
+		if (sk->sk_type == SOCK_STREAM)
+			goto e_inval;
+		/*
+		 *	Check the arguments are allowable
+		 */
+
+		err = -EFAULT;
+		if (optlen >= sizeof(struct ip_mreqn)) {
+			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+				break;
+		} else {
+			memset(&mreq, 0, sizeof(mreq));
+			if (optlen >= sizeof(struct in_addr) &&
+			    copy_from_user(&mreq.imr_address,optval,sizeof(struct in_addr)))
+				break;
+		}
+
+		if (!mreq.imr_ifindex) {
+			if (mreq.imr_address.s_addr == INADDR_ANY) {
+				inet->mc_index = 0;
+				inet->mc_addr  = 0;
+				err = 0;
 				break;
 			}
-			inet->hdrincl = val ? 1 : 0;
-			break;
-		case IP_MTU_DISCOVER:
-			if (val<0 || val>2)
-				goto e_inval;
-			inet->pmtudisc = val;
-			break;
-		case IP_RECVERR:
-			inet->recverr = !!val;
-			if (!val)
-				skb_queue_purge(&sk->sk_error_queue);
-			break;
-		case IP_MULTICAST_TTL:
-			if (sk->sk_type == SOCK_STREAM)
-				goto e_inval;
-			if (optlen<1)
-				goto e_inval;
-			if (val==-1)
-				val = 1;
-			if (val < 0 || val > 255)
-				goto e_inval;
-			inet->mc_ttl = val;
-			break;
-		case IP_MULTICAST_LOOP:
-			if (optlen<1)
-				goto e_inval;
-			inet->mc_loop = !!val;
-			break;
-		case IP_MULTICAST_IF:
-		{
-			struct ip_mreqn mreq;
-			struct net_device *dev = NULL;
+			dev = ip_dev_find(mreq.imr_address.s_addr);
+			if (dev) {
+				mreq.imr_ifindex = dev->ifindex;
+				dev_put(dev);
+			}
+		} else
+			dev = __dev_get_by_index(mreq.imr_ifindex);
 
-			if (sk->sk_type == SOCK_STREAM)
-				goto e_inval;
-			/*
-			 *	Check the arguments are allowable
-			 */
 
-			err = -EFAULT;
-			if (optlen >= sizeof(struct ip_mreqn)) {
-				if (copy_from_user(&mreq,optval,sizeof(mreq)))
-					break;
-			} else {
-				memset(&mreq, 0, sizeof(mreq));
-				if (optlen >= sizeof(struct in_addr) &&
-				    copy_from_user(&mreq.imr_address,optval,sizeof(struct in_addr)))
-					break;
-			}
+		err = -EADDRNOTAVAIL;
+		if (!dev)
+			break;
 
-			if (!mreq.imr_ifindex) {
-				if (mreq.imr_address.s_addr == INADDR_ANY) {
-					inet->mc_index = 0;
-					inet->mc_addr  = 0;
-					err = 0;
-					break;
-				}
-				dev = ip_dev_find(mreq.imr_address.s_addr);
-				if (dev) {
-					mreq.imr_ifindex = dev->ifindex;
-					dev_put(dev);
-				}
-			} else
-				dev = __dev_get_by_index(mreq.imr_ifindex);
+		err = -EINVAL;
+		if (sk->sk_bound_dev_if &&
+		    mreq.imr_ifindex != sk->sk_bound_dev_if)
+			break;
 
+		inet->mc_index = mreq.imr_ifindex;
+		inet->mc_addr  = mreq.imr_address.s_addr;
+		err = 0;
+		break;
+	}
 
-			err = -EADDRNOTAVAIL;
-			if (!dev)
-				break;
+	case IP_ADD_MEMBERSHIP:
+	case IP_DROP_MEMBERSHIP:
+	{
+		struct ip_mreqn mreq;
 
-			err = -EINVAL;
-			if (sk->sk_bound_dev_if &&
-			    mreq.imr_ifindex != sk->sk_bound_dev_if)
+		if (optlen < sizeof(struct ip_mreq))
+			goto e_inval;
+		err = -EFAULT;
+		if (optlen >= sizeof(struct ip_mreqn)) {
+			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+				break;
+		} else {
+			memset(&mreq, 0, sizeof(mreq));
+			if (copy_from_user(&mreq,optval,sizeof(struct ip_mreq)))
 				break;
-
-			inet->mc_index = mreq.imr_ifindex;
-			inet->mc_addr  = mreq.imr_address.s_addr;
-			err = 0;
-			break;
 		}
 
-		case IP_ADD_MEMBERSHIP:
-		case IP_DROP_MEMBERSHIP:
-		{
-			struct ip_mreqn mreq;
-
-			if (optlen < sizeof(struct ip_mreq))
-				goto e_inval;
-			err = -EFAULT;
-			if (optlen >= sizeof(struct ip_mreqn)) {
-				if(copy_from_user(&mreq,optval,sizeof(mreq)))
-					break;
-			} else {
-				memset(&mreq, 0, sizeof(mreq));
-				if (copy_from_user(&mreq,optval,sizeof(struct ip_mreq)))
-					break;
-			}
+		if (optname == IP_ADD_MEMBERSHIP)
+			err = ip_mc_join_group(sk, &mreq);
+		else
+			err = ip_mc_leave_group(sk, &mreq);
+		break;
+	}
+	case IP_MSFILTER:
+	{
+		extern int sysctl_igmp_max_msf;
+		struct ip_msfilter *msf;
 
-			if (optname == IP_ADD_MEMBERSHIP)
-				err = ip_mc_join_group(sk, &mreq);
-			else
-				err = ip_mc_leave_group(sk, &mreq);
+		if (optlen < IP_MSFILTER_SIZE(0))
+			goto e_inval;
+		if (optlen > sysctl_optmem_max) {
+			err = -ENOBUFS;
 			break;
 		}
-		case IP_MSFILTER:
-		{
-			extern int sysctl_igmp_max_msf;
-			struct ip_msfilter *msf;
-
-			if (optlen < IP_MSFILTER_SIZE(0))
-				goto e_inval;
-			if (optlen > sysctl_optmem_max) {
-				err = -ENOBUFS;
-				break;
-			}
-			msf = kmalloc(optlen, GFP_KERNEL);
-			if (msf == 0) {
-				err = -ENOBUFS;
-				break;
-			}
-			err = -EFAULT;
-			if (copy_from_user(msf, optval, optlen)) {
-				kfree(msf);
-				break;
-			}
-			/* numsrc >= (1G-4) overflow in 32 bits */
-			if (msf->imsf_numsrc >= 0x3ffffffcU ||
-			    msf->imsf_numsrc > sysctl_igmp_max_msf) {
-				kfree(msf);
-				err = -ENOBUFS;
-				break;
-			}
-			if (IP_MSFILTER_SIZE(msf->imsf_numsrc) > optlen) {
-				kfree(msf);
-				err = -EINVAL;
-				break;
-			}
-			err = ip_mc_msfilter(sk, msf, 0);
+		msf = kmalloc(optlen, GFP_KERNEL);
+		if (msf == 0) {
+			err = -ENOBUFS;
+			break;
+		}
+		err = -EFAULT;
+		if (copy_from_user(msf, optval, optlen)) {
 			kfree(msf);
 			break;
 		}
-		case IP_BLOCK_SOURCE:
-		case IP_UNBLOCK_SOURCE:
-		case IP_ADD_SOURCE_MEMBERSHIP:
-		case IP_DROP_SOURCE_MEMBERSHIP:
-		{
-			struct ip_mreq_source mreqs;
-			int omode, add;
-
-			if (optlen != sizeof(struct ip_mreq_source))
-				goto e_inval;
-			if (copy_from_user(&mreqs, optval, sizeof(mreqs))) {
-				err = -EFAULT;
-				break;
-			}
-			if (optname == IP_BLOCK_SOURCE) {
-				omode = MCAST_EXCLUDE;
-				add = 1;
-			} else if (optname == IP_UNBLOCK_SOURCE) {
-				omode = MCAST_EXCLUDE;
-				add = 0;
-			} else if (optname == IP_ADD_SOURCE_MEMBERSHIP) {
-				struct ip_mreqn mreq;
-
-				mreq.imr_multiaddr.s_addr = mreqs.imr_multiaddr;
-				mreq.imr_address.s_addr = mreqs.imr_interface;
-				mreq.imr_ifindex = 0;
-				err = ip_mc_join_group(sk, &mreq);
-				if (err && err != -EADDRINUSE)
-					break;
-				omode = MCAST_INCLUDE;
-				add = 1;
-			} else /* IP_DROP_SOURCE_MEMBERSHIP */ {
-				omode = MCAST_INCLUDE;
-				add = 0;
-			}
-			err = ip_mc_source(add, omode, sk, &mreqs, 0);
+		/* numsrc >= (1G-4) overflow in 32 bits */
+		if (msf->imsf_numsrc >= 0x3ffffffcU ||
+		    msf->imsf_numsrc > sysctl_igmp_max_msf) {
+			kfree(msf);
+			err = -ENOBUFS;
 			break;
 		}
-		case MCAST_JOIN_GROUP:
-		case MCAST_LEAVE_GROUP:
-		{
-			struct group_req greq;
-			struct sockaddr_in *psin;
-			struct ip_mreqn mreq;
+		if (IP_MSFILTER_SIZE(msf->imsf_numsrc) > optlen) {
+			kfree(msf);
+			err = -EINVAL;
+			break;
+		}
+		err = ip_mc_msfilter(sk, msf, 0);
+		kfree(msf);
+		break;
+	}
+	case IP_BLOCK_SOURCE:
+	case IP_UNBLOCK_SOURCE:
+	case IP_ADD_SOURCE_MEMBERSHIP:
+	case IP_DROP_SOURCE_MEMBERSHIP:
+	{
+		struct ip_mreq_source mreqs;
+		int omode, add;
 
-			if (optlen < sizeof(struct group_req))
-				goto e_inval;
+		if (optlen != sizeof(struct ip_mreq_source))
+			goto e_inval;
+		if (copy_from_user(&mreqs, optval, sizeof(mreqs))) {
 			err = -EFAULT;
-			if(copy_from_user(&greq, optval, sizeof(greq)))
-				break;
-			psin = (struct sockaddr_in *)&greq.gr_group;
-			if (psin->sin_family != AF_INET)
-				goto e_inval;
-			memset(&mreq, 0, sizeof(mreq));
-			mreq.imr_multiaddr = psin->sin_addr;
-			mreq.imr_ifindex = greq.gr_interface;
-
-			if (optname == MCAST_JOIN_GROUP)
-				err = ip_mc_join_group(sk, &mreq);
-			else
-				err = ip_mc_leave_group(sk, &mreq);
-			break;
-		}
-		case MCAST_JOIN_SOURCE_GROUP:
-		case MCAST_LEAVE_SOURCE_GROUP:
-		case MCAST_BLOCK_SOURCE:
-		case MCAST_UNBLOCK_SOURCE:
-		{
-			struct group_source_req greqs;
-			struct ip_mreq_source mreqs;
-			struct sockaddr_in *psin;
-			int omode, add;
-
-			if (optlen != sizeof(struct group_source_req))
-				goto e_inval;
-			if (copy_from_user(&greqs, optval, sizeof(greqs))) {
-				err = -EFAULT;
-				break;
-			}
-			if (greqs.gsr_group.ss_family != AF_INET ||
-			    greqs.gsr_source.ss_family != AF_INET) {
-				err = -EADDRNOTAVAIL;
-				break;
-			}
-			psin = (struct sockaddr_in *)&greqs.gsr_group;
-			mreqs.imr_multiaddr = psin->sin_addr.s_addr;
-			psin = (struct sockaddr_in *)&greqs.gsr_source;
-			mreqs.imr_sourceaddr = psin->sin_addr.s_addr;
-			mreqs.imr_interface = 0; /* use index for mc_source */
-
-			if (optname == MCAST_BLOCK_SOURCE) {
-				omode = MCAST_EXCLUDE;
-				add = 1;
-			} else if (optname == MCAST_UNBLOCK_SOURCE) {
-				omode = MCAST_EXCLUDE;
-				add = 0;
-			} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
-				struct ip_mreqn mreq;
-
-				psin = (struct sockaddr_in *)&greqs.gsr_group;
-				mreq.imr_multiaddr = psin->sin_addr;
-				mreq.imr_address.s_addr = 0;
-				mreq.imr_ifindex = greqs.gsr_interface;
-				err = ip_mc_join_group(sk, &mreq);
-				if (err && err != -EADDRINUSE)
-					break;
-				greqs.gsr_interface = mreq.imr_ifindex;
-				omode = MCAST_INCLUDE;
-				add = 1;
-			} else /* MCAST_LEAVE_SOURCE_GROUP */ {
-				omode = MCAST_INCLUDE;
-				add = 0;
-			}
-			err = ip_mc_source(add, omode, sk, &mreqs,
-				greqs.gsr_interface);
 			break;
 		}
-		case MCAST_MSFILTER:
-		{
-			extern int sysctl_igmp_max_msf;
-			struct sockaddr_in *psin;
-			struct ip_msfilter *msf = NULL;
-			struct group_filter *gsf = NULL;
-			int msize, i, ifindex;
-
-			if (optlen < GROUP_FILTER_SIZE(0))
-				goto e_inval;
-			if (optlen > sysctl_optmem_max) {
-				err = -ENOBUFS;
-				break;
-			}
-			gsf = kmalloc(optlen,GFP_KERNEL);
-			if (gsf == 0) {
-				err = -ENOBUFS;
-				break;
-			}
-			err = -EFAULT;
-			if (copy_from_user(gsf, optval, optlen)) {
-				goto mc_msf_out;
-			}
-			/* numsrc >= (4G-140)/128 overflow in 32 bits */
-			if (gsf->gf_numsrc >= 0x1ffffff ||
-			    gsf->gf_numsrc > sysctl_igmp_max_msf) {
-				err = -ENOBUFS;
-				goto mc_msf_out;
-			}
-			if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
-				err = -EINVAL;
-				goto mc_msf_out;
-			}
-			msize = IP_MSFILTER_SIZE(gsf->gf_numsrc);
-			msf = kmalloc(msize,GFP_KERNEL);
-			if (msf == 0) {
-				err = -ENOBUFS;
-				goto mc_msf_out;
-			}
-			ifindex = gsf->gf_interface;
-			psin = (struct sockaddr_in *)&gsf->gf_group;
-			if (psin->sin_family != AF_INET) {
-				err = -EADDRNOTAVAIL;
-				goto mc_msf_out;
-			}
-			msf->imsf_multiaddr = psin->sin_addr.s_addr;
-			msf->imsf_interface = 0;
-			msf->imsf_fmode = gsf->gf_fmode;
-			msf->imsf_numsrc = gsf->gf_numsrc;
-			err = -EADDRNOTAVAIL;
-			for (i=0; i<gsf->gf_numsrc; ++i) {
-				psin = (struct sockaddr_in *)&gsf->gf_slist[i];
-
-				if (psin->sin_family != AF_INET)
-					goto mc_msf_out;
-				msf->imsf_slist[i] = psin->sin_addr.s_addr;
-			}
-			kfree(gsf);
-			gsf = NULL;
+		if (optname == IP_BLOCK_SOURCE) {
+			omode = MCAST_EXCLUDE;
+			add = 1;
+		} else if (optname == IP_UNBLOCK_SOURCE) {
+			omode = MCAST_EXCLUDE;
+			add = 0;
+		} else if (optname == IP_ADD_SOURCE_MEMBERSHIP) {
+			struct ip_mreqn mreq;
 
-			err = ip_mc_msfilter(sk, msf, ifindex);
-mc_msf_out:
-			kfree(msf);
-			kfree(gsf);
+			mreq.imr_multiaddr.s_addr = mreqs.imr_multiaddr;
+			mreq.imr_address.s_addr = mreqs.imr_interface;
+			mreq.imr_ifindex = 0;
+			err = ip_mc_join_group(sk, &mreq);
+			if (err && err != -EADDRINUSE)
+				break;
+			omode = MCAST_INCLUDE;
+			add = 1;
+		} else /* IP_DROP_SOURCE_MEMBERSHIP */ {
+			omode = MCAST_INCLUDE;
+			add = 0;
+		}
+		err = ip_mc_source(add, omode, sk, &mreqs, 0);
+		break;
+	}
+	case MCAST_JOIN_GROUP:
+	case MCAST_LEAVE_GROUP:
+	{
+		struct group_req greq;
+		struct sockaddr_in *psin;
+		struct ip_mreqn mreq;
+
+		if (optlen < sizeof(struct group_req))
+			goto e_inval;
+		err = -EFAULT;
+		if (copy_from_user(&greq, optval, sizeof(greq)))
+			break;
+		psin = (struct sockaddr_in *)&greq.gr_group;
+		if (psin->sin_family != AF_INET)
+			goto e_inval;
+		memset(&mreq, 0, sizeof(mreq));
+		mreq.imr_multiaddr = psin->sin_addr;
+		mreq.imr_ifindex = greq.gr_interface;
+
+		if (optname == MCAST_JOIN_GROUP)
+			err = ip_mc_join_group(sk, &mreq);
+		else
+			err = ip_mc_leave_group(sk, &mreq);
+		break;
+	}
+	case MCAST_JOIN_SOURCE_GROUP:
+	case MCAST_LEAVE_SOURCE_GROUP:
+	case MCAST_BLOCK_SOURCE:
+	case MCAST_UNBLOCK_SOURCE:
+	{
+		struct group_source_req greqs;
+		struct ip_mreq_source mreqs;
+		struct sockaddr_in *psin;
+		int omode, add;
+
+		if (optlen != sizeof(struct group_source_req))
+			goto e_inval;
+		if (copy_from_user(&greqs, optval, sizeof(greqs))) {
+			err = -EFAULT;
 			break;
 		}
-		case IP_ROUTER_ALERT:
-			err = ip_ra_control(sk, val ? 1 : 0, NULL);
+		if (greqs.gsr_group.ss_family != AF_INET ||
+		    greqs.gsr_source.ss_family != AF_INET) {
+			err = -EADDRNOTAVAIL;
 			break;
+		}
+		psin = (struct sockaddr_in *)&greqs.gsr_group;
+		mreqs.imr_multiaddr = psin->sin_addr.s_addr;
+		psin = (struct sockaddr_in *)&greqs.gsr_source;
+		mreqs.imr_sourceaddr = psin->sin_addr.s_addr;
+		mreqs.imr_interface = 0; /* use index for mc_source */
+
+		if (optname == MCAST_BLOCK_SOURCE) {
+			omode = MCAST_EXCLUDE;
+			add = 1;
+		} else if (optname == MCAST_UNBLOCK_SOURCE) {
+			omode = MCAST_EXCLUDE;
+			add = 0;
+		} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
+			struct ip_mreqn mreq;
 
-		case IP_FREEBIND:
-			if (optlen<1)
-				goto e_inval;
-			inet->freebind = !!val;
-			break;
+			psin = (struct sockaddr_in *)&greqs.gsr_group;
+			mreq.imr_multiaddr = psin->sin_addr;
+			mreq.imr_address.s_addr = 0;
+			mreq.imr_ifindex = greqs.gsr_interface;
+			err = ip_mc_join_group(sk, &mreq);
+			if (err && err != -EADDRINUSE)
+				break;
+			greqs.gsr_interface = mreq.imr_ifindex;
+			omode = MCAST_INCLUDE;
+			add = 1;
+		} else /* MCAST_LEAVE_SOURCE_GROUP */ {
+			omode = MCAST_INCLUDE;
+			add = 0;
+		}
+		err = ip_mc_source(add, omode, sk, &mreqs,
+				   greqs.gsr_interface);
+		break;
+	}
+	case MCAST_MSFILTER:
+	{
+		extern int sysctl_igmp_max_msf;
+		struct sockaddr_in *psin;
+		struct ip_msfilter *msf = NULL;
+		struct group_filter *gsf = NULL;
+		int msize, i, ifindex;
+
+		if (optlen < GROUP_FILTER_SIZE(0))
+			goto e_inval;
+		if (optlen > sysctl_optmem_max) {
+			err = -ENOBUFS;
+			break;
+		}
+		gsf = kmalloc(optlen,GFP_KERNEL);
+		if (gsf == 0) {
+			err = -ENOBUFS;
+			break;
+		}
+		err = -EFAULT;
+		if (copy_from_user(gsf, optval, optlen)) {
+			goto mc_msf_out;
+		}
+		/* numsrc >= (4G-140)/128 overflow in 32 bits */
+		if (gsf->gf_numsrc >= 0x1ffffff ||
+		    gsf->gf_numsrc > sysctl_igmp_max_msf) {
+			err = -ENOBUFS;
+			goto mc_msf_out;
+		}
+		if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
+			err = -EINVAL;
+			goto mc_msf_out;
+		}
+		msize = IP_MSFILTER_SIZE(gsf->gf_numsrc);
+		msf = kmalloc(msize,GFP_KERNEL);
+		if (msf == 0) {
+			err = -ENOBUFS;
+			goto mc_msf_out;
+		}
+		ifindex = gsf->gf_interface;
+		psin = (struct sockaddr_in *)&gsf->gf_group;
+		if (psin->sin_family != AF_INET) {
+			err = -EADDRNOTAVAIL;
+			goto mc_msf_out;
+		}
+		msf->imsf_multiaddr = psin->sin_addr.s_addr;
+		msf->imsf_interface = 0;
+		msf->imsf_fmode = gsf->gf_fmode;
+		msf->imsf_numsrc = gsf->gf_numsrc;
+		err = -EADDRNOTAVAIL;
+		for (i=0; i<gsf->gf_numsrc; ++i) {
+			psin = (struct sockaddr_in *)&gsf->gf_slist[i];
 
-		case IP_IPSEC_POLICY:
-		case IP_XFRM_POLICY:
-			err = -EPERM;
-			if (!capable(CAP_NET_ADMIN))
-				break;
-			err = xfrm_user_policy(sk, optname, optval, optlen);
-			break;
+			if (psin->sin_family != AF_INET)
+				goto mc_msf_out;
+			msf->imsf_slist[i] = psin->sin_addr.s_addr;
+		}
+		kfree(gsf);
+		gsf = NULL;
 
-		default:
-			err = -ENOPROTOOPT;
-			break;
+		err = ip_mc_msfilter(sk, msf, ifindex);
+	mc_msf_out:
+		kfree(msf);
+		kfree(gsf);
+		break;
+	}
+	case IP_ROUTER_ALERT:
+		err = ip_ra_control(sk, val ? 1 : 0, NULL);
+		break;
+
+	case IP_FREEBIND:
+		if (optlen<1)
+			goto e_inval;
+		inet->freebind = !!val;
+		break;
+
+	case IP_IPSEC_POLICY:
+	case IP_XFRM_POLICY:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			break;
+		err = xfrm_user_policy(sk, optname, optval, optlen);
+		break;
+
+	default:
+		err = -ENOPROTOOPT;
+		break;
 	}
 	release_sock(sk);
 	return err;
@@ -948,214 +948,213 @@
  */
 
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
-		char __user *optval, int __user *optlen)
+			    char __user *optval, int __user *optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val;
 	int len;
 
-	if(level!=SOL_IP)
+	if (level != SOL_IP)
 		return -EOPNOTSUPP;
 
 #ifdef CONFIG_IP_MROUTE
-	if(optname>=MRT_BASE && optname <=MRT_BASE+10)
-	{
+	if (optname >= MRT_BASE && optname <= MRT_BASE+10) {
 		return ip_mroute_getsockopt(sk,optname,optval,optlen);
 	}
 #endif
 
-	if(get_user(len,optlen))
+	if (get_user(len,optlen))
 		return -EFAULT;
-	if(len < 0)
+	if (len < 0)
 		return -EINVAL;
 
 	lock_sock(sk);
 
-	switch(optname)	{
-		case IP_OPTIONS:
-			{
-				unsigned char optbuf[sizeof(struct ip_options)+40];
-				struct ip_options * opt = (struct ip_options*)optbuf;
-				opt->optlen = 0;
-				if (inet->opt)
-					memcpy(optbuf, inet->opt,
-					       sizeof(struct ip_options)+
-					       inet->opt->optlen);
-				release_sock(sk);
-
-				if (opt->optlen == 0)
-					return put_user(0, optlen);
-
-				ip_options_undo(opt);
-
-				len = min_t(unsigned int, len, opt->optlen);
-				if(put_user(len, optlen))
-					return -EFAULT;
-				if(copy_to_user(optval, opt->__data, len))
-					return -EFAULT;
-				return 0;
-			}
-		case IP_PKTINFO:
-			val = (inet->cmsg_flags & IP_CMSG_PKTINFO) != 0;
-			break;
-		case IP_RECVTTL:
-			val = (inet->cmsg_flags & IP_CMSG_TTL) != 0;
-			break;
-		case IP_RECVTOS:
-			val = (inet->cmsg_flags & IP_CMSG_TOS) != 0;
-			break;
-		case IP_RECVOPTS:
-			val = (inet->cmsg_flags & IP_CMSG_RECVOPTS) != 0;
-			break;
-		case IP_RETOPTS:
-			val = (inet->cmsg_flags & IP_CMSG_RETOPTS) != 0;
-			break;
-		case IP_PASSSEC:
-			val = (inet->cmsg_flags & IP_CMSG_PASSSEC) != 0;
-			break;
-		case IP_TOS:
-			val = inet->tos;
-			break;
-		case IP_TTL:
-			val = (inet->uc_ttl == -1 ?
-			       sysctl_ip_default_ttl :
-			       inet->uc_ttl);
-			break;
-		case IP_HDRINCL:
-			val = inet->hdrincl;
-			break;
-		case IP_MTU_DISCOVER:
-			val = inet->pmtudisc;
-			break;
-		case IP_MTU:
-		{
-			struct dst_entry *dst;
-			val = 0;
-			dst = sk_dst_get(sk);
-			if (dst) {
-				val = dst_mtu(dst);
-				dst_release(dst);
-			}
-			if (!val) {
-				release_sock(sk);
-				return -ENOTCONN;
-			}
-			break;
+	switch (optname) {
+	case IP_OPTIONS:
+	{
+		unsigned char optbuf[sizeof(struct ip_options)+40];
+		struct ip_options * opt = (struct ip_options*)optbuf;
+		opt->optlen = 0;
+		if (inet->opt)
+			memcpy(optbuf, inet->opt,
+			       sizeof(struct ip_options)+
+			       inet->opt->optlen);
+		release_sock(sk);
+
+		if (opt->optlen == 0)
+			return put_user(0, optlen);
+
+		ip_options_undo(opt);
+
+		len = min_t(unsigned int, len, opt->optlen);
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, opt->__data, len))
+			return -EFAULT;
+		return 0;
+	}
+	case IP_PKTINFO:
+		val = (inet->cmsg_flags & IP_CMSG_PKTINFO) != 0;
+		break;
+	case IP_RECVTTL:
+		val = (inet->cmsg_flags & IP_CMSG_TTL) != 0;
+		break;
+	case IP_RECVTOS:
+		val = (inet->cmsg_flags & IP_CMSG_TOS) != 0;
+		break;
+	case IP_RECVOPTS:
+		val = (inet->cmsg_flags & IP_CMSG_RECVOPTS) != 0;
+		break;
+	case IP_RETOPTS:
+		val = (inet->cmsg_flags & IP_CMSG_RETOPTS) != 0;
+		break;
+	case IP_PASSSEC:
+		val = (inet->cmsg_flags & IP_CMSG_PASSSEC) != 0;
+		break;
+	case IP_TOS:
+		val = inet->tos;
+		break;
+	case IP_TTL:
+		val = (inet->uc_ttl == -1 ?
+		       sysctl_ip_default_ttl :
+		       inet->uc_ttl);
+		break;
+	case IP_HDRINCL:
+		val = inet->hdrincl;
+		break;
+	case IP_MTU_DISCOVER:
+		val = inet->pmtudisc;
+		break;
+	case IP_MTU:
+	{
+		struct dst_entry *dst;
+		val = 0;
+		dst = sk_dst_get(sk);
+		if (dst) {
+			val = dst_mtu(dst);
+			dst_release(dst);
 		}
-		case IP_RECVERR:
-			val = inet->recverr;
-			break;
-		case IP_MULTICAST_TTL:
-			val = inet->mc_ttl;
-			break;
-		case IP_MULTICAST_LOOP:
-			val = inet->mc_loop;
-			break;
-		case IP_MULTICAST_IF:
-		{
-			struct in_addr addr;
-			len = min_t(unsigned int, len, sizeof(struct in_addr));
-			addr.s_addr = inet->mc_addr;
+		if (!val) {
 			release_sock(sk);
-
-			if(put_user(len, optlen))
-				return -EFAULT;
-			if(copy_to_user(optval, &addr, len))
-				return -EFAULT;
-			return 0;
+			return -ENOTCONN;
 		}
-		case IP_MSFILTER:
-		{
-			struct ip_msfilter msf;
-			int err;
-
-			if (len < IP_MSFILTER_SIZE(0)) {
-				release_sock(sk);
-				return -EINVAL;
-			}
-			if (copy_from_user(&msf, optval, IP_MSFILTER_SIZE(0))) {
-				release_sock(sk);
-				return -EFAULT;
-			}
-			err = ip_mc_msfget(sk, &msf,
-				(struct ip_msfilter __user *)optval, optlen);
+		break;
+	}
+	case IP_RECVERR:
+		val = inet->recverr;
+		break;
+	case IP_MULTICAST_TTL:
+		val = inet->mc_ttl;
+		break;
+	case IP_MULTICAST_LOOP:
+		val = inet->mc_loop;
+		break;
+	case IP_MULTICAST_IF:
+	{
+		struct in_addr addr;
+		len = min_t(unsigned int, len, sizeof(struct in_addr));
+		addr.s_addr = inet->mc_addr;
+		release_sock(sk);
+
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &addr, len))
+			return -EFAULT;
+		return 0;
+	}
+	case IP_MSFILTER:
+	{
+		struct ip_msfilter msf;
+		int err;
+
+		if (len < IP_MSFILTER_SIZE(0)) {
 			release_sock(sk);
-			return err;
+			return -EINVAL;
 		}
-		case MCAST_MSFILTER:
-		{
-			struct group_filter gsf;
-			int err;
-
-			if (len < GROUP_FILTER_SIZE(0)) {
-				release_sock(sk);
-				return -EINVAL;
-			}
-			if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0))) {
-				release_sock(sk);
-				return -EFAULT;
-			}
-			err = ip_mc_gsfget(sk, &gsf,
-				(struct group_filter __user *)optval, optlen);
+		if (copy_from_user(&msf, optval, IP_MSFILTER_SIZE(0))) {
 			release_sock(sk);
-			return err;
+			return -EFAULT;
 		}
-		case IP_PKTOPTIONS:
-		{
-			struct msghdr msg;
+		err = ip_mc_msfget(sk, &msf,
+				   (struct ip_msfilter __user *)optval, optlen);
+		release_sock(sk);
+		return err;
+	}
+	case MCAST_MSFILTER:
+	{
+		struct group_filter gsf;
+		int err;
 
+		if (len < GROUP_FILTER_SIZE(0)) {
 			release_sock(sk);
-
-			if (sk->sk_type != SOCK_STREAM)
-				return -ENOPROTOOPT;
-
-			msg.msg_control = optval;
-			msg.msg_controllen = len;
-			msg.msg_flags = 0;
-
-			if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
-				struct in_pktinfo info;
-
-				info.ipi_addr.s_addr = inet->rcv_saddr;
-				info.ipi_spec_dst.s_addr = inet->rcv_saddr;
-				info.ipi_ifindex = inet->mc_index;
-				put_cmsg(&msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
-			}
-			if (inet->cmsg_flags & IP_CMSG_TTL) {
-				int hlim = inet->mc_ttl;
-				put_cmsg(&msg, SOL_IP, IP_TTL, sizeof(hlim), &hlim);
-			}
-			len -= msg.msg_controllen;
-			return put_user(len, optlen);
+			return -EINVAL;
 		}
-		case IP_FREEBIND:
-			val = inet->freebind;
-			break;
-		default:
+		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0))) {
 			release_sock(sk);
+			return -EFAULT;
+		}
+		err = ip_mc_gsfget(sk, &gsf,
+				   (struct group_filter __user *)optval, optlen);
+		release_sock(sk);
+		return err;
+	}
+	case IP_PKTOPTIONS:
+	{
+		struct msghdr msg;
+
+		release_sock(sk);
+
+		if (sk->sk_type != SOCK_STREAM)
 			return -ENOPROTOOPT;
+
+		msg.msg_control = optval;
+		msg.msg_controllen = len;
+		msg.msg_flags = 0;
+
+		if (inet->cmsg_flags & IP_CMSG_PKTINFO) {
+			struct in_pktinfo info;
+
+			info.ipi_addr.s_addr = inet->rcv_saddr;
+			info.ipi_spec_dst.s_addr = inet->rcv_saddr;
+			info.ipi_ifindex = inet->mc_index;
+			put_cmsg(&msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
+		}
+		if (inet->cmsg_flags & IP_CMSG_TTL) {
+			int hlim = inet->mc_ttl;
+			put_cmsg(&msg, SOL_IP, IP_TTL, sizeof(hlim), &hlim);
+		}
+		len -= msg.msg_controllen;
+		return put_user(len, optlen);
+	}
+	case IP_FREEBIND:
+		val = inet->freebind;
+		break;
+	default:
+		release_sock(sk);
+		return -ENOPROTOOPT;
 	}
 	release_sock(sk);
 
 	if (len < sizeof(int) && len > 0 && val>=0 && val<255) {
 		unsigned char ucval = (unsigned char)val;
 		len = 1;
-		if(put_user(len, optlen))
+		if (put_user(len, optlen))
 			return -EFAULT;
-		if(copy_to_user(optval,&ucval,1))
+		if (copy_to_user(optval,&ucval,1))
 			return -EFAULT;
 	} else {
 		len = min_t(unsigned int, sizeof(int), len);
-		if(put_user(len, optlen))
+		if (put_user(len, optlen))
 			return -EFAULT;
-		if(copy_to_user(optval,&val,len))
+		if (copy_to_user(optval,&val,len))
 			return -EFAULT;
 	}
 	return 0;
 }
 
 int ip_getsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int __user *optlen)
+		  int optname, char __user *optval, int __user *optlen)
 {
 	int err;
 
@@ -1169,7 +1168,7 @@
 	   ) {
 		int len;
 
-		if(get_user(len,optlen))
+		if (get_user(len,optlen))
 			return -EFAULT;
 
 		lock_sock(sk);
--- net-2.6.22.orig/net/ipv4/ipmr.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/ipmr.c	2007-03-07 15:11:11.000000000 -0800
@@ -302,7 +302,7 @@
 
 	atomic_dec(&cache_resolve_queue_len);
 
-	while((skb=skb_dequeue(&c->mfc_un.unres.unresolved))) {
+	while ((skb=skb_dequeue(&c->mfc_un.unres.unresolved))) {
 		if (skb->nh.iph->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 			nlh->nlmsg_type = NLMSG_ERROR;
@@ -479,7 +479,7 @@
 static struct mfc_cache *ipmr_cache_alloc(void)
 {
 	struct mfc_cache *c=kmem_cache_zalloc(mrt_cachep, GFP_KERNEL);
-	if(c==NULL)
+	if (c==NULL)
 		return NULL;
 	c->mfc_un.res.minvif = MAXVIFS;
 	return c;
@@ -488,7 +488,7 @@
 static struct mfc_cache *ipmr_cache_alloc_unres(void)
 {
 	struct mfc_cache *c=kmem_cache_zalloc(mrt_cachep, GFP_ATOMIC);
-	if(c==NULL)
+	if (c==NULL)
 		return NULL;
 	skb_queue_head_init(&c->mfc_un.unres.unresolved);
 	c->mfc_un.unres.expires = jiffies + 10*HZ;
@@ -508,7 +508,7 @@
 	 *	Play the pending entries through our router
 	 */
 
-	while((skb=__skb_dequeue(&uc->mfc_un.unres.unresolved))) {
+	while ((skb=__skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (skb->nh.iph->version == 0) {
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct iphdr));
 
@@ -551,7 +551,7 @@
 #endif
 		skb = alloc_skb(128, GFP_ATOMIC);
 
-	if(!skb)
+	if (!skb)
 		return -ENOBUFS;
 
 #ifdef CONFIG_IP_PIMSM
@@ -734,7 +734,7 @@
 		return 0;
 	}
 
-	if(!MULTICAST(mfc->mfcc_mcastgrp.s_addr))
+	if (!MULTICAST(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
 	c=ipmr_cache_alloc();
@@ -788,7 +788,7 @@
 	/*
 	 *	Shut down all active vif entries
 	 */
-	for(i=0; i<maxvif; i++) {
+	for (i=0; i<maxvif; i++) {
 		if (!(vif_table[i].flags&VIFF_STATIC))
 			vif_delete(i);
 	}
@@ -858,119 +858,117 @@
 	struct vifctl vif;
 	struct mfcctl mfc;
 
-	if(optname!=MRT_INIT)
-	{
-		if(sk!=mroute_socket && !capable(CAP_NET_ADMIN))
+	if (optname != MRT_INIT) {
+		if (sk != mroute_socket && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
-	switch(optname)
-	{
-		case MRT_INIT:
-			if (sk->sk_type != SOCK_RAW ||
-			    inet_sk(sk)->num != IPPROTO_IGMP)
-				return -EOPNOTSUPP;
-			if(optlen!=sizeof(int))
-				return -ENOPROTOOPT;
-
-			rtnl_lock();
-			if (mroute_socket) {
-				rtnl_unlock();
-				return -EADDRINUSE;
-			}
-
-			ret = ip_ra_control(sk, 1, mrtsock_destruct);
-			if (ret == 0) {
-				write_lock_bh(&mrt_lock);
-				mroute_socket=sk;
-				write_unlock_bh(&mrt_lock);
+	switch (optname) {
+	case MRT_INIT:
+		if (sk->sk_type != SOCK_RAW ||
+		    inet_sk(sk)->num != IPPROTO_IGMP)
+			return -EOPNOTSUPP;
+		if (optlen!=sizeof(int))
+			return -ENOPROTOOPT;
 
-				ipv4_devconf.mc_forwarding++;
-			}
+		rtnl_lock();
+		if (mroute_socket) {
 			rtnl_unlock();
-			return ret;
-		case MRT_DONE:
-			if (sk!=mroute_socket)
-				return -EACCES;
-			return ip_ra_control(sk, 0, NULL);
-		case MRT_ADD_VIF:
-		case MRT_DEL_VIF:
-			if(optlen!=sizeof(vif))
-				return -EINVAL;
-			if (copy_from_user(&vif,optval,sizeof(vif)))
-				return -EFAULT;
-			if(vif.vifc_vifi >= MAXVIFS)
-				return -ENFILE;
-			rtnl_lock();
-			if (optname==MRT_ADD_VIF) {
-				ret = vif_add(&vif, sk==mroute_socket);
-			} else {
-				ret = vif_delete(vif.vifc_vifi);
-			}
-			rtnl_unlock();
-			return ret;
+			return -EADDRINUSE;
+		}
+
+		ret = ip_ra_control(sk, 1, mrtsock_destruct);
+		if (ret == 0) {
+			write_lock_bh(&mrt_lock);
+			mroute_socket=sk;
+			write_unlock_bh(&mrt_lock);
+
+			ipv4_devconf.mc_forwarding++;
+		}
+		rtnl_unlock();
+		return ret;
+	case MRT_DONE:
+		if (sk!=mroute_socket)
+			return -EACCES;
+		return ip_ra_control(sk, 0, NULL);
+	case MRT_ADD_VIF:
+	case MRT_DEL_VIF:
+		if (optlen!=sizeof(vif))
+			return -EINVAL;
+		if (copy_from_user(&vif,optval,sizeof(vif)))
+			return -EFAULT;
+		if (vif.vifc_vifi >= MAXVIFS)
+			return -ENFILE;
+		rtnl_lock();
+		if (optname==MRT_ADD_VIF) {
+			ret = vif_add(&vif, sk==mroute_socket);
+		} else {
+			ret = vif_delete(vif.vifc_vifi);
+		}
+		rtnl_unlock();
+		return ret;
 
 		/*
 		 *	Manipulate the forwarding caches. These live
 		 *	in a sort of kernel/user symbiosis.
 		 */
-		case MRT_ADD_MFC:
-		case MRT_DEL_MFC:
-			if(optlen!=sizeof(mfc))
-				return -EINVAL;
-			if (copy_from_user(&mfc,optval, sizeof(mfc)))
-				return -EFAULT;
-			rtnl_lock();
-			if (optname==MRT_DEL_MFC)
-				ret = ipmr_mfc_delete(&mfc);
-			else
-				ret = ipmr_mfc_add(&mfc, sk==mroute_socket);
-			rtnl_unlock();
-			return ret;
+	case MRT_ADD_MFC:
+	case MRT_DEL_MFC:
+		if (optlen!=sizeof(mfc))
+			return -EINVAL;
+		if (copy_from_user(&mfc,optval, sizeof(mfc)))
+			return -EFAULT;
+		rtnl_lock();
+		if (optname==MRT_DEL_MFC)
+			ret = ipmr_mfc_delete(&mfc);
+		else
+			ret = ipmr_mfc_add(&mfc, sk==mroute_socket);
+		rtnl_unlock();
+		return ret;
 		/*
 		 *	Control PIM assert.
 		 */
-		case MRT_ASSERT:
-		{
-			int v;
-			if(get_user(v,(int __user *)optval))
-				return -EFAULT;
-			mroute_do_assert=(v)?1:0;
-			return 0;
-		}
+	case MRT_ASSERT:
+	{
+		int v;
+		if (get_user(v,(int __user *)optval))
+			return -EFAULT;
+		mroute_do_assert=(v)?1:0;
+		return 0;
+	}
 #ifdef CONFIG_IP_PIMSM
-		case MRT_PIM:
-		{
-			int v, ret;
-			if(get_user(v,(int __user *)optval))
-				return -EFAULT;
-			v = (v)?1:0;
-			rtnl_lock();
-			ret = 0;
-			if (v != mroute_do_pim) {
-				mroute_do_pim = v;
-				mroute_do_assert = v;
+	case MRT_PIM:
+	{
+		int v, ret;
+		if (get_user(v,(int __user *)optval))
+			return -EFAULT;
+		v = (v)?1:0;
+		rtnl_lock();
+		ret = 0;
+		if (v != mroute_do_pim) {
+			mroute_do_pim = v;
+			mroute_do_assert = v;
 #ifdef CONFIG_IP_PIMSM_V2
-				if (mroute_do_pim)
-					ret = inet_add_protocol(&pim_protocol,
-								IPPROTO_PIM);
-				else
-					ret = inet_del_protocol(&pim_protocol,
-								IPPROTO_PIM);
-				if (ret < 0)
-					ret = -EAGAIN;
+			if (mroute_do_pim)
+				ret = inet_add_protocol(&pim_protocol,
+							IPPROTO_PIM);
+			else
+				ret = inet_del_protocol(&pim_protocol,
+							IPPROTO_PIM);
+			if (ret < 0)
+				ret = -EAGAIN;
 #endif
-			}
-			rtnl_unlock();
-			return ret;
 		}
+		rtnl_unlock();
+		return ret;
+	}
 #endif
-		/*
-		 *	Spurious command, or MRT_VERSION which you cannot
-		 *	set.
-		 */
-		default:
-			return -ENOPROTOOPT;
+	/*
+	 *	Spurious command, or MRT_VERSION which you cannot
+	 *	set.
+	 */
+	default:
+		return -ENOPROTOOPT;
 	}
 }
 
@@ -983,7 +981,7 @@
 	int olr;
 	int val;
 
-	if(optname!=MRT_VERSION &&
+	if (optname!=MRT_VERSION &&
 #ifdef CONFIG_IP_PIMSM
 	   optname!=MRT_PIM &&
 #endif
@@ -997,17 +995,17 @@
 	if (olr < 0)
 		return -EINVAL;
 
-	if(put_user(olr,optlen))
+	if (put_user(olr,optlen))
 		return -EFAULT;
-	if(optname==MRT_VERSION)
+	if (optname==MRT_VERSION)
 		val=0x0305;
 #ifdef CONFIG_IP_PIMSM
-	else if(optname==MRT_PIM)
+	else if (optname==MRT_PIM)
 		val=mroute_do_pim;
 #endif
 	else
 		val=mroute_do_assert;
-	if(copy_to_user(optval,&val,olr))
+	if (copy_to_user(optval,&val,olr))
 		return -EFAULT;
 	return 0;
 }
@@ -1023,48 +1021,47 @@
 	struct vif_device *vif;
 	struct mfc_cache *c;
 
-	switch(cmd)
-	{
-		case SIOCGETVIFCNT:
-			if (copy_from_user(&vr,arg,sizeof(vr)))
-				return -EFAULT;
-			if(vr.vifi>=maxvif)
-				return -EINVAL;
-			read_lock(&mrt_lock);
-			vif=&vif_table[vr.vifi];
-			if(VIF_EXISTS(vr.vifi))	{
-				vr.icount=vif->pkt_in;
-				vr.ocount=vif->pkt_out;
-				vr.ibytes=vif->bytes_in;
-				vr.obytes=vif->bytes_out;
-				read_unlock(&mrt_lock);
-
-				if (copy_to_user(arg,&vr,sizeof(vr)))
-					return -EFAULT;
-				return 0;
-			}
+	switch (cmd) {
+	case SIOCGETVIFCNT:
+		if (copy_from_user(&vr,arg,sizeof(vr)))
+			return -EFAULT;
+		if (vr.vifi>=maxvif)
+			return -EINVAL;
+		read_lock(&mrt_lock);
+		vif=&vif_table[vr.vifi];
+		if (VIF_EXISTS(vr.vifi))	{
+			vr.icount=vif->pkt_in;
+			vr.ocount=vif->pkt_out;
+			vr.ibytes=vif->bytes_in;
+			vr.obytes=vif->bytes_out;
 			read_unlock(&mrt_lock);
-			return -EADDRNOTAVAIL;
-		case SIOCGETSGCNT:
-			if (copy_from_user(&sr,arg,sizeof(sr)))
-				return -EFAULT;
 
-			read_lock(&mrt_lock);
-			c = ipmr_cache_find(sr.src.s_addr, sr.grp.s_addr);
-			if (c) {
-				sr.pktcnt = c->mfc_un.res.pkt;
-				sr.bytecnt = c->mfc_un.res.bytes;
-				sr.wrong_if = c->mfc_un.res.wrong_if;
-				read_unlock(&mrt_lock);
-
-				if (copy_to_user(arg,&sr,sizeof(sr)))
-					return -EFAULT;
-				return 0;
-			}
+			if (copy_to_user(arg,&vr,sizeof(vr)))
+				return -EFAULT;
+			return 0;
+		}
+		read_unlock(&mrt_lock);
+		return -EADDRNOTAVAIL;
+	case SIOCGETSGCNT:
+		if (copy_from_user(&sr,arg,sizeof(sr)))
+			return -EFAULT;
+
+		read_lock(&mrt_lock);
+		c = ipmr_cache_find(sr.src.s_addr, sr.grp.s_addr);
+		if (c) {
+			sr.pktcnt = c->mfc_un.res.pkt;
+			sr.bytecnt = c->mfc_un.res.bytes;
+			sr.wrong_if = c->mfc_un.res.wrong_if;
 			read_unlock(&mrt_lock);
-			return -EADDRNOTAVAIL;
-		default:
-			return -ENOIOCTLCMD;
+
+			if (copy_to_user(arg,&sr,sizeof(sr)))
+				return -EFAULT;
+			return 0;
+		}
+		read_unlock(&mrt_lock);
+		return -EADDRNOTAVAIL;
+	default:
+		return -ENOIOCTLCMD;
 	}
 }
 
@@ -1076,7 +1073,7 @@
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
 	v=&vif_table[0];
-	for(ct=0;ct<maxvif;ct++,v++) {
+	for (ct=0;ct<maxvif;ct++,v++) {
 		if (v->dev==ptr)
 			vif_delete(ct);
 	}
@@ -1625,7 +1622,7 @@
 					   loff_t pos)
 {
 	for (iter->ct = 0; iter->ct < maxvif; ++iter->ct) {
-		if(!VIF_EXISTS(iter->ct))
+		if (!VIF_EXISTS(iter->ct))
 			continue;
 		if (pos-- == 0)
 			return &vif_table[iter->ct];
@@ -1649,7 +1646,7 @@
 		return ipmr_vif_seq_idx(iter, 0);
 
 	while (++iter->ct < maxvif) {
-		if(!VIF_EXISTS(iter->ct))
+		if (!VIF_EXISTS(iter->ct))
 			continue;
 		return &vif_table[iter->ct];
 	}
@@ -1732,14 +1729,14 @@
 	it->cache = mfc_cache_array;
 	read_lock(&mrt_lock);
 	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
-		for(mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next)
+		for (mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next)
 			if (pos-- == 0)
 				return mfc;
 	read_unlock(&mrt_lock);
 
 	it->cache = &mfc_unres_queue;
 	spin_lock_bh(&mfc_unres_lock);
-	for(mfc = mfc_unres_queue; mfc; mfc = mfc->next)
+	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
 		if (pos-- == 0)
 			return mfc;
 	spin_unlock_bh(&mfc_unres_lock);
@@ -1829,9 +1826,9 @@
 			   mfc->mfc_un.res.wrong_if);
 
 		if (it->cache != &mfc_unres_queue) {
-			for(n = mfc->mfc_un.res.minvif;
-			    n < mfc->mfc_un.res.maxvif; n++ ) {
-				if(VIF_EXISTS(n)
+			for (n = mfc->mfc_un.res.minvif;
+			     n < mfc->mfc_un.res.maxvif; n++ ) {
+				if (VIF_EXISTS(n)
 				   && mfc->mfc_un.res.ttls[n] < 255)
 				seq_printf(seq,
 					   " %2d:%-3d",
--- net-2.6.22.orig/net/ipv4/xfrm4_mode_tunnel.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/xfrm4_mode_tunnel.c	2007-03-07 15:11:11.000000000 -0800
@@ -93,7 +93,7 @@
 	struct iphdr *iph = skb->nh.iph;
 	int err = -EINVAL;
 
-	switch(iph->protocol){
+	switch (iph->protocol){
 		case IPPROTO_IPIP:
 			break;
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
--- net-2.6.22.orig/net/ipv4/xfrm4_policy.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/xfrm4_policy.c	2007-03-07 15:11:11.000000000 -0800
@@ -119,7 +119,7 @@
 
 		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
 			unsigned short encap_family = xfrm[i]->props.family;
-			switch(encap_family) {
+			switch (encap_family) {
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
--- net-2.6.22.orig/net/ipv4/cipso_ipv4.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/cipso_ipv4.c	2007-03-07 15:11:11.000000000 -0800
@@ -1174,7 +1174,7 @@
 	u16 cat_low;
 	u16 cat_high;
 
-	for(net_iter = 0; net_iter < net_cat_len; net_iter += 4) {
+	for (net_iter = 0; net_iter < net_cat_len; net_iter += 4) {
 		cat_high = ntohs(*((__be16 *)&net_cat[net_iter]));
 		if ((net_iter + 4) <= net_cat_len)
 			cat_low = ntohs(*((__be16 *)&net_cat[net_iter + 2]));
--- net-2.6.22.orig/net/ipv4/ip_output.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/ip_output.c	2007-03-07 15:11:11.000000000 -0800
@@ -566,7 +566,7 @@
 	 *	Keep copying data until we run out.
 	 */
 
-	while(left > 0)	{
+	while (left > 0) {
 		len = left;
 		/* IF: it doesn't fit, use 'mtu' - the data space left */
 		if (len > mtu)
--- net-2.6.22.orig/net/ipv4/ipconfig.c	2007-03-07 15:09:04.000000000 -0800
+++ net-2.6.22/net/ipv4/ipconfig.c	2007-03-07 15:11:11.000000000 -0800
@@ -782,7 +782,7 @@
 	u8 *c;
 
 	printk("DHCP/BOOTP: Got extension %d:",*ext);
-	for(c=ext+2; c<ext+2+ext[1]; c++)
+	for (c=ext+2; c<ext+2+ext[1]; c++)
 		printk(" %02x", *c);
 	printk("\n");
 #endif
@@ -1094,7 +1094,7 @@
 	retries = CONF_SEND_RETRIES;
 	get_random_bytes(&timeout, sizeof(timeout));
 	timeout = CONF_BASE_TIMEOUT + (timeout % (unsigned) CONF_TIMEOUT_RANDOM);
-	for(;;) {
+	for (;;) {
 #ifdef IPCONFIG_BOOTP
 		if (do_bootp && (d->able & IC_BOOTP))
 			ic_bootp_send_if(d, jiffies - start_jiffies);

--
Stephen Hemminger <shemminger@linux-foundation.org>

