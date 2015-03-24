From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5 net-next] rhashtable: Extend RCU read lock into rhashtable_insert_rehash()
Date: Tue, 24 Mar 2015 14:18:16 +0100
Message-ID: <d12cd2734040e1cfb4fb04e78d51ec6c12a538c2.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34655 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbbCXNS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:27 -0400
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rhashtable_insert_rehash() requires RCU locks to be held in order
to access ht->tbl and traverse to the last table.

Fixes: ccd57b1bd324 ("rhashtable: Add immediate rehash during insertion")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index d7be9cb..5976ab5 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -585,8 +585,8 @@ restart:
 	if (unlikely(rht_grow_above_100(ht, tbl))) {
 slow_path:
 		spin_unlock_bh(lock);
-		rcu_read_unlock();
 		err = rhashtable_insert_rehash(ht);
+		rcu_read_unlock();
 		if (err)
 			return err;
 
-- 
1.9.3
