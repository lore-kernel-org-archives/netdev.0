From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv6: fix unappropriate errno returned for non-multicast
 address
Date: Tue, 17 Jul 2012 15:28:59 +0800
Message-ID: <5005143B.9000301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:46464 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab2GQH3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 03:29:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We need to check the passed in multicast address and return
appropriate errno(EINVAL) if it is not valid. And it's no need
to walk through the ipv6_mc_list in this situation.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/mcast.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 6d0f5dc..92f8e48 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -211,6 +211,9 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct ipv6_mc_socklist __rcu **lnk;
 	struct net *net = sock_net(sk);
 
+	if (!ipv6_addr_is_multicast(addr))
+		return -EINVAL;
+
 	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rcu_dereference_protected(*lnk,
-- 
1.7.1
