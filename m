From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/2] fib6: install fib6 ops in the last step
Date: Wed, 25 Mar 2015 14:45:02 -0700
Message-ID: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35947 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbCYVp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 17:45:26 -0400
Received: by pdbcz9 with SMTP id cz9so41132017pdb.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 14:45:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not commit the new ops until we finish
all the setup, otherwise we have to NULL it on failure.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/fib6_rules.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 27ca796..273eb26 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -299,19 +299,16 @@ static int __net_init fib6_rules_net_init(struct net *net)
 	ops = fib_rules_register(&fib6_rules_ops_template, net);
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
-	net->ipv6.fib6_rules_ops = ops;
-
 
-	err = fib_default_rule_add(net->ipv6.fib6_rules_ops, 0,
-				   RT6_TABLE_LOCAL, 0);
+	err = fib_default_rule_add(ops, 0, RT6_TABLE_LOCAL, 0);
 	if (err)
 		goto out_fib6_rules_ops;
 
-	err = fib_default_rule_add(net->ipv6.fib6_rules_ops,
-				   0x7FFE, RT6_TABLE_MAIN, 0);
+	err = fib_default_rule_add(ops, 0x7FFE, RT6_TABLE_MAIN, 0);
 	if (err)
 		goto out_fib6_rules_ops;
 
+	net->ipv6.fib6_rules_ops = ops;
 out:
 	return err;
 
-- 
1.8.3.1
