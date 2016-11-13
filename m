From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/39] netfilter: remove comments that predate rcu days
Date: Sun, 13 Nov 2016 23:24:56 +0100
Message-ID: <1479075933-4491-3-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We cannot block/sleep on nf_iterate because netfilter runs under rcu
read lock these days, where blocking is well-known to be illegal. So
let's remove these old comments.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 3d4aa96cb219..76014ad72ec5 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -308,18 +308,11 @@ unsigned int nf_iterate(struct sk_buff *skb,
 {
 	unsigned int verdict;
 
-	/*
-	 * The caller must not block between calls to this
-	 * function because of risk of continuing from deleted element.
-	 */
 	while (*entryp) {
 		if (state->thresh > (*entryp)->ops.priority) {
 			*entryp = rcu_dereference((*entryp)->next);
 			continue;
 		}
-
-		/* Optimization: we don't need to hold module
-		   reference here, since function can't sleep. --RR */
 repeat:
 		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
 		if (verdict != NF_ACCEPT) {
-- 
2.1.4

