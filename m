From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 1/10][TCP_IPV4]: CodingStyle cleanups, no code change
Date: Fri, 17 Nov 2006 13:15:43 -0200
Message-ID: <20061117151542.GB17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:4494 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S933659AbWKQPP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:15:57 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mostly related to CONFIG_TCP_MD5SIG recent merge.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/tcp_ipv4.c |  143 +++++++++++++++++++++++++++------------------------
 1 files changed, 75 insertions(+), 68 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index dadf802..010dff4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -93,16 +93,18 @@ static struct socket *tcp_socket;
 void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb);
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr);
+static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk,
+						   __be32 addr);
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
-				   __be32 saddr, __be32 daddr, struct tcphdr *th,
-				   int protocol, int tcplen);
+				   __be32 saddr, __be32 daddr,
+				   struct tcphdr *th, int protocol,
+				   int tcplen);
 #endif
 
 struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
-	.lhash_lock	= __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
-	.lhash_users	= ATOMIC_INIT(0),
-	.lhash_wait	= __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
+	.lhash_lock  = __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
+	.lhash_users = ATOMIC_INIT(0),
+	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
@@ -215,13 +217,14 @@ int tcp_v4_connect(struct sock *sk, stru
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp && rt->rt_dst == daddr) {
 		struct inet_peer *peer = rt_get_peer(rt);
-
-		/* VJ's idea. We save last timestamp seen from
-		 * the destination in peer table, when entering state TIME-WAIT
-		 * and initialize rx_opt.ts_recent from it, when trying new connection.
+		/*
+		 * VJ's idea. We save last timestamp seen from
+		 * the destination in peer table, when entering state
+		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
+		 * when trying new connection.
 		 */
-
-		if (peer && peer->tcp_ts_stamp + TCP_PAWS_MSL >= xtime.tv_sec) {
+		if (peer != NULL &&
+		    peer->tcp_ts_stamp + TCP_PAWS_MSL >= xtime.tv_sec) {
 			tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
 			tp->rx_opt.ts_recent = peer->tcp_ts;
 		}
@@ -246,7 +249,8 @@ int tcp_v4_connect(struct sock *sk, stru
 	if (err)
 		goto failure;
 
-	err = ip_route_newports(&rt, IPPROTO_TCP, inet->sport, inet->dport, sk);
+	err = ip_route_newports(&rt, IPPROTO_TCP,
+				inet->sport, inet->dport, sk);
 	if (err)
 		goto failure;
 
@@ -270,7 +274,10 @@ int tcp_v4_connect(struct sock *sk, stru
 	return 0;
 
 failure:
-	/* This unhashes the socket and releases the local port, if necessary. */
+	/*
+	 * This unhashes the socket and releases the local port,
+	 * if necessary.
+	 */
 	tcp_set_state(sk, TCP_CLOSE);
 	ip_rt_put(rt);
 	sk->sk_route_caps = 0;
@@ -495,7 +502,8 @@ void tcp_v4_send_check(struct sock *sk, 
 	struct tcphdr *th = skb->h.th;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~tcp_v4_check(th, len, inet->saddr, inet->daddr, 0);
+		th->check = ~tcp_v4_check(th, len,
+					  inet->saddr, inet->daddr, 0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
 		th->check = tcp_v4_check(th, len, inet->saddr, inet->daddr,
@@ -572,7 +580,7 @@ #endif
 				       skb->len - (th->doff << 2));
 	}
 
-	memset(&arg, 0, sizeof arg);
+	memset(&arg, 0, sizeof(arg));
 	arg.iov[0].iov_base = (unsigned char *)&rep;
 	arg.iov[0].iov_len  = sizeof(rep.th);
 
@@ -595,9 +603,8 @@ #ifdef CONFIG_TCP_MD5SIG
 					arg.iov[0].iov_len);
 	}
 #endif
-
 	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
-				      skb->nh.iph->saddr, /*XXX*/
+				      skb->nh.iph->saddr, /* XXX */
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
@@ -631,7 +638,7 @@ #ifdef CONFIG_TCP_MD5SIG
 #endif
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
-	memset(&arg, 0, sizeof arg);
+	memset(&arg, 0, sizeof(arg));
 
 	arg.iov[0].iov_base = (unsigned char *)&rep;
 	arg.iov[0].iov_len  = sizeof(rep.th);
@@ -668,9 +675,8 @@ #ifdef CONFIG_TCP_MD5SIG
 		tw_key.key = twsk->tw_md5_key;
 		tw_key.keylen = twsk->tw_md5_keylen;
 		key = &tw_key;
-	} else {
+	} else
 		key = NULL;
-	}
 
 	if (key) {
 		int offset = (ts) ? 3 : 0;
@@ -690,9 +696,8 @@ #ifdef CONFIG_TCP_MD5SIG
 					arg.iov[0].iov_len);
 	}
 #endif
