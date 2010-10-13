From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: remove a useless synchronize_rcu() call
Date: Wed, 13 Oct 2010 16:43:04 +0200
Message-ID: <1286980984.3876.679.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42565 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817Ab0JMOnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 10:43:09 -0400
Received: by wyb28 with SMTP id 28so1113238wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 07:43:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_nl_delrule() calls synchronize_rcu() for no apparent reason,
while rtnl is held.

I suspect it was done to avoid an atomic_inc_not_zero() in
fib_rules_lookup(), which commit 7fa7cb7109d07 added anyway.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/fib_rules.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 21698f8..1bc3f25 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -494,7 +494,6 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 			}
 		}
 
-		synchronize_rcu();
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).pid);
 		fib_rule_put(rule);


