From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 4/5] sky2: Remove tx locks
Date: Mon, 3 Aug 2009 20:08:59 +0900
Message-ID: <392fb48f0908030408h45fd44a6wc50ee4ed2256f096@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:27818 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbZHCLI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:08:59 -0400
Received: by fg-out-1718.google.com with SMTP id e12so463898fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 04:08:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should no longer be necessary.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
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
@@ -2369,11 +2367,7 @@ static inline void sky2_tx_done(struct
net_device *dev, u16 last)
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
