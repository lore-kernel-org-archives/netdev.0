From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: remove ipv6_addr_copy()
Date: Mon, 21 Nov 2011 16:39:03 +0300
Message-ID: <20111121133903.GA18453@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63164 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697Ab1KUNjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 08:39:11 -0500
Received: by bke11 with SMTP id 11so6555088bke.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 05:39:09 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

C assignment can handle struct in6_addr copying.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/infiniband/core/addr.c         |    6 ++--
 drivers/infiniband/core/cma.c          |    8 ++---
 drivers/net/bonding/bond_ipv6.c        |    8 ++---
 drivers/net/ethernet/broadcom/cnic.c   |    2 -
 fs/dlm/lowcomms.c                      |    2 -
 include/linux/sunrpc/clnt.h            |    2 -
 include/net/inetpeer.h                 |    2 -
 include/net/ip_vs.h                    |    8 ++---
 include/net/ipv6.h                     |    5 ---
 include/net/xfrm.h                     |    4 +-
 net/bridge/br_multicast.c              |   10 +++----
 net/core/pktgen.c                      |   15 ++++------
 net/dccp/ipv6.c                        |   42 +++++++++++++++---------------
 net/dccp/minisocks.c                   |    4 +-
 net/ipv4/inet_diag.c                   |   18 ++++--------
 net/ipv4/tcp_minisocks.c               |    4 +-
 net/ipv6/addrconf.c                    |    8 ++---
 net/ipv6/af_inet6.c                    |   14 +++++-----
 net/ipv6/ah6.c                         |   12 ++++----
 net/ipv6/anycast.c                     |    4 +-
 net/ipv6/datagram.c                    |   34 ++++++++++++------------
 net/ipv6/exthdrs.c                     |   18 ++++++------
 net/ipv6/fib6_rules.c                  |    2 -
 net/ipv6/icmp.c                        |   18 ++++++------
 net/ipv6/inet6_connection_sock.c       |   12 ++++----
 net/ipv6/ip6_flowlabel.c               |    2 -
 net/ipv6/ip6_output.c                  |   18 ++++++------
 net/ipv6/ip6_tunnel.c                  |   12 ++++----
 net/ipv6/ip6mr.c                       |   12 ++++----
 net/ipv6/ipv6_sockglue.c               |    8 ++---
 net/ipv6/mcast.c                       |    6 ++--
 net/ipv6/mip6.c                        |    4 +-
 net/ipv6/ndisc.c                       |    6 ++--
 net/ipv6/netfilter/ip6t_REJECT.c       |    8 ++---
 net/ipv6/raw.c                         |   10 +++----
 net/ipv6/reassembly.c                  |    4 +-
 net/ipv6/route.c                       |   42 +++++++++++++++---------------
 net/ipv6/sit.c                         |    4 +-
 net/ipv6/syncookies.c                  |    8 ++---
 net/ipv6/tcp_ipv6.c                    |   46 +++++++++++++++------------------
 net/ipv6/udp.c                         |    7 ++---
 net/ipv6/xfrm6_mode_beet.c             |    8 ++---
 net/ipv6/xfrm6_mode_tunnel.c           |    4 +-
 net/ipv6/xfrm6_output.c                |    4 +-
 net/ipv6/xfrm6_policy.c                |    4 +-
 net/ipv6/xfrm6_state.c                 |    4 +-
 net/key/af_key.c                       |    2 -
 net/netfilter/ipset/ip_set_hash_ip.c   |    2 -
 net/netfilter/ipset/ip_set_hash_net.c  |    2 -
 net/netfilter/ipvs/ip_vs_core.c        |    2 -
 net/netfilter/ipvs/ip_vs_sync.c        |    6 ++--
 net/netfilter/ipvs/ip_vs_xmit.c        |   10 +++----
 net/netfilter/nf_conntrack_h323_main.c |    4 +-
 net/netfilter/xt_TCPMSS.c              |    2 -
 net/netfilter/xt_addrtype.c            |    2 -
 net/netlabel/netlabel_kapi.c           |    4 +-
 net/netlabel/netlabel_mgmt.c           |    4 +-
 net/netlabel/netlabel_unlabeled.c      |    4 +-
 net/sctp/ipv6.c                        |   40 +++++++++++++---------------
 net/sctp/socket.c                      |    2 -
 net/sunrpc/svcauth_unix.c              |    6 ++--
 net/sunrpc/svcsock.c                   |    4 +-
 net/xfrm/xfrm_state.c                  |   12 ++------
 security/lsm_audit.c                   |    4 +-
 security/selinux/hooks.c               |    6 ++--
 security/selinux/netnode.c             |    2 -
 66 files changed, 288 insertions(+), 315 deletions(-)

--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -243,8 +243,8 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 	int ret;
 
 	memset(&fl6, 0, sizeof fl6);
-	ipv6_addr_copy(&fl6.daddr, &dst_in->sin6_addr);
-	ipv6_addr_copy(&fl6.saddr, &src_in->sin6_addr);
+	fl6.daddr = dst_in->sin6_addr;
+	fl6.saddr = src_in->sin6_addr;
 	fl6.flowi6_oif = addr->bound_dev_if;
 
 	dst = ip6_route_output(&init_net, NULL, &fl6);
@@ -258,7 +258,7 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 			goto put;
 
 		src_in->sin6_family = AF_INET6;
-		ipv6_addr_copy(&src_in->sin6_addr, &fl6.saddr);
+		src_in->sin6_addr = fl6.saddr;
 	}
 
 	if (dst->dev->flags & IFF_LOOPBACK) {
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2005,11 +2005,11 @@ static int cma_resolve_loopback(struct rdma_id_private *id_priv)
 	if (cma_zero_addr(src)) {
 		dst = (struct sockaddr *) &id_priv->id.route.addr.dst_addr;
 		if ((src->sa_family = dst->sa_family) == AF_INET) {
-			((struct sockaddr_in *) src)->sin_addr.s_addr =
-				((struct sockaddr_in *) dst)->sin_addr.s_addr;
+			((struct sockaddr_in *)src)->sin_addr =
+				((struct sockaddr_in *)dst)->sin_addr;
 		} else {
-			ipv6_addr_copy(&((struct sockaddr_in6 *) src)->sin6_addr,
-				       &((struct sockaddr_in6 *) dst)->sin6_addr);
+			((struct sockaddr_in6 *)src)->sin6_addr =
+				((struct sockaddr_in6 *)dst)->sin6_addr;
 		}
 	}
 
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -50,7 +50,7 @@ static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
 		struct inet6_ifaddr *ifa
 			= list_first_entry(&idev->addr_list,
 					   struct inet6_ifaddr, if_list);
-		ipv6_addr_copy(addr, &ifa->addr);
+		*addr = ifa->addr;
 	} else
 		ipv6_addr_set(addr, 0, 0, 0, 0);
 
