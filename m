From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx_eth: Fix tx_bytes stats calculation
Date: Fri, 14 Sep 2007 11:23:16 -0700
Message-ID: <20070914182316.GA10642@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:38883 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752367AbXINSXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:23:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reported by Corey Minyard <cminyard@mvista.com>

---
 drivers/net/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..6a117e9 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1222,7 +1222,7 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_irqsave(&mp->lock, flags);
 
 	eth_tx_submit_descs_for_skb(mp, skb);
-	stats->tx_bytes = skb->len;
+	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
