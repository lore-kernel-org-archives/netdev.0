From: Joe Perches <joe@perches.com>
Subject: [net-next-2.6 PATCH] net/ipv4: Move && and || to end of previous
 line
Date: Mon, 23 Nov 2009 10:28:15 -0800
Message-ID: <1259000895.16503.77.camel@Joe-Laptop.home>
References: <4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>
	 <20091122.163112.80105623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1084 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755060AbZKWS2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 13:28:10 -0500
In-Reply-To: <20091122.163112.80105623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-22 at 16:31 -0800, David Miller wrote:
> It should be of the form:
> 	if (x &&
> 	    y)
> 
> or:
> 	if (x && y)
> 
> Fix patches, rather than complaints, for existing cases where things
> do not follow this pattern are certainly welcome.

Also collapsed some multiple tabs to single space.

Compiled tested only:

 net/ipv4/inet_lro.c   |   36 ++++++++++++++++++------------------
 net/ipv4/ip_output.c  |    6 ++++--
 net/ipv4/ipconfig.c   |   13 ++++++-------
 net/ipv4/route.c      |   19 ++++++++++---------
 net/ipv4/tcp_htcp.c   |   10 +++++-----
 net/ipv4/tcp_input.c  |    4 ++--
 net/ipv4/tcp_lp.c     |    4 ++--
 net/ipv4/tcp_output.c |    4 ++--
 net/ipv4/tcp_probe.c  |    4 ++--
 net/ipv4/tcp_veno.c   |    5 ++---
 net/ipv4/tcp_yeah.c   |    4 ++--
 net/ipv4/udp.c        |   36 ++++++++++++++++++------------------
 12 files changed, 73 insertions(+), 72 deletions(-)

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 6a667da..47038cb 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -64,15 +64,15 @@ static int lro_tcp_ip_check(struct iphdr *iph, struct tcphdr *tcph,
 	if (iph->ihl != IPH_LEN_WO_OPTIONS)
 		return -1;
 
-	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack
-	    || tcph->rst || tcph->syn || tcph->fin)
+	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack ||
+	    tcph->rst || tcph->syn || tcph->fin)
 		return -1;
 
 	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
 		return -1;
 
-	if (tcph->doff != TCPH_LEN_WO_OPTIONS
-	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
+	if (tcph->doff != TCPH_LEN_WO_OPTIONS &&
+	    tcph->doff != TCPH_LEN_W_TIMESTAMP)
 		return -1;
 
 	/* check tcp options (only timestamp allowed) */
@@ -262,10 +262,10 @@ static int lro_check_tcp_conn(struct net_lro_desc *lro_desc,
 			      struct iphdr *iph,
 			      struct tcphdr *tcph)
 {
-	if ((lro_desc->iph->saddr != iph->saddr)
-	    || (lro_desc->iph->daddr != iph->daddr)
-	    || (lro_desc->tcph->source != tcph->source)
-	    || (lro_desc->tcph->dest != tcph->dest))
+	if ((lro_desc->iph->saddr != iph->saddr) ||
+	    (lro_desc->iph->daddr != iph->daddr) ||
+	    (lro_desc->tcph->source != tcph->source) ||
+	    (lro_desc->tcph->dest != tcph->dest))
 		return -1;
 	return 0;
 }
@@ -339,9 +339,9 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 	u64 flags;
 	int vlan_hdr_len = 0;
 
-	if (!lro_mgr->get_skb_header
-	    || lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
-				       &flags, priv))
+	if (!lro_mgr->get_skb_header ||
+	    lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
+				    &flags, priv))
 		goto out;
 
 	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
@@ -351,8 +351,8 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
 	if (!lro_desc)
 		goto out;
 
