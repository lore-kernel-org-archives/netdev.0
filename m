From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fib: fix incorrect call_rcu_bh()
Date: Tue, 07 Aug 2012 12:47:11 +0200
Message-ID: <1344336431.28967.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65252 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab2HGKrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 06:47:16 -0400
Received: by bkwj10 with SMTP id j10so1385989bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 03:47:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After IP route cache removal, I believe rcu_bh() has very little use and
we should remove this RCU variant, since it adds some cycles in fast
path.

Anyway, the call_rcu_bh() use in fib_true is obviously wrong, since
some users only assert rcu_read_lock().

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
---
 net/ipv4/fib_trie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f0cdb30..57bd978 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -367,7 +367,7 @@ static void __leaf_free_rcu(struct rcu_head *head)
 
 static inline void free_leaf(struct leaf *l)
 {
-	call_rcu_bh(&l->rcu, __leaf_free_rcu);
+	call_rcu(&l->rcu, __leaf_free_rcu);
 }
 
 static inline void free_leaf_info(struct leaf_info *leaf)
