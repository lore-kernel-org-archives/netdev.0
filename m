From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: ipv4: Standardize prefixes for message logging
Date: Mon, 12 Mar 2012 10:03:32 -0700
Message-ID: <1331571812.13200.23.camel@joe2Laptop>
References: <1331526971.13200.9.camel@joe2Laptop>
	 <20120311.234846.455580505379366792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120311.234846.455580505379366792.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) as appropriate.

Add "IPv4: ", "TCP: ", and "IPsec: " to appropriate files.
Standardize on "UDPLite: " for appropriate uses.
Some prefixes were previously "UDPLITE: " and "UDP-Lite: ".

Add KBUILD_MODNAME ": " to icmp and gre.
Remove embedded prefixes as appropriate.

Add missing "\n" to pr_info in gre.c.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/udplite.h   |    4 ++--
 net/ipv4/af_inet.c      |    2 ++
 net/ipv4/ah4.c          |    9 ++++++---
 net/ipv4/esp4.c         |    2 ++
 net/ipv4/gre.c          |    6 ++++--
 net/ipv4/icmp.c         |    6 ++++--
 net/ipv4/ip_fragment.c  |    8 +++++---
 net/ipv4/ip_gre.c       |    2 ++
 net/ipv4/ip_input.c     |    2 ++
 net/ipv4/ip_options.c   |    2 ++
 net/ipv4/ipcomp.c       |    1 +
 net/ipv4/route.c        |    4 +++-
 net/ipv4/tcp.c          |   11 +++++++----
 net/ipv4/tcp_cong.c     |    8 +++++---
 net/ipv4/tcp_input.c    |    2 ++
 net/ipv4/tcp_ipv4.c     |    6 +++---
 net/ipv4/tcp_probe.c    |    4 +++-
 net/ipv4/tcp_timer.c    |   14 ++++++++------
 net/ipv4/udp.c          |   34 ++++++++++++++--------------------
 net/ipv4/udplite.c      |    3 +++
 net/ipv4/xfrm4_tunnel.c |    2 ++
 21 files changed, 82 insertions(+), 50 deletions(-)

diff --git a/include/net/udplite.h b/include/net/udplite.h
index 5f097ca..7137545 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -40,7 +40,7 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
          * checksum. UDP-Lite (like IPv6) mandates checksums, hence packets
          * with a zero checksum field are illegal.                            */
 	if (uh->check == 0) {
-		LIMIT_NETDEBUG(KERN_DEBUG "UDPLITE: zeroed checksum field\n");
+		LIMIT_NETDEBUG(KERN_DEBUG "UDPLite: zeroed checksum field\n");
 		return 1;
 	}
 
@@ -52,7 +52,7 @@ static inline int udplite_checksum_init(struct sk_buff *skb, struct udphdr *uh)
 		/*
 		 * Coverage length violates RFC 3828: log and discard silently.
 		 */
-		LIMIT_NETDEBUG(KERN_DEBUG "UDPLITE: bad csum coverage %d/%d\n",
+		LIMIT_NETDEBUG(KERN_DEBUG "UDPLite: bad csum coverage %d/%d\n",
 			       cscov, skb->len);
 		return 1;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b7a9466..fdf49fd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -65,6 +65,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "IPv4: " fmt
+
 #include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/types.h>
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index b552466..fd508b5 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) "IPsec: " fmt
+
 #include <crypto/hash.h>
 #include <linux/err.h>
 #include <linux/module.h>
