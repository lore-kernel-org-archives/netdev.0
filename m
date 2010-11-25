From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 7/8] ethoc: fix function return type
Date: Thu, 25 Nov 2010 13:30:31 +0100
Message-ID: <1290688232-25142-8-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38975 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab0KYMag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:36 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update_ethoc_tx_stats doesn't need to return anything so make its return
type void in order to avoid an unnecessary cast when the function is called.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index f3048fa..93b50d6 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -462,7 +462,7 @@ static int ethoc_rx(struct net_device *dev, int limit)
 	return count;
 }
 
-static int ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
+static void ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
 {
 	struct net_device *netdev = dev->netdev;
 
@@ -492,7 +492,6 @@ static int ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
 	netdev->stats.collisions += (bd->stat >> 4) & 0xf;
 	netdev->stats.tx_bytes += bd->stat >> 16;
 	netdev->stats.tx_packets++;
-	return 0;
 }
 
 static int ethoc_tx(struct net_device *dev, int limit)
@@ -523,7 +522,7 @@ static int ethoc_tx(struct net_device *dev, int limit)
 				break;
 		}
 
-		(void)ethoc_update_tx_stats(priv, &bd);
+		ethoc_update_tx_stats(priv, &bd);
 		priv->dty_tx++;
 	}
 
-- 
1.7.1

