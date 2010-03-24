From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/2] ipv4: Cleanup struct net dereference in rt_intern_hash
Date: Wed, 24 Mar 2010 20:43:17 +0300
Message-ID: <4BAA4F35.3000903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33563 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756435Ab0CXRnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 13:43:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need in getting it 3 times and gcc isn't smart enough
to understand this himself.

This is just a cleanup before the fix (next patch).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 32d3961..28c1c2f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1212,11 +1212,11 @@ restart:
 		    slow_chain_length(rt_hash_table[hash].chain) > rt_chain_length_max) {
 			struct net *net = dev_net(rt->u.dst.dev);
 			int num = ++net->ipv4.current_rt_cache_rebuild_count;
-			if (!rt_caching(dev_net(rt->u.dst.dev))) {
+			if (!rt_caching(net)) {
 				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching disabled\n",
 					rt->u.dst.dev->name, num);
 			}
-			rt_emergency_hash_rebuild(dev_net(rt->u.dst.dev));
+			rt_emergency_hash_rebuild(net);
 		}
 	}
 
