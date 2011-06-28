From: alex.bluesman.smirnov@gmail.com
Subject: [PATCH] Exclude duplicated checking for iface-up. This flags is checked in 'is_skb_forwardable' function, which is subroutine of 'dev_forward_skb'.
Date: Tue, 28 Jun 2011 17:30:44 +0400
Message-ID: <1309267844-29334-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34077 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757863Ab1F1Nco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 09:32:44 -0400
Received: by wwe5 with SMTP id 5so212288wwe.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2011 06:32:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/net/veth.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 3b99f64..fb2fd37 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -163,9 +163,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats = this_cpu_ptr(priv->stats);
 	rcv_stats = this_cpu_ptr(rcv_priv->stats);
 
-	if (!(rcv->flags & IFF_UP))
-		goto tx_drop;
-
 	/* don't change ip_summed == CHECKSUM_PARTIAL, as that
 	   will cause bad checksum on forwarded packets */
 	if (skb->ip_summed == CHECKSUM_NONE)
-- 
1.7.2.3

