From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Remove tb_peers from fib_table.
Date: Thu, 12 Jul 2012 09:46:45 -0700 (PDT)
Message-ID: <20120712.094645.1971211672785513777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233Ab2GLQqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:46:47 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3912058347C
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 09:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h |    1 -
 net/ipv4/fib_trie.c  |    3 ---
 2 files changed, 4 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 000c467..e91fedd 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -162,7 +162,6 @@ struct fib_table {
 	u32			tb_id;
 	int			tb_default;
 	int			tb_num_default;
-	struct inet_peer_base	tb_peers;
 	unsigned long		tb_data[0];
 };
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9b0f259..18cbc15 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1843,8 +1843,6 @@ int fib_table_flush(struct fib_table *tb)
 	if (ll && hlist_empty(&ll->list))
 		trie_leaf_remove(t, ll);
 
-	inetpeer_invalidate_tree(&tb->tb_peers);
-
 	pr_debug("trie_flush found=%d\n", found);
 	return found;
 }
@@ -1993,7 +1991,6 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_id = id;
 	tb->tb_default = -1;
 	tb->tb_num_default = 0;
-	inet_peer_base_init(&tb->tb_peers);
 
 	t = (struct trie *) tb->tb_data;
 	memset(t, 0, sizeof(*t));
-- 
1.7.10.4