@@ -168,8 +168,7 @@ static int bond_inet6addr_event(struct notifier_block *this,
 			switch (event) {
 			case NETDEV_UP:
 				if (ipv6_addr_any(&bond->master_ipv6))
-					ipv6_addr_copy(&bond->master_ipv6,
-						       &ifa->addr);
+					bond->master_ipv6 = ifa->addr;
 				return NOTIFY_OK;
 			case NETDEV_DOWN:
 				if (ipv6_addr_equal(&bond->master_ipv6,
@@ -191,8 +190,7 @@ static int bond_inet6addr_event(struct notifier_block *this,
 				switch (event) {
 				case NETDEV_UP:
 					if (ipv6_addr_any(&vlan->vlan_ipv6))
-						ipv6_addr_copy(&vlan->vlan_ipv6,
-							       &ifa->addr);
+						vlan->vlan_ipv6 = ifa->addr;
 					return NOTIFY_OK;
 				case NETDEV_DOWN:
 					if (ipv6_addr_equal(&vlan->vlan_ipv6,
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3475,7 +3475,7 @@ static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
 	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
-	ipv6_addr_copy(&fl6.daddr, &dst_addr->sin6_addr);
+	fl6.daddr = dst_addr->sin6_addr;
 	if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
 		fl6.flowi6_oif = dst_addr->sin6_scope_id;
 
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -281,7 +281,7 @@ static int nodeid_to_addr(int nodeid, struct sockaddr *retaddr)
 	} else {
 		struct sockaddr_in6 *in6  = (struct sockaddr_in6 *) &addr;
 		struct sockaddr_in6 *ret6 = (struct sockaddr_in6 *) retaddr;
-		ipv6_addr_copy(&ret6->sin6_addr, &in6->sin6_addr);
+		ret6->sin6_addr = in6->sin6_addr;
 	}
 
 	return 0;
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -237,7 +237,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
 	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
 
 	dsin6->sin6_family = ssin6->sin6_family;
-	ipv6_addr_copy(&dsin6->sin6_addr, &ssin6->sin6_addr);
+	dsin6->sin6_addr = ssin6->sin6_addr;
 	return true;
 }
 #else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -86,7 +86,7 @@ static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr,
 {
 	struct inetpeer_addr daddr;
 
-	ipv6_addr_copy((struct in6_addr *)daddr.addr.a6, v6daddr);
+	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
 	daddr.family = AF_INET6;
 	return inet_getpeer(&daddr, create);
 }
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -21,7 +21,7 @@
 #include <linux/netfilter.h>		/* for union nf_inet_addr */
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
-#include <net/ipv6.h>			/* for ipv6_addr_copy */
+#include <net/ipv6.h>
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -119,8 +119,8 @@ ip_vs_fill_iphdr(int af, const void *nh, struct ip_vs_iphdr *iphdr)
 		const struct ipv6hdr *iph = nh;
 		iphdr->len = sizeof(struct ipv6hdr);
 		iphdr->protocol = iph->nexthdr;
-		ipv6_addr_copy(&iphdr->saddr.in6, &iph->saddr);
-		ipv6_addr_copy(&iphdr->daddr.in6, &iph->daddr);
+		iphdr->saddr.in6 = iph->saddr;
+		iphdr->daddr.in6 = iph->daddr;
 	} else
 #endif
 	{
@@ -137,7 +137,7 @@ static inline void ip_vs_addr_copy(int af, union nf_inet_addr *dst,
 {
 #ifdef CONFIG_IP_VS_IPV6
 	if (af == AF_INET6)
-		ipv6_addr_copy(&dst->in6, &src->in6);
+		dst->in6 = src->in6;
 	else
 #endif
 	dst->ip = src->ip;
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -309,11 +309,6 @@ ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
 		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
 }
 
-static inline void ipv6_addr_copy(struct in6_addr *a1, const struct in6_addr *a2)
-{
-	memcpy(a1, a2, sizeof(struct in6_addr));
-}
-
 static inline void ipv6_addr_prefix(struct in6_addr *pfx, 
 				    const struct in6_addr *addr,
 				    int plen)
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1209,8 +1209,8 @@ void xfrm_flowi_addr_get(const struct flowi *fl,
 		memcpy(&daddr->a4, &fl->u.ip4.daddr, sizeof(daddr->a4));
 		break;
 	case AF_INET6:
-		ipv6_addr_copy((struct in6_addr *)&saddr->a6, &fl->u.ip6.saddr);
-		ipv6_addr_copy((struct in6_addr *)&daddr->a6, &fl->u.ip6.daddr);
+		*(struct in6_addr *)saddr->a6 = fl->u.ip6.saddr;
+		*(struct in6_addr *)daddr->a6 = fl->u.ip6.daddr;
 		break;
 	}
 }
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -127,7 +127,7 @@ static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 {
 	struct br_ip br_dst;
 
-	ipv6_addr_copy(&br_dst.u.ip6, dst);
+	br_dst.u.ip6 = *dst;
 	br_dst.proto = htons(ETH_P_IPV6);
 
 	return br_mdb_ip_get(mdb, &br_dst);
@@ -154,7 +154,7 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 		break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case htons(ETH_P_IPV6):
-		ipv6_addr_copy(&ip.u.ip6, &ipv6_hdr(skb)->daddr);
+		ip.u.ip6 = ipv6_hdr(skb)->daddr;
 		break;
 #endif
 	default:
@@ -474,7 +474,7 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 	mldq->mld_cksum = 0;
 	mldq->mld_maxdelay = htons((u16)jiffies_to_msecs(interval));
 	mldq->mld_reserved = 0;
-	ipv6_addr_copy(&mldq->mld_mca, group);
+	mldq->mld_mca = *group;
 
 	/* checksum */
 	mldq->mld_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
@@ -783,7 +783,7 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 	if (!ipv6_is_transient_multicast(group))
 		return 0;
 
-	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
 
 	return br_multicast_add_group(br, port, &br_group);
@@ -1344,7 +1344,7 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 	if (!ipv6_is_transient_multicast(group))
 		return;
 
-	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.u.ip6 = *group;
 	br_group.proto = htons(ETH_P_IPV6);
 
 	br_multicast_leave_group(br, port, &br_group);
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1304,7 +1304,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		scan_ip6(buf, pkt_dev->in6_daddr.s6_addr);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_daddr);
 
-		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->in6_daddr);
+		pkt_dev->cur_in6_daddr = pkt_dev->in6_daddr;
 
 		if (debug)
 			printk(KERN_DEBUG "pktgen: dst6 set to: %s\n", buf);
@@ -1327,8 +1327,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		scan_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->min_in6_daddr);
 
-		ipv6_addr_copy(&pkt_dev->cur_in6_daddr,
-			       &pkt_dev->min_in6_daddr);
+		pkt_dev->cur_in6_daddr = pkt_dev->min_in6_daddr;
 		if (debug)
 			printk(KERN_DEBUG "pktgen: dst6_min set to: %s\n", buf);
 
@@ -1371,7 +1370,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		scan_ip6(buf, pkt_dev->in6_saddr.s6_addr);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_saddr);
 
-		ipv6_addr_copy(&pkt_dev->cur_in6_saddr, &pkt_dev->in6_saddr);
+		pkt_dev->cur_in6_saddr = pkt_dev->in6_saddr;
 
 		if (debug)
 			printk(KERN_DEBUG "pktgen: src6 set to: %s\n", buf);
@@ -2079,9 +2078,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 				     ifp = ifp->if_next) {
 					if (ifp->scope == IFA_LINK &&
 					    !(ifp->flags & IFA_F_TENTATIVE)) {
-						ipv6_addr_copy(&pkt_dev->
-							       cur_in6_saddr,
-							       &ifp->addr);
+						pkt_dev->cur_in6_saddr = ifp->addr;
 						err = 0;
 						break;
 					}
@@ -2958,8 +2955,8 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	iph->payload_len = htons(sizeof(struct udphdr) + datalen);
 	iph->nexthdr = IPPROTO_UDP;
 
-	ipv6_addr_copy(&iph->daddr, &pkt_dev->cur_in6_daddr);
-	ipv6_addr_copy(&iph->saddr, &pkt_dev->cur_in6_saddr);
+	iph->daddr = pkt_dev->cur_in6_daddr;
+	iph->saddr = pkt_dev->cur_in6_saddr;
 
 	skb->mac_header = (skb->network_header - ETH_HLEN -
 			   pkt_dev->pkt_overhead);
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -150,8 +150,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			 */
 			memset(&fl6, 0, sizeof(fl6));
 			fl6.flowi6_proto = IPPROTO_DCCP;
-			ipv6_addr_copy(&fl6.daddr, &np->daddr);
-			ipv6_addr_copy(&fl6.saddr, &np->saddr);
+			fl6.daddr = np->daddr;
+			fl6.saddr = np->saddr;
 			fl6.flowi6_oif = sk->sk_bound_dev_if;
 			fl6.fl6_dport = inet->inet_dport;
 			fl6.fl6_sport = inet->inet_sport;
@@ -244,8 +244,8 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_DCCP;
-	ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
-	ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+	fl6.daddr = ireq6->rmt_addr;
+	fl6.saddr = ireq6->loc_addr;
 	fl6.flowlabel = 0;
 	fl6.flowi6_oif = ireq6->iif;
 	fl6.fl6_dport = inet_rsk(req)->rmt_port;
@@ -270,7 +270,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 		dh->dccph_checksum = dccp_v6_csum_finish(skb,
 							 &ireq6->loc_addr,
 							 &ireq6->rmt_addr);
-		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		fl6.daddr = ireq6->rmt_addr;
 		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
@@ -313,8 +313,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 							    &rxip6h->daddr);
 
 	memset(&fl6, 0, sizeof(fl6));
-	ipv6_addr_copy(&fl6.daddr, &rxip6h->saddr);
-	ipv6_addr_copy(&fl6.saddr, &rxip6h->daddr);
+	fl6.daddr = rxip6h->saddr;
+	fl6.saddr = rxip6h->daddr;
 
 	fl6.flowi6_proto = IPPROTO_DCCP;
 	fl6.flowi6_oif = inet6_iif(rxskb);
@@ -419,8 +419,8 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	ireq6 = inet6_rsk(req);
-	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
+	ireq6->rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq6->loc_addr = ipv6_hdr(skb)->daddr;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
@@ -491,7 +491,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
-		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
+		newnp->rcv_saddr = newnp->saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &dccp_ipv6_mapped;
 		newsk->sk_backlog_rcv = dccp_v4_do_rcv;
@@ -526,9 +526,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_DCCP;
-		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		fl6.daddr = ireq6->rmt_addr;
 		final_p = fl6_update_dst(&fl6, opt, &final);
-		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+		fl6.saddr = ireq6->loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.fl6_dport = inet_rsk(req)->rmt_port;
 		fl6.fl6_sport = inet_rsk(req)->loc_port;
@@ -559,9 +559,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	ipv6_addr_copy(&newnp->daddr, &ireq6->rmt_addr);
-	ipv6_addr_copy(&newnp->saddr, &ireq6->loc_addr);
-	ipv6_addr_copy(&newnp->rcv_saddr, &ireq6->loc_addr);
+	newnp->daddr = ireq6->rmt_addr;
+	newnp->saddr = ireq6->loc_addr;
+	newnp->rcv_saddr = ireq6->loc_addr;
 	newsk->sk_bound_dev_if = ireq6->iif;
 
 	/* Now IPv6 options...
@@ -877,7 +877,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
+			usin->sin6_addr = flowlabel->dst;
 			fl6_sock_release(flowlabel);
 		}
 	}
@@ -910,7 +910,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			return -EINVAL;
 	}
 
-	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
+	np->daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
 	/*
@@ -949,8 +949,8 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		saddr = &np->rcv_saddr;
 
 	fl6.flowi6_proto = IPPROTO_DCCP;
-	ipv6_addr_copy(&fl6.daddr, &np->daddr);
-	ipv6_addr_copy(&fl6.saddr, saddr ? saddr : &np->saddr);
+	fl6.daddr = np->daddr;
+	fl6.saddr = saddr ? *saddr : np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.fl6_dport = usin->sin6_port;
 	fl6.fl6_sport = inet->inet_sport;
@@ -966,11 +966,11 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (saddr == NULL) {
 		saddr = &fl6.saddr;
-		ipv6_addr_copy(&np->rcv_saddr, saddr);
+		np->rcv_saddr = *saddr;
 	}
 
 	/* set the source address */
-	ipv6_addr_copy(&np->saddr, saddr);
+	np->saddr = *saddr;
 	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	__ip6_dst_store(sk, dst, NULL, NULL);
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -60,8 +60,8 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 
 			tw->tw_ipv6_offset = inet6_tw_offset(sk->sk_prot);
 			tw6 = inet6_twsk((struct sock *)tw);
-			ipv6_addr_copy(&tw6->tw_v6_daddr, &np->daddr);
-			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
+			tw6->tw_v6_daddr = np->daddr;
+			tw6->tw_v6_rcv_saddr = np->rcv_saddr;
 			tw->tw_ipv6only = np->ipv6only;
 		}
 #endif
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -129,10 +129,8 @@ static int inet_csk_diag_fill(struct sock *sk,
 	if (r->idiag_family == AF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
 
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
-			       &np->rcv_saddr);
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
-			       &np->daddr);
+		*(struct in6_addr *)r->id.idiag_src = np->rcv_saddr;
+		*(struct in6_addr *)r->id.idiag_dst = np->daddr;
 		if (ext & (1 << (INET_DIAG_TOS - 1)))
 			RTA_PUT_U8(skb, INET_DIAG_TOS, np->tclass);
 	}
@@ -224,10 +222,8 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 		const struct inet6_timewait_sock *tw6 =
 						inet6_twsk((struct sock *)tw);
 
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
-			       &tw6->tw_v6_rcv_saddr);
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
-			       &tw6->tw_v6_daddr);
+		*(struct in6_addr *)r->id.idiag_src = tw6->tw_v6_rcv_saddr;
+		*(struct in6_addr *)r->id.idiag_dst = tw6->tw_v6_daddr;
 	}
 #endif
 	nlh->nlmsg_len = skb_tail_pointer(skb) - previous_tail;
