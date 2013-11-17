From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fix NULL pointer Oops in fib(6)_rule_suppress
Date: Sun, 17 Nov 2013 12:14:09 +0100
Message-ID: <20131117111409.GB23153@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Golle <daniel@makrotopia.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:54753 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab3KQLvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 06:51:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Daniel Golle <daniel.golle@gmail.com>
Tested-by: Daniel Golle <daniel.golle@gmail.com>
Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 net/ipv4/fib_rules.c  |    4 +++-
 net/ipv6/fib6_rules.c |    5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 523be38..4e1c1e5 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -104,7 +104,9 @@ errout:
 static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
 	struct fib_result *result = (struct fib_result *) arg->result;
-	struct net_device *dev = result->fi->fib_dev;
+	struct net_device *dev = NULL;
+	if (result->fi)
+		dev = result->fi->fib_dev;
 
 	/* do not accept result if the route does
 	 * not meet the required prefix length
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index e275916..43e45b5 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -122,7 +122,10 @@ out:
 static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
 	struct rt6_info *rt = (struct rt6_info *) arg->result;
-	struct net_device *dev = rt->rt6i_idev->dev;
+	struct net_device *dev = NULL;
+	if (rt->rt6i_idev)
+		dev = rt->rt6i_idev->dev;
+
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-- 
1.7.10.4
