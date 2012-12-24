From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 26/29] net/core:  rename random32() and net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:13 +0900
Message-ID: <1356315256-6572-27-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/core/neighbour.c |  4 ++--
 net/core/pktgen.c    | 29 +++++++++++++++--------------
 net/core/stream.c    |  2 +-
 3 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c815f28..6818badb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -123,7 +123,7 @@ static void neigh_cleanup_and_release(struct neighbour *neigh)
 
 unsigned long neigh_rand_reach_time(unsigned long base)
 {
-	return base ? (net_random() % base) + (base >> 1) : 0;
+	return base ? (prandom_u32() % base) + (base >> 1) : 0;
 }
 EXPORT_SYMBOL(neigh_rand_reach_time);
 
@@ -1402,7 +1402,7 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 		    struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
-	unsigned long sched_next = now + (net_random() % p->proxy_delay);
+	unsigned long sched_next = now + (prandom_u32() % p->proxy_delay);
 
 	if (tbl->proxy_queue.qlen > p->proxy_qlen) {
 		kfree_skb(skb);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b29dacf..d23ec86 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2182,7 +2182,7 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 				pkt_dev->curfl = 0; /*reset */
 		}
 	} else {
-		flow = random32() % pkt_dev->cflows;
+		flow = prandom_u32() % pkt_dev->cflows;
 		pkt_dev->curfl = flow;
 
 		if (pkt_dev->flows[flow].count > pkt_dev->lflow) {
@@ -2229,7 +2229,7 @@ static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
 	else if (pkt_dev->queue_map_min <= pkt_dev->queue_map_max) {
 		__u16 t;
 		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
-			t = random32() %
+			t = prandom_u32() %
 				(pkt_dev->queue_map_max -
 				 pkt_dev->queue_map_min + 1)
 				+ pkt_dev->queue_map_min;
@@ -2261,7 +2261,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACSRC_RND)
-			mc = random32() % pkt_dev->src_mac_count;
+			mc = prandom_u32() % pkt_dev->src_mac_count;
 		else {
 			mc = pkt_dev->cur_src_mac_offset++;
 			if (pkt_dev->cur_src_mac_offset >=
@@ -2287,7 +2287,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACDST_RND)
-			mc = random32() % pkt_dev->dst_mac_count;
+			mc = prandom_u32() % pkt_dev->dst_mac_count;
 
 		else {
 			mc = pkt_dev->cur_dst_mac_offset++;
@@ -2314,21 +2314,21 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		for (i = 0; i < pkt_dev->nr_labels; i++)
 			if (pkt_dev->labels[i] & MPLS_STACK_BOTTOM)
 				pkt_dev->labels[i] = MPLS_STACK_BOTTOM |
-					     ((__force __be32)random32() &
+					     ((__force __be32)prandom_u32() &
 						      htonl(0x000fffff));
 	}
 
 	if ((pkt_dev->flags & F_VID_RND) && (pkt_dev->vlan_id != 0xffff)) {
-		pkt_dev->vlan_id = random32() & (4096-1);
+		pkt_dev->vlan_id = prandom_u32() & (4096 - 1);
 	}
 
 	if ((pkt_dev->flags & F_SVID_RND) && (pkt_dev->svlan_id != 0xffff)) {
-		pkt_dev->svlan_id = random32() & (4096 - 1);
+		pkt_dev->svlan_id = prandom_u32() & (4096 - 1);
 	}
 
 	if (pkt_dev->udp_src_min < pkt_dev->udp_src_max) {
 		if (pkt_dev->flags & F_UDPSRC_RND)
-			pkt_dev->cur_udp_src = random32() %
+			pkt_dev->cur_udp_src = prandom_u32() %
 				(pkt_dev->udp_src_max - pkt_dev->udp_src_min)
 				+ pkt_dev->udp_src_min;
 
@@ -2341,7 +2341,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 	if (pkt_dev->udp_dst_min < pkt_dev->udp_dst_max) {
 		if (pkt_dev->flags & F_UDPDST_RND) {
-			pkt_dev->cur_udp_dst = random32() %
+			pkt_dev->cur_udp_dst = prandom_u32() %
 				(pkt_dev->udp_dst_max - pkt_dev->udp_dst_min)
 				+ pkt_dev->udp_dst_min;
 		} else {
@@ -2358,7 +2358,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		if (imn < imx) {
 			__u32 t;
 			if (pkt_dev->flags & F_IPSRC_RND)
-				t = random32() % (imx - imn) + imn;
+				t = prandom_u32() % (imx - imn) + imn;
 			else {
 				t = ntohl(pkt_dev->cur_saddr);
 				t++;
@@ -2379,7 +2379,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				__be32 s;
 				if (pkt_dev->flags & F_IPDST_RND) {
 
-					t = random32() % (imx - imn) + imn;
+					t = prandom_u32() % (imx - imn) + imn;
 					s = htonl(t);
 
 					while (ipv4_is_loopback(s) ||
@@ -2387,7 +2387,8 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					       ipv4_is_lbcast(s) ||
 					       ipv4_is_zeronet(s) ||
 					       ipv4_is_local_multicast(s)) {
-						t = random32() % (imx - imn) + imn;
+						t = prandom_u32() %
+							(imx - imn) + imn;
 						s = htonl(t);
 					}
 					pkt_dev->cur_daddr = s;
@@ -2420,7 +2421,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 			for (i = 0; i < 4; i++) {
 				pkt_dev->cur_in6_daddr.s6_addr32[i] =
-				    (((__force __be32)random32() |
+				    (((__force __be32)prandom_u32() |
 				      pkt_dev->min_in6_daddr.s6_addr32[i]) &
 				     pkt_dev->max_in6_daddr.s6_addr32[i]);
 			}
@@ -2430,7 +2431,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->min_pkt_size < pkt_dev->max_pkt_size) {
 		__u32 t;
 		if (pkt_dev->flags & F_TXSIZE_RND) {
-			t = random32() %
+			t = prandom_u32() %
 				(pkt_dev->max_pkt_size - pkt_dev->min_pkt_size)
 				+ pkt_dev->min_pkt_size;
 		} else {
diff --git a/net/core/stream.c b/net/core/stream.c
index f5df85d..6881f0c 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -122,7 +122,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 	DEFINE_WAIT(wait);
 
 	if (sk_stream_memory_free(sk))
-		current_timeo = vm_wait = (net_random() % (HZ / 5)) + 2;
+		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
 
 	while (1) {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
-- 
1.7.11.7
