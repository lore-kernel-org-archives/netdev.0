From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH 4/4] forcedeth: add transmit timestamping support
Date: Fri, 27 Apr 2012 15:04:07 -0400
Message-ID: <1335553447-11964-5-git-send-email-willemb@google.com>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:49576 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759422Ab2D0TLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 15:11:54 -0400
Received: by qabg24 with SMTP id g24so94993qab.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 12:11:53 -0700 (PDT)
In-Reply-To: <1335553447-11964-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Insert an skb_tx_timestamp call in both ndo_start_xmit routines
Tested to work for the nv_start_xmit_optimized case

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index d93a088..928913c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2279,6 +2279,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netdev_sent_queue(np->dev, skb->len);
 
+	skb_tx_timestamp(skb);
+
 	np->put_tx.orig = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
@@ -2426,6 +2428,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 
 	netdev_sent_queue(np->dev, skb->len);
 
+	skb_tx_timestamp(skb);
+
 	np->put_tx.ex = put_tx;
 
 	spin_unlock_irqrestore(&np->lock, flags);
-- 
1.7.7.3
