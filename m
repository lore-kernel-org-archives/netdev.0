From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/7] ipv6: addrconf: do not block BH in ipv6_chk_home_addr()
Date: Mon, 23 Oct 2017 16:17:51 -0700
Message-ID: <20171023231751.29530-8-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:47020 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdJWXSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:11 -0400
Received: by mail-it0-f66.google.com with SMTP id f187so7900844itb.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:11 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu_read_lock() is enough here, no need to block BH.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9232e9537082ea44f5e0af4e4b0d052d780395fd..5a8a10229a07fe3d3f96b237e744332c192a509f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4248,8 +4248,8 @@ int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 	struct inet6_ifaddr *ifp = NULL;
 	int ret = 0;
 
-	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -4258,7 +4258,7 @@ int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 			break;
 		}
 	}
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 	return ret;
 }
 #endif
-- 
2.15.0.rc0.271.g36b669edcc-goog
