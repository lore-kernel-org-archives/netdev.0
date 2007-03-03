From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] udp: whitespace fixes
Date: Fri, 2 Mar 2007 16:47:19 -0800
Message-ID: <20070302164719.6dfc78c1@freekitty>
References: <20070302140449.1e86aef4@freekitty>
	<20070302.155527.85408614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50214 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992813AbXCCAr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 19:47:26 -0500
In-Reply-To: <20070302.155527.85408614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resend with less garbage...

The udp code is full of bad indenting, extra whitespace and other
style confusion.  It makes no sense to declare functions that are used
outside the current file (extern) as inline.

Signed-off-by: Stephen Hemminger <shemminge@linux-foundation.org>
---
 net/ipv4/udp.c |  312 +++++++++++++++++++++++++++------------------------------
 net/ipv6/udp.c |  153 +++++++++++++++------------
 2 files changed, 236 insertions(+), 229 deletions(-)

--- tcp-2.6.orig/net/ipv4/udp.c	2007-03-02 16:25:12.000000000 -0800
+++ tcp-2.6/net/ipv4/udp.c	2007-03-02 16:41:04.000000000 -0800
@@ -136,13 +136,13 @@
  */
 int __udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       struct hlist_head udptable[], int *port_rover,
-		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2 )    )
+		       int (*saddr_comp)(const struct sock * sk1,
+					 const struct sock * sk2))
 {
 	struct hlist_node *node;
 	struct hlist_head *head;
 	struct sock *sk2;
-	int    error = 1;
+	int error = 1;
 
 	write_lock_bh(&udp_hash_lock);
 	if (snum == 0) {
@@ -160,7 +160,8 @@
 			if (hlist_empty(head)) {
 				if (result > sysctl_local_port_range[1])
 					result = sysctl_local_port_range[0] +
-						((result - sysctl_local_port_range[0]) &
+						((result -
+						  sysctl_local_port_range[0]) &
 						 (UDP_HTABLE_SIZE - 1));
 				goto gotit;
 			}
@@ -175,12 +176,13 @@
 			;
 		}
 		result = best;
-		for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result += UDP_HTABLE_SIZE) {
+		for (i = 0; i < (1 << 16) / UDP_HTABLE_SIZE;
+		     i++, result += UDP_HTABLE_SIZE) {
 			if (result > sysctl_local_port_range[1])
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
 					   (UDP_HTABLE_SIZE - 1));
-			if (! __udp_lib_lport_inuse(result, udptable))
+			if (!__udp_lib_lport_inuse(result, udptable))
 				break;
 		}
 		if (i >= (1 << 16) / UDP_HTABLE_SIZE)
@@ -194,9 +196,8 @@
 			if (sk2->sk_hash == snum                             &&
 			    sk2 != sk                                        &&
 			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
-			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
-			    (*saddr_comp)(sk, sk2)                             )
+			    (*saddr_comp)(sk, sk2))
 				goto fail;
 	}
 	inet_sk(sk)->num = snum;
@@ -212,19 +213,19 @@
 	return error;
 }
 
-__inline__ int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *))
+int udp_get_port(struct sock *sk, unsigned short snum,
+		 int (*scmp)(const struct sock *, const struct sock *))
 {
-	return  __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
+	return __udp_lib_get_port(sk, snum, udp_hash, &udp_port_rover, scmp);
 }
 
-inline int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
-	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
+	const struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
-	return 	( !ipv6_only_sock(sk2)  &&
-		  (!inet1->rcv_saddr || !inet2->rcv_saddr ||
-		   inet1->rcv_saddr == inet2->rcv_saddr      ));
+	return !ipv6_only_sock(sk2) &&
+		(!inet1->rcv_saddr || !inet2->rcv_saddr ||
+		 inet1->rcv_saddr == inet2->rcv_saddr);
 }
 
 static inline int udp_v4_get_port(struct sock *sk, unsigned short snum)
@@ -253,27 +254,27 @@
 			if (inet->rcv_saddr) {
 				if (inet->rcv_saddr != daddr)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (inet->daddr) {
 				if (inet->daddr != saddr)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (inet->dport) {
 				if (inet->dport != sport)
 					continue;
-				score+=2;
+				score += 2;
 			}
 			if (sk->sk_bound_dev_if) {
 				if (sk->sk_bound_dev_if != dif)
 					continue;
-				score+=2;
+				score += 2;
 			}
-			if(score == 9) {
+			if (score == 9) {
 				result = sk;
 				break;
-			} else if(score > badness) {
+			} else if (score > badness) {
 				result = sk;
 				badness = score;
 			}
@@ -327,8 +328,8 @@
 void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 {
 	struct inet_sock *inet;
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	struct udphdr *uh = (struct udphdr*)(skb->data+(iph->ihl<<2));
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct udphdr *uh = (struct udphdr *)(skb->data + (iph->ihl << 2));
 	int type = skb->h.icmph->type;
 	int code = skb->h.icmph->code;
 	struct sock *sk;
@@ -336,10 +337,10 @@
 	int err;
 
 	sk = __udp4_lib_lookup(iph->daddr, uh->dest, iph->saddr, uh->source,
-			       skb->dev->ifindex, udptable		    );
+			       skb->dev->ifindex, udptable);
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(ICMP_MIB_INERRORS);
-		return;	/* No socket for error */
+		return;		/* No socket for error */
 	}
 
 	err = 0;
@@ -382,7 +383,7 @@
 		if (!harderr || sk->sk_state != TCP_ESTABLISHED)
 			goto out;
 	} else {
-		ip_icmp_error(sk, skb, err, uh->dest, info, (u8*)(uh+1));
+		ip_icmp_error(sk, skb, err, uh->dest, info, (u8 *)(uh + 1));
 	}
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
@@ -390,7 +391,7 @@
 	sock_put(sk);
 }
 
