From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: ipv6: use common fib_default_rule_pref
Date: Wed,  2 Sep 2015 15:03:12 +0200
Message-ID: <1441198992-25359-1-git-send-email-phil@nwl.cc>
Cc: tgraf@suug.ch, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59856 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754628AbbIBNDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 09:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches IPv6 policy routing to use the shared
fib_default_rule_pref() function of IPv4 and DECnet. It is also used in
multicast routing for IPv4 as well as IPv6.

The motivation for this patch is a complaint about iproute2 behaving
inconsistent between IPv4 and IPv6 when adding policy rules: Formerly,
IPv6 rules were assigned a fixed priority of 0x3FFF whereas for IPv4 the
assigned priority value was decreased with each rule added.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/ipv6/fib6_rules.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 2367a16..a859ad2 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -258,11 +258,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static u32 fib6_rule_default_pref(struct fib_rules_ops *ops)
-{
-	return 0x3FFF;
-}
-
 static size_t fib6_rule_nlmsg_payload(struct fib_rule *rule)
 {
 	return nla_total_size(16) /* dst */
@@ -279,7 +274,7 @@ static const struct fib_rules_ops __net_initconst fib6_rules_ops_template = {
 	.configure		= fib6_rule_configure,
 	.compare		= fib6_rule_compare,
 	.fill			= fib6_rule_fill,
-	.default_pref		= fib6_rule_default_pref,
+	.default_pref		= fib_default_rule_pref,
 	.nlmsg_payload		= fib6_rule_nlmsg_payload,
 	.nlgroup		= RTNLGRP_IPV6_RULE,
 	.policy			= fib6_rule_policy,
-- 
2.1.2
