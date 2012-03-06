From: Tom Herbert <therbert@google.com>
Subject: tg3: Fix to use multi queue BQL interfaces
Date: Mon, 5 Mar 2012 21:53:50 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1203052147540.19396@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com, cl@gentwo.org, mcarlson@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:45850 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2CFFxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:53:51 -0500
Received: by yhgm50 with SMTP id m50so587855yhg.1
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 21:53:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix tg3 to use BQL multi queue related netdev interfaces since the
device supports multi queue.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bc236b6..b065746 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5595,7 +5595,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		}
 	}
 
-	netdev_completed_queue(tp->dev, pkts_compl, bytes_compl);
+	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
 
 	tnapi->tx_cons = sw_idx;
 
@@ -6971,7 +6971,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	skb_tx_timestamp(skb);
-	netdev_sent_queue(tp->dev, skb->len);
+	netdev_tx_sent_queue(txq, skb->len);
 
 	/* Sync BD data before updating mailbox */
 	wmb();
@@ -7396,8 +7396,8 @@ static void tg3_free_rings(struct tg3 *tp)
 
 			dev_kfree_skb_any(skb);
 		}
+		netdev_tx_reset_queue(netdev_get_tx_queue(tp->dev, j));
 	}
-	netdev_reset_queue(tp->dev);
 }
 
 /* Initialize tx/rx rings for packet processing.
-- 
1.7.7.3
