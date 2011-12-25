From: pablo@netfilter.org
Subject: [PATCH 01/19] net: ipv4: export fib_lookup and fib_table_lookup
Date: Sun, 25 Dec 2011 02:57:17 +0100
Message-ID: <1324778255-2830-2-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55977 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314Ab1LYB5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:57:51 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The reverse path filter module will use fib_lookup.

If CONFIG_IP_MULTIPLE_TABLES is not set, fib_lookup is
only a static inline helper that calls fib_table_lookup,
so export that too.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/fib_rules.c |    1 +
 net/ipv4/fib_trie.c  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 46339ba..799fc79 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -67,6 +67,7 @@ int fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(fib_lookup);
 
 static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 			    int flags, struct fib_lookup_arg *arg)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 37b6711..d04b13a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1607,6 +1607,7 @@ found:
 	rcu_read_unlock();
 	return ret;
 }
+EXPORT_SYMBOL_GPL(fib_table_lookup);
 
 /*
  * Remove the leaf and return parent.
-- 
1.7.2.5
