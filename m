From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 1/4] net: ipv4: export fib_lookup and fib_table_lookup
Date: Wed,  9 Nov 2011 23:19:45 +0100
Message-ID: <1320877188-1972-2-git-send-email-fw@strlen.de>
References: <1320877188-1972-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1320877188-1972-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reverse path filter module will use fib_lookup.

If CONFIG_IP_MULTIPLE_TABLES is not set, fib_lookup is
only a static inline helper that calls fib_table_lookup,
so export that too.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
1.7.3.4

