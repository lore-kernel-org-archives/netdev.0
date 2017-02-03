From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/27] netfilter: xt_connlimit: use rb_entry()
Date: Fri,  3 Feb 2017 13:25:18 +0100
Message-ID: <1486124738-3013-8-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58958 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753252AbdBCM2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9A2CDC2B23
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8B644DA7E9
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9E13FDA808
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:33 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@gmail.com>

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 2aff2b7c4689..660b61dbd776 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -218,7 +218,7 @@ count_tree(struct net *net, struct rb_root *root,
 		int diff;
 		bool addit;
 
-		rbconn = container_of(*rbnode, struct xt_connlimit_rb, node);
+		rbconn = rb_entry(*rbnode, struct xt_connlimit_rb, node);
 
 		parent = *rbnode;
 		diff = same_source_net(addr, mask, &rbconn->addr, family);
@@ -398,7 +398,7 @@ static void destroy_tree(struct rb_root *r)
 	struct rb_node *node;
 
 	while ((node = rb_first(r)) != NULL) {
-		rbconn = container_of(node, struct xt_connlimit_rb, node);
+		rbconn = rb_entry(node, struct xt_connlimit_rb, node);
 
 		rb_erase(node, r);
 
-- 
2.1.4