-__inline__ void udp_err(struct sk_buff *skb, u32 info)
+void udp_err(struct sk_buff *skb, u32 info)
 {
 	return __udp4_lib_err(skb, info, udp_hash);
 }
@@ -416,7 +417,7 @@
  * 	        (checksum field must be zeroed out)
  */
 static void udp4_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
-				 __be32 src, __be32 dst, int len      )
+				 __be32 src, __be32 dst, int len)
 {
 	unsigned int offset;
 	struct udphdr *uh = skb->h.uh;
@@ -454,7 +455,7 @@
  */
 static int udp_push_pending_frames(struct sock *sk)
 {
-	struct udp_sock  *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	struct sk_buff *skb;
@@ -475,17 +476,15 @@
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (up->pcflag)  				 /*     UDP-Lite      */
-		csum  = udplite_csum_outgoing(sk, skb);
+	if (up->pcflag)					 /*     UDP-Lite      */
+		csum = udplite_csum_outgoing(sk, skb);
 
 	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {   /* UDP csum disabled */
-
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
-
-		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src,fl->fl4_dst, up->len);
+		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src, fl->fl4_dst, up->len);
 		goto send;
 
 	} else						 /*   `normal' UDP    */
@@ -493,7 +492,7 @@
 
 	/* add protocol-dependent pseudo-header */
 	uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, up->len,
-				      sk->sk_protocol, csum             );
+				      sk->sk_protocol, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
@@ -517,9 +516,9 @@
 	int connected = 0;
 	__be32 daddr, faddr, saddr;
 	__be16 dport;
-	u8  tos;
+	u8 tos;
 	int err, is_udplite = up->pcflag;
-	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
+	int corkreq = up->corkflag || msg->msg_flags & MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	if (len > 0xFFFF)
@@ -529,7 +528,7 @@
 	 *	Check the flags.
 	 */
 
-	if (msg->msg_flags&MSG_OOB)	/* Mirror BSD error message compatibility */
+	if (msg->msg_flags & MSG_OOB)	/* Mirror BSD error message compatibility */
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
@@ -555,7 +554,7 @@
 	 *	Get and verify the address.
 	 */
 	if (msg->msg_name) {
-		struct sockaddr_in * usin = (struct sockaddr_in*)msg->msg_name;
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET) {
@@ -617,18 +616,17 @@
 	}
 
 	if (connected)
-		rt = (struct rtable*)sk_dst_check(sk, 0);
+		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		struct flowi fl = { .oif = ipc.oif,
-				    .nl_u = { .ip4_u =
-					      { .daddr = faddr,
-						.saddr = saddr,
-						.tos = tos } },
-				    .proto = sk->sk_protocol,
-				    .uli_u = { .ports =
-					       { .sport = inet->sport,
-						 .dport = dport } } };
+		struct flowi fl = {.oif = ipc.oif,
+			.nl_u = {.ip4_u = {.daddr = faddr,
+					   .saddr = saddr,
+					   .tos = tos}},
+			.proto = sk->sk_protocol,
+			.uli_u = {.ports = {.sport = inet->sport,
+					    .dport = dport}}
+		};
 		security_sk_classify_flow(sk, &fl);
 		err = ip_route_output_flow(&rt, &fl, sk, 1);
 		if (err)
@@ -642,7 +640,7 @@
 			sk_dst_set(sk, dst_clone(&rt->u.dst));
 	}
 