@@ -445,9 +447,10 @@ static int ah_init_state(struct xfrm_state *x)
 
 	if (aalg_desc->uinfo.auth.icv_fullbits/8 !=
 	    crypto_ahash_digestsize(ahash)) {
-		pr_info("AH: %s digestsize %u != %hu\n",
-			x->aalg->alg_name, crypto_ahash_digestsize(ahash),
-			aalg_desc->uinfo.auth.icv_fullbits/8);
+		pr_info("%s: %s digestsize %u != %hu\n",
+			__func__, x->aalg->alg_name,
+			crypto_ahash_digestsize(ahash),
+			aalg_desc->uinfo.auth.icv_fullbits / 8);
 		goto error;
 	}
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 0a86dbe..89a47b3 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) "IPsec: " fmt
+
 #include <crypto/aead.h>
 #include <crypto/authenc.h>
 #include <linux/err.h>
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 8cb1ebb..42a4910 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -10,6 +10,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/kmod.h>
@@ -118,10 +120,10 @@ static const struct net_protocol net_gre_protocol = {
 
 static int __init gre_init(void)
 {
-	pr_info("GRE over IPv4 demultiplexor driver");
+	pr_info("GRE over IPv4 demultiplexor driver\n");
 
 	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
-		pr_err("gre: can't add protocol\n");
+		pr_err("can't add protocol\n");
 		return -EAGAIN;
 	}
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5c7323b..9664d35 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -62,6 +62,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/jiffies.h>
@@ -670,7 +672,7 @@ static void icmp_unreach(struct sk_buff *skb)
 			break;
 		case ICMP_FRAG_NEEDED:
 			if (ipv4_config.no_pmtu_disc) {
-				LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: fragmentation needed and DF set\n",
+				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
 					       &iph->daddr);
 			} else {
 				info = ip_rt_frag_needed(net, iph,
@@ -681,7 +683,7 @@ static void icmp_unreach(struct sk_buff *skb)
 			}
 			break;
 		case ICMP_SR_FAILED:
-			LIMIT_NETDEBUG(KERN_INFO "ICMP: %pI4: Source Route Failed\n",
+			LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: Source Route Failed\n"),
 				       &iph->daddr);
 			break;
 		default:
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b2fd333..3727e23 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -20,6 +20,8 @@
  *		Patrick McHardy :	LRU queue of frag heads for evictor.
  */
 
+#define pr_fmt(fmt) "IPv4: " fmt
+
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -299,7 +301,7 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	return container_of(q, struct ipq, q);
 
 out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR "ip_frag_create: no memory left !\n");
+	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: no memory left !\n"));
 	return NULL;
 }
 
@@ -637,8 +639,8 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	return 0;
 
 out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR "IP: queue_glue: no memory for gluing "
-			      "queue %p\n", qp);
+	LIMIT_NETDEBUG(KERN_ERR pr_fmt("queue_glue: no memory for gluing queue %p\n"),
+		       qp);
 	err = -ENOMEM;
 	goto out_fail;
 out_oversize:
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 185e0a7..b57532d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -10,6 +10,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/types.h>
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index de8e9be..f3f1108 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -113,6 +113,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "IPv4: " fmt
+
 #include <asm/system.h>
 #include <linux/module.h>
 #include <linux/types.h>
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index e25ee7c..a0d0d9d 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -9,6 +9,8 @@
  *
  */
 
+#define pr_fmt(fmt) "IPv4: " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/slab.h>
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 63b64c4..56d6768 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -13,6 +13,7 @@
  *   - Compression stats.
  *   - Adaptive compression.
  */
+
 #include <linux/module.h>
 #include <linux/err.h>
 #include <linux/rtnetlink.h>
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cbda6de..12ccf88 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -62,6 +62,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "IPv4: " fmt
+
 #include <linux/module.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -1298,7 +1300,7 @@ restart:
 			}
 
 			if (net_ratelimit())
-				pr_warn("ipv4: Neighbour table overflow\n");
+				pr_warn("Neighbour table overflow\n");
 			rt_drop(rt);
 			return ERR_PTR(-ENOBUFS);
 		}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2baba1b..cfd7edd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -245,6 +245,8 @@
  *	TCP_CLOSE		socket is finished
  */
 
+#define pr_fmt(fmt) "TCP: " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -1675,7 +1677,8 @@ do_prequeue:
 
 				if (tp->ucopy.dma_cookie < 0) {
 
-					pr_alert("dma_cookie < 0\n");
+					pr_alert("%s: dma_cookie < 0\n",
+						 __func__);
 
 					/* Exception. Bailout! */
 					if (!copied)
@@ -1884,9 +1887,9 @@ bool tcp_check_oom(struct sock *sk, int shift)
 	out_of_socket_memory = tcp_out_of_memory(sk);
 
 	if (too_many_orphans && net_ratelimit())
-		pr_info("TCP: too many orphaned sockets\n");
+		pr_info("too many orphaned sockets\n");
 	if (out_of_socket_memory && net_ratelimit())
-		pr_info("TCP: out of memory -- consider tuning tcp_mem\n");
+		pr_info("out of memory -- consider tuning tcp_mem\n");
 	return too_many_orphans || out_of_socket_memory;
 }
 
