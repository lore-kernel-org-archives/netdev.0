From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: bcmgenet: remove bogus tx queue checks
Date: Thu, 20 Mar 2014 10:53:22 -0700
Message-ID: <1395338003-17982-4-git-send-email-f.fainelli@gmail.com>
References: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42603 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759400AbaCTRxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:53:38 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so1269641pab.24
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:53:37 -0700 (PDT)
In-Reply-To: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_pick_tx already takes care of making sure that a given
skb->queue_mapping value will remain within the number of advertised
hardware queue number, there is no need to re-do this again in the
driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 0a9f6df819bb..cfcb046f4de5 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1125,14 +1125,6 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	else
 		index -= 1;
 
-	if ((index != DESC_INDEX) && (index > priv->hw_params->tx_queues - 1)) {
-		netdev_err(dev, "%s: queue_mapping %d is invalid\n",
-				__func__, skb_get_queue_mapping(skb));
-		dev->stats.tx_errors++;
-		dev->stats.tx_dropped++;
-		ret = NETDEV_TX_OK;
-		goto out;
-	}
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	ring = &priv->tx_rings[index];
 
-- 
1.8.3.2
