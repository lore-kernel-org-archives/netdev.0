From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v3 20/23] net/core:  rename random32() to prandom_u32()
Date: Mon,  4 Mar 2013 21:58:28 +0900
Message-ID: <1362401911-14074-21-git-send-email-akinobu.mita@gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:47017 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757486Ab3CDM75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 07:59:57 -0500
In-Reply-To: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

No change from v2

 net/core/pktgen.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6048fc1..4582275 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2198,7 +2198,7 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 				pkt_dev->curfl = 0; /*reset */
 		}
 	} else {
-		flow = random32() % pkt_dev->cflows;
+		flow = prandom_u32() % pkt_dev->cflows;
 		pkt_dev->curfl = flow;
 
 		if (pkt_dev->flows[flow].count > pkt_dev->lflow) {
@@ -2246,7 +2246,7 @@ static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
 	else if (pkt_dev->queue_map_min <= pkt_dev->queue_map_max) {
 		__u16 t;
 		if (pkt_dev->flags & F_QUEUE_MAP_RND) {
-			t = random32() %
+			t = prandom_u32() %
 				(pkt_dev->queue_map_max -
 				 pkt_dev->queue_map_min + 1)
 				+ pkt_dev->queue_map_min;
@@ -2278,7 +2278,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACSRC_RND)
-			mc = random32() % pkt_dev->src_mac_count;
+			mc = prandom_u32() % pkt_dev->src_mac_count;
 		else {
 			mc = pkt_dev->cur_src_mac_offset++;
 			if (pkt_dev->cur_src_mac_offset >=
@@ -2304,7 +2304,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACDST_RND)
-			mc = random32() % pkt_dev->dst_mac_count;
+			mc = prandom_u32() % pkt_dev->dst_mac_count;
 
 		else {
 			mc = pkt_dev->cur_dst_mac_offset++;
@@ -2331,21 +2331,21 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
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
 
@@ -2358,7 +2358,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 	if (pkt_dev->udp_dst_min < pkt_dev->udp_dst_max) {
 		if (pkt_dev->flags & F_UDPDST_RND) {
-			pkt_dev->cur_udp_dst = random32() %
+			pkt_dev->cur_udp_dst = prandom_u32() %
 				(pkt_dev->udp_dst_max - pkt_dev->udp_dst_min)
 				+ pkt_dev->udp_dst_min;
 		} else {
@@ -2375,7 +2375,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		if (imn < imx) {
 			__u32 t;
 			if (pkt_dev->flags & F_IPSRC_RND)
-				t = random32() % (imx - imn) + imn;
+				t = prandom_u32() % (imx - imn) + imn;
 			else {
 				t = ntohl(pkt_dev->cur_saddr);
 				t++;
@@ -2396,7 +2396,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				__be32 s;
 				if (pkt_dev->flags & F_IPDST_RND) {
 
-					t = random32() % (imx - imn) + imn;
+					t = prandom_u32() % (imx - imn) + imn;
 					s = htonl(t);
 
 					while (ipv4_is_loopback(s) ||
@@ -2404,7 +2404,8 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					       ipv4_is_lbcast(s) ||
 					       ipv4_is_zeronet(s) ||
 					       ipv4_is_local_multicast(s)) {
-						t = random32() % (imx - imn) + imn;
+						t = prandom_u32() %
+							(imx - imn) + imn;
 						s = htonl(t);
 					}
 					pkt_dev->cur_daddr = s;
@@ -2437,7 +2438,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 
 			for (i = 0; i < 4; i++) {
 				pkt_dev->cur_in6_daddr.s6_addr32[i] =
-				    (((__force __be32)random32() |
+				    (((__force __be32)prandom_u32() |
 				      pkt_dev->min_in6_daddr.s6_addr32[i]) &
 				     pkt_dev->max_in6_daddr.s6_addr32[i]);
 			}
@@ -2447,7 +2448,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->min_pkt_size < pkt_dev->max_pkt_size) {
 		__u32 t;
 		if (pkt_dev->flags & F_TXSIZE_RND) {
-			t = random32() %
+			t = prandom_u32() %
 				(pkt_dev->max_pkt_size - pkt_dev->min_pkt_size)
 				+ pkt_dev->min_pkt_size;
 		} else {
-- 
1.8.1.2
