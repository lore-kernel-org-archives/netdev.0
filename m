From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 6/6] net, misc: replace uses of NIP6_FMT with %p6
Date: Tue, 28 Oct 2008 12:54:09 -0700
Message-ID: <1225223649.11483.44.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:56931 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbYJ1Uxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 16:53:42 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2810696wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 13:53:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/netlabel/netlabel_addrlist.c |    2 +-
 net/sctp/ipv6.c                  |   35 ++++++++++++++---------------------
 net/sctp/sm_statefuns.c          |    5 ++---
 net/sunrpc/clnt.c                |    4 ++--
 net/sunrpc/rpcb_clnt.c           |    6 +++---
 net/sunrpc/svcauth_unix.c        |    5 ++---
 net/sunrpc/xprtsock.c            |   19 +++++++++----------
 net/xfrm/xfrm_policy.c           |    6 ++----
 net/xfrm/xfrm_state.c            |   12 ++++--------
 9 files changed, 39 insertions(+), 55 deletions(-)

diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index b0925a3..614c95e 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -370,7 +370,7 @@ void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 
 	if (dev != NULL)
 		audit_log_format(audit_buf, " netif=%s", dev);
-	audit_log_format(audit_buf, " %s=" NIP6_FMT, dir, NIP6(*addr));
+	audit_log_format(audit_buf, " %s=%p6", dir, addr);
 	if (ntohl(mask->s6_addr32[3]) != 0xffffffff) {
 		u32 mask_len = 0;
 		u32 mask_val;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4124bbb..e82668b 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -223,10 +223,9 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 	}
 
-	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
-			  "src:" NIP6_FMT " dst:" NIP6_FMT "\n",
+	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%p6 dst:%p6\n",
 			  __func__, skb, skb->len,
-			  NIP6(fl.fl6_src), NIP6(fl.fl6_dst));
+			  &fl.fl6_src, &fl.fl6_dst);
 
 	SCTP_INC_STATS(SCTP_MIB_OUTSCTPPACKS);
 
@@ -252,23 +251,19 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 		fl.oif = daddr->v6.sin6_scope_id;
 

-	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " ",
-			  __func__, NIP6(fl.fl6_dst));
+	SCTP_DEBUG_PRINTK("%s: DST=%p6 ", __func__, &fl.fl6_dst);
 
 	if (saddr) {
 		ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK(
-			"SRC=" NIP6_FMT " - ",
-			NIP6(fl.fl6_src));
+		SCTP_DEBUG_PRINTK("SRC=%p6 - ", &fl.fl6_src);
 	}
 
 	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
-		SCTP_DEBUG_PRINTK(
-			"rt6_dst:" NIP6_FMT " rt6_src:" NIP6_FMT "\n",
-			NIP6(rt->rt6i_dst.addr), NIP6(rt->rt6i_src.addr));
+		SCTP_DEBUG_PRINTK("rt6_dst:%p6 rt6_src:%p6\n",
+			&rt->rt6i_dst.addr, &rt->rt6i_src.addr);
 		return dst;
 	}
 	SCTP_DEBUG_PRINTK("NO ROUTE\n");
@@ -314,9 +309,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 
-	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p "
-			  "daddr:" NIP6_FMT " ",
-			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
+	SCTP_DEBUG_PRINTK("%s: asoc:%p dst:%p daddr:%p6 ",
+			  __func__, asoc, dst, &daddr->v6.sin6_addr);
 
 	if (!asoc) {
 		ipv6_dev_get_saddr(sock_net(sctp_opt2sk(sk)),
@@ -324,8 +318,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 				   &daddr->v6.sin6_addr,
 				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);
-		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT "\n",
-				  NIP6(saddr->v6.sin6_addr));
+		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: %p6\n",
+				  &saddr->v6.sin6_addr);
 		return;
 	}
 
@@ -353,12 +347,11 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 
 	if (baddr) {
 		memcpy(saddr, baddr, sizeof(union sctp_addr));
-		SCTP_DEBUG_PRINTK("saddr: " NIP6_FMT "\n",
-				  NIP6(saddr->v6.sin6_addr));
+		SCTP_DEBUG_PRINTK("saddr: %p6\n", &saddr->v6.sin6_addr);
 	} else {
 		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
-		       "address for the dest:" NIP6_FMT "\n",
-		       __func__, asoc, NIP6(daddr->v6.sin6_addr));
+		       "address for the dest:%p6\n",
+		       __func__, asoc, &daddr->v6.sin6_addr);
 	}
 
 	rcu_read_unlock();