@@ -603,10 +599,8 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_inode = 0;
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
 	if (r->idiag_family == AF_INET6) {
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_src,
-			       &inet6_rsk(req)->loc_addr);
-		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
-			       &inet6_rsk(req)->rmt_addr);
+		*(struct in6_addr *)r->id.idiag_src = inet6_rsk(req)->loc_addr;
+		*(struct in6_addr *)r->id.idiag_dst = inet6_rsk(req)->rmt_addr;
 	}
 #endif
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -343,8 +343,8 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 
 			tw->tw_ipv6_offset = inet6_tw_offset(sk->sk_prot);
 			tw6 = inet6_twsk((struct sock *)tw);
-			ipv6_addr_copy(&tw6->tw_v6_daddr, &np->daddr);
-			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
+			tw6->tw_v6_daddr = np->daddr;
+			tw6->tw_v6_rcv_saddr = np->rcv_saddr;
 			tw->tw_tclass = np->tclass;
 			tw->tw_ipv6only = np->ipv6only;
 		}
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -636,7 +636,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 		goto out;
 	}
 
-	ipv6_addr_copy(&ifa->addr, addr);
+	ifa->addr = *addr;
 
 	spin_lock_init(&ifa->lock);
 	spin_lock_init(&ifa->state_lock);
@@ -1228,7 +1228,7 @@ try_nextdev:
 	if (!hiscore->ifa)
 		return -EADDRNOTAVAIL;
 
-	ipv6_addr_copy(saddr, &hiscore->ifa->addr);
+	*saddr = hiscore->ifa->addr;
 	in6_ifa_put(hiscore->ifa);
 	return 0;
 }
@@ -1249,7 +1249,7 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		list_for_each_entry(ifp, &idev->addr_list, if_list) {
 			if (ifp->scope == IFA_LINK &&
 			    !(ifp->flags & banned_flags)) {
-				ipv6_addr_copy(addr, &ifp->addr);
+				*addr = ifp->addr;
 				err = 0;
 				break;
 			}
@@ -1700,7 +1700,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		.fc_protocol = RTPROT_KERNEL,
 	};
 
-	ipv6_addr_copy(&cfg.fc_dst, pfx);
+	cfg.fc_dst = *pfx;
 
 	/* Prevent useless cloning on PtP SIT.
 	   This thing is done here expecting that the whole
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -361,10 +361,10 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	inet->inet_rcv_saddr = v4addr;
 	inet->inet_saddr = v4addr;
 
-	ipv6_addr_copy(&np->rcv_saddr, &addr->sin6_addr);
+	np->rcv_saddr = addr->sin6_addr;
 
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
-		ipv6_addr_copy(&np->saddr, &addr->sin6_addr);
+		np->saddr = addr->sin6_addr;
 
 	/* Make sure we are allowed to bind here. */
 	if (sk->sk_prot->get_port(sk, snum)) {
@@ -458,14 +458,14 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		    peer == 1)
 			return -ENOTCONN;
 		sin->sin6_port = inet->inet_dport;
-		ipv6_addr_copy(&sin->sin6_addr, &np->daddr);
+		sin->sin6_addr = np->daddr;
 		if (np->sndflow)
 			sin->sin6_flowinfo = np->flow_label;
 	} else {
 		if (ipv6_addr_any(&np->rcv_saddr))
-			ipv6_addr_copy(&sin->sin6_addr, &np->saddr);
+			sin->sin6_addr = np->saddr;
 		else
-			ipv6_addr_copy(&sin->sin6_addr, &np->rcv_saddr);
+			sin->sin6_addr = np->rcv_saddr;
 
 		sin->sin6_port = inet->inet_sport;
 	}
@@ -660,8 +660,8 @@ int inet6_sk_rebuild_header(struct sock *sk)
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = sk->sk_protocol;
-		ipv6_addr_copy(&fl6.daddr, &np->daddr);
-		ipv6_addr_copy(&fl6.saddr, &np->saddr);
+		fl6.daddr = np->daddr;
+		fl6.saddr = np->saddr;
 		fl6.flowlabel = np->flow_label;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.flowi6_mark = sk->sk_mark;
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -193,9 +193,9 @@ static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *des
 						printk(KERN_WARNING "destopt hao: invalid header length: %u\n", hao->length);
 					goto bad;
 				}
-				ipv6_addr_copy(&final_addr, &hao->addr);
-				ipv6_addr_copy(&hao->addr, &iph->saddr);
-				ipv6_addr_copy(&iph->saddr, &final_addr);
+				final_addr = hao->addr;
+				hao->addr = iph->saddr;
+				iph->saddr = final_addr;
 			}
 			break;
 		}
@@ -241,13 +241,13 @@ static void ipv6_rearrange_rthdr(struct ipv6hdr *iph, struct ipv6_rt_hdr *rthdr)
 	segments = rthdr->hdrlen >> 1;
 
 	addrs = ((struct rt0_hdr *)rthdr)->addr;
-	ipv6_addr_copy(&final_addr, addrs + segments - 1);
+	final_addr = addrs[segments - 1];
 
 	addrs += segments - segments_left;
 	memmove(addrs + 1, addrs, (segments_left - 1) * sizeof(*addrs));
 
-	ipv6_addr_copy(addrs, &iph->daddr);
-	ipv6_addr_copy(&iph->daddr, &final_addr);
+	addrs[0] = iph->daddr;
+	iph->daddr = final_addr;
 }
 
 static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -75,7 +75,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	if (pac == NULL)
 		return -ENOMEM;
 	pac->acl_next = NULL;
-	ipv6_addr_copy(&pac->acl_addr, addr);
+	pac->acl_addr = *addr;
 
 	rcu_read_lock();
 	if (ifindex == 0) {
@@ -296,7 +296,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
 		goto out;
 	}
 
-	ipv6_addr_copy(&aca->aca_addr, addr);
+	aca->aca_addr = *addr;
 	aca->aca_idev = idev;
 	aca->aca_rt = rt;
 	aca->aca_users = 1;
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -71,7 +71,7 @@ int ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
+			usin->sin6_addr = flowlabel->dst;
 		}
 	}
 
@@ -143,7 +143,7 @@ ipv4_connected:
 		}
 	}
 
-	ipv6_addr_copy(&np->daddr, daddr);
+	np->daddr = *daddr;
 	np->flow_label = fl6.flowlabel;
 
 	inet->inet_dport = usin->sin6_port;
@@ -154,8 +154,8 @@ ipv4_connected:
 	 */
 
 	fl6.flowi6_proto = sk->sk_protocol;
-	ipv6_addr_copy(&fl6.daddr, &np->daddr);
-	ipv6_addr_copy(&fl6.saddr, &np->saddr);
+	fl6.daddr = np->daddr;
+	fl6.saddr = np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_dport = inet->inet_dport;
@@ -179,10 +179,10 @@ ipv4_connected:
 	/* source address lookup done in ip6_dst_lookup */
 
 	if (ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&np->saddr, &fl6.saddr);
+		np->saddr = fl6.saddr;
 
 	if (ipv6_addr_any(&np->rcv_saddr)) {
-		ipv6_addr_copy(&np->rcv_saddr, &fl6.saddr);
+		np->rcv_saddr = fl6.saddr;
 		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 		if (sk->sk_prot->rehash)
 			sk->sk_prot->rehash(sk);
@@ -257,7 +257,7 @@ void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info)
 	skb_put(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	iph = ipv6_hdr(skb);
-	ipv6_addr_copy(&iph->daddr, &fl6->daddr);
+	iph->daddr = fl6->daddr;
 
 	serr = SKB_EXT_ERR(skb);
 	serr->ee.ee_errno = err;
@@ -294,7 +294,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 	skb_put(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
 	iph = ipv6_hdr(skb);
-	ipv6_addr_copy(&iph->daddr, &fl6->daddr);
+	iph->daddr = fl6->daddr;
 
 	mtu_info = IP6CBMTU(skb);
 
@@ -303,7 +303,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 	mtu_info->ip6m_addr.sin6_port = 0;
 	mtu_info->ip6m_addr.sin6_flowinfo = 0;
 	mtu_info->ip6m_addr.sin6_scope_id = fl6->flowi6_oif;
-	ipv6_addr_copy(&mtu_info->ip6m_addr.sin6_addr, &ipv6_hdr(skb)->daddr);
+	mtu_info->ip6m_addr.sin6_addr = ipv6_hdr(skb)->daddr;
 
 	__skb_pull(skb, skb_tail_pointer(skb) - skb->data);
 	skb_reset_transport_header(skb);
@@ -354,8 +354,8 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		sin->sin6_port = serr->port;
 		sin->sin6_scope_id = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
-			ipv6_addr_copy(&sin->sin6_addr,
-				  (struct in6_addr *)(nh + serr->addr_offset));
+			sin->sin6_addr =
+				*(struct in6_addr *)(nh + serr->addr_offset);
 			if (np->sndflow)
 				sin->sin6_flowinfo =
 					(*(__be32 *)(nh + serr->addr_offset - 24) &
@@ -376,7 +376,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		sin->sin6_flowinfo = 0;
 		sin->sin6_scope_id = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
-			ipv6_addr_copy(&sin->sin6_addr, &ipv6_hdr(skb)->saddr);
+			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
 				datagram_recv_ctl(sk, msg, skb);
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
@@ -451,7 +451,7 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len)
 		sin->sin6_flowinfo = 0;
 		sin->sin6_port = 0;
 		sin->sin6_scope_id = mtu_info.ip6m_addr.sin6_scope_id;
-		ipv6_addr_copy(&sin->sin6_addr, &mtu_info.ip6m_addr.sin6_addr);
+		sin->sin6_addr = mtu_info.ip6m_addr.sin6_addr;
 	}
 
 	put_cmsg(msg, SOL_IPV6, IPV6_PATHMTU, sizeof(mtu_info), &mtu_info);
@@ -475,7 +475,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		struct in6_pktinfo src_info;
 
 		src_info.ipi6_ifindex = opt->iif;
-		ipv6_addr_copy(&src_info.ipi6_addr, &ipv6_hdr(skb)->daddr);
+		src_info.ipi6_addr = ipv6_hdr(skb)->daddr;
 		put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 	}
 
@@ -550,7 +550,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 		struct in6_pktinfo src_info;
 
 		src_info.ipi6_ifindex = opt->iif;
-		ipv6_addr_copy(&src_info.ipi6_addr, &ipv6_hdr(skb)->daddr);
+		src_info.ipi6_addr = ipv6_hdr(skb)->daddr;
 		put_cmsg(msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 	}
 	if (np->rxopt.bits.rxohlim) {
@@ -584,7 +584,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 			 */
 
 			sin6.sin6_family = AF_INET6;
-			ipv6_addr_copy(&sin6.sin6_addr, &ipv6_hdr(skb)->daddr);
+			sin6.sin6_addr = ipv6_hdr(skb)->daddr;
 			sin6.sin6_port = ports[1];
 			sin6.sin6_flowinfo = 0;
 			sin6.sin6_scope_id = 0;
@@ -659,7 +659,7 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 						   strict ? dev : NULL, 0))
 					err = -EINVAL;
 				else