-	if (msg->msg_flags&MSG_CONFIRM)
+	if (msg->msg_flags & MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
 
@@ -671,10 +669,11 @@
 
 do_append_data:
 	up->len += ulen;
-	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
+	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
 	err = ip_append_data(sk, getfrag, msg->msg_iov, ulen,
-			sizeof(struct udphdr), &ipc, rt,
-			corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+			     sizeof(struct udphdr), &ipc, rt,
+			     corkreq ? msg->msg_flags | MSG_MORE : msg->
+			     msg_flags);
 	if (err)
 		udp_flush_pending_frames(sk);
 	else if (!corkreq)
@@ -705,7 +704,7 @@
 
 do_confirm:
 	dst_confirm(&rt->u.dst);
-	if (!(msg->msg_flags&MSG_PROBE) || len)
+	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
 	goto out;
@@ -718,7 +717,7 @@
 	int ret;
 
 	if (!up->pending) {
-		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };
+		struct msghdr msg = {.msg_flags = flags | MSG_MORE };
 
 		/* Call udp_sendmsg to specify destination address which
 		 * sendpage interface can't pass.
@@ -750,7 +749,7 @@
 	}
 
 	up->len += size;
-	if (!(up->corkflag || (flags&MSG_MORE)))
+	if (!(up->corkflag || (flags & MSG_MORE)))
 		ret = udp_push_pending_frames(sk);
 	if (!ret)
 		ret = size;
@@ -765,15 +764,14 @@
 
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
-	switch(cmd)
-	{
-		case SIOCOUTQ:
+	switch (cmd) {
+	case SIOCOUTQ:
 		{
 			int amount = atomic_read(&sk->sk_wmem_alloc);
 			return put_user(amount, (int __user *)arg);
 		}
 
-		case SIOCINQ:
+	case SIOCINQ:
 		{
 			struct sk_buff *skb;
 			unsigned long amount;
@@ -793,10 +791,10 @@
 			return put_user(amount, (int __user *)arg);
 		}
 
-		default:
-			return -ENOIOCTLCMD;
+	default:
+		return -ENOIOCTLCMD;
 	}
-	return(0);
+	return 0;
 }
 
 /*
@@ -816,7 +814,7 @@
 	 *	Check any passed addresses
 	 */
 	if (addr_len)
-		*addr_len=sizeof(*sin);
+		*addr_len = sizeof(*sin);
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len);
@@ -839,9 +837,9 @@
 	 * 	          (re-)compute it if message is truncated.
 	 * 	UDP-Lite: always needs to checksum, no HW support.
 	 */
-	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
+	copy_only = (skb->ip_summed == CHECKSUM_UNNECESSARY);
 
-	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
+	if (is_udplite || (!copy_only && msg->msg_flags & MSG_TRUNC)) {
 		if (__udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
 		copy_only = 1;
@@ -849,10 +847,10 @@
 
 	if (copy_only)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied       );
+					      msg->msg_iov, copied);
 	else {
-		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
-
+		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr),
+						       msg->msg_iov);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
@@ -863,13 +861,13 @@
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
-	if (sin)
-	{
+	if (sin) {
 		sin->sin_family = AF_INET;
 		sin->sin_port = skb->h.uh->source;
 		sin->sin_addr.s_addr = skb->nh.iph->saddr;
 		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
 	}
+
 	if (inet->cmsg_flags)
 		ip_cmsg_recv(msg, skb);
 
@@ -892,7 +890,6 @@
 	goto try_again;
 }
 
-
 int udp_disconnect(struct sock *sk, int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -920,7 +917,7 @@
  *	0  if we should drop this packet
  * 	-1 if it should get processed by xfrm4_rcv_encap
  */
-static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
+static int udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 {
 #ifndef CONFIG_XFRM
 	return 1;
@@ -959,7 +956,7 @@
 		/* Check if this is a keepalive packet.  If so, eat it. */
 		if (len == 1 && udpdata[0] == 0xff) {
 			return 0;
-		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0 ) {
+		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0) {
 			/* ESP Packet without Non-ESP header */
 			len = sizeof(struct udphdr);
 		} else
@@ -1020,7 +1017,7 @@
  * Note that in the success and error cases, the skb is assumed to
  * have either been requeued or freed.
  */
-int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
@@ -1062,7 +1059,7 @@
 	/*
 	 * 	UDP-Lite specific tests, ignored on UDP sockets
 	 */
-	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+	if ((up->pcflag & UDPLITE_RECV_CC) && UDP_SKB_CB(skb)->partial_cov) {
 
 		/*
 		 * MIB statistics other than incrementing the error count are
@@ -1077,8 +1074,8 @@
 		 */
 		if (up->pcrlen == 0) {          /* full coverage was set  */
 			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE: partial coverage "
-				"%d while full coverage %d requested\n",
-				UDP_SKB_CB(skb)->cscov, skb->len);
+				       "%d while full coverage %d requested\n",
+				       UDP_SKB_CB(skb)->cscov, skb->len);
 			goto drop;
 		}
 		/* The next case involves violating the min. coverage requested
@@ -1087,10 +1084,10 @@
 		 * that it wants x while sender emits packets of smaller size y.
 		 * Therefore the above ...()->partial_cov statement is essential.
 		 */
-		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
+		if (UDP_SKB_CB(skb)->cscov < up->pcrlen) {
 			LIMIT_NETDEBUG(KERN_WARNING
-				"UDPLITE: coverage %d too small, need min %d\n",
-				UDP_SKB_CB(skb)->cscov, up->pcrlen);
+				       "UDPLITE: coverage %d too small, need min %d\n",
+				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
 			goto drop;
 		}
 	}
@@ -1101,7 +1098,7 @@
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
 			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
@@ -1124,7 +1121,7 @@
  *	so we don't need to lock the hashes.
  */
 static int __udp4_lib_mcast_deliver(struct sk_buff *skb,
-				    struct udphdr  *uh,
+				    struct udphdr *uh,
 				    __be32 saddr, __be32 daddr,
 				    struct hlist_head udptable[])
 {
@@ -1143,10 +1140,10 @@
 
 			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
 						   uh->source, saddr, dif);