@@ -727,7 +720,7 @@ static int sctp_v6_is_ce(const struct sk_buff *skb)
 /* Dump the v6 addr to the seq file. */
 static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 {
-	seq_printf(seq, NIP6_FMT " ", NIP6(addr->v6.sin6_addr));
+	seq_printf(seq, "%p6 ", &addr->v6.sin6_addr);
 }
 
 static void sctp_v6_ecn_capable(struct sock *sk)
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a6a0ea7..9f37096 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1123,11 +1123,10 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 		if (from_addr.sa.sa_family == AF_INET6) {
 			if (net_ratelimit())
 				printk(KERN_WARNING
-				    "%s association %p could not find address "
-				    NIP6_FMT "\n",
+				    "%s association %p could not find address %p6\n",
 				    __func__,
 				    asoc,
-				    NIP6(from_addr.v6.sin6_addr));
+				    &from_addr.v6.sin6_addr);
 		} else {
 			if (net_ratelimit())
 				printk(KERN_WARNING
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4895c34..26f61fd 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -278,8 +278,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		case AF_INET6: {
 			struct sockaddr_in6 *sin =
 					(struct sockaddr_in6 *)args->address;
-			snprintf(servername, sizeof(servername), NIP6_FMT,
-				 NIP6(sin->sin6_addr));
+			snprintf(servername, sizeof(servername), "%p6",
+				 &sin->sin6_addr);
 			break;
 		}
 		default:
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 41013dd..968ec1f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -305,9 +305,9 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
 		snprintf(buf, sizeof(buf), "::.%u.%u",
 				port >> 8, port & 0xff);
 	else
-		snprintf(buf, sizeof(buf), NIP6_FMT".%u.%u",
-				NIP6(address_to_register->sin6_addr),
-				port >> 8, port & 0xff);
+		snprintf(buf, sizeof(buf), "%p6.%u.%u",
+			 &address_to_register->sin6_addr,
+			 port >> 8, port & 0xff);
 	map->r_addr = buf;
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f24800f..9a6d0cf 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -168,7 +168,7 @@ static void ip_map_request(struct cache_detail *cd,
 				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
 				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
 	} else {
-		snprintf(text_addr, 40, NIP6_FMT, NIP6(im->m_addr));
+		snprintf(text_addr, 40, "%p6", &im->m_addr);
 	}
 	qword_add(bpp, blen, im->m_class);
 	qword_add(bpp, blen, text_addr);
@@ -286,8 +286,7 @@ static int ip_map_show(struct seq_file *m,
 			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
 			dom);
 	} else {
-		seq_printf(m, "%s " NIP6_FMT " %s\n",
-			im->m_class, NIP6(addr), dom);
+		seq_printf(m, "%s %p6 %s\n", im->m_class, &addr, dom);
 	}
 	return 0;
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 59155ae..3498522 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -341,8 +341,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(40, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 40, NIP6_FMT,
-				NIP6(addr->sin6_addr));
+		snprintf(buf, 40, "%p6",&addr->sin6_addr);
 	}
 	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
 
@@ -357,8 +356,8 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(64, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 64, "addr="NIP6_FMT" port=%u proto=%s",
-				NIP6(addr->sin6_addr),
+		snprintf(buf, 64, "addr=%p6 port=%u proto=%s",
+				&addr->sin6_addr,
 				ntohs(addr->sin6_port),
 				protocol);
 	}
@@ -379,10 +378,10 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(50, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 50, NIP6_FMT".%u.%u",
-				NIP6(addr->sin6_addr),
-				ntohs(addr->sin6_port) >> 8,
-				ntohs(addr->sin6_port) & 0xff);
+		snprintf(buf, 50, "%p6.%u.%u",
+			 &addr->sin6_addr,
+			 ntohs(addr->sin6_port) >> 8,
+			 ntohs(addr->sin6_port) & 0xff);
 	}
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
 
@@ -1408,8 +1407,8 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
-	dprintk("RPC:       xs_bind6 "NIP6_FMT":%u: %s (%d)\n",
-		NIP6(myaddr.sin6_addr), port, err ? "failed" : "ok", err);
+	dprintk("RPC:       xs_bind6 %p6:%u: %s (%d)\n",
+		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
 	return err;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 832b47c..f052b06 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2467,13 +2467,11 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 					 sel->prefixlen_d);
 		break;
 	case AF_INET6:
-		audit_log_format(audit_buf, " src=" NIP6_FMT,
-				 NIP6(*(struct in6_addr *)sel->saddr.a6));
+		audit_log_format(audit_buf, " src=%p6", sel->saddr.a6);
 		if (sel->prefixlen_s != 128)
 			audit_log_format(audit_buf, " src_prefixlen=%d",
 					 sel->prefixlen_s);
-		audit_log_format(audit_buf, " dst=" NIP6_FMT,
-				 NIP6(*(struct in6_addr *)sel->daddr.a6));
+		audit_log_format(audit_buf, " dst=%p6", sel->daddr.a6);
 		if (sel->prefixlen_d != 128)
 			audit_log_format(audit_buf, " dst_prefixlen=%d",
 					 sel->prefixlen_d);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 508337f..7944861 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2115,10 +2115,8 @@ static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
 				 NIPQUAD(x->id.daddr.a4));
 		break;
 	case AF_INET6:
-		audit_log_format(audit_buf,
-				 " src=" NIP6_FMT " dst=" NIP6_FMT,
-				 NIP6(*(struct in6_addr *)x->props.saddr.a6),
-				 NIP6(*(struct in6_addr *)x->id.daddr.a6));
+		audit_log_format(audit_buf, " src=%p6 dst=%p6",
+				 x->props.saddr.a6, x->id.daddr.a6);
 		break;
 	}
 
@@ -2142,10 +2140,8 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 	case AF_INET6:
 		iph6 = ipv6_hdr(skb);
 		audit_log_format(audit_buf,
-				 " src=" NIP6_FMT " dst=" NIP6_FMT
-				 " flowlbl=0x%x%02x%02x",
-				 NIP6(iph6->saddr),
-				 NIP6(iph6->daddr),
+				 " src=%p6 dst=%p6 flowlbl=0x%x%02x%02x",
+				 &iph6->saddr,&iph6->daddr,
 				 iph6->flow_lbl[0] & 0x0f,
 				 iph6->flow_lbl[1],
 				 iph6->flow_lbl[2]);
-- 
1.6.0.3.729.g6ea410

