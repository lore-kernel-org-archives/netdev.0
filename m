From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/3 net-2.6.25] Add netns to fib_rules_ops.
Date: Thu, 17 Jan 2008 13:09:16 +0300
Message-ID: <1200564558-7869-1-git-send-email-den@openvz.org>
References: <478F2933.1000007@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61340 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754554AbYAQKJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 05:09:18 -0500
In-Reply-To: <478F2933.1000007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The backward link from FIB rules operations to the network namespace will
allow to simplify the API a bit.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/fib_rules.h |    1 +
 net/decnet/dn_rules.c   |    1 +
 net/ipv4/fib_rules.c    |    2 ++
 net/ipv6/fib6_rules.c   |    1 +
 4 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 4f47250..6910e01 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -67,6 +67,7 @@ struct fib_rules_ops
 	const struct nla_policy	*policy;
 	struct list_head	rules_list;
 	struct module		*owner;
+	struct net		*fro_net;
 };
 
 #define FRA_GENERIC_POLICY \
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index c1fae23..964e658 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -249,6 +249,7 @@ static struct fib_rules_ops dn_fib_rules_ops = {
 	.policy		= dn_fib_rule_policy,
 	.rules_list	= LIST_HEAD_INIT(dn_fib_rules_ops.rules_list),
 	.owner		= THIS_MODULE,
+	.fro_net	= &init_net,
 };
 
 void __init dn_fib_rules_init(void)
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 72232ab..8d0ebe7 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -315,6 +315,8 @@ int __net_init fib4_rules_init(struct net *net)
 	if (ops == NULL)
 		return -ENOMEM;
 	INIT_LIST_HEAD(&ops->rules_list);
+	ops->fro_net = net;
+
 	fib_rules_register(net, ops);
 
 	err = fib_default_rules_init(ops);
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 76437a1..ead5ab2 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -249,6 +249,7 @@ static struct fib_rules_ops fib6_rules_ops = {
 	.policy			= fib6_rule_policy,
 	.rules_list		= LIST_HEAD_INIT(fib6_rules_ops.rules_list),
 	.owner			= THIS_MODULE,
+	.fro_net		= &init_net,
 };
 
 static int __init fib6_default_rules_init(void)
-- 
1.5.3.rc5