-			if(sknext)
+			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
-			if(skb1) {
+			if (skb1) {
 				int ret = udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
 					/* we should probably re-process instead
@@ -1154,7 +1151,7 @@
 					kfree_skb(skb1);
 			}
 			sk = sknext;
-		} while(sknext);
+		} while (sknext);
 	} else
 		kfree_skb(skb);
 	read_unlock(&udp_hash_lock);
@@ -1171,8 +1168,8 @@
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
-	       if (!csum_tcpudp_magic(skb->nh.iph->saddr, skb->nh.iph->daddr,
-				      skb->len, IPPROTO_UDP, skb->csum       ))
+		if (!csum_tcpudp_magic(skb->nh.iph->saddr, skb->nh.iph->daddr,
+				       skb->len, IPPROTO_UDP, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -1197,7 +1194,7 @@
 	struct sock *sk;
 	struct udphdr *uh = skb->h.uh;
 	unsigned short ulen;
-	struct rtable *rt = (struct rtable*)skb->dst;
+	struct rtable *rt = (struct rtable *)skb->dst;
 	__be32 saddr = skb->nh.iph->saddr;
 	__be32 daddr = skb->nh.iph->daddr;
 
@@ -1211,23 +1208,23 @@
 	if (ulen > skb->len)
 		goto short_packet;
 
-	if(! is_udplite ) {		/* UDP validates ulen. */
-
+	if (!is_udplite) {		/* UDP validates ulen. */
 		if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
 			goto short_packet;
 
 		udp4_csum_init(skb, uh);
 
-	} else 	{			/* UDP-Lite validates cscov. */
+	} else {		/* UDP-Lite validates cscov. */
 		if (udplite4_csum_init(skb, uh))
 			goto csum_error;
 	}
 
-	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
+	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr,
+						udptable);
 
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
+			       skb->dev->ifindex, udptable);
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
@@ -1257,16 +1254,13 @@
 	 * don't wanna listen.  Ignore it.
 	 */
 	kfree_skb(skb);
-	return(0);
+	return 0;
 
 short_packet:
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
-		       is_udplite? "-Lite" : "",
-		       NIPQUAD(saddr),
-		       ntohs(uh->source),
-		       ulen,
-		       skb->len,
-		       NIPQUAD(daddr),
+	LIMIT_NETDEBUG(KERN_DEBUG
+		       "UDP%s: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
+		       is_udplite ? "-Lite" : "", NIPQUAD(saddr),
+		       ntohs(uh->source), ulen, skb->len, NIPQUAD(daddr),
 		       ntohs(uh->dest));
 	goto drop;
 
@@ -1275,20 +1269,18 @@
 	 * RFC1122: OK.  Discards the bad packet silently (as far as
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
 	 */
-	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %d.%d.%d.%d:%d to %d.%d.%d.%d:%d ulen %d\n",
-		       is_udplite? "-Lite" : "",
-		       NIPQUAD(saddr),
-		       ntohs(uh->source),
-		       NIPQUAD(daddr),
-		       ntohs(uh->dest),
+	LIMIT_NETDEBUG(KERN_DEBUG
+		       "UDP%s: bad checksum. From %d.%d.%d.%d:%d to %d.%d.%d.%d:%d ulen %d\n",
+		       is_udplite ? "-Lite" : "", NIPQUAD(saddr),
+		       ntohs(uh->source), NIPQUAD(daddr), ntohs(uh->dest),
 		       ulen);
 drop:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
-	return(0);
+	return 0;
 }
 
-__inline__ int udp_rcv(struct sk_buff *skb)
+int udp_rcv(struct sk_buff *skb)
 {
 	return __udp4_lib_rcv(skb, udp_hash, 0);
 }
@@ -1305,20 +1297,20 @@
  *	Socket option code for UDP
  */
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, int optlen,
+		       char __user * optval, int optlen,
 		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val;
 	int err = 0;
 
-	if(optlen<sizeof(int))
+	if (optlen < sizeof(int))
 		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
-	switch(optname) {
+	switch (optname) {
 	case UDP_CORK:
 		if (val != 0) {
 			up->corkflag = 1;
@@ -1343,27 +1335,27 @@
 		}
 		break;
 
-	/*
-	 * 	UDP-Lite's partial checksum coverage (RFC 3828).
-	 */
-	/* The sender sets actual checksum coverage length via this option.
-	 * The case coverage > packet length is handled by send module. */
+		/*
+		 *      UDP-Lite's partial checksum coverage (RFC 3828).
+		 */
+		/* The sender sets actual checksum coverage length via this option.
+		 * The case coverage > packet length is handled by send module. */
 	case UDPLITE_SEND_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
+		if (!up->pcflag)	/* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
+		if (val != 0 && val < 8)	/* Illegal coverage: use default (8) */
 			val = 8;
 		up->pcslen = val;
 		up->pcflag |= UDPLITE_SEND_CC;
 		break;
 
-	/* The receiver specifies a minimum checksum coverage value. To make
-	 * sense, this should be set to at least 8 (as done below). If zero is
-	 * used, this again means full checksum coverage.                     */
+		/* The receiver specifies a minimum checksum coverage value. To make
+		 * sense, this should be set to at least 8 (as done below). If zero is
+		 * used, this again means full checksum coverage.                     */
 	case UDPLITE_RECV_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
+		if (!up->pcflag)	/* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
-		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
+		if (val != 0 && val < 8)	/* Avoid silly minimal values.       */
 			val = 8;
 		up->pcrlen = val;
 		up->pcflag |= UDPLITE_RECV_CC;
@@ -1372,15 +1364,15 @@
 	default:
 		err = -ENOPROTOOPT;
 		break;
-	};
+	}
 
 	return err;
 }
 
 int udp_setsockopt(struct sock *sk, int level, int optname,
-		   char __user *optval, int optlen)
+		   char __user * optval, int optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
 					  udp_push_pending_frames);
 	return ip_setsockopt(sk, level, optname, optval, optlen);
