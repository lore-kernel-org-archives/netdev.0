From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 23/31: bridge: refcount fix
Date: Thu, 10 Sep 2009 18:12:16 +0200 (MEST)
Message-ID: <20090910161212.31179.82349.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbZIJQMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:13 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f3abc9b963e004b8c96cd7fbee6fd905f2bfd620
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Aug 24 19:35:38 2009 +0200

    netfilter: bridge: refcount fix
    
    commit f216f082b2b37c4943f1e7c393e2786648d48f6f
    ([NETFILTER]: bridge netfilter: deal with martians correctly)
    added a refcount leak on in_dev.
    
    Instead of using in_dev_get(), we can use __in_dev_get_rcu(),
    as netfilter hooks are running under rcu_read_lock(), as pointed
    by Patrick.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4fde742..907a82e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -359,7 +359,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 				},
 				.proto = 0,
 			};
-			struct in_device *in_dev = in_dev_get(dev);
+			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 			/* If err equals -EHOSTUNREACH the error is due to a
 			 * martian destination or due to the fact that