@@ -3311,7 +3314,7 @@ void __init tcp_init(void)
 	sysctl_tcp_rmem[1] = 87380;
 	sysctl_tcp_rmem[2] = max(87380, max_share);
 
-	pr_info("TCP: Hash tables configured (established %u bind %u)\n",
+	pr_info("Hash tables configured (established %u bind %u)\n",
 		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 67bab75..272a845 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -6,6 +6,8 @@
  * Copyright (C) 2005 Stephen Hemminger <shemminger@osdl.org>
  */
 
+#define pr_fmt(fmt) "TCP: " fmt
+
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/types.h>
@@ -41,17 +43,17 @@ int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
 
 	/* all algorithms must implement ssthresh and cong_avoid ops */
 	if (!ca->ssthresh || !ca->cong_avoid) {
-		pr_err("TCP %s does not implement required ops\n", ca->name);
+		pr_err("%s does not implement required ops\n", ca->name);
 		return -EINVAL;
 	}
 
 	spin_lock(&tcp_cong_list_lock);
 	if (tcp_ca_find(ca->name)) {
-		pr_notice("TCP %s already registered\n", ca->name);
+		pr_notice("%s already registered\n", ca->name);
 		ret = -EEXIST;
 	} else {
 		list_add_tail_rcu(&ca->list, &tcp_cong_list);
-		pr_info("TCP %s registered\n", ca->name);
+		pr_info("%s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 23ca366..68d4057 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -61,6 +61,8 @@
  *		Pasi Sarolahti:		F-RTO for dealing with spurious RTOs
  */
 
+#define pr_fmt(fmt) "TCP: " fmt
+
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/module.h>
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 257dba6..fe9f604 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -50,6 +50,7 @@
  *					a single port at the same time.
  */
 
+#define pr_fmt(fmt) "TCP: " fmt
 
 #include <linux/bottom_half.h>
 #include <linux/types.h>
@@ -876,8 +877,7 @@ int tcp_syn_flood_action(struct sock *sk,
 	lopt = inet_csk(sk)->icsk_accept_queue.listen_opt;
 	if (!lopt->synflood_warned) {
 		lopt->synflood_warned = 1;
-		pr_info("%s: Possible SYN flooding on port %d. %s. "
-			" Check SNMP counters.\n",
+		pr_info("%s: Possible SYN flooding on port %d. %s.  Check SNMP counters.\n",
 			proto, ntohs(tcp_hdr(skb)->dest), msg);
 	}
 	return want_cookie;
@@ -1399,7 +1399,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			 * to destinations, already remembered
 			 * to the moment of synflood.
 			 */
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: drop open request from %pI4/%u\n",
+			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("drop open request from %pI4/%u\n"),
 				       &saddr, ntohs(tcp_hdr(skb)->source));
 			goto drop_and_release;
 		}
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 85ee7eb..a981cdc 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -18,6 +18,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/kprobes.h>
 #include <linux/socket.h>
@@ -239,7 +241,7 @@ static __init int tcpprobe_init(void)
 	if (ret)
 		goto err1;
 
-	pr_info("TCP probe registered (port=%d) bufsize=%u\n", port, bufsize);
+	pr_info("probe registered (port=%d) bufsize=%u\n", port, bufsize);
 	return 0;
  err1:
 	proc_net_remove(&init_net, procname);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index cd2e072..34d4a02 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -333,16 +333,18 @@ void tcp_retransmit_timer(struct sock *sk)
 		 */
 		struct inet_sock *inet = inet_sk(sk);
 		if (sk->sk_family == AF_INET) {
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
-			       &inet->inet_daddr, ntohs(inet->inet_dport),
-			       inet->inet_num, tp->snd_una, tp->snd_nxt);
+			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("Peer %pI4:%u/%u unexpectedly shrunk window %u:%u (repaired)\n"),
+				       &inet->inet_daddr,
+				       ntohs(inet->inet_dport), inet->inet_num,
+				       tp->snd_una, tp->snd_nxt);
 		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (sk->sk_family == AF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
-			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n",
-			       &np->daddr, ntohs(inet->inet_dport),
-			       inet->inet_num, tp->snd_una, tp->snd_nxt);
+			LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("Peer %pI6:%u/%u unexpectedly shrunk window %u:%u (repaired)\n"),
+				       &np->daddr,
+				       ntohs(inet->inet_dport), inet->inet_num,
+				       tp->snd_una, tp->snd_nxt);
 		}
 #endif
 		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7c41ab8..d6f5fee 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -77,6 +77,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "UDP: " fmt
+
 #include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -975,7 +977,7 @@ back_from_confirm:
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
 
-		LIMIT_NETDEBUG(KERN_DEBUG "udp cork app bug 2\n");
+		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("cork app bug 2\n"));
 		err = -EINVAL;
 		goto out;
 	}