-	if ((skb->protocol == htons(ETH_P_8021Q))
-	    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
+	if ((skb->protocol == htons(ETH_P_8021Q)) &&
+	    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
 		vlan_hdr_len = VLAN_HLEN;
 
 	if (!lro_desc->active) { /* start new lro session */
@@ -446,9 +446,9 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 	int hdr_len = LRO_MAX_PG_HLEN;
 	int vlan_hdr_len = 0;
 
-	if (!lro_mgr->get_frag_header
-	    || lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
-					(void *)&tcph, &flags, priv)) {
+	if (!lro_mgr->get_frag_header ||
+	    lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
+				     (void *)&tcph, &flags, priv)) {
 		mac_hdr = page_address(frags->page) + frags->page_offset;
 		goto out1;
 	}
@@ -472,8 +472,8 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
 		if (!skb)
 			goto out;
 
-		if ((skb->protocol == htons(ETH_P_8021Q))
-		    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
+		if ((skb->protocol == htons(ETH_P_8021Q)) &&
+		    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
 			vlan_hdr_len = VLAN_HLEN;
 
 		iph = (void *)(skb->data + vlan_hdr_len);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 322b408..b78e615 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -264,9 +264,11 @@ int ip_mc_output(struct sk_buff *skb)
 
 		   This check is duplicated in ip_mr_input at the moment.
 		 */
-		    && ((rt->rt_flags&RTCF_LOCAL) || !(IPCB(skb)->flags&IPSKB_FORWARDED))
+		    &&
+		    ((rt->rt_flags & RTCF_LOCAL) ||
+		     !(IPCB(skb)->flags & IPSKB_FORWARDED))
 #endif
-		) {
+		   ) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(PF_INET, NF_INET_POST_ROUTING, newskb,
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index f8d04c2..4e08b7f 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1172,10 +1172,9 @@ static int __init ic_dynamic(void)
 			schedule_timeout_uninterruptible(1);
 #ifdef IPCONFIG_DHCP
 		/* DHCP isn't done until we get a DHCPACK. */
-		if ((ic_got_reply & IC_BOOTP)
-		    && (ic_proto_enabled & IC_USE_DHCP)
-		    && ic_dhcp_msgtype != DHCPACK)
-		{
+		if ((ic_got_reply & IC_BOOTP) &&
+		    (ic_proto_enabled & IC_USE_DHCP) &&
+		    ic_dhcp_msgtype != DHCPACK) {
 			ic_got_reply = 0;
 			printk(",");
 			continue;
@@ -1344,9 +1343,9 @@ static int __init ip_auto_config(void)
 	 */
 	if (ic_myaddr == NONE ||
 #ifdef CONFIG_ROOT_NFS
-	    (root_server_addr == NONE
-	     && ic_servaddr == NONE
-	     && ROOT_DEV == Root_NFS) ||
+	    (root_server_addr == NONE &&
+	     ic_servaddr == NONE &&
+	     ROOT_DEV == Root_NFS) ||
 #endif
 	    ic_first_dev->next) {
 #ifdef IPCONFIG_DYNAMIC
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4284cee..7547944 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1346,9 +1346,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		return;
 
 	net = dev_net(dev);
-	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev)
-	    || ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw)
-	    || ipv4_is_zeronet(new_gw))
+	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev) ||
+	    ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw) ||
+	    ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
 	if (!rt_caching(net))
@@ -2311,10 +2311,11 @@ skip_cache:
 				ip_hdr(skb)->protocol);
 			if (our
 #ifdef CONFIG_IP_MROUTE
-			    || (!ipv4_is_local_multicast(daddr) &&
-				IN_DEV_MFORWARD(in_dev))
+				||
+			    (!ipv4_is_local_multicast(daddr) &&
+			     IN_DEV_MFORWARD(in_dev))
 #endif
-			    ) {
+			   ) {
 				rcu_read_unlock();
 				return ip_route_input_mc(skb, daddr, saddr,
 							 tos, dev, our);
@@ -2511,9 +2512,9 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->oif == 0
-		    && (ipv4_is_multicast(oldflp->fl4_dst) ||
-			oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
+		if (oldflp->oif == 0 &&
+		    (ipv4_is_multicast(oldflp->fl4_dst) ||
+		     oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 			dev_out = ip_dev_find(net, oldflp->fl4_src);
 			if (dev_out == NULL)
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 26d5c7f..7c94a49 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -92,8 +92,8 @@ static inline void measure_rtt(struct sock *sk, u32 srtt)
 	if (icsk->icsk_ca_state == TCP_CA_Open) {
 		if (ca->maxRTT < ca->minRTT)
 			ca->maxRTT = ca->minRTT;
-		if (ca->maxRTT < srtt
-		    && srtt <= ca->maxRTT + msecs_to_jiffies(20))
+		if (ca->maxRTT < srtt &&
+		    srtt <= ca->maxRTT + msecs_to_jiffies(20))
 			ca->maxRTT = srtt;
 	}
 }
@@ -123,9 +123,9 @@ static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, s32 rtt
 
 	ca->packetcount += pkts_acked;
 
-	if (ca->packetcount >= tp->snd_cwnd - (ca->alpha >> 7 ? : 1)
-	    && now - ca->lasttime >= ca->minRTT
-	    && ca->minRTT > 0) {
+	if (ca->packetcount >= tp->snd_cwnd - (ca->alpha >> 7 ? : 1) &&
+	    now - ca->lasttime >= ca->minRTT &&
+	    ca->minRTT > 0) {
 		__u32 cur_Bi = ca->packetcount * HZ / (now - ca->lasttime);
 
 		if (htcp_ccount(ca) <= 3) {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc306ac..be166e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4852,11 +4852,11 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	    /* More than one full frame received... */
-	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss
+	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
-	     && __tcp_select_window(sk) >= tp->rcv_wnd) ||
+	     __tcp_select_window(sk) >= tp->rcv_wnd) ||
 	    /* We ACK each frame or... */
 	    tcp_in_quickack_mode(sk) ||
 	    /* We have out of order data. */
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index ce3c41f..de87037 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -143,8 +143,8 @@ static u32 tcp_lp_remote_hz_estimator(struct sock *sk)
 		goto out;
 
 	/* we can't calc remote HZ with no different!! */
-	if (tp->rx_opt.rcv_tsval == lp->remote_ref_time
-	    || tp->rx_opt.rcv_tsecr == lp->local_ref_time)
+	if (tp->rx_opt.rcv_tsval == lp->remote_ref_time ||
+	    tp->rx_opt.rcv_tsecr == lp->local_ref_time)
 		goto out;
 
 	m = HZ * (tp->rx_opt.rcv_tsval -
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 616c686..875bc6d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1923,8 +1923,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 * case, when window is shrunk to zero. In this case
 	 * our retransmit serves as a zero window probe.
 	 */
-	if (!before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp))
-	    && TCP_SKB_CB(skb)->seq != tp->snd_una)
+	if (!before(TCP_SKB_CB(skb)->seq, tcp_wnd_end(tp)) &&
+	    TCP_SKB_CB(skb)->seq != tp->snd_una)
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 7a3cc2f..bb110c5 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -95,8 +95,8 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 	/* Only update if port matches */
 	if ((port == 0 || ntohs(inet->inet_dport) == port ||
-	     ntohs(inet->inet_sport) == port)
-	    && (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
+	     ntohs(inet->inet_sport) == port) &&
+	    (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
 
 		spin_lock(&tcp_probe.lock);
 		/* If log fills, just silently drop */
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index e9bbff7..b612acf 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -165,9 +165,8 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 				 * every other rtt.
 				 */
 				if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
-					if (veno->inc
-					    && tp->snd_cwnd <
-					    tp->snd_cwnd_clamp) {
+					if (veno->inc &&
+					    tp->snd_cwnd < tp->snd_cwnd_clamp) {
 						tp->snd_cwnd++;
 						veno->inc = 0;
 					} else
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 66b6821..a0f2403 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -157,8 +157,8 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 
 			if (queue > TCP_YEAH_ALPHA ||
 			    rtt - yeah->vegas.baseRTT > (yeah->vegas.baseRTT / TCP_YEAH_PHY)) {
-				if (queue > TCP_YEAH_ALPHA
-				    && tp->snd_cwnd > yeah->reno_count) {
+				if (queue > TCP_YEAH_ALPHA &&
+				    tp->snd_cwnd > yeah->reno_count) {
 					u32 reduction = min(queue / TCP_YEAH_GAMMA ,
 							    tp->snd_cwnd >> TCP_YEAH_EPSILON);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1eaf575..1f95348 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -136,12 +136,12 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct hlist_nulls_node *node;
 
 	sk_nulls_for_each(sk2, node, &hslot->head)
-		if (net_eq(sock_net(sk2), net)			&&
-		    sk2 != sk					&&
+		if (net_eq(sock_net(sk2), net) &&
+		    sk2 != sk &&
 		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
-		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
-		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
-			|| sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (!sk2->sk_reuse || !sk->sk_reuse) &&
+		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
+		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (*saddr_comp)(sk, sk2)) {
 			if (bitmap)
 				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
@@ -168,12 +168,12 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 
 	spin_lock(&hslot2->lock);
 	udp_portaddr_for_each_entry(sk2, node, &hslot2->head)
-		if (net_eq(sock_net(sk2), net)			&&
-		    sk2 != sk					&&
-		    (udp_sk(sk2)->udp_port_hash == num)		&&
-		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
-		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
-			|| sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		if (net_eq(sock_net(sk2), net) &&
+		    sk2 != sk &&
+		    (udp_sk(sk2)->udp_port_hash == num) &&
+		    (!sk2->sk_reuse || !sk->sk_reuse) &&
+		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
+		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (*saddr_comp)(sk, sk2)) {
 			res = 1;
 			break;
@@ -545,13 +545,13 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 	sk_nulls_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
-		if (!net_eq(sock_net(s), net)				||
-		    udp_sk(s)->udp_port_hash != hnum			||
-		    (inet->inet_daddr && inet->inet_daddr != rmt_addr)	||
-		    (inet->inet_dport != rmt_port && inet->inet_dport)	||
-		    (inet->inet_rcv_saddr	&&
-		     inet->inet_rcv_saddr != loc_addr)			||
-		    ipv6_only_sock(s)					||
+		if (!net_eq(sock_net(s), net) ||
+		    udp_sk(s)->udp_port_hash != hnum ||
+		    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
+		    (inet->inet_dport != rmt_port && inet->inet_dport) ||
+		    (inet->inet_rcv_saddr &&
+		     inet->inet_rcv_saddr != loc_addr) ||
+		    ipv6_only_sock(s) ||
 		    (s->sk_bound_dev_if && s->sk_bound_dev_if != dif))
 			continue;
 		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))



