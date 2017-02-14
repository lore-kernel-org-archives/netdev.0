From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] pch_gbe: Omit private ndo_get_stats function
Date: Tue, 14 Feb 2017 17:47:12 +0100
Message-ID: <20170214164712.18561-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:60362 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754829AbdBNQrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 11:47:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pch_gbe_get_stats() just returns dev->stats so we can leave it out
altogether and let dev_get_stats() do the job.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index f9e4e8eca665..5ae9681a2da7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2149,17 +2149,6 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 }
 
 /**
- * pch_gbe_get_stats - Get System Network Statistics
- * @netdev:  Network interface device structure
- * Returns:  The current stats
- */
-static struct net_device_stats *pch_gbe_get_stats(struct net_device *netdev)
-{
-	/* only return the current stats */
-	return &netdev->stats;
-}
-
-/**
  * pch_gbe_set_multi - Multicast and Promiscuous mode set
  * @netdev:   Network interface device structure
  */
@@ -2420,7 +2409,6 @@ static const struct net_device_ops pch_gbe_netdev_ops = {
 	.ndo_open = pch_gbe_open,
 	.ndo_stop = pch_gbe_stop,
 	.ndo_start_xmit = pch_gbe_xmit_frame,
-	.ndo_get_stats = pch_gbe_get_stats,
 	.ndo_set_mac_address = pch_gbe_set_mac,
 	.ndo_tx_timeout = pch_gbe_tx_timeout,
 	.ndo_change_mtu = pch_gbe_change_mtu,
-- 
2.11.0