-					ipv6_addr_copy(&fl6->saddr, &src_info->ipi6_addr);
+					fl6->saddr = src_info->ipi6_addr;
 			}
 
 			rcu_read_unlock();
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -243,9 +243,9 @@ static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 
-	ipv6_addr_copy(&tmp_addr, &ipv6h->saddr);
-	ipv6_addr_copy(&ipv6h->saddr, &hao->addr);
-	ipv6_addr_copy(&hao->addr, &tmp_addr);
+	tmp_addr = ipv6h->saddr;
+	ipv6h->saddr = hao->addr;
+	hao->addr = tmp_addr;
 
 	if (skb->tstamp.tv64 == 0)
 		__net_timestamp(skb);
@@ -461,9 +461,9 @@ looped_back:
 		return -1;
 	}
 
-	ipv6_addr_copy(&daddr, addr);
-	ipv6_addr_copy(addr, &ipv6_hdr(skb)->daddr);
-	ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &daddr);
+	daddr = *addr;
+	*addr = ipv6_hdr(skb)->daddr;
+	ipv6_hdr(skb)->daddr = daddr;
 
 	skb_dst_drop(skb);
 	ip6_route_input(skb);
@@ -690,7 +690,7 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 		memcpy(phdr->addr, ihdr->addr + 1,
 		       (hops - 1) * sizeof(struct in6_addr));
 
-	ipv6_addr_copy(phdr->addr + (hops - 1), *addr_p);
+	phdr->addr[hops - 1] = **addr_p;
 	*addr_p = ihdr->addr;
 
 	phdr->rt_hdr.nexthdr = *proto;
@@ -888,8 +888,8 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 	if (!opt || !opt->srcrt)
 		return NULL;
 
-	ipv6_addr_copy(orig, &fl6->daddr);
-	ipv6_addr_copy(&fl6->daddr, ((struct rt0_hdr *)opt->srcrt)->addr);
+	*orig = fl6->daddr;
+	fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
 	return orig;
 }
 
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -96,7 +96,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
 					       r->src.plen))
 				goto again;
-			ipv6_addr_copy(&flp6->saddr, &saddr);
+			flp6->saddr = saddr;
 		}
 		goto out;
 	}
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -290,9 +290,9 @@ static void mip6_addr_swap(struct sk_buff *skb)
 		if (likely(off >= 0)) {
 			hao = (struct ipv6_destopt_hao *)
 					(skb_network_header(skb) + off);
-			ipv6_addr_copy(&tmp, &iph->saddr);
-			ipv6_addr_copy(&iph->saddr, &hao->addr);
-			ipv6_addr_copy(&hao->addr, &tmp);
+			tmp = iph->saddr;
+			iph->saddr = hao->addr;
+			hao->addr = tmp;
 		}
 	}
 }
@@ -444,9 +444,9 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
-	ipv6_addr_copy(&fl6.daddr, &hdr->saddr);
+	fl6.daddr = hdr->saddr;
 	if (saddr)
-		ipv6_addr_copy(&fl6.saddr, saddr);
+		fl6.saddr = *saddr;
 	fl6.flowi6_oif = iif;
 	fl6.fl6_icmp_type = type;
 	fl6.fl6_icmp_code = code;
@@ -538,9 +538,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
-	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->saddr);
+	fl6.daddr = ipv6_hdr(skb)->saddr;
 	if (saddr)
-		ipv6_addr_copy(&fl6.saddr, saddr);
+		fl6.saddr = *saddr;
 	fl6.flowi6_oif = skb->dev->ifindex;
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
@@ -786,8 +786,8 @@ void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 		      int oif)
 {
 	memset(fl6, 0, sizeof(*fl6));
-	ipv6_addr_copy(&fl6->saddr, saddr);
-	ipv6_addr_copy(&fl6->daddr, daddr);
+	fl6->saddr = *saddr;
+	fl6->daddr = *daddr;
 	fl6->flowi6_proto 	= IPPROTO_ICMPV6;
 	fl6->fl6_icmp_type	= type;
 	fl6->fl6_icmp_code	= 0;
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -65,9 +65,9 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
+	fl6.daddr = treq->rmt_addr;
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
-	ipv6_addr_copy(&fl6.saddr, &treq->loc_addr);
+	fl6.saddr = treq->loc_addr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_dport = inet_rsk(req)->rmt_port;
@@ -157,7 +157,7 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
 
 	sin6->sin6_family = AF_INET6;
-	ipv6_addr_copy(&sin6->sin6_addr, &np->daddr);
+	sin6->sin6_addr = np->daddr;
 	sin6->sin6_port	= inet_sk(sk)->inet_dport;
 	/* We do not store received flowlabel for TCP */
 	sin6->sin6_flowinfo = 0;
@@ -215,8 +215,8 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = sk->sk_protocol;
-	ipv6_addr_copy(&fl6.daddr, &np->daddr);
-	ipv6_addr_copy(&fl6.saddr, &np->saddr);
+	fl6.daddr = np->daddr;
+	fl6.saddr = np->saddr;
 	fl6.flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
@@ -246,7 +246,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	skb_dst_set_noref(skb, dst);
 
 	/* Restore final destination back after routing done */
-	ipv6_addr_copy(&fl6.daddr, &np->daddr);
+	fl6.daddr = np->daddr;
 
 	res = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 	rcu_read_unlock();
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -386,7 +386,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		err = -EINVAL;
 		goto done;
 	}
