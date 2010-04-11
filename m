From: kaber@trash.net
Subject: [RFC PATCH 2/9] net: fib_rules: set family in fib_rule_hdr centrally
Date: Sun, 11 Apr 2010 19:37:08 +0200
Message-ID: <1271007435-20035-3-git-send-email-kaber@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37499 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528Ab0DKRhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:19 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id 5DFEEB2C4E
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:18 +0200 (MEST)
In-Reply-To: <1271007435-20035-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

All fib_rules implementations need to set the family in their ->fill()
functions. Since the value is available to the generic fib_nl_fill_rule()
function, set it there.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/core/fib_rules.c  |    1 +
 net/decnet/dn_rules.c |    1 -
 net/ipv4/fib_rules.c  |    1 -
 net/ipv6/fib6_rules.c |    1 -
 4 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index ca8215a..9ac60ec 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -534,6 +534,7 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 		return -EMSGSIZE;
 
 	frh = nlmsg_data(nlh);
+	frh->family = ops->family;
 	frh->table = rule->table;
 	NLA_PUT_U32(skb, FRA_TABLE, rule->table);
 	frh->res1 = 0;
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 2d14093..1c8cc6d 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -196,7 +196,6 @@ static int dn_fib_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 {
 	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
 
-	frh->family = AF_DECnet;
 	frh->dst_len = r->dst_len;
 	frh->src_len = r->src_len;
 	frh->tos = 0;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 73b6784..a18355e 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -213,7 +213,6 @@ static int fib4_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 {
 	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
-	frh->family = AF_INET;
 	frh->dst_len = rule4->dst_len;
 	frh->src_len = rule4->src_len;
 	frh->tos = rule4->tos;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 5e463c4..92b2b7f 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -208,7 +208,6 @@ static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 {
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
-	frh->family = AF_INET6;
 	frh->dst_len = rule6->dst.plen;
 	frh->src_len = rule6->src.plen;
 	frh->tos = rule6->tclass;
-- 
1.7.0.4

