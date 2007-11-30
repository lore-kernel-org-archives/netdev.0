From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/4] net: prevent usage of flowi with not initialized
	fl_net in routing
Date: Fri, 30 Nov 2007 19:10:27 +0300
Message-ID: <20071130161027.GA10234@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:54854 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755306AbXK3QJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:09:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prevent usage of flowi with not initialized fl_net in routing. This is
a temporary measure to simplify maintenance of the patchset.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c      |    1 +
 net/ipv6/fib6_rules.c |    1 +
 net/ipv6/ip6_fib.c    |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 84a7f32..996fd9e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2444,6 +2444,7 @@ int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk,
 {
 	int err;
 
+	BUG_ON(flp->fl_net == NULL);
 	if ((err = __ip_route_output_key(rp, flp)) != 0)
 		return err;
 
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 428c6b0..326ea69 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -38,6 +38,7 @@ struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
 		.lookup_ptr = lookup,
 	};
 
+	BUG_ON(fl->fl_net == NULL);
 	fib_rules_lookup(&fib6_rules_ops, fl, flags, &arg);
 	if (arg.rule)
 		fib_rule_put(arg.rule);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 31b60a0..706cb72 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -282,6 +282,7 @@ struct fib6_table *fib6_get_table(u32 id)
 struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
 				   pol_lookup_t lookup)
 {
+	BUG_ON(fl->fl_net == NULL);
 	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags);
 }
 
-- 
1.5.3.rc5