-	ipv6_addr_copy(&fl->dst, &freq->flr_dst);
+	fl->dst = freq->flr_dst;
 	atomic_set(&fl->users, 1);
 	switch (fl->share) {
 	case IPV6_FL_S_EXCL:
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -238,8 +238,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	hdr->nexthdr = proto;
 	hdr->hop_limit = hlimit;
 
-	ipv6_addr_copy(&hdr->saddr, &fl6->saddr);
-	ipv6_addr_copy(&hdr->daddr, first_hop);
+	hdr->saddr = fl6->saddr;
+	hdr->daddr = *first_hop;
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
@@ -290,8 +290,8 @@ int ip6_nd_hdr(struct sock *sk, struct sk_buff *skb, struct net_device *dev,
 	hdr->nexthdr = proto;
 	hdr->hop_limit = np->hop_limit;
 
-	ipv6_addr_copy(&hdr->saddr, saddr);
-	ipv6_addr_copy(&hdr->daddr, daddr);
+	hdr->saddr = *saddr;
+	hdr->daddr = *daddr;
 
 	return 0;
 }
@@ -1063,7 +1063,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
-		ipv6_addr_copy(&fl6->daddr, final_dst);
+		fl6->daddr = *final_dst;
 	if (can_sleep)
 		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
@@ -1099,7 +1099,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 	if (err)
 		return ERR_PTR(err);
 	if (final_dst)
-		ipv6_addr_copy(&fl6->daddr, final_dst);
+		fl6->daddr = *final_dst;
 	if (can_sleep)
 		fl6->flowi6_flags |= FLOWI_FLAG_CAN_SLEEP;
 
@@ -1592,7 +1592,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	if (np->pmtudisc < IPV6_PMTUDISC_DO)
 		skb->local_df = 1;
 
-	ipv6_addr_copy(final_dst, &fl6->daddr);
+	*final_dst = fl6->daddr;
 	__skb_pull(skb, skb_network_header_len(skb));
 	if (opt && opt->opt_flen)
 		ipv6_push_frag_opts(skb, opt, &proto);
@@ -1608,8 +1608,8 @@ int ip6_push_pending_frames(struct sock *sk)
 
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
-	ipv6_addr_copy(&hdr->saddr, &fl6->saddr);
-	ipv6_addr_copy(&hdr->daddr, final_dst);
+	hdr->saddr = fl6->saddr;
+	hdr->daddr = *final_dst;
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -977,8 +977,8 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
-	ipv6_addr_copy(&ipv6h->saddr, &fl6->saddr);
-	ipv6_addr_copy(&ipv6h->daddr, &fl6->daddr);
+	ipv6h->saddr = fl6->saddr;
+	ipv6h->daddr = fl6->daddr;
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = ip6_local_out(skb);
@@ -1153,8 +1153,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	memcpy(dev->broadcast, &p->raddr, sizeof(struct in6_addr));
 
 	/* Set up flowi template */
-	ipv6_addr_copy(&fl6->saddr, &p->laddr);
-	ipv6_addr_copy(&fl6->daddr, &p->raddr);
+	fl6->saddr = p->laddr;
+	fl6->daddr = p->raddr;
 	fl6->flowi6_oif = p->link;
 	fl6->flowlabel = 0;
 
@@ -1210,8 +1210,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 static int
 ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
 {
-	ipv6_addr_copy(&t->parms.laddr, &p->laddr);
-	ipv6_addr_copy(&t->parms.raddr, &p->raddr);
+	t->parms.laddr = p->laddr;
+	t->parms.raddr = p->raddr;
 	t->parms.flags = p->flags;
 	t->parms.hop_limit = p->hop_limit;
 	t->parms.encap_limit = p->encap_limit;
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1105,8 +1105,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 		msg->im6_msgtype = MRT6MSG_WHOLEPKT;
 		msg->im6_mif = mrt->mroute_reg_vif_num;
 		msg->im6_pad = 0;
-		ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
-		ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
+		msg->im6_src = ipv6_hdr(pkt)->saddr;
+		msg->im6_dst = ipv6_hdr(pkt)->daddr;
 
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -1131,8 +1131,8 @@ static int ip6mr_cache_report(struct mr6_table *mrt, struct sk_buff *pkt,
 	msg->im6_msgtype = assert;
 	msg->im6_mif = mifi;
 	msg->im6_pad = 0;
-	ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
-	ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
+	msg->im6_src = ipv6_hdr(pkt)->saddr;
+	msg->im6_dst = ipv6_hdr(pkt)->daddr;
 
 	skb_dst_set(skb, dst_clone(skb_dst(pkt)));
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -2181,8 +2181,8 @@ int ip6mr_get_route(struct net *net,
 		iph->payload_len = 0;
 		iph->nexthdr = IPPROTO_NONE;
 		iph->hop_limit = 0;
-		ipv6_addr_copy(&iph->saddr, &rt->rt6i_src.addr);
-		ipv6_addr_copy(&iph->daddr, &rt->rt6i_dst.addr);
+		iph->saddr = rt->rt6i_src.addr;
+		iph->daddr = rt->rt6i_dst.addr;
 
 		err = ip6mr_cache_unresolved(mrt, vif, skb2);
 		read_unlock(&mrt_lock);
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -435,7 +435,7 @@ sticky_done:
 			goto e_inval;
 
 		np->sticky_pktinfo.ipi6_ifindex = pkt.ipi6_ifindex;
-		ipv6_addr_copy(&np->sticky_pktinfo.ipi6_addr, &pkt.ipi6_addr);
+		np->sticky_pktinfo.ipi6_addr = pkt.ipi6_addr;
 		retv = 0;
 		break;
 	}
@@ -980,8 +980,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
-				np->mcast_oif? ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr) :
-					ipv6_addr_copy(&src_info.ipi6_addr, &(np->sticky_pktinfo.ipi6_addr));
+				src_info.ipi6_addr = np->mcast_oif ? np->daddr : np->sticky_pktinfo.ipi6_addr;
 				put_cmsg(&msg, SOL_IPV6, IPV6_PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxhlim) {
@@ -992,8 +991,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
 					np->sticky_pktinfo.ipi6_ifindex;
-				np->mcast_oif? ipv6_addr_copy(&src_info.ipi6_addr, &np->daddr) :
-					ipv6_addr_copy(&src_info.ipi6_addr, &(np->sticky_pktinfo.ipi6_addr));
+				src_info.ipi6_addr = np->mcast_oif ? np->daddr : np->sticky_pktinfo.ipi6_addr;
 				put_cmsg(&msg, SOL_IPV6, IPV6_2292PKTINFO, sizeof(src_info), &src_info);
 			}
 			if (np->rxopt.bits.rxohlim) {
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -155,7 +155,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		return -ENOMEM;
 
 	mc_lst->next = NULL;
-	ipv6_addr_copy(&mc_lst->addr, addr);
+	mc_lst->addr = *addr;
 
 	rcu_read_lock();
 	if (ifindex == 0) {
@@ -858,7 +858,7 @@ int ipv6_dev_mc_inc(struct net_device *dev, const struct in6_addr *addr)
 
 	setup_timer(&mc->mca_timer, igmp6_timer_handler, (unsigned long)mc);
 
-	ipv6_addr_copy(&mc->mca_addr, addr);
+	mc->mca_addr = *addr;
 	mc->idev = idev; /* (reference taken) */
 	mc->mca_users = 1;
 	/* mca_stamp should be updated upon changes */
@@ -1776,7 +1776,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
 	memset(hdr, 0, sizeof(struct mld_msg));
 	hdr->mld_type = type;
-	ipv6_addr_copy(&hdr->mld_mca, addr);
+	hdr->mld_mca = *addr;
 
 	hdr->mld_cksum = csum_ipv6_magic(saddr, snd_addr, len,
 					 IPPROTO_ICMPV6,
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -195,8 +195,8 @@ static inline int mip6_report_rl_allow(struct timeval *stamp,
 		mip6_report_rl.stamp.tv_sec = stamp->tv_sec;
 		mip6_report_rl.stamp.tv_usec = stamp->tv_usec;
 		mip6_report_rl.iif = iif;
-		ipv6_addr_copy(&mip6_report_rl.src, src);
-		ipv6_addr_copy(&mip6_report_rl.dst, dst);
+		mip6_report_rl.src = *src;
+		mip6_report_rl.dst = *dst;
 		allow = 1;
 	}
 	spin_unlock_bh(&mip6_report_rl.lock);
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -481,7 +481,7 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 	opt = skb_transport_header(skb) + sizeof(struct icmp6hdr);
 	if (target) {
-		ipv6_addr_copy((struct in6_addr *)opt, target);
+		*(struct in6_addr *)opt = *target;
 		opt += sizeof(*target);
 	}
 
@@ -1622,9 +1622,9 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	 */
 
 	addrp = (struct in6_addr *)(icmph + 1);
-	ipv6_addr_copy(addrp, target);
+	*addrp = *target;
 	addrp++;
-	ipv6_addr_copy(addrp, &ipv6_hdr(skb)->daddr);
+	*addrp = ipv6_hdr(skb)->daddr;
 
 	opt = (u8*) (addrp + 1);
 
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -93,8 +93,8 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl6.saddr, &oip6h->daddr);
-	ipv6_addr_copy(&fl6.daddr, &oip6h->saddr);
+	fl6.saddr = oip6h->daddr;
+	fl6.daddr = oip6h->saddr;
 	fl6.fl6_sport = otcph.dest;
 	fl6.fl6_dport = otcph.source;
 	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
@@ -129,8 +129,8 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	*(__be32 *)ip6h =  htonl(0x60000000 | (tclass << 20));
 	ip6h->hop_limit = ip6_dst_hoplimit(dst);
 	ip6h->nexthdr = IPPROTO_TCP;
-	ipv6_addr_copy(&ip6h->saddr, &oip6h->daddr);
-	ipv6_addr_copy(&ip6h->daddr, &oip6h->saddr);
+	ip6h->saddr = oip6h->daddr;
+	ip6h->daddr = oip6h->saddr;
 
 	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
 	/* Truncate to length (no data) */
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -299,9 +299,9 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 
 	inet->inet_rcv_saddr = inet->inet_saddr = v4addr;
-	ipv6_addr_copy(&np->rcv_saddr, &addr->sin6_addr);
+	np->rcv_saddr = addr->sin6_addr;
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
-		ipv6_addr_copy(&np->saddr, &addr->sin6_addr);
+		np->saddr = addr->sin6_addr;
 	err = 0;
 out_unlock:
 	rcu_read_unlock();
@@ -495,7 +495,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (sin6) {
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = 0;
-		ipv6_addr_copy(&sin6->sin6_addr, &ipv6_hdr(skb)->saddr);
+		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 		sin6->sin6_flowinfo = 0;
 		sin6->sin6_scope_id = 0;
 		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
@@ -846,11 +846,11 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		goto out;
 
 	if (!ipv6_addr_any(daddr))
-		ipv6_addr_copy(&fl6.daddr, daddr);
+		fl6.daddr = *daddr;
 	else
 		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl6.saddr, &np->saddr);
+		fl6.saddr = np->saddr;
 
 	final_p = fl6_update_dst(&fl6, opt, &final);
 
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -153,8 +153,8 @@ void ip6_frag_init(struct inet_frag_queue *q, void *a)
 
 	fq->id = arg->id;
 	fq->user = arg->user;
-	ipv6_addr_copy(&fq->saddr, arg->src);
-	ipv6_addr_copy(&fq->daddr, arg->dst);
+	fq->saddr = *arg->src;
+	fq->daddr = *arg->dst;
 }
 EXPORT_SYMBOL(ip6_frag_init);
 
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -729,14 +729,14 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 			if (rt->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
 				rt->rt6i_flags |= RTF_ANYCAST;
-			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
+			rt->rt6i_gateway = *daddr;
 		}
 
 		rt->rt6i_flags |= RTF_CACHE;
 
 #ifdef CONFIG_IPV6_SUBTREES
 		if (rt->rt6i_src.plen && saddr) {
-			ipv6_addr_copy(&rt->rt6i_src.addr, saddr);
+			rt->rt6i_src.addr = *saddr;
 			rt->rt6i_src.plen = 128;
 		}
 #endif
@@ -932,7 +932,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 			in6_dev_hold(rt->rt6i_idev);
 		rt->rt6i_expires = 0;
 
-		ipv6_addr_copy(&rt->rt6i_gateway, &ort->rt6i_gateway);
+		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
 		rt->rt6i_metric = 0;
 
@@ -1087,7 +1087,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
-	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
+	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
@@ -1324,7 +1324,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		int gwa_type;
 
 		gw_addr = &cfg->fc_gateway;
-		ipv6_addr_copy(&rt->rt6i_gateway, gw_addr);
+		rt->rt6i_gateway = *gw_addr;
 		gwa_type = ipv6_addr_type(gw_addr);
 
 		if (gwa_type != (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)) {
@@ -1378,7 +1378,7 @@ int ip6_route_add(struct fib6_config *cfg)
 			err = -EINVAL;
 			goto out;
 		}
-		ipv6_addr_copy(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc);
+		rt->rt6i_prefsrc.addr = cfg->fc_prefsrc;
 		rt->rt6i_prefsrc.plen = 128;
 	} else
 		rt->rt6i_prefsrc.plen = 0;
@@ -1575,7 +1575,7 @@ static struct rt6_info *ip6_route_redirect(const struct in6_addr *dest,
 		},
 	};
 
-	ipv6_addr_copy(&rdfl.gateway, gateway);
+	rdfl.gateway = *gateway;
 
 	if (rt6_need_strict(dest))
 		flags |= RT6_LOOKUP_F_IFACE;
@@ -1631,7 +1631,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	if (on_link)
 		nrt->rt6i_flags &= ~RTF_GATEWAY;
 
-	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
+	nrt->rt6i_gateway = *(struct in6_addr *)neigh->primary_key;
 	dst_set_neighbour(&nrt->dst, neigh_clone(neigh));
 
 	if (ip6_ins_rt(nrt))
@@ -1777,7 +1777,7 @@ static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 		rt->dst.output = ort->dst.output;
 		rt->dst.flags |= DST_HOST;
 
-		ipv6_addr_copy(&rt->rt6i_dst.addr, dest);
+		rt->rt6i_dst.addr = *dest;
 		rt->rt6i_dst.plen = 128;
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
@@ -1787,7 +1787,7 @@ static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 		rt->dst.lastuse = jiffies;
 		rt->rt6i_expires = 0;
 
-		ipv6_addr_copy(&rt->rt6i_gateway, &ort->rt6i_gateway);
+		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
 		rt->rt6i_metric = 0;
 
@@ -1850,8 +1850,8 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_nlinfo.nl_net = net,
 	};
 
-	ipv6_addr_copy(&cfg.fc_dst, prefix);
-	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
+	cfg.fc_dst = *prefix;
+	cfg.fc_gateway = *gwaddr;
 
 	/* We should treat it as a default route if prefix length is 0. */
 	if (!prefixlen)
@@ -1900,7 +1900,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
-	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
+	cfg.fc_gateway = *gwaddr;
 
 	ip6_route_add(&cfg);
 
@@ -1946,9 +1946,9 @@ static void rtmsg_to_fib6_config(struct net *net,
 
 	cfg->fc_nlinfo.nl_net = net;
 
-	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
-	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
-	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
+	cfg->fc_dst = rtmsg->rtmsg_dst;
+	cfg->fc_src = rtmsg->rtmsg_src;
+	cfg->fc_gateway = rtmsg->rtmsg_gateway;
 }
 
 int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
