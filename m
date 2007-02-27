From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] pktgen: don't use __constant_htonl()
Date: Tue, 27 Feb 2007 12:12:01 -0800
Message-ID: <20070227121201.66cfe0da@freekitty>
References: <20070227120447.55a7e39d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52665 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbXB0VTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 16:19:44 -0500
In-Reply-To: <20070227120447.55a7e39d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The existing htonl() macro is smart enough to do the same code as
using __constant_htonl() and it looks cleaner.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/core/pktgen.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- pktgen.orig/net/core/pktgen.c	2007-02-26 14:40:31.000000000 -0800
+++ pktgen/net/core/pktgen.c	2007-02-26 15:36:38.000000000 -0800
@@ -167,7 +167,7 @@
 #define LAT_BUCKETS_MAX 32
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
-#define MPLS_STACK_BOTTOM __constant_htonl(0x00000100)
+#define MPLS_STACK_BOTTOM htonl(0x00000100)
 
 /* Device flag bits */
 #define F_IPSRC_RND   (1<<0)	/* IP-Src Random  */
@@ -2297,7 +2297,7 @@
 	int datalen, iplen;
 	struct iphdr *iph;
 	struct pktgen_hdr *pgh = NULL;
-	__be16 protocol = __constant_htons(ETH_P_IP);
+	__be16 protocol = htons(ETH_P_IP);
 	__be32 *mpls;
 	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
@@ -2306,10 +2306,10 @@
 
 
 	if (pkt_dev->nr_labels)
-		protocol = __constant_htons(ETH_P_MPLS_UC);
+		protocol = htons(ETH_P_MPLS_UC);
 
 	if (pkt_dev->vlan_id != 0xffff)
-		protocol = __constant_htons(ETH_P_8021Q);
+		protocol = htons(ETH_P_8021Q);
 
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
@@ -2341,14 +2341,14 @@
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
 			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
-			*svlan_encapsulated_proto = __constant_htons(ETH_P_8021Q);
+			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
 		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
 		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
-		*vlan_encapsulated_proto = __constant_htons(ETH_P_IP);
+		*vlan_encapsulated_proto = htons(ETH_P_IP);
 	}
 
 	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
@@ -2635,7 +2635,7 @@
 	int datalen;
 	struct ipv6hdr *iph;
 	struct pktgen_hdr *pgh = NULL;
-	__be16 protocol = __constant_htons(ETH_P_IPV6);
+	__be16 protocol = htons(ETH_P_IPV6);
 	__be32 *mpls;
 	__be16 *vlan_tci = NULL;                 /* Encapsulates priority and VLAN ID */
 	__be16 *vlan_encapsulated_proto = NULL;  /* packet type ID field (or len) for VLAN tag */
@@ -2643,10 +2643,10 @@
 	__be16 *svlan_encapsulated_proto = NULL; /* packet type ID field (or len) for SVLAN tag */
 
 	if (pkt_dev->nr_labels)
-		protocol = __constant_htons(ETH_P_MPLS_UC);
+		protocol = htons(ETH_P_MPLS_UC);
 
 	if (pkt_dev->vlan_id != 0xffff)
-		protocol = __constant_htons(ETH_P_8021Q);
+		protocol = htons(ETH_P_8021Q);
 
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
@@ -2677,14 +2677,14 @@
 					       pkt_dev->svlan_cfi,
 					       pkt_dev->svlan_p);
 			svlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
-			*svlan_encapsulated_proto = __constant_htons(ETH_P_8021Q);
+			*svlan_encapsulated_proto = htons(ETH_P_8021Q);
 		}
 		vlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
 		*vlan_tci = build_tci(pkt_dev->vlan_id,
 				      pkt_dev->vlan_cfi,
 				      pkt_dev->vlan_p);
 		vlan_encapsulated_proto = (__be16 *)skb_put(skb, sizeof(__be16));
-		*vlan_encapsulated_proto = __constant_htons(ETH_P_IPV6);
+		*vlan_encapsulated_proto = htons(ETH_P_IPV6);
 	}
 
 	iph = (struct ipv6hdr *)skb_put(skb, sizeof(struct ipv6hdr));
@@ -2710,7 +2710,7 @@
 	udph->len = htons(datalen + sizeof(struct udphdr));
 	udph->check = 0;	/* No checksum */
 
-	*(__be32 *) iph = __constant_htonl(0x60000000);	/* Version + flow */
+	*(__be32 *) iph = htonl(0x60000000);	/* Version + flow */
 
 	if (pkt_dev->traffic_class) {
 		/* Version + traffic class + flow (0) */
