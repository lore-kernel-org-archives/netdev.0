From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib6: use FIB_LOOKUP_NOREF in fib6_rule_lookup()
Date: Wed, 13 Oct 2010 14:45:40 +0200
Message-ID: <1286973940.3876.423.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49430 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab0JMMpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 08:45:45 -0400
Received: by wyb28 with SMTP id 28so985620wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 05:45:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two atomic ops on found rule in fib6_rule_lookup()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/fib6_rules.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b1108ed..d829874 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -34,11 +34,10 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 {
 	struct fib_lookup_arg arg = {
 		.lookup_ptr = lookup,
+		.flags = FIB_LOOKUP_NOREF,
 	};
 
 	fib_rules_lookup(net->ipv6.fib6_rules_ops, fl, flags, &arg);
-	if (arg.rule)
-		fib_rule_put(arg.rule);
 
 	if (arg.result)
 		return arg.result;


