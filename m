From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 05/11] bcm63xx_enet: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:20:40 -0700
Message-ID: <87bnxdpgjb.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37807 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbaCKDUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:20:47 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index b9a5fb6400d3..7cde07fee3c0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -469,7 +469,7 @@ static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
 		if (desc->len_stat & DMADESC_UNDER_MASK)
 			dev->stats.tx_errors++;
 
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		released++;
 	}
 
@@ -606,7 +606,7 @@ static int bcm_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				ret = NETDEV_TX_BUSY;
 				goto out_unlock;
 			}
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			skb = nskb;
 		}
 		data = skb_put(skb, needed);
-- 
1.7.5.4
