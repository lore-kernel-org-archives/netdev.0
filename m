From: kaber@trash.net
Subject: [PATCH 1/7] netfilter: ipvs: fix compiler warnings
Date: Mon, 31 Jan 2011 21:10:14 +0100
Message-ID: <1296504620-820-2-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59939 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab1AaUKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 15:10:34 -0500
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Fix compiler warnings when no transport protocol load balancing support
is configured.

[horms@verge.net.au: removed suprious __ip_vs_cleanup() clean-up hunk]
Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c   |    4 ++++
 net/netfilter/ipvs/ip_vs_proto.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 09ca2ce..68b8033 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2062,7 +2062,9 @@ static const struct file_operations ip_vs_stats_percpu_fops = {
  */
 static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 {
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
 	struct ip_vs_proto_data *pd;
+#endif
 
 	IP_VS_DBG(2, "Setting timeout tcp:%d tcpfin:%d udp:%d\n",
 		  u->tcp_timeout,
@@ -2405,7 +2407,9 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 static inline void
 __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 {
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP)
 	struct ip_vs_proto_data *pd;
+#endif
 
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	pd = ip_vs_proto_data_get(net, IPPROTO_TCP);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 6ac986c..17484a4 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -60,6 +60,9 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return 0;
 }
 
+#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP) || \
+    defined(CONFIG_IP_VS_PROTO_SCTP) || defined(CONFIG_IP_VS_PROTO_AH) || \
+    defined(CONFIG_IP_VS_PROTO_ESP)
 /*
  *	register an ipvs protocols netns related data
  */
@@ -85,6 +88,7 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 
 	return 0;
 }
+#endif
 
 /*
  *	unregister an ipvs protocol
-- 
1.7.2.3