@@ -2082,7 +2082,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	}
 	dst_set_neighbour(&rt->dst, neigh);
 
-	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
+	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
 
@@ -2100,7 +2100,7 @@ int ip6_route_get_saddr(struct net *net,
 	struct inet6_dev *idev = ip6_dst_idev((struct dst_entry*)rt);
 	int err = 0;
 	if (rt->rt6i_prefsrc.plen)
-		ipv6_addr_copy(saddr, &rt->rt6i_prefsrc.addr);
+		*saddr = rt->rt6i_prefsrc.addr;
 	else
 		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
 					 daddr, prefs, saddr);
@@ -2439,7 +2439,7 @@ static int rt6_fill_node(struct net *net,
 
 	if (rt->rt6i_prefsrc.plen) {
 		struct in6_addr saddr_buf;
-		ipv6_addr_copy(&saddr_buf, &rt->rt6i_prefsrc.addr);
+		saddr_buf = rt->rt6i_prefsrc.addr;
 		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
@@ -2513,14 +2513,14 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
 			goto errout;
 
-		ipv6_addr_copy(&fl6.saddr, nla_data(tb[RTA_SRC]));
+		fl6.saddr = *(struct in6_addr *)nla_data(tb[RTA_SRC]);
 	}
 
 	if (tb[RTA_DST]) {
 		if (nla_len(tb[RTA_DST]) < sizeof(struct in6_addr))
 			goto errout;
 
-		ipv6_addr_copy(&fl6.daddr, nla_data(tb[RTA_DST]));
+		fl6.daddr = *(struct in6_addr *)nla_data(tb[RTA_DST]);
 	}
 
 	if (tb[RTA_IIF])
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -914,7 +914,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				goto done;
 #ifdef CONFIG_IPV6_SIT_6RD
 		} else {
-			ipv6_addr_copy(&ip6rd.prefix, &t->ip6rd.prefix);
+			ip6rd.prefix = t->ip6rd.prefix;
 			ip6rd.relay_prefix = t->ip6rd.relay_prefix;
 			ip6rd.prefixlen = t->ip6rd.prefixlen;
 			ip6rd.relay_prefixlen = t->ip6rd.relay_prefixlen;
@@ -1082,7 +1082,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (relay_prefix != ip6rd.relay_prefix)
 				goto done;
 
-			ipv6_addr_copy(&t->ip6rd.prefix, &prefix);
+			t->ip6rd.prefix = prefix;
 			t->ip6rd.relay_prefix = relay_prefix;
 			t->ip6rd.prefixlen = ip6rd.prefixlen;
 			t->ip6rd.relay_prefixlen = ip6rd.relay_prefixlen;
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -200,8 +200,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->mss = mss;
 	ireq->rmt_port = th->source;
 	ireq->loc_port = th->dest;
-	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
+	ireq6->rmt_addr = ipv6_hdr(skb)->saddr;
+	ireq6->loc_addr = ipv6_hdr(skb)->daddr;
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
@@ -237,9 +237,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		struct flowi6 fl6;
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_TCP;
-		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
+		fl6.daddr = ireq6->rmt_addr;
 		final_p = fl6_update_dst(&fl6, np->opt, &final);
-		ipv6_addr_copy(&fl6.saddr, &ireq6->loc_addr);
+		fl6.saddr = ireq6->loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.flowi6_mark = sk->sk_mark;
 		fl6.fl6_dport = inet_rsk(req)->rmt_port;
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -153,7 +153,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
-			ipv6_addr_copy(&usin->sin6_addr, &flowlabel->dst);
+			usin->sin6_addr = flowlabel->dst;
 			fl6_sock_release(flowlabel);
 		}
 	}
@@ -195,7 +195,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		tp->write_seq = 0;
 	}
 
-	ipv6_addr_copy(&np->daddr, &usin->sin6_addr);
+	np->daddr = usin->sin6_addr;
 	np->flow_label = fl6.flowlabel;
 
 	/*
@@ -244,9 +244,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 		saddr = &np->rcv_saddr;
 
 	fl6.flowi6_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl6.daddr, &np->daddr);
-	ipv6_addr_copy(&fl6.saddr,
-		       (saddr ? saddr : &np->saddr));
+	fl6.daddr = np->daddr;
+	fl6.saddr = saddr ? *saddr : np->saddr;
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_dport = usin->sin6_port;
@@ -264,11 +263,11 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	if (saddr == NULL) {
 		saddr = &fl6.saddr;
-		ipv6_addr_copy(&np->rcv_saddr, saddr);
+		np->rcv_saddr = *saddr;
 	}
 
 	/* set the source address */
-	ipv6_addr_copy(&np->saddr, saddr);
+	np->saddr = *saddr;
 	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	sk->sk_gso_type = SKB_GSO_TCPV6;
@@ -398,8 +397,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			 */
 			memset(&fl6, 0, sizeof(fl6));
 			fl6.flowi6_proto = IPPROTO_TCP;
-			ipv6_addr_copy(&fl6.daddr, &np->daddr);
-			ipv6_addr_copy(&fl6.saddr, &np->saddr);
+			fl6.daddr = np->daddr;
+			fl6.saddr = np->saddr;
 			fl6.flowi6_oif = sk->sk_bound_dev_if;
 			fl6.flowi6_mark = sk->sk_mark;
 			fl6.fl6_dport = inet->inet_dport;
@@ -489,8 +488,8 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
-	ipv6_addr_copy(&fl6.saddr, &treq->loc_addr);
+	fl6.daddr = treq->rmt_addr;
+	fl6.saddr = treq->loc_addr;
 	fl6.flowlabel = 0;
 	fl6.flowi6_oif = treq->iif;
 	fl6.flowi6_mark = sk->sk_mark;
@@ -512,7 +511,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
-		ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
+		fl6.daddr = treq->rmt_addr;
 		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
@@ -617,8 +616,7 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 			tp->md5sig_info->alloced6++;
 		}
 
-		ipv6_addr_copy(&tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr,
-			       peer);
+		tp->md5sig_info->keys6[tp->md5sig_info->entries6].addr = *peer;
 		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.key = newkey;
 		tp->md5sig_info->keys6[tp->md5sig_info->entries6].base.keylen = newkeylen;
 
@@ -750,8 +748,8 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 
 	bp = &hp->md5_blk.ip6;
 	/* 1. TCP pseudo-header (RFC2460) */
-	ipv6_addr_copy(&bp->saddr, saddr);
-	ipv6_addr_copy(&bp->daddr, daddr);
+	bp->saddr = *saddr;
+	bp->daddr = *daddr;
 	bp->protocol = cpu_to_be32(IPPROTO_TCP);
 	bp->len = cpu_to_be32(nbytes);
 
@@ -1039,8 +1037,8 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 #endif
 
 	memset(&fl6, 0, sizeof(fl6));
-	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&fl6.saddr, &ipv6_hdr(skb)->daddr);
+	fl6.daddr = ipv6_hdr(skb)->saddr;
+	fl6.saddr = ipv6_hdr(skb)->daddr;
 
 	buff->ip_summed = CHECKSUM_PARTIAL;
 	buff->csum = 0;
@@ -1250,8 +1248,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	treq = inet6_rsk(req);
-	ipv6_addr_copy(&treq->rmt_addr, &ipv6_hdr(skb)->saddr);
-	ipv6_addr_copy(&treq->loc_addr, &ipv6_hdr(skb)->daddr);
+	treq->rmt_addr = ipv6_hdr(skb)->saddr;
+	treq->loc_addr = ipv6_hdr(skb)->daddr;
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
@@ -1380,7 +1378,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
 
-		ipv6_addr_copy(&newnp->rcv_saddr, &newnp->saddr);
+		newnp->rcv_saddr = newnp->saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
 		newsk->sk_backlog_rcv = tcp_v4_do_rcv;
@@ -1444,9 +1442,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-	ipv6_addr_copy(&newnp->daddr, &treq->rmt_addr);
-	ipv6_addr_copy(&newnp->saddr, &treq->loc_addr);
-	ipv6_addr_copy(&newnp->rcv_saddr, &treq->loc_addr);
+	newnp->daddr = treq->rmt_addr;
+	newnp->saddr = treq->loc_addr;
+	newnp->rcv_saddr = treq->loc_addr;
 	newsk->sk_bound_dev_if = treq->iif;
 
 	/* Now IPv6 options...
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -417,8 +417,7 @@ try_again:
 			ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr,
 					       &sin6->sin6_addr);
 		else {
-			ipv6_addr_copy(&sin6->sin6_addr,
-				       &ipv6_hdr(skb)->saddr);
+			sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin6->sin6_scope_id = IP6CB(skb)->iif;
 		}
@@ -1115,11 +1114,11 @@ do_udp_sendmsg:
 
 	fl6.flowi6_proto = sk->sk_protocol;
 	if (!ipv6_addr_any(daddr))
-		ipv6_addr_copy(&fl6.daddr, daddr);
+		fl6.daddr = *daddr;
 	else
 		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
 	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
-		ipv6_addr_copy(&fl6.saddr, &np->saddr);
+		fl6.saddr = np->saddr;
 	fl6.fl6_sport = inet->inet_sport;
 
 	final_p = fl6_update_dst(&fl6, opt, &final);
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -72,8 +72,8 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 		top_iph->nexthdr = IPPROTO_BEETPH;
 	}
 
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	top_iph->saddr = *(struct in6_addr *)&x->props.saddr;
+	top_iph->daddr = *(struct in6_addr *)&x->id.daddr;
 	return 0;
 }
 
@@ -99,8 +99,8 @@ static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	ip6h = ipv6_hdr(skb);
 	ip6h->payload_len = htons(skb->len - size);
-	ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
-	ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *) &x->sel.saddr.a6);
+	ip6h->daddr = *(struct in6_addr *)&x->sel.daddr.a6;
+	ip6h->saddr = *(struct in6_addr *)&x->sel.saddr.a6;
 	err = 0;
 out:
 	return err;
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -55,8 +55,8 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
 	top_iph->hop_limit = ip6_dst_hoplimit(dst->child);
-	ipv6_addr_copy(&top_iph->saddr, (const struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (const struct in6_addr *)&x->id.daddr);
+	top_iph->saddr = *(struct in6_addr *)&x->props.saddr;
+	top_iph->daddr = *(struct in6_addr *)&x->id.daddr;
 	return 0;
 }
 
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -49,7 +49,7 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 	struct sock *sk = skb->sk;
 
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->daddr);
+	fl6.daddr = ipv6_hdr(skb)->daddr;
 
 	ipv6_local_rxpmtu(sk, &fl6, mtu);
 }
@@ -60,7 +60,7 @@ static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 	struct sock *sk = skb->sk;
 
 	fl6.fl6_dport = inet_sk(sk)->inet_dport;
-	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->daddr);
+	fl6.daddr = ipv6_hdr(skb)->daddr;
 
 	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
 }
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -132,8 +132,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
 
-	ipv6_addr_copy(&fl6->daddr, reverse ? &hdr->saddr : &hdr->daddr);
-	ipv6_addr_copy(&fl6->saddr, reverse ? &hdr->daddr : &hdr->saddr);
+	fl6->daddr = reverse ? hdr->saddr : hdr->daddr;
+	fl6->saddr = reverse ? hdr->daddr : hdr->saddr;
 
 	while (nh + offset + 1 < skb->data ||
 	       pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -27,8 +27,8 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 
 	/* Initialize temporary selector matching only
 	 * to current session. */