@@ -1388,9 +1380,9 @@
 
 #ifdef CONFIG_COMPAT
 int compat_udp_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+			  char __user * optval, int optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
 					  udp_push_pending_frames);
 	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
@@ -1398,20 +1390,20 @@
 #endif
 
 int udp_lib_getsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, int __user *optlen)
+		       char __user * optval, int __user * optlen)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
-	if(get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	len = min_t(unsigned int, len, sizeof(int));
 
-	if(len < 0)
+	if (len < 0)
 		return -EINVAL;
 
-	switch(optname) {
+	switch (optname) {
 	case UDP_CORK:
 		val = up->corkflag;
 		break;
@@ -1420,8 +1412,8 @@
 		val = up->encap_type;
 		break;
 
-	/* The following two cannot be changed on UDP sockets, the return is
-	 * always 0 (which corresponds to the full checksum coverage of UDP). */
+		/* The following two cannot be changed on UDP sockets, the return is
+		 * always 0 (which corresponds to the full checksum coverage of UDP). */
 	case UDPLITE_SEND_CSCOV:
 		val = up->pcslen;
 		break;
@@ -1432,28 +1424,28 @@
 
 	default:
 		return -ENOPROTOOPT;
-	};
+	}
 
-	if(put_user(len, optlen))
+	if (put_user(len, optlen))
 		return -EFAULT;
-	if(copy_to_user(optval, &val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
 
 int udp_getsockopt(struct sock *sk, int level, int optname,
-		   char __user *optval, int __user *optlen)
+		   char __user * optval, int __user * optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return ip_getsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 int compat_udp_getsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, int __user *optlen)
+			  char __user * optval, int __user * optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return compat_ip_getsockopt(sk, level, optname, optval, optlen);
 }
@@ -1471,16 +1463,16 @@
  *	but then block when reading it. Add special case code
  *	to work around these arguably broken applications.
  */
-unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
+unsigned int udp_poll(struct file *file, struct socket *sock, poll_table * wait)
 {
 	unsigned int mask = datagram_poll(file, sock, wait);
 	struct sock *sk = sock->sk;
-	int 	is_lite = IS_UDPLITE(sk);
+	int is_lite = IS_UDPLITE(sk);
 
 	/* Check for false positives due to checksum errors */
-	if ( (mask & POLLRDNORM) &&
-	     !(file->f_flags & O_NONBLOCK) &&
-	     !(sk->sk_shutdown & RCV_SHUTDOWN)){
+	if ((mask & POLLRDNORM) &&
+	    !(file->f_flags & O_NONBLOCK) &&
+	    !(sk->sk_shutdown & RCV_SHUTDOWN)) {
 		struct sk_buff_head *rcvq = &sk->sk_receive_queue;
 		struct sk_buff *skb;
 
@@ -1538,7 +1530,8 @@
 	struct sock *sk;
 	struct udp_iter_state *state = seq->private;
 
-	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
+	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE;
+	     ++state->bucket) {
 		struct hlist_node *node;
 		sk_for_each(sk, node, state->hashtable + state->bucket) {
 			if (sk->sk_family == state->family)
@@ -1572,22 +1565,22 @@
 	struct sock *sk = udp_get_first(seq);
 
 	if (sk)
-		while(pos && (sk = udp_get_next(seq, sk)) != NULL)
+		while (pos && (sk = udp_get_next(seq, sk)) != NULL)
 			--pos;
 	return pos ? NULL : sk;
 }
 
-static void *udp_seq_start(struct seq_file *seq, loff_t *pos)
+static void *udp_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	read_lock(&udp_hash_lock);
-	return *pos ? udp_get_idx(seq, *pos-1) : (void *)1;
+	return *pos ? udp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
-static void *udp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *udp_seq_next(struct seq_file *seq, void *v, loff_t * pos)
 {
 	struct sock *sk;
 
-	if (v == (void *)1)
+	if (v == SEQ_START_TOKEN)
 		sk = udp_get_idx(seq, 0);
 	else
 		sk = udp_get_next(seq, v);
@@ -1621,7 +1614,7 @@
 	if (rc)
 		goto out_kfree;
 
-	seq	     = file->private_data;
+	seq = file->private_data;
 	seq->private = s;
 out:
 	return rc;
@@ -1638,6 +1631,7 @@
 
 	if (!afinfo)
 		return -EINVAL;
+
 	afinfo->seq_fops->owner		= afinfo->owner;
 	afinfo->seq_fops->open		= udp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
@@ -1666,8 +1660,8 @@
 	struct inet_sock *inet = inet_sk(sp);
 	__be32 dest = inet->daddr;
 	__be32 src  = inet->rcv_saddr;
-	__u16 destp	  = ntohs(inet->dport);
-	__u16 srcp	  = ntohs(inet->sport);
+	__u16 dest  = ntohs(inet->dport);
+	__u16 srcp  = ntohs(inet->sport);
 
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p",
--- tcp-2.6.orig/net/ipv6/udp.c	2007-03-02 16:25:12.000000000 -0800
+++ tcp-2.6/net/ipv6/udp.c	2007-03-02 16:45:12.000000000 -0800
@@ -93,10 +93,10 @@
 					continue;
 				score++;
 			}
-			if(score == 4) {
+			if (score == 4) {
 				result = sk;
 				break;
-			} else if(score > badness) {
+			} else if (score > badness) {
 				result = sk;
 				badness = score;
 			}
@@ -124,7 +124,7 @@
 	int err, copy_only, is_udplite = IS_UDPLITE(sk);
 
 	if (addr_len)
-		*addr_len=sizeof(struct sockaddr_in6);
+		*addr_len = sizeof(struct sockaddr_in6);
 
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len);
@@ -141,11 +141,11 @@
 	}
 
 	/*
-	 * 	Decide whether to checksum and/or copy data.
+	 *      Decide whether to checksum and/or copy data.
 	 */
-	copy_only = (skb->ip_summed==CHECKSUM_UNNECESSARY);
+	copy_only = (skb->ip_summed == CHECKSUM_UNNECESSARY);
 
-	if (is_udplite  ||  (!copy_only  &&  msg->msg_flags&MSG_TRUNC)) {
+	if (is_udplite || (!copy_only && msg->msg_flags & MSG_TRUNC)) {
 		if (__udp_lib_checksum_complete(skb))
 			goto csum_copy_err;
 		copy_only = 1;
@@ -153,12 +153,15 @@
 
 	if (copy_only)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied       );
+					      msg->msg_iov, copied);
 	else {
-		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
+		err =
+		    skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr),
+						     msg->msg_iov);
 		if (err == -EINVAL)
 			goto csum_copy_err;
 	}
+
 	if (err)
 		goto out_free;
 
@@ -168,7 +171,7 @@
 	if (msg->msg_name) {
 		struct sockaddr_in6 *sin6;
 
-		sin6 = (struct sockaddr_in6 *) msg->msg_name;
+		sin6 = (struct sockaddr_in6 *)msg->msg_name;
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = skb->h.uh->source;
 		sin6->sin6_flowinfo = 0;
@@ -179,11 +182,13 @@
 				      htonl(0xffff), skb->nh.iph->saddr);
 		else {
 			ipv6_addr_copy(&sin6->sin6_addr, &skb->nh.ipv6h->saddr);
-			if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+			if (ipv6_addr_type(&sin6->sin6_addr) &
+			    IPV6_ADDR_LINKLOCAL)
 				sin6->sin6_scope_id = IP6CB(skb)->iif;
 		}
 
 	}
