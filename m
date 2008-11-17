From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] include/net net/ - csum_partial - remove unnecessary casts
Date: Mon, 17 Nov 2008 09:55:11 -0800
Message-ID: <1226944512-13310-2-git-send-email-joe@perches.com>
References: <1226944512-13310-1-git-send-email-joe@perches.com>
Cc: David Miller <davem@davemloft.net>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3348 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYKQRzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 12:55:03 -0500
In-Reply-To: <1226944512-13310-1-git-send-email-joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first argument to csum_partial is const void *
casts to char/u8 * are not necessary

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/checksum.h |    2 +-
 include/net/ip_vs.h    |    6 +++---
 net/core/netpoll.c     |    2 +-
 net/ipv4/inet_lro.c    |    4 ++--
 net/ipv4/tcp_ipv4.c    |    4 ++--
 net/ipv6/icmp.c        |    4 ++--
 net/ipv6/mcast.c       |    2 +-
 net/ipv6/ndisc.c       |    4 ++--
 net/ipv6/tcp_ipv6.c    |    6 +++---
 net/unix/af_unix.c     |    4 ++--
 10 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 07602b7..ba55d8b 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -98,7 +98,7 @@ static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
 {
 	__be32 diff[] = { ~from, to };
 
-	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
+	*sum = csum_fold(csum_partial(diff, sizeof(diff), ~csum_unfold(*sum)));
 }
 
 static inline void csum_replace2(__sum16 *sum, __be16 from, __be16 to)
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8f6abf4..ab9b003 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -913,7 +913,7 @@ static inline __wsum ip_vs_check_diff4(__be32 old, __be32 new, __wsum oldsum)
 {
 	__be32 diff[2] = { ~old, new };
 
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
+	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
@@ -923,7 +923,7 @@ static inline __wsum ip_vs_check_diff16(const __be32 *old, const __be32 *new,
 	__be32 diff[8] = { ~old[3], ~old[2], ~old[1], ~old[0],
 			    new[3],  new[2],  new[1],  new[0] };
 
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
+	return csum_partial(diff, sizeof(diff), oldsum);
 }
 #endif
 
@@ -931,7 +931,7 @@ static inline __wsum ip_vs_check_diff2(__be16 old, __be16 new, __wsum oldsum)
 {
 	__be16 diff[2] = { ~old, new };
 
-	return csum_partial((char *) diff, sizeof(diff), oldsum);
+	return csum_partial(diff, sizeof(diff), oldsum);
 }
 
 #endif /* __KERNEL__ */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 34f5d07..fc4e28e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -343,7 +343,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	udph->check = csum_tcpudp_magic(htonl(np->local_ip),
 					htonl(np->remote_ip),
 					udp_len, IPPROTO_UDP,
-					csum_partial((unsigned char *)udph, udp_len, 0));
+					csum_partial(udph, udp_len, 0));
 	if (udph->check == 0)
 		udph->check = CSUM_MANGLED_0;
 
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index cfd034a..6a667da 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -120,7 +120,7 @@ static void lro_update_tcp_ip_header(struct net_lro_desc *lro_desc)
 	iph->check = ip_fast_csum((u8 *)lro_desc->iph, iph->ihl);
 
 	tcph->check = 0;
-	tcp_hdr_csum = csum_partial((u8 *)tcph, TCP_HDR_LEN(tcph), 0);
+	tcp_hdr_csum = csum_partial(tcph, TCP_HDR_LEN(tcph), 0);
 	lro_desc->data_csum = csum_add(lro_desc->data_csum, tcp_hdr_csum);
 	tcph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
 					lro_desc->ip_tot_len -
@@ -135,7 +135,7 @@ static __wsum lro_tcp_data_csum(struct iphdr *iph, struct tcphdr *tcph, int len)
 	__wsum tcp_ps_hdr_csum;
 
 	tcp_csum = ~csum_unfold(tcph->check);
