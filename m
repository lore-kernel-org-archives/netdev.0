From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25 18/19] [NETNS] Replace init_net with the correct context in fib_frontend.c
Date: Wed, 19 Dec 2007 18:24:48 +0300
Message-ID: <1198077889-10693-19-git-send-email-den@openvz.org>
References: <4769370F.5020303@openvz.org>
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:63352 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756558AbXLSPXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 10:23:31 -0500
In-Reply-To: <4769370F.5020303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_frontend.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a5c47fc..a5e2fb3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -597,7 +594,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	if (err < 0)
 		goto errout;
 
-	tb = fib_new_table(&init_net, cfg.fc_table);
+	tb = fib_new_table(net, cfg.fc_table);
 	if (tb == NULL) {
 		err = -ENOBUFS;
 		goto errout;
@@ -794,7 +785,7 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
-		if (inet_addr_type(&init_net, ifa->ifa_local) != RTN_LOCAL) {
+		if (inet_addr_type(dev->nd_net, ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			   We must flush stray FIB entries.
 
@@ -802,7 +793,7 @@ static void fib_del_ifaddr(struct in_ifaddr *ifa)
 			   for stray nexthop entries, then ignite fib_flush.
 			*/
 			if (fib_sync_down(ifa->ifa_local, NULL, 0))
-				fib_flush(&init_net);
+				fib_flush(dev->nd_net);
 		}
 	}
 #undef LOCAL_OK
@@ -894,7 +885,7 @@ static void nl_fib_lookup_exit(struct net *net)
 static void fib_disable_ip(struct net_device *dev, int force)
 {
 	if (fib_sync_down(0, dev, force))
-		fib_flush(&init_net);
+		fib_flush(dev->nd_net);
 	rt_cache_flush(0);
 	arp_ifdown(dev);
 }
-- 
1.5.3.rc5