+
 	if (skb->protocol == htons(ETH_P_IP)) {
 		if (inet->cmsg_flags)
 			ip_cmsg_recv(msg, skb);
@@ -213,13 +218,13 @@
 
 void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    int type, int code, int offset, __be32 info,
-		    struct hlist_head udptable[]                    )
+		    struct hlist_head udptable[])
 {
 	struct ipv6_pinfo *np;
-	struct ipv6hdr *hdr = (struct ipv6hdr*)skb->data;
+	struct ipv6hdr *hdr = (struct ipv6hdr *)skb->data;
 	struct in6_addr *saddr = &hdr->saddr;
 	struct in6_addr *daddr = &hdr->daddr;
-	struct udphdr *uh = (struct udphdr*)(skb->data+offset);
+	struct udphdr *uh = (struct udphdr *)(skb->data + offset);
 	struct sock *sk;
 	int err;
 
@@ -237,7 +242,8 @@
 		goto out;
 
 	if (np->recverr)
-		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info), (u8 *)(uh+1));
+		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info),
+				(u8 *)(uh + 1));
 
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
@@ -245,14 +251,14 @@
 	sock_put(sk);
 }
 
-static __inline__ void udpv6_err(struct sk_buff *skb,
-				 struct inet6_skb_parm *opt, int type,
-				 int code, int offset, __be32 info     )
+static void udpv6_err(struct sk_buff *skb,
+		      struct inet6_skb_parm *opt, int type,
+		      int code, int offset, __be32 info)
 {
 	return __udp6_lib_err(skb, opt, type, code, offset, info, udp_hash);
 }
 
-int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
@@ -263,17 +269,17 @@
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
-	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+	if ((up->pcflag & UDPLITE_RECV_CC) && UDP_SKB_CB(skb)->partial_cov) {
 
-		if (up->pcrlen == 0) {          /* full coverage was set  */
+		if (up->pcrlen == 0) {	/* full coverage was set  */
 			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: partial coverage"
-				" %d while full coverage %d requested\n",
-				UDP_SKB_CB(skb)->cscov, skb->len);
+				       " %d while full coverage %d requested\n",
+				       UDP_SKB_CB(skb)->cscov, skb->len);
 			goto drop;
 		}
