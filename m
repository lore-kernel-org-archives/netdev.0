From: greearb@candelatech.com
Subject: [PATCH] ipv6-multicast:  Fix memory leak in input path.
Date: Tue, 27 Sep 2011 11:58:17 -0700
Message-ID: <1317149897-14932-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47494 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab1I0TGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:06:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Have to free the skb before returning if we fail
the fib lookup.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e9a8df9... 86e3cc1... M	net/ipv6/ip6mr.c
 net/ipv6/ip6mr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e9a8df9..86e3cc1 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2053,8 +2053,10 @@ int ip6_mr_input(struct sk_buff *skb)
 	int err;
 
 	err = ip6mr_fib_lookup(net, &fl6, &mrt);
-	if (err < 0)
+	if (err < 0) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	read_lock(&mrt_lock);
 	cache = ip6mr_cache_find(mrt,
-- 
1.7.3.4