@@ -1054,7 +1056,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	if (unlikely(!up->pending)) {
 		release_sock(sk);
 
-		LIMIT_NETDEBUG(KERN_DEBUG "udp cork app bug 3\n");
+		LIMIT_NETDEBUG(KERN_DEBUG pr_fmt("udp cork app bug 3\n"));
 		return -EINVAL;
 	}
 
@@ -1447,9 +1449,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		 * provided by the application."
 		 */
 		if (up->pcrlen == 0) {          /* full coverage was set  */
-			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE: partial coverage "
-				"%d while full coverage %d requested\n",
-				UDP_SKB_CB(skb)->cscov, skb->len);
+			LIMIT_NETDEBUG(KERN_WARNING "UDPLite: partial coverage %d while full coverage %d requested\n",
+				       UDP_SKB_CB(skb)->cscov, skb->len);
 			goto drop;
 		}
 		/* The next case involves violating the min. coverage requested
@@ -1459,9 +1460,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		 * Therefore the above ...()->partial_cov statement is essential.
 		 */
 		if (UDP_SKB_CB(skb)->cscov  <  up->pcrlen) {
-			LIMIT_NETDEBUG(KERN_WARNING
-				"UDPLITE: coverage %d too small, need min %d\n",
-				UDP_SKB_CB(skb)->cscov, up->pcrlen);
+			LIMIT_NETDEBUG(KERN_WARNING "UDPLite: coverage %d too small, need min %d\n",
+				       UDP_SKB_CB(skb)->cscov, up->pcrlen);
 			goto drop;
 		}
 	}
@@ -1689,13 +1689,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %pI4:%u %d/%d to %pI4:%u\n",
-		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
-		       &saddr,
-		       ntohs(uh->source),
-		       ulen,
-		       skb->len,
-		       &daddr,
-		       ntohs(uh->dest));
+		       proto == IPPROTO_UDPLITE ? "Lite" : "",
+		       &saddr, ntohs(uh->source),
+		       ulen, skb->len,
+		       &daddr, ntohs(uh->dest));
 	goto drop;
 
 csum_error:
@@ -1704,11 +1701,8 @@ csum_error:
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
 	 */
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %pI4:%u to %pI4:%u ulen %d\n",
-		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
-		       &saddr,
-		       ntohs(uh->source),
-		       &daddr,
-		       ntohs(uh->dest),
+		       proto == IPPROTO_UDPLITE ? "Lite" : "",
+		       &saddr, ntohs(uh->source), &daddr, ntohs(uh->dest),
 		       ulen);
 drop:
 	UDP_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 280bfb1..2c46acd 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -10,6 +10,9 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  */
+
+#define pr_fmt(fmt) "UDPLite: " fmt
+
 #include <linux/export.h>
 #include "udp_impl.h"
 
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 5b48f49..05a5df2 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -3,6 +3,8 @@
  * Copyright (C) 2003 David S. Miller (davem@redhat.com)
  */
 
+#define pr_fmt(fmt) "IPsec: " fmt
+
 #include <linux/skbuff.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
-- 
1.7.8.111.gad25c.dirty