-	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl6->daddr);
-	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl6->saddr);
+	*(struct in6_addr *)&sel->daddr = fl6->daddr;
+	*(struct in6_addr *)&sel->saddr = fl6->saddr;
 	sel->dport = xfrm_flowi_dport(fl, &fl6->uli);
 	sel->dport_mask = htons(0xffff);
 	sel->sport = xfrm_flowi_sport(fl, &fl6->uli);
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -712,7 +712,7 @@ static unsigned int pfkey_sockaddr_fill(const xfrm_address_t *xaddr, __be16 port
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = port;
 		sin6->sin6_flowinfo = 0;
-		ipv6_addr_copy(&sin6->sin6_addr, (const struct in6_addr *)xaddr->a6);
+		sin6->sin6_addr = *(struct in6_addr *)xaddr->a6;
 		sin6->sin6_scope_id = 0;
 		return 128;
 	    }
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -241,7 +241,7 @@ hash_ip6_data_isnull(const struct hash_ip6_elem *elem)
 static inline void
 hash_ip6_data_copy(struct hash_ip6_elem *dst, const struct hash_ip6_elem *src)
 {
-	ipv6_addr_copy(&dst->ip.in6, &src->ip.in6);
+	dst->ip.in6 = src->ip.in6;
 }
 
 static inline void
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -267,7 +267,7 @@ static inline void
 hash_net6_data_copy(struct hash_net6_elem *dst,
 		    const struct hash_net6_elem *src)
 {
-	ipv6_addr_copy(&dst->ip.in6, &src->ip.in6);
+	dst->ip.in6 = src->ip.in6;
 	dst->cidr = src->cidr;
 }
 
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -983,7 +983,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	if (!cp)
 		return NF_ACCEPT;
 
-	ipv6_addr_copy(&snet.in6, &iph->saddr);
+	snet.in6 = iph->saddr;
 	return handle_response_icmp(AF_INET6, skb, &snet, cih->nexthdr, cp,
 				    pp, offset, sizeof(struct ipv6hdr));
 }
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -603,9 +603,9 @@ sloop:
 #ifdef CONFIG_IP_VS_IPV6
 	if (cp->af == AF_INET6) {
 		p += sizeof(struct ip_vs_sync_v6);
-		ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
-		ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
-		ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
+		s->v6.caddr = cp->caddr.in6;
+		s->v6.vaddr = cp->vaddr.in6;
+		s->v6.daddr = cp->daddr.in6;
 	} else
 #endif
 	{
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -235,7 +235,7 @@ __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
 			goto out_err;
 		}
 	}
-	ipv6_addr_copy(ret_saddr, &fl6.saddr);
+	*ret_saddr = fl6.saddr;
 	return dst;
 
 out_err:
@@ -279,7 +279,7 @@ __ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_dest *dest,
 				  atomic_read(&rt->dst.__refcnt));
 		}
 		if (ret_saddr)
-			ipv6_addr_copy(ret_saddr, &dest->dst_saddr.in6);
+			*ret_saddr = dest->dst_saddr.in6;
 		spin_unlock(&dest->dst_lock);
 	} else {
 		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
@@ -705,7 +705,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
 		goto tx_error;
-	ipv6_addr_copy(&ipv6_hdr(skb)->daddr, &cp->daddr.in6);
+	ipv6_hdr(skb)->daddr = cp->daddr.in6;
 
 	if (!local || !skb->dev) {
 		/* drop the old route when skb is not shared */
@@ -967,8 +967,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
 	iph->priority		=	old_iph->priority;
 	memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
-	ipv6_addr_copy(&iph->daddr, &cp->daddr.in6);
-	ipv6_addr_copy(&iph->saddr, &saddr);
+	iph->daddr = cp->daddr.in6;
+	iph->saddr = saddr;
 	iph->hop_limit		=	old_iph->hop_limit;
 
 	/* Another hack: avoid icmp_send in ip_fragment */
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -750,10 +750,10 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 		struct rt6_info *rt1, *rt2;
 
 		memset(&fl1, 0, sizeof(fl1));
-		ipv6_addr_copy(&fl1.daddr, &src->in6);
+		fl1.daddr = src->in6;
 
 		memset(&fl2, 0, sizeof(fl2));
-		ipv6_addr_copy(&fl2.daddr, &dst->in6);
+		fl2.daddr = dst->in6;
 		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
 				   flowi6_to_flowi(&fl1), false)) {
 			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -161,7 +161,7 @@ static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
 		struct flowi6 *fl6 = &fl.u.ip6;
 
 		memset(fl6, 0, sizeof(*fl6));
-		ipv6_addr_copy(&fl6->daddr, &ipv6_hdr(skb)->saddr);
+		fl6->daddr = ipv6_hdr(skb)->saddr;
 	}
 	rcu_read_lock();
 	ai = nf_get_afinfo(family);
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -42,7 +42,7 @@ static u32 match_lookup_rt6(struct net *net, const struct net_device *dev,
 	int route_err;
 
 	memset(&flow, 0, sizeof(flow));
-	ipv6_addr_copy(&flow.daddr, addr);
+	flow.daddr = *addr;
 	if (dev)
 		flow.flowi6_oif = dev->ifindex;
 
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -155,12 +155,12 @@ int netlbl_cfg_unlbl_map_add(const char *domain,
 			if (map6 == NULL)
 				goto cfg_unlbl_map_add_failure;
 			map6->type = NETLBL_NLTYPE_UNLABELED;
-			ipv6_addr_copy(&map6->list.addr, addr6);
+			map6->list.addr = *addr6;
 			map6->list.addr.s6_addr32[0] &= mask6->s6_addr32[0];
 			map6->list.addr.s6_addr32[1] &= mask6->s6_addr32[1];
 			map6->list.addr.s6_addr32[2] &= mask6->s6_addr32[2];
 			map6->list.addr.s6_addr32[3] &= mask6->s6_addr32[3];
-			ipv6_addr_copy(&map6->list.mask, mask6);
+			map6->list.mask = *mask6;
 			map6->list.valid = 1;
 			ret_val = netlbl_af4list_add(&map4->list,
 						     &addrmap->list4);
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -216,12 +216,12 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
 			ret_val = -ENOMEM;
 			goto add_failure;
 		}
-		ipv6_addr_copy(&map->list.addr, addr);
+		map->list.addr = *addr;
 		map->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
 		map->list.addr.s6_addr32[1] &= mask->s6_addr32[1];
 		map->list.addr.s6_addr32[2] &= mask->s6_addr32[2];
 		map->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
-		ipv6_addr_copy(&map->list.mask, mask);
+		map->list.mask = *mask;
 		map->list.valid = 1;
 		map->type = entry->type;
 
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -300,12 +300,12 @@ static int netlbl_unlhsh_add_addr6(struct netlbl_unlhsh_iface *iface,
 	if (entry == NULL)
 		return -ENOMEM;
 
-	ipv6_addr_copy(&entry->list.addr, addr);
+	entry->list.addr = *addr;
 	entry->list.addr.s6_addr32[0] &= mask->s6_addr32[0];
 	entry->list.addr.s6_addr32[1] &= mask->s6_addr32[1];
 	entry->list.addr.s6_addr32[2] &= mask->s6_addr32[2];
 	entry->list.addr.s6_addr32[3] &= mask->s6_addr32[3];
-	ipv6_addr_copy(&entry->list.mask, mask);
+	entry->list.mask = *mask;
 	entry->list.valid = 1;
 	entry->secid = secid;
 
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -107,7 +107,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 		if (addr) {
 			addr->a.v6.sin6_family = AF_INET6;
 			addr->a.v6.sin6_port = 0;
-			ipv6_addr_copy(&addr->a.v6.sin6_addr, &ifa->addr);
+			addr->a.v6.sin6_addr = ifa->addr;
 			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);
@@ -219,8 +219,8 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	/* Fill in the dest address from the route entry passed with the skb
 	 * and the source address from the transport.
 	 */
-	ipv6_addr_copy(&fl6.daddr, &transport->ipaddr.v6.sin6_addr);
-	ipv6_addr_copy(&fl6.saddr, &transport->saddr.v6.sin6_addr);
+	fl6.daddr = transport->ipaddr.v6.sin6_addr;
+	fl6.saddr = transport->saddr.v6.sin6_addr;
 
 	fl6.flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
@@ -231,7 +231,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		ipv6_addr_copy(&fl6.daddr, rt0->addr);
+		fl6.daddr = *rt0->addr;
 	}
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI6 dst:%pI6\n",
@@ -265,7 +265,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	sctp_scope_t scope;
 
 	memset(fl6, 0, sizeof(struct flowi6));
-	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
+	fl6->daddr = daddr->v6.sin6_addr;
 	fl6->fl6_dport = daddr->v6.sin6_port;
 	fl6->flowi6_proto = IPPROTO_SCTP;
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
@@ -277,7 +277,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		fl6->fl6_sport = htons(asoc->base.bind_addr.port);
 
 	if (saddr) {
-		ipv6_addr_copy(&fl6->saddr, &saddr->v6.sin6_addr);
+		fl6->saddr = saddr->v6.sin6_addr;
 		fl6->fl6_sport = saddr->v6.sin6_port;
 		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6->saddr);
 	}
@@ -334,7 +334,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	}
 	rcu_read_unlock();
 	if (baddr) {
-		ipv6_addr_copy(&fl6->saddr, &baddr->v6.sin6_addr);
+		fl6->saddr = baddr->v6.sin6_addr;
 		fl6->fl6_sport = baddr->v6.sin6_port;
 		dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
 	}