-	tcp_hdr_csum = csum_partial((u8 *)tcph, TCP_HDR_LEN(tcph), tcp_csum);
+	tcp_hdr_csum = csum_partial(tcph, TCP_HDR_LEN(tcph), tcp_csum);
 
 	tcp_ps_hdr_csum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
 					     len + TCP_HDR_LEN(tcph),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b2e3ab2..5559fea 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -492,7 +492,7 @@ void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
 		th->check = tcp_v4_check(len, inet->saddr, inet->daddr,
-					 csum_partial((char *)th,
+					 csum_partial(th,
 						      th->doff << 2,
 						      skb->csum));
 	}
@@ -726,7 +726,7 @@ static int __tcp_v4_send_synack(struct sock *sk, struct request_sock *req,
 		th->check = tcp_v4_check(skb->len,
 					 ireq->loc_addr,
 					 ireq->rmt_addr,
-					 csum_partial((char *)th, skb->len,
+					 csum_partial(th, skb->len,
 						      skb->csum));
 
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index be35100..a77b8d1 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -233,7 +233,7 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 	icmp6h->icmp6_cksum = 0;
 
 	if (skb_queue_len(&sk->sk_write_queue) == 1) {
-		skb->csum = csum_partial((char *)icmp6h,
+		skb->csum = csum_partial(icmp6h,
 					sizeof(struct icmp6hdr), skb->csum);
 		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
 						      &fl->fl6_dst,
@@ -246,7 +246,7 @@ static int icmpv6_push_pending_frames(struct sock *sk, struct flowi *fl, struct
 			tmp_csum = csum_add(tmp_csum, skb->csum);
 		}
 
-		tmp_csum = csum_partial((char *)icmp6h,
+		tmp_csum = csum_partial(icmp6h,
 					sizeof(struct icmp6hdr), tmp_csum);
 		icmp6h->icmp6_cksum = csum_ipv6_magic(&fl->fl6_src,
 						      &fl->fl6_dst,
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a76199e..870a1d6 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1817,7 +1817,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, snd_addr, len,
 					   IPPROTO_ICMPV6,
-					   csum_partial((__u8 *) hdr, len, 0));
+					   csum_partial(hdr, len, 0));
 
 	idev = in6_dev_get(skb->dev);
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index fbf451c..af6705f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -491,7 +491,7 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, len,
 					   IPPROTO_ICMPV6,
-					   csum_partial((__u8 *) hdr,
+					   csum_partial(hdr,
 							len, 0));
 
 	return skb;
@@ -1612,7 +1612,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	icmph->icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
 					     len, IPPROTO_ICMPV6,
-					     csum_partial((u8 *) icmph, len, 0));
+					     csum_partial(icmph, len, 0));
 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b357870..a5d750a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -501,7 +501,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 
 		th->check = tcp_v6_check(th, skb->len,
 					 &treq->loc_addr, &treq->rmt_addr,
-					 csum_partial((char *)th, skb->len, skb->csum));
+					 csum_partial(th, skb->len, skb->csum));
 
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt, 0);
@@ -915,7 +915,7 @@ static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
 		th->check = csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,
-					    csum_partial((char *)th, th->doff<<2,
+					    csum_partial(th, th->doff<<2,
 							 skb->csum));
 	}
 }
@@ -997,7 +997,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	}
 #endif
 
-	buff->csum = csum_partial((char *)t1, tot_len, 0);
+	buff->csum = csum_partial(t1, tot_len, 0);
 
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a1eb596..c10ceee 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -216,7 +216,7 @@ static int unix_mkname(struct sockaddr_un *sunaddr, int len, unsigned *hashp)
 		return len;
 	}
 
-	*hashp = unix_hash_fold(csum_partial((char *)sunaddr, len, 0));
+	*hashp = unix_hash_fold(csum_partial(sunaddr, len, 0));
 	return len;
 }
 
@@ -682,7 +682,7 @@ static int unix_autobind(struct socket *sock)
 
 retry:
 	addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);
-	addr->hash = unix_hash_fold(csum_partial((void *)addr->name, addr->len, 0));
+	addr->hash = unix_hash_fold(csum_partial(addr->name, addr->len, 0));
 
 	spin_lock(&unix_table_lock);
 	ordernum = (ordernum+1)&0xFFFFF;
-- 
1.6.0.2

