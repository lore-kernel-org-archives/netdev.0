From: roy.qing.li@gmail.com
Subject: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr()
Date: Tue,  1 Nov 2011 13:30:55 +0800
Message-ID: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35412 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab1KAFbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 01:31:05 -0400
Received: by gyb13 with SMTP id 13so6679307gyb.19
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 22:31:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

Replace hlist_for_each_entry and hlist_for_each_entry_rcu with
hlist_for_each_entry_rcu_bh() in ipv6_chk_same_addr and
ipv6_chk_addr to keep that all dereference methods for addr_list
are same, and take advantage of _rcu_bh() critical section
checking and prevention from compiler merging or refetching.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e39239e..5ad7d5f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1279,7 +1279,7 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
+	hlist_for_each_entry_rcu_bh(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -1303,7 +1303,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
 
-	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
+	hlist_for_each_entry_rcu_bh(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
-- 
1.7.1