@@ -375,7 +375,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 
 	if (t->dst) {
 		saddr->v6.sin6_family = AF_INET6;
-		ipv6_addr_copy(&saddr->v6.sin6_addr, &fl6->saddr);
+		saddr->v6.sin6_addr = fl6->saddr;
 	}
 }
 
@@ -400,7 +400,7 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 		if (addr) {
 			addr->a.v6.sin6_family = AF_INET6;
 			addr->a.v6.sin6_port = 0;
-			ipv6_addr_copy(&addr->a.v6.sin6_addr, &ifp->addr);
+			addr->a.v6.sin6_addr = ifp->addr;
 			addr->a.v6.sin6_scope_id = dev->ifindex;
 			addr->valid = 1;
 			INIT_LIST_HEAD(&addr->list);
@@ -416,7 +416,6 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 static void sctp_v6_from_skb(union sctp_addr *addr,struct sk_buff *skb,
 			     int is_saddr)
 {
-	void *from;
 	__be16 *port;
 	struct sctphdr *sh;
 
@@ -428,12 +427,11 @@ static void sctp_v6_from_skb(union sctp_addr *addr,struct sk_buff *skb,
 	sh = sctp_hdr(skb);
 	if (is_saddr) {
 		*port  = sh->source;
-		from = &ipv6_hdr(skb)->saddr;
+		addr->v6.sin6_addr = ipv6_hdr(skb)->saddr;
 	} else {
 		*port = sh->dest;
-		from = &ipv6_hdr(skb)->daddr;
+		addr->v6.sin6_addr = ipv6_hdr(skb)->daddr;
 	}
-	ipv6_addr_copy(&addr->v6.sin6_addr, from);
 }
 
 /* Initialize an sctp_addr from a socket. */
@@ -441,7 +439,7 @@ static void sctp_v6_from_sk(union sctp_addr *addr, struct sock *sk)
 {
 	addr->v6.sin6_family = AF_INET6;
 	addr->v6.sin6_port = 0;
-	ipv6_addr_copy(&addr->v6.sin6_addr, &inet6_sk(sk)->rcv_saddr);
+	addr->v6.sin6_addr = inet6_sk(sk)->rcv_saddr;
 }
 
 /* Initialize sk->sk_rcv_saddr from sctp_addr. */
@@ -454,7 +452,7 @@ static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 		inet6_sk(sk)->rcv_saddr.s6_addr32[3] =
 			addr->v4.sin_addr.s_addr;
 	} else {
-		ipv6_addr_copy(&inet6_sk(sk)->rcv_saddr, &addr->v6.sin6_addr);
+		inet6_sk(sk)->rcv_saddr = addr->v6.sin6_addr;
 	}
 }
 
@@ -467,7 +465,7 @@ static void sctp_v6_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
 		inet6_sk(sk)->daddr.s6_addr32[2] = htonl(0x0000ffff);
 		inet6_sk(sk)->daddr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
 	} else {
-		ipv6_addr_copy(&inet6_sk(sk)->daddr, &addr->v6.sin6_addr);
+		inet6_sk(sk)->daddr = addr->v6.sin6_addr;
 	}
 }
 
@@ -479,7 +477,7 @@ static void sctp_v6_from_addr_param(union sctp_addr *addr,
 	addr->v6.sin6_family = AF_INET6;
 	addr->v6.sin6_port = port;
 	addr->v6.sin6_flowinfo = 0; /* BUG */
-	ipv6_addr_copy(&addr->v6.sin6_addr, &param->v6.addr);
+	addr->v6.sin6_addr = param->v6.addr;
 	addr->v6.sin6_scope_id = iif;
 }
 
@@ -493,7 +491,7 @@ static int sctp_v6_to_addr_param(const union sctp_addr *addr,
 
 	param->v6.param_hdr.type = SCTP_PARAM_IPV6_ADDRESS;
 	param->v6.param_hdr.length = htons(length);
-	ipv6_addr_copy(&param->v6.addr, &addr->v6.sin6_addr);
+	param->v6.addr = addr->v6.sin6_addr;
 
 	return length;
 }
@@ -504,7 +502,7 @@ static void sctp_v6_to_addr(union sctp_addr *addr, struct in6_addr *saddr,
 {
 	addr->sa.sa_family = AF_INET6;
 	addr->v6.sin6_port = port;
-	ipv6_addr_copy(&addr->v6.sin6_addr, saddr);
+	addr->v6.sin6_addr = *saddr;
 }
 
 /* Compare addresses exactly.
@@ -759,7 +757,7 @@ static void sctp_inet6_event_msgname(struct sctp_ulpevent *event,
 		}
 
 		sin6from = &asoc->peer.primary_addr.v6;
-		ipv6_addr_copy(&sin6->sin6_addr, &sin6from->sin6_addr);
+		sin6->sin6_addr = sin6from->sin6_addr;
 		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 			sin6->sin6_scope_id = sin6from->sin6_scope_id;
 	}
@@ -787,7 +785,7 @@ static void sctp_inet6_skb_msgname(struct sk_buff *skb, char *msgname,
 		}
 
 		/* Otherwise, just copy the v6 address. */
-		ipv6_addr_copy(&sin6->sin6_addr, &ipv6_hdr(skb)->saddr);
+		sin6->sin6_addr = ipv6_hdr(skb)->saddr;
 		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) {
 			struct sctp_ulpevent *ev = sctp_skb2event(skb);
 			sin6->sin6_scope_id = ev->iif;
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -804,7 +804,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 				struct sockaddr_in6 *sin6;
 
 				sin6 = (struct sockaddr_in6 *)addrs;
-				ipv6_addr_copy(&asoc->asconf_addr_del_pending->v6.sin6_addr, &sin6->sin6_addr);
+				asoc->asconf_addr_del_pending->v6.sin6_addr = sin6->sin6_addr;
 			}
 			SCTP_DEBUG_PRINTK_IPADDR("send_asconf_del_ip: keep the last address asoc: %p ",
 			    " at %p\n", asoc, asoc->asconf_addr_del_pending,
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -134,7 +134,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
-	ipv6_addr_copy(&new->m_addr, &item->m_addr);
+	new->m_addr = item->m_addr;
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -274,7 +274,7 @@ static int ip_map_show(struct seq_file *m,
 	}
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
-	ipv6_addr_copy(&addr, &im->m_addr);
+	addr = im->m_addr;
 
 	if (test_bit(CACHE_VALID, &h->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &h->flags))
@@ -297,7 +297,7 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
-	ipv6_addr_copy(&ip.m_addr, addr);
+	ip.m_addr = *addr;
 	ch = sunrpc_cache_lookup(cd, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
 				 hash_ip6(*addr));
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -157,7 +157,7 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 			cmh->cmsg_level = SOL_IPV6;
 			cmh->cmsg_type = IPV6_PKTINFO;
 			pki->ipi6_ifindex = daddr->sin6_scope_id;
-			ipv6_addr_copy(&pki->ipi6_addr,	&daddr->sin6_addr);
+			pki->ipi6_addr = daddr->sin6_addr;
 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
 		}
 		break;
@@ -523,7 +523,7 @@ static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
 		return 0;
 
 	daddr->sin6_family = AF_INET6;
-	ipv6_addr_copy(&daddr->sin6_addr, &pki->ipi6_addr);
+	daddr->sin6_addr = pki->ipi6_addr;
 	daddr->sin6_scope_id = pki->ipi6_ifindex;
 	return 1;
 }
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1035,16 +1035,12 @@ static struct xfrm_state *__find_acq_core(struct net *net, struct xfrm_mark *m,
 			break;
 
 		case AF_INET6:
-			ipv6_addr_copy((struct in6_addr *)x->sel.daddr.a6,
-				       (const struct in6_addr *)daddr);
-			ipv6_addr_copy((struct in6_addr *)x->sel.saddr.a6,
-				       (const struct in6_addr *)saddr);
+			*(struct in6_addr *)x->sel.daddr.a6 = *(struct in6_addr *)daddr;
+			*(struct in6_addr *)x->sel.saddr.a6 = *(struct in6_addr *)saddr;
 			x->sel.prefixlen_d = 128;
 			x->sel.prefixlen_s = 128;
-			ipv6_addr_copy((struct in6_addr *)x->props.saddr.a6,
-				       (const struct in6_addr *)saddr);
-			ipv6_addr_copy((struct in6_addr *)x->id.daddr.a6,
-				       (const struct in6_addr *)daddr);
+			*(struct in6_addr *)x->props.saddr.a6 = *(struct in6_addr *)saddr;
+			*(struct in6_addr *)x->id.daddr.a6 = *(struct in6_addr *)daddr;
 			break;
 		}
 
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -118,8 +118,8 @@ int ipv6_skb_to_auditdata(struct sk_buff *skb,
 	ip6 = ipv6_hdr(skb);
 	if (ip6 == NULL)
 		return -EINVAL;
-	ipv6_addr_copy(&ad->u.net.v6info.saddr, &ip6->saddr);
-	ipv6_addr_copy(&ad->u.net.v6info.daddr, &ip6->daddr);
+	ad->u.net.v6info.saddr = ip6->saddr;
+	ad->u.net.v6info.daddr = ip6->daddr;
 	ret = 0;
 	/* IPv6 can have several extension header before the Transport header
 	 * skip them */
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3567,8 +3567,8 @@ static int selinux_parse_skb_ipv6(struct sk_buff *skb,
 	if (ip6 == NULL)
 		goto out;
 
-	ipv6_addr_copy(&ad->u.net.v6info.saddr, &ip6->saddr);
-	ipv6_addr_copy(&ad->u.net.v6info.daddr, &ip6->daddr);
+	ad->u.net.v6info.saddr = ip6->saddr;
+	ad->u.net.v6info.daddr = ip6->daddr;
 	ret = 0;
 
 	nexthdr = ip6->nexthdr;
@@ -3871,7 +3871,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 		if (family == PF_INET)
 			ad.u.net.v4info.saddr = addr4->sin_addr.s_addr;
 		else
-			ipv6_addr_copy(&ad.u.net.v6info.saddr, &addr6->sin6_addr);
+			ad.u.net.v6info.saddr = addr6->sin6_addr;
 
 		err = avc_has_perm(sksec->sid, sid,
 				   sksec->sclass, node_perm, &ad);
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -220,7 +220,7 @@ static int sel_netnode_sid_slow(void *addr, u16 family, u32 *sid)
 	case PF_INET6:
 		ret = security_node_sid(PF_INET6,
 					addr, sizeof(struct in6_addr), sid);
-		ipv6_addr_copy(&new->nsec.addr.ipv6, addr);
+		new->nsec.addr.ipv6 = *(struct in6_addr *)addr;
 		break;
 	default:
 		BUG();