-		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
+		if (UDP_SKB_CB(skb)->cscov < up->pcrlen) {
 			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: coverage %d "
-						    "too small, need min %d\n",
+				       "too small, need min %d\n",
 				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
 			goto drop;
 		}
@@ -282,7 +288,7 @@
 	if (udp_lib_checksum_complete(skb))
 		goto drop;
 
-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
 			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
@@ -325,7 +331,7 @@
 				if (!ipv6_addr_equal(&np->rcv_saddr, loc_addr))
 					continue;
 			}
-			if(!inet6_mc_check(s, loc_addr, rmt_addr))
+			if (!inet6_mc_check(s, loc_addr, rmt_addr))
 				continue;
 			return s;
 		}
@@ -338,7 +344,8 @@
  * so we don't need to lock the hashes.
  */
 static int __udp6_lib_mcast_deliver(struct sk_buff *skb, struct in6_addr *saddr,
-			   struct in6_addr *daddr, struct hlist_head udptable[])
+				    struct in6_addr *daddr,
+				    struct hlist_head udptable[])
 {
 	struct sock *sk, *sk2;
 	const struct udphdr *uh = skb->h.uh;
@@ -367,7 +374,6 @@
 }
 
 static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh)
-
 {
 	if (uh->check == 0) {
 		/* RFC 2460 section 8.1 says that we SHOULD log
@@ -376,9 +382,10 @@
 		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
 		return 1;
 	}
+
 	if (skb->ip_summed == CHECKSUM_COMPLETE &&
 	    !csum_ipv6_magic(&skb->nh.ipv6h->saddr, &skb->nh.ipv6h->daddr,
-			     skb->len, IPPROTO_UDP, skb->csum             ))
+			     skb->len, IPPROTO_UDP, skb->csum))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (skb->ip_summed != CHECKSUM_UNNECESSARY)
@@ -386,8 +393,8 @@
 							 &skb->nh.ipv6h->daddr,
 							 skb->len, IPPROTO_UDP,
 							 0));
-
-	return (UDP_SKB_CB(skb)->partial_cov = 0);
+	UDP_SKB_CB(skb)->partial_cov = 0;
+	return 0;
 }
 
 int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
@@ -411,7 +418,7 @@
 	if (ulen > skb->len)
 		goto short_packet;
 
-	if(! is_udplite ) {		/* UDP validates ulen. */
+	if (!is_udplite) {	/* UDP validates ulen. */
 
 		/* Check for jumbo payload */
 		if (ulen == 0)
@@ -431,7 +438,7 @@
 		if (udp6_csum_init(skb, uh))
 			goto discard;
 
-	} else 	{			/* UDP-Lite validates cscov. */
+	} else {		/* UDP-Lite validates cscov. */
 		if (udplite6_csum_init(skb, uh))
 			goto discard;
 	}
@@ -459,29 +466,30 @@
 			goto discard;
 		UDP6_INC_STATS_BH(UDP_MIB_NOPORTS, is_udplite);
 
-		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
+		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0,
+			    dev);
 
 		kfree_skb(skb);
-		return(0);
+		return 0;
 	}
 
 	/* deliver */
 
 	udpv6_queue_rcv_skb(sk, skb);
 	sock_put(sk);
-	return(0);
+	return 0;
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: %d/%u\n",
-		       is_udplite? "-Lite" : "",  ulen, skb->len);
+		       is_udplite ? "-Lite" : "", ulen, skb->len);
 
 discard:
 	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
-	return(0);
+	return 0;
 }
 
-static __inline__ int udpv6_rcv(struct sk_buff **pskb)
+static int udpv6_rcv(struct sk_buff **pskb)
 {
 	return __udp6_lib_rcv(pskb, udp_hash, 0);
 }
@@ -508,7 +516,7 @@
 {
 	struct sk_buff *skb;
 	struct udphdr *uh;
-	struct udp_sock  *up = udp_sk(sk);
+	struct udp_sock *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
@@ -529,12 +537,12 @@
 
 	if (up->pcflag)
 		csum = udplite_csum_outgoing(sk, skb);
-	 else
+	else
 		csum = udp_csum_outgoing(sk, skb);
 
 	/* add protocol-dependent pseudo-header */
 	uh->check = csum_ipv6_magic(&fl->fl6_src, &fl->fl6_dst,
-				    up->len, fl->proto, csum   );
+				    up->len, fl->proto, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
@@ -552,7 +560,7 @@
 	struct udp_sock *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)msg->msg_name;
 	struct in6_addr *daddr, *final_p = NULL, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
@@ -562,7 +570,7 @@
 	int ulen = len;
 	int hlimit = -1;
 	int tclass = -1;
-	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
+	int corkreq = up->corkflag || msg->msg_flags & MSG_MORE;
 	int err;
 	int connected = 0;
 	int is_udplite = up->pcflag;
