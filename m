From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] macvlan/macvtap: Fix unicast between macvtap interfaces in bridge mode
Date: Sun, 18 Sep 2011 18:53:20 -0400
Message-ID: <1316386400-3470-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shlomo Pongratz <shlomop@mellanox.com>,
	Arnd Bergmann <arnd@arndb.de>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:39443 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932770Ab1IRXWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Sep 2011 19:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets should always be forwarded to the lowerdev using dev_forward_skb.
vlan->forward is for packets being forwarded directly to another macvlan/
macvtap device (used for multicast in bridge mode).

Reported-and-tested-by: Shlomo Pongratz <shlomop@mellanox.com>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/macvlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 05172c3..376e3e9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -239,7 +239,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
 			/* send to lowerdev first for its network taps */
-			vlan->forward(vlan->lowerdev, skb);
+			dev_forward_skb(vlan->lowerdev, skb);
 
 			return NET_XMIT_SUCCESS;
 		}
-- 
1.7.4.1
