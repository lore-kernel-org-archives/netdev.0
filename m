From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 02/16] net: export a few FIB functions
Date: Mon, 27 Jul 2015 12:30:55 -0600
Message-ID: <1438021869-49186-3-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37867 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbbG0Scx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:32:53 -0400
Received: by igbpg9 with SMTP id pg9so89320740igb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:32:53 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Required by the VRF driver.

Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c | 2 ++
 net/ipv4/fib_trie.c     | 1 +
 2 files changed, 3 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6b98de0d7949..c565fc182240 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -108,6 +108,7 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	hlist_add_head_rcu(&tb->tb_hlist, &net->ipv4.fib_table_hash[h]);
 	return tb;
 }
+EXPORT_SYMBOL_GPL(fib_new_table);
 
 /* caller must hold either rtnl or rcu read lock */
 struct fib_table *fib_get_table(struct net *net, u32 id)
@@ -127,6 +128,7 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 	}
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(fib_get_table);
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 static void fib_replace_table(struct net *net, struct fib_table *old,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 15d32612e3c6..ac2d828c6daa 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1887,6 +1887,7 @@ void fib_free_table(struct fib_table *tb)
 {
 	call_rcu(&tb->rcu, __trie_free_rcu);
 }
+EXPORT_SYMBOL_GPL(fib_free_table);
 
 static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			     struct sk_buff *skb, struct netlink_callback *cb)
-- 
2.3.2 (Apple Git-55)
