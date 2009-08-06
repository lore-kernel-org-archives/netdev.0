From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/8] sky2: Remove tx locks
Date: Thu, 06 Aug 2009 09:12:18 -0700
Message-ID: <20090806161232.849543871@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbZHFQop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:45 -0400
Content-Disposition: inline; filename=sky2-tx4.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should no longer be necessary.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index ac303cb..dbedee4 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1799,9 +1799,7 @@ static void sky2_tx_clean(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);

-	netif_tx_lock_bh(dev);
 	sky2_tx_complete(sky2, sky2->tx_prod);
-	netif_tx_unlock_bh(dev);
 }

 static void sky2_tx_reset(struct sky2_port* sky2)
@@ -2369,11 +2367,7 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);

-	if (netif_running(dev)) {
-		netif_tx_lock(dev);
-		sky2_tx_complete(sky2, last);
-		netif_tx_unlock(dev);
-	}
+	sky2_tx_complete(sky2, last);
 }

 static inline void sky2_skb_rx(const struct sky2_port *sky2,
-- 
1.5.6.5

-- 

