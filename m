From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/08: remove synchronize_net() calls in ip_queue/ip6_queue
Date: Thu,  3 Dec 2009 21:19:34 +0100 (MET)
Message-ID: <20091203201934.8831.81960.sendpatchset@x2.localnet>
References: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37694 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265AbZLCUT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:19:29 -0500
In-Reply-To: <20091203201931.8831.92922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9481721be10a1bfd1ee9ccf507eecd7f37caa5ec
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Nov 4 21:14:31 2009 +0100

    netfilter: remove synchronize_net() calls in ip_queue/ip6_queue
    
    nf_unregister_queue_handlers() already does a synchronize_rcu()
    call, we dont need to do it again in callers.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index c156db2..9811a45 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -622,7 +622,7 @@ cleanup_netlink_notifier:
 static void __exit ip_queue_fini(void)
 {
 	nf_unregister_queue_handlers(&nfqh);
-	synchronize_net();
+
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 1cf3f0c..a82016f 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -625,7 +625,7 @@ cleanup_netlink_notifier:
 static void __exit ip6_queue_fini(void)
 {
 	nf_unregister_queue_handlers(&nfqh);
-	synchronize_net();
+
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
