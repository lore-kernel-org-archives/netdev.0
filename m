From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] inet: fix NULL pointer Oops in fib(6)_rule_suppress
Date: Sun, 8 Dec 2013 20:18:28 +0100
Message-ID: <20131208191828.GS23153@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, daniel.golle@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:44506 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3LHTSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 14:18:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Daniel Golle <daniel.golle@gmail.com>
Tested-by: Daniel Golle <daniel.golle@gmail.com>
Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 net/ipv4/fib_rules.c  |    5 ++++-
 net/ipv6/fib6_rules.c |    6 +++++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 523be38..f2e1573 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -104,7 +104,10 @@ errout:
 static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
 	struct fib_result *result = (struct fib_result *) arg->result;
-	struct net_device *dev = result->fi->fib_dev;
+	struct net_device *dev = NULL;
+
+	if (result->fi)
+		dev = result->fi->fib_dev;
 
 	/* do not accept result if the route does
 	 * not meet the required prefix length
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index e275916..3fd0a57 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -122,7 +122,11 @@ out:
 static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
 	struct rt6_info *rt = (struct rt6_info *) arg->result;
-	struct net_device *dev = rt->rt6i_idev->dev;
+	struct net_device *dev = NULL;
+
+	if (rt->rt6i_idev)
+		dev = rt->rt6i_idev->dev;
+
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-- 
1.7.10.4
