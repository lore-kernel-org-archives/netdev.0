From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] atl1c: use net_device_stats from struct
 net_device
Date: Fri, 20 Aug 2010 14:55:16 +0200
Message-ID: <1282308916.2484.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jie Yang <Jie.Yang@atheros.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44622 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab0HTMzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 08:55:21 -0400
Received: by ewy23 with SMTP id 23so2052273ewy.19
        for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 05:55:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct net_device has its own struct net_device_stats member, so use
this one instead of a private copy in the atl1c_adapter struct.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/atl1c/atl1c.h      |    1 -
 drivers/net/atl1c/atl1c_main.c |    6 +++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 52abbbd..ef4115b 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -559,7 +559,6 @@ struct atl1c_adapter {
 	struct napi_struct  napi;
 	struct atl1c_hw        hw;
 	struct atl1c_hw_stats  hw_stats;
-	struct net_device_stats net_stats;
 	struct mii_if_info  mii;    /* MII interface info */
 	u16 rx_buffer_len;
 
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index c7b8ef5..61f1634 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1562,7 +1562,7 @@ static struct net_device_stats *atl1c_get_stats(struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw_stats  *hw_stats = &adapter->hw_stats;
-	struct net_device_stats *net_stats = &adapter->net_stats;
+	struct net_device_stats *net_stats = &netdev->stats;
 
 	atl1c_update_hw_stats(adapter);
 	net_stats->rx_packets = hw_stats->rx_ok;
@@ -1590,7 +1590,7 @@ static struct net_device_stats *atl1c_get_stats(struct net_device *netdev)
 	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
 	net_stats->tx_window_errors  = hw_stats->tx_late_col;
 
-	return &adapter->net_stats;
+	return net_stats;
 }
 
 static inline void atl1c_clear_phy_int(struct atl1c_adapter *adapter)
@@ -1700,7 +1700,7 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 
 		/* link event */
 		if (status & (ISR_GPHY | ISR_MANUAL)) {
-			adapter->net_stats.tx_carrier_errors++;
+			netdev->stats.tx_carrier_errors++;
 			atl1c_link_chg_event(adapter);
 			break;
 		}


