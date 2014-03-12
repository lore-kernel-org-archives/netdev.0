From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/6] net: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:17 -0700
Message-ID: <5bc6ebcb56edc59ea478416474fbbe52200a8cb2.1394643455.git.joe@perches.com>
References: <cover.1394643455.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c            | 10 +++++-----
 net/core/flow_dissector.c | 14 +++++++-------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..587f9fb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3495,11 +3495,11 @@ EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_ARP):
-	case __constant_htons(ETH_P_IP):
-	case __constant_htons(ETH_P_IPV6):
-	case __constant_htons(ETH_P_8021Q):
-	case __constant_htons(ETH_P_8021AD):
+	case htons(ETH_P_ARP):
+	case htons(ETH_P_IP):
+	case htons(ETH_P_IPV6):
+	case htons(ETH_P_8021Q):
+	case htons(ETH_P_8021AD):
 		return true;
 	default:
 		return false;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e29e810..80201bf 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -61,7 +61,7 @@ bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
 
 again:
 	switch (proto) {
-	case __constant_htons(ETH_P_IP): {
+	case htons(ETH_P_IP): {
 		const struct iphdr *iph;
 		struct iphdr _iph;
 ip:
@@ -77,7 +77,7 @@ ip:
 		iph_to_flow_copy_addrs(flow, iph);
 		break;
 	}
-	case __constant_htons(ETH_P_IPV6): {
+	case htons(ETH_P_IPV6): {
 		const struct ipv6hdr *iph;
 		struct ipv6hdr _iph;
 ipv6:
@@ -91,8 +91,8 @@ ipv6:
 		nhoff += sizeof(struct ipv6hdr);
 		break;
 	}
-	case __constant_htons(ETH_P_8021AD):
-	case __constant_htons(ETH_P_8021Q): {
+	case htons(ETH_P_8021AD):
+	case htons(ETH_P_8021Q): {
 		const struct vlan_hdr *vlan;
 		struct vlan_hdr _vlan;
 
@@ -104,7 +104,7 @@ ipv6:
 		nhoff += sizeof(*vlan);
 		goto again;
 	}
-	case __constant_htons(ETH_P_PPP_SES): {
+	case htons(ETH_P_PPP_SES): {
 		struct {
 			struct pppoe_hdr hdr;
 			__be16 proto;
@@ -115,9 +115,9 @@ ipv6:
 		proto = hdr->proto;
 		nhoff += PPPOE_SES_HLEN;
 		switch (proto) {
-		case __constant_htons(PPP_IP):
+		case htons(PPP_IP):
 			goto ip;
-		case __constant_htons(PPP_IPV6):
+		case htons(PPP_IPV6):
 			goto ipv6;
 		default:
 			return false;
-- 
1.8.1.2.459.gbcd45b4.dirty
