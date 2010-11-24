From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 8/8] ethoc: fix function return type
Date: Wed, 24 Nov 2010 14:40:58 +0100
Message-ID: <1290606058-26703-9-git-send-email-jonas@southpole.se>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38155 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755279Ab0KXOCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:50 -0500
In-Reply-To: <1290606058-26703-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update_ethoc_tx_stats doesn't need to return anything so make its return
type void in order to avoid an unnecessary cast when the function is called.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 4f7c9ad..b12c588 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -466,7 +466,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 	return count;
 }
 
-static int ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
+static void ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
 {
 	struct net_device *netdev = dev->netdev;
 
@@ -496,7 +496,6 @@ static int ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
 	netdev->stats.collisions += (bd->stat >> 4) & 0xf;
 	netdev->stats.tx_bytes += bd->stat >> 16;
 	netdev->stats.tx_packets++;
-	return 0;
 }
 
 static int ethoc_tx(struct net_device *dev, int limit)
@@ -527,7 +526,7 @@ static int ethoc_tx(struct net_device *dev, int limit)
 				break;
 		}
 
-		(void)ethoc_update_tx_stats(priv, &bd);
+		ethoc_update_tx_stats(priv, &bd);
 		priv->dty_tx++;
 	}
 
-- 
1.7.1