@@ -571,7 +579,7 @@
 	/* destination address check */
 	if (sin6) {
 		if (addr_len < offsetof(struct sockaddr, sa_data))
-			return -EINVAL;
+			 return -EINVAL;
 
 		switch (sin6->sin6_family) {
 		case AF_INET6:
@@ -616,7 +624,7 @@
 
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_build_xmit
-	   */
+	 */
 	if (len > INT_MAX - sizeof(struct udphdr))
 		return -EMSGSIZE;
 
@@ -648,9 +656,11 @@
 		daddr = &sin6->sin6_addr;
 
 		if (np->sndflow) {
-			fl.fl6_flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
+			fl.fl6_flowlabel =
+			    sin6->sin6_flowinfo & IPV6_FLOWINFO_MASK;
+			if (fl.fl6_flowlabel & IPV6_FLOWLABEL_MASK) {
+				flowlabel =
+				    fl6_sock_lookup(sk, fl.fl6_flowlabel);
 				if (flowlabel == NULL)
 					return -EINVAL;
 				daddr = &flowlabel->dst;
@@ -667,7 +677,7 @@
 
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    sin6->sin6_scope_id &&
-		    ipv6_addr_type(daddr)&IPV6_ADDR_LINKLOCAL)
+		    ipv6_addr_type(daddr) & IPV6_ADDR_LINKLOCAL)
 			fl.oif = sin6->sin6_scope_id;
 	} else {
 		if (sk->sk_state != TCP_ESTABLISHED)
@@ -692,12 +702,12 @@
 			fl6_sock_release(flowlabel);
 			return err;
 		}
-		if ((fl.fl6_flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+		if ((fl.fl6_flowlabel & IPV6_FLOWLABEL_MASK) && !flowlabel) {
 			flowlabel = fl6_sock_lookup(sk, fl.fl6_flowlabel);
 			if (flowlabel == NULL)
 				return -EINVAL;
 		}
-		if (!(opt->opt_nflen|opt->opt_flen))
+		if (!(opt->opt_nflen | opt->opt_flen))
 			opt = NULL;
 		connected = 0;
 	}
@@ -715,7 +725,7 @@
 
 	/* merge ip6_build_xmit from ip6_output */
 	if (opt && opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) opt->srcrt;
+		struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
 		ipv6_addr_copy(&final, &fl.fl6_dst);
 		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
 		final_p = &final;
@@ -755,7 +765,7 @@
 			tclass = 0;
 	}
 
-	if (msg->msg_flags&MSG_CONFIRM)
+	if (msg->msg_flags & MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
 
@@ -774,11 +784,12 @@
 
 do_append_data:
 	up->len += ulen;
-	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
+	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
-		(struct rt6_info*)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+			      sizeof(struct udphdr), hlimit, tclass, opt, &fl,
+			      (struct rt6_info *)dst,
+			      corkreq ? msg->msg_flags | MSG_MORE : msg->
+			      msg_flags);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
@@ -824,7 +835,7 @@
 
 do_confirm:
 	dst_confirm(dst);
-	if (!(msg->msg_flags&MSG_PROBE) || len)
+	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
 	goto out;
@@ -845,9 +856,9 @@
  *	Socket option code for UDP
  */
 int udpv6_setsockopt(struct sock *sk, int level, int optname,
-		     char __user *optval, int optlen)
+		     char __user * optval, int optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
 					  udp_v6_push_pending_frames);
 	return ipv6_setsockopt(sk, level, optname, optval, optlen);
@@ -855,9 +866,9 @@
 
 #ifdef CONFIG_COMPAT
 int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int optlen)
+			    char __user * optval, int optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
 					  udp_v6_push_pending_frames);
 	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
@@ -865,18 +876,18 @@
 #endif
 
 int udpv6_getsockopt(struct sock *sk, int level, int optname,
-		     char __user *optval, int __user *optlen)
+		     char __user * optval, int __user * optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
 
 #ifdef CONFIG_COMPAT
 int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
-			    char __user *optval, int __user *optlen)
+			    char __user * optval, int __user * optlen)
 {
-	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
+	if (level == SOL_UDP || level == SOL_UDPLITE)
 		return udp_lib_getsockopt(sk, level, optname, optval, optlen);
 	return compat_ipv6_getsockopt(sk, level, optname, optval, optlen);
 }
@@ -902,6 +913,7 @@
 	src   = &np->rcv_saddr;
 	destp = ntohs(inet->dport);
 	srcp  = ntohs(inet->sport);
+
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p\n",
@@ -929,7 +941,8 @@
 			   "st tx_queue rx_queue tr tm->when retrnsmt"
 			   "   uid  timeout inode\n");
 	else
-		udp6_sock_seq_show(seq, v, ((struct udp_iter_state *)seq->private)->bucket);
+		udp6_sock_seq_show(seq, v,
+				   ((struct udp_iter_state *)seq->private)-> bucket);
 	return 0;
 }
 
@@ -948,7 +961,8 @@
 	return udp_proc_register(&udp6_seq_afinfo);
 }
 
-void udp6_proc_exit(void) {
+void udp6_proc_exit(void)
+{
 	udp_proc_unregister(&udp6_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
@@ -988,7 +1002,6 @@
 	.flags =     INET_PROTOSW_PERMANENT,
 };
 
-
 void __init udpv6_init(void)
 {
 	if (inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP) < 0)
