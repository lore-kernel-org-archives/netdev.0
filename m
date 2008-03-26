From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26][NETNS][ICMP]: Build fix for NET_NS=n case (dev->nd_net
 is omitted).
Date: Wed, 26 Mar 2008 12:16:07 +0300
Message-ID: <47EA1457.3010706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58332 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYCZJQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 05:16:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't check the kernel build after pulling dev->nd_net access 
optimization from net-2.6.26 tree :(

Sorry.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 7049b3f..3697e05 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -821,7 +821,7 @@ static void icmp_echo(struct sk_buff *skb)
 {
 	struct net *net;
 
-	net = skb->dst->dev->nd_net;
+	net = dev_net(skb->dst->dev);
 	if (!net->ipv4.sysctl_icmp_echo_ignore_all) {
 		struct icmp_bxm icmp_param;
 
@@ -1027,7 +1027,7 @@ int icmp_rcv(struct sk_buff *skb)
 	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
 		struct net *net;
 
-		net = rt->u.dst.dev->nd_net;
+		net = dev_net(rt->u.dst.dev);
 		/*
 		 *	RFC 1122: 3.2.2.6 An ICMP_ECHO to broadcast MAY be
 		 *	  silently ignored (we let user decide with a sysctl).
