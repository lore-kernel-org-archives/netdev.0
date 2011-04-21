From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 2/2] macvlan: Send frames to AF_PACKET sockets attached to lowerdev
Date: Thu, 21 Apr 2011 09:31:33 -0400
Message-ID: <1303392693-1350-3-git-send-email-david.ward@ll.mit.edu>
References: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:39273 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab1DUNmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 09:42:39 -0400
In-Reply-To: <1303392693-1350-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bridge mode, unicast frames can be forwarded directly between macvlan
interfaces attached to the same lowerdev without calling dev_queue_xmit.
These frames should still be sent to any AF_PACKET sockets (network taps)
attached to the lowerdev.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/macvlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3ad5425..2b1ee81 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -237,6 +237,7 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
+			dev_queue_xmit_nit(skb, vlan->lowerdev);
 			unsigned int length = skb->len + ETH_HLEN;
 			int ret = dest->forward(dest->dev, skb);
 			macvlan_count_rx(dest, length,
-- 
1.7.4

