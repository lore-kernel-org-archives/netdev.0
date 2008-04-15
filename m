From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/8 net-2.6.26] [NETNS]: Add netns refcnt debug for timewait buckets.
Date: Tue, 15 Apr 2008 16:37:50 +0400
Message-ID: <1208263075-28016-3-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45092 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759789AbYDOMiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:38:21 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/inet_timewait_sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a741378..ce16e9a 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -57,6 +57,7 @@ void inet_twsk_put(struct inet_timewait_sock *tw)
 		printk(KERN_DEBUG "%s timewait_sock %p released\n",
 		       tw->tw_prot->name, tw);
 #endif
+		release_net(twsk_net(tw));
 		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 		module_put(owner);
 	}
@@ -124,7 +125,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
-		twsk_net_set(tw, sock_net(sk));
+		twsk_net_set(tw, hold_net(sock_net(sk)));
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
-- 
1.5.3.rc5

