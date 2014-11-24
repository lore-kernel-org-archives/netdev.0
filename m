From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/17] netfilter: fix various sparse warnings
Date: Mon, 24 Nov 2014 14:27:49 +0100
Message-ID: <1416835674-11871-13-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44906 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859AbaKXNZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:59 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

net/bridge/br_netfilter.c:870:6: symbol 'br_netfilter_enable' was not declared. Should it be static?
  no; add include
net/ipv4/netfilter/nft_reject_ipv4.c:22:6: symbol 'nft_reject_ipv4_eval' was not declared. Should it be static?
  yes
net/ipv6/netfilter/nf_reject_ipv6.c:16:6: symbol 'nf_send_reset6' was not declared. Should it be static?
  no; add include
net/ipv6/netfilter/nft_reject_ipv6.c:22:6: symbol 'nft_reject_ipv6_eval' was not declared. Should it be static?
  yes
net/netfilter/core.c:33:32: symbol 'nf_ipv6_ops' was not declared. Should it be static?
  no; add include
net/netfilter/xt_DSCP.c:40:57: cast truncates bits from constant value (ffffff03 becomes 3)
net/netfilter/xt_DSCP.c:57:59: cast truncates bits from constant value (ffffff03 becomes 3)
  add __force, 3 is what we want.
net/ipv4/netfilter/nf_log_arp.c:77:6: symbol 'nf_log_arp_packet' was not declared. Should it be static?
  yes
net/ipv4/netfilter/nf_reject_ipv4.c:17:6: symbol 'nf_send_reset' was not declared. Should it be static?
  no; add include

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c            |    1 +
 net/ipv4/netfilter/nf_log_arp.c      |   12 ++++++------
 net/ipv4/netfilter/nf_reject_ipv4.c  |    1 +
 net/ipv4/netfilter/nft_reject_ipv4.c |    7 +++----
 net/ipv6/netfilter/nf_reject_ipv6.c  |    1 +
 net/ipv6/netfilter/nft_reject_ipv6.c |    7 +++----
 net/netfilter/core.c                 |    1 +
 net/netfilter/xt_DSCP.c              |    6 ++++--
 8 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1bada53..f81dc33 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -35,6 +35,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/route.h>
+#include <net/netfilter/br_netfilter.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index 0c8799a..d059182 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -75,12 +75,12 @@ static void dump_arp_packet(struct nf_log_buf *m,
 		       ap->mac_src, ap->ip_src, ap->mac_dst, ap->ip_dst);
 }
 
-void nf_log_arp_packet(struct net *net, u_int8_t pf,
-		      unsigned int hooknum, const struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      const struct nf_loginfo *loginfo,
-		      const char *prefix)
+static void nf_log_arp_packet(struct net *net, u_int8_t pf,
+			      unsigned int hooknum, const struct sk_buff *skb,
+			      const struct net_device *in,
+			      const struct net_device *out,
+			      const struct nf_loginfo *loginfo,
+			      const char *prefix)
 {
 	struct nf_log_buf *m;
 
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 92b303d..cdcb9a5 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -11,6 +11,7 @@
 #include <net/tcp.h>
 #include <net/route.h>
 #include <net/dst.h>
+#include <net/netfilter/ipv4/nf_reject.h>
 #include <linux/netfilter_ipv4.h>
 
 /* Send RST reply */
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index ed33299..d729542 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -19,9 +19,9 @@
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/nft_reject.h>
 
-void nft_reject_ipv4_eval(const struct nft_expr *expr,
-			  struct nft_data data[NFT_REG_MAX + 1],
-			  const struct nft_pktinfo *pkt)
+static void nft_reject_ipv4_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 
@@ -36,7 +36,6 @@ void nft_reject_ipv4_eval(const struct nft_expr *expr,
 
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
-EXPORT_SYMBOL_GPL(nft_reject_ipv4_eval);
 
 static struct nft_expr_type nft_reject_ipv4_type;
 static const struct nft_expr_ops nft_reject_ipv4_ops = {
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 20d9def..87576ff 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -11,6 +11,7 @@
 #include <net/ip6_route.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_checksum.h>
+#include <net/netfilter/ipv6/nf_reject.h>
 #include <linux/netfilter_ipv6.h>
 
 void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
diff --git a/net/ipv6/netfilter/nft_reject_ipv6.c b/net/ipv6/netfilter/nft_reject_ipv6.c
index 0bc19fa..f732859 100644
--- a/net/ipv6/netfilter/nft_reject_ipv6.c
+++ b/net/ipv6/netfilter/nft_reject_ipv6.c
@@ -19,9 +19,9 @@
 #include <net/netfilter/nft_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
 
-void nft_reject_ipv6_eval(const struct nft_expr *expr,
-			  struct nft_data data[NFT_REG_MAX + 1],
-			  const struct nft_pktinfo *pkt)
+static void nft_reject_ipv6_eval(const struct nft_expr *expr,
+				 struct nft_data data[NFT_REG_MAX + 1],
+				 const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
@@ -38,7 +38,6 @@ void nft_reject_ipv6_eval(const struct nft_expr *expr,
 
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
-EXPORT_SYMBOL_GPL(nft_reject_ipv6_eval);
 
 static struct nft_expr_type nft_reject_ipv6_type;
 static const struct nft_expr_ops nft_reject_ipv6_ops = {
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 024a2e2..fea9ef5 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -17,6 +17,7 @@
 #include <linux/interrupt.h>
 #include <linux/if.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/inetdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/mutex.h>
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index ae82716..3f83d38 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -37,7 +37,8 @@ dscp_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		if (!skb_make_writable(skb, sizeof(struct iphdr)))
 			return NF_DROP;
 
-		ipv4_change_dsfield(ip_hdr(skb), (__u8)(~XT_DSCP_MASK),
+		ipv4_change_dsfield(ip_hdr(skb),
+				    (__force __u8)(~XT_DSCP_MASK),
 				    dinfo->dscp << XT_DSCP_SHIFT);
 
 	}
@@ -54,7 +55,8 @@ dscp_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
 			return NF_DROP;
 
-		ipv6_change_dsfield(ipv6_hdr(skb), (__u8)(~XT_DSCP_MASK),
+		ipv6_change_dsfield(ipv6_hdr(skb),
+				    (__force __u8)(~XT_DSCP_MASK),
 				    dinfo->dscp << XT_DSCP_SHIFT);
 	}
 	return XT_CONTINUE;
-- 
1.7.10.4
