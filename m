From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: move the anycast_src_echo_reply sysctl to netns_sysctl_ipv6
Date: Mon, 13 Jan 2014 15:59:01 +0100
Message-ID: <1389625141-3076-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.smtpout.orange.fr ([80.12.242.124]:51292 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAMPSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 10:18:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change move anycast_src_echo_reply sysctl with other ipv6 sysctls.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 include/net/netns/ipv6.h   |    2 +-
 net/ipv6/icmp.c            |    2 +-
 net/ipv6/sysctl_net_ipv6.c |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 76fc7d1..592fecd 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -28,6 +28,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_mtu_expires;
 	int ip6_rt_min_advmss;
 	int icmpv6_time;
+	int anycast_src_echo_reply;
 };
 
 struct netns_ipv6 {
@@ -73,7 +74,6 @@ struct netns_ipv6 {
 #endif
 	atomic_t		dev_addr_genid;
 	atomic_t		rt_genid;
-	int			anycast_src_echo_reply;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9a809a4..13640f2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -557,7 +557,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	saddr = &ipv6_hdr(skb)->daddr;
 
 	if (!ipv6_unicast_destination(skb) &&
-	    !(net->ipv6.anycast_src_echo_reply &&
+	    !(net->ipv6.sysctl.anycast_src_echo_reply &&
 	      ipv6_anycast_destination(skb)))
 		saddr = NULL;
 
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 6b6a2c8..b51b268 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -26,7 +26,7 @@ static struct ctl_table ipv6_table_template[] = {
 	},
 	{
 		.procname	= "anycast_src_echo_reply",
-		.data		= &init_net.ipv6.anycast_src_echo_reply,
+		.data		= &init_net.ipv6.sysctl.anycast_src_echo_reply,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
@@ -58,7 +58,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	if (!ipv6_table)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
-	ipv6_table[1].data = &net->ipv6.anycast_src_echo_reply;
+	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