-
 	arg.csum = csum_tcpudp_nofold(skb->nh.iph->daddr,
-				      skb->nh.iph->saddr, /*XXX*/
+				      skb->nh.iph->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
@@ -707,12 +712,14 @@ static void tcp_v4_timewait_ack(struct s
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
 	tcp_v4_send_ack(tcptw, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
-			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale, tcptw->tw_ts_recent);
+			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
+			tcptw->tw_ts_recent);
 
 	inet_twsk_put(tw);
 }
 
-static void tcp_v4_reqsk_send_ack(struct sk_buff *skb, struct request_sock *req)
+static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
+				  struct request_sock *req)
 {
 	tcp_v4_send_ack(NULL, skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
@@ -809,7 +816,8 @@ #ifdef CONFIG_TCP_MD5SIG
  */
 
 /* Find the Key structure for an address.  */
-static struct tcp_md5sig_key *tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
+static struct tcp_md5sig_key *
+			tcp_v4_md5_do_lookup(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int i;
@@ -818,7 +826,8 @@ static struct tcp_md5sig_key *tcp_v4_md5
 		return NULL;
 	for (i = 0; i < tp->md5sig_info->entries4; i++) {
 		if (tp->md5sig_info->keys4[i].addr == addr)
-			return (struct tcp_md5sig_key *)&tp->md5sig_info->keys4[i];
+			return (struct tcp_md5sig_key *)
+						&tp->md5sig_info->keys4[i];
 	}
 	return NULL;
 }
@@ -915,13 +924,12 @@ int tcp_v4_md5_do_del(struct sock *sk, _
 			if (tp->md5sig_info->entries4 == 0) {
 				kfree(tp->md5sig_info->keys4);
 				tp->md5sig_info->keys4 = NULL;
-			} else {
+			} else if (tp->md5sig_info->entries4 != i) {
 				/* Need to do some manipulation */
-				if (tp->md5sig_info->entries4 != i)
-					memcpy(&tp->md5sig_info->keys4[i],
-					       &tp->md5sig_info->keys4[i+1],
-					       (tp->md5sig_info->entries4 - i)
-					        * sizeof (struct tcp4_md5sig_key));
+				memcpy(&tp->md5sig_info->keys4[i],
+				       &tp->md5sig_info->keys4[i+1],
+				       (tp->md5sig_info->entries4 - i) *
+				        sizeof(struct tcp4_md5sig_key));
 			}
 			tcp_free_md5sig_pool();
 			return 0;
@@ -932,7 +940,7 @@ int tcp_v4_md5_do_del(struct sock *sk, _
 
 EXPORT_SYMBOL(tcp_v4_md5_do_del);
 
-static void tcp_v4_clear_md5_list (struct sock *sk)
+static void tcp_v4_clear_md5_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -954,8 +962,8 @@ static void tcp_v4_clear_md5_list (struc
 	}
 }
 
-static int tcp_v4_parse_md5_keys (struct sock *sk, char __user *optval,
-				  int optlen)
+static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
+				 int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
@@ -964,7 +972,7 @@ static int tcp_v4_parse_md5_keys (struct
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
 
-	if (copy_from_user (&cmd, optval, sizeof(cmd)))
+	if (copy_from_user(&cmd, optval, sizeof(cmd)))
 		return -EFAULT;
 
 	if (sin->sin_family != AF_INET)
@@ -981,9 +989,8 @@ static int tcp_v4_parse_md5_keys (struct
 
 	if (!tcp_sk(sk)->md5sig_info) {
 		struct tcp_sock *tp = tcp_sk(sk);
-		struct tcp_md5sig_info *p;
+		struct tcp_md5sig_info *p = kzalloc(sizeof(*p), GFP_KERNEL);
 
-		p = kzalloc(sizeof(struct tcp_md5sig_info), GFP_KERNEL);
 		if (!p)
 			return -EINVAL;
 
@@ -1044,8 +1051,8 @@ #endif
 
 #ifdef CONFIG_TCP_MD5SIG_DEBUG
 	printk("Calcuating hash for: ");
-	for (i = 0; i < sizeof (*bp); i++)
-		printk ("%02x ", (unsigned int)((unsigned char *)bp)[i]);
+	for (i = 0; i < sizeof(*bp); i++)
+		printk("%02x ", (unsigned int)((unsigned char *)bp)[i]);
 	printk(" ");
 #endif
 
@@ -1057,8 +1064,8 @@ #endif
 	sg_set_buf(&sg[block++], th, sizeof(struct tcphdr));
 	nbytes += sizeof(struct tcphdr);
 #ifdef CONFIG_TCP_MD5SIG_DEBUG
-	for (i = 0; i < sizeof (struct tcphdr); i++)
-		printk (" %02x", (unsigned int)((unsigned char *)th)[i]);
+	for (i = 0; i < sizeof(struct tcphdr); i++)
+		printk(" %02x", (unsigned int)((unsigned char *)th)[i]);
 #endif
 	/* 3. the TCP segment data (if any) */
 	data_len = tcplen - (th->doff << 2);
@@ -1075,9 +1082,9 @@ #endif
 	nbytes += key->keylen;
 
 #ifdef CONFIG_TCP_MD5SIG_DEBUG
-	printk ("  and password: ");
+	printk("  and password: ");
 	for (i = 0; i < key->keylen; i++)
-		printk ("%02x ", (unsigned int)key->key[i]);
+		printk("%02x ", (unsigned int)key->key[i]);
 #endif
 
 	/* Now store the Hash into the packet */
@@ -1099,7 +1106,7 @@ out:
 #ifdef CONFIG_TCP_MD5SIG_DEBUG
 	printk(" result:");
 	for (i = 0; i < 16; i++)
-		printk (" %02x", (unsigned int)(((u8*)md5_hash)[i]));
+		printk(" %02x", (unsigned int)(((u8*)md5_hash)[i]));
 	printk("\n");
 #endif
 	return 0;
@@ -1135,7 +1142,7 @@ int tcp_v4_calc_md5_hash(char *md5_hash,
 
 EXPORT_SYMBOL(tcp_v4_calc_md5_hash);
 
-static int tcp_v4_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
+static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1149,7 +1156,7 @@ static int tcp_v4_inbound_md5_hash (stru
 	struct tcp_md5sig_key *hash_expected;
 	struct iphdr *iph = skb->nh.iph;
 	struct tcphdr *th = skb->h.th;
-	int length = (th->doff << 2) - sizeof (struct tcphdr);
+	int length = (th->doff << 2) - sizeof(struct tcphdr);
 	int genhash;
 	unsigned char *ptr;
 	unsigned char newhash[16];
@@ -1200,22 +1207,18 @@ done_opts:
 		return 0;
 
 	if (hash_expected && !hash_location) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash NOT expected but found "
+		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD (iph->saddr), ntohs(th->source),
-			       NIPQUAD (iph->daddr), ntohs(th->dest));
-		}
+			       NIPQUAD(iph->saddr), ntohs(th->source),
+			       NIPQUAD(iph->daddr), ntohs(th->dest));
 		return 1;
 	}
 
 	if (!hash_expected && hash_location) {
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash NOT expected but found "
+		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD (iph->saddr), ntohs(th->source),
-			       NIPQUAD (iph->daddr), ntohs(th->dest));
-		}
+			       NIPQUAD(iph->saddr), ntohs(th->source),
+			       NIPQUAD(iph->daddr), ntohs(th->dest));
 		return 1;
 	}
 
@@ -1232,15 +1235,16 @@ done_opts:
 		if (net_ratelimit()) {
 			printk(KERN_INFO "MD5 Hash failed for "
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)%s\n",
-			       NIPQUAD (iph->saddr), ntohs(th->source),
-			       NIPQUAD (iph->daddr), ntohs(th->dest),
+			       NIPQUAD(iph->saddr), ntohs(th->source),
+			       NIPQUAD(iph->daddr), ntohs(th->dest),
 			       genhash ? " tcp_v4_calc_md5_hash failed" : "");
 #ifdef CONFIG_TCP_MD5SIG_DEBUG
 			do {
 				int i;
 				printk("Received: ");
 				for (i = 0; i < 16; i++)
-					printk("%02x ", 0xff & (int)hash_location[i]);
+					printk("%02x ",
+					       0xff & (int)hash_location[i]);
 				printk("\n");
 				printk("Calculated: ");
 				for (i = 0; i < 16; i++)
@@ -1582,7 +1586,7 @@ #ifdef CONFIG_TCP_MD5SIG
 	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
 	 *  o There is an MD5 option and we're not expecting one
 	 */
-	if (tcp_v4_inbound_md5_hash (sk, skb))
+	if (tcp_v4_inbound_md5_hash(sk, skb))
 		goto discard;
 #endif
 
@@ -2155,7 +2159,7 @@ static void *established_get_idx(struct 
 	while (rc && pos) {
 		rc = established_get_next(seq, rc);
 		--pos;
-	}		
+	}
 	return rc;
 }
 
@@ -2284,7 +2288,7 @@ int tcp_proc_register(struct tcp_seq_afi
 	afinfo->seq_fops->read		= seq_read;
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= seq_release_private;
-	
+
 	p = proc_net_fops_create(afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
@@ -2298,7 +2302,7 @@ void tcp_proc_unregister(struct tcp_seq_
 	if (!afinfo)
 		return;
 	proc_net_remove(afinfo->name);
-	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops)); 
+	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 
 static void get_openreq4(struct sock *sk, struct request_sock *req,
@@ -2356,7 +2360,8 @@ static void get_tcp4_sock(struct sock *s
 			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
 		i, src, srcp, dest, destp, sp->sk_state,
 		tp->write_seq - tp->snd_una,
-		(sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
+		sp->sk_state == TCP_LISTEN ? sp->sk_ack_backlog :
+					     (tp->rcv_nxt - tp->copied_seq),
 		timer_active,
 		jiffies_to_clock_t(timer_expires - jiffies),
 		icsk->icsk_retransmits,
@@ -2371,7 +2376,8 @@ static void get_tcp4_sock(struct sock *s
 		tp->snd_ssthresh >= 0xFFFF ? -1 : tp->snd_ssthresh);
 }
 
-static void get_timewait4_sock(struct inet_timewait_sock *tw, char *tmpbuf, int i)
+static void get_timewait4_sock(struct inet_timewait_sock *tw,
+			       char *tmpbuf, int i)
 {
 	__be32 dest, src;
 	__u16 destp, srcp;
@@ -2484,7 +2490,8 @@ #endif
 
 void __init tcp_v4_init(struct net_proto_family *ops)
 {
-	if (inet_csk_ctl_sock_create(&tcp_socket, PF_INET, SOCK_RAW, IPPROTO_TCP) < 0)
+	if (inet_csk_ctl_sock_create(&tcp_socket, PF_INET, SOCK_RAW,
+				     IPPROTO_TCP) < 0)
 		panic("Failed to create the TCP control socket.\n");
 }
 
-- 
1.4.2.1.g3d5c

