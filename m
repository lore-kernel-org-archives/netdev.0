From: Ben Greear <greearb@candelatech.com>
Subject: [net 2/2] veth:  Remove redundant timestamp assignment.
Date: Thu, 22 Jul 2010 12:54:48 -0700
Message-ID: <1279828488-17800-3-git-send-email-greearb@candelatech.com>
References: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54553 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab0GVTzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 15:55:00 -0400
In-Reply-To: <1279828488-17800-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timestamp is already cleared in the dev_forward_skb
logic.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 0cfbb3d... 161ee02... M	drivers/net/veth.c
 drivers/net/veth.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0cfbb3d..161ee02 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -181,11 +181,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dev->features & NETIF_F_NO_CSUM)
 		skb->ip_summed = rcv_priv->ip_summed;
 
-	/* Zero out the time-stamp so that receiving code is forced
-	 * to recalculate it.
-	 */
-	skb->tstamp.tv64 = 0;
-
 	length = skb->len + ETH_HLEN;
 	if (dev_forward_skb(rcv, skb) != NET_RX_SUCCESS)
 		goto rx_drop;
-- 
1.6.2.5

