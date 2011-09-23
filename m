From: greearb@candelatech.com
Subject: [PATCH] ipv6-multicast:  Fix memory leak in IPv6 multicast.
Date: Fri, 23 Sep 2011 16:11:01 -0700
Message-ID: <1316819461-3192-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36248 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab1IWXLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 19:11:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

If reg_vif_xmit cannot find a routing entry, be sure to
free the skb before returning the error.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 82a8099... e9a8df9... M	net/ipv6/ip6mr.c
 net/ipv6/ip6mr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 82a8099..e9a8df9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -696,8 +696,10 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 	int err;
 
 	err = ip6mr_fib_lookup(net, &fl6, &mrt);
-	if (err < 0)
+	if (err < 0) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
-- 
1.7.3.4
