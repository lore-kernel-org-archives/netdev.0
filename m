From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] atl1: use netdev->stats
Date: Tue, 26 May 2009 08:42:34 +0200
Message-ID: <4A1B8F5A.9040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59076 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbZEZGmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 02:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of private struct net_device_stats in "struct atl1e_adapter",
and use one provided in struct net_device instead.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/atl1e/atl1e.h      |    1 -
 drivers/net/atl1e/atl1e_main.c |    6 +++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index 2bf63b4..ba48220 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -429,7 +429,6 @@ struct atl1e_adapter {
 	struct mii_if_info  mii;    /* MII interface info */
 	struct atl1e_hw        hw;
 	struct atl1e_hw_stats  hw_stats;
-	struct net_device_stats net_stats;
 
 	bool have_msi;
 	u32 wol;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index adac061..c271b75 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1153,7 +1153,7 @@ static struct net_device_stats *atl1e_get_stats(struct net_device *netdev)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	struct atl1e_hw_stats  *hw_stats = &adapter->hw_stats;
-	struct net_device_stats *net_stats = &adapter->net_stats;
+	struct net_device_stats *net_stats = &netdev->stats;
 
 	net_stats->rx_packets = hw_stats->rx_ok;
 	net_stats->tx_packets = hw_stats->tx_ok;
@@ -1181,7 +1181,7 @@ static struct net_device_stats *atl1e_get_stats(struct net_device *netdev)
 	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
 	net_stats->tx_window_errors  = hw_stats->tx_late_col;
 
-	return &adapter->net_stats;
+	return net_stats;
 }
 
 static void atl1e_update_hw_stats(struct atl1e_adapter *adapter)
@@ -1309,7 +1309,7 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 
 		/* link event */
 		if (status & (ISR_GPHY | ISR_MANUAL)) {
-			adapter->net_stats.tx_carrier_errors++;
+			netdev->stats.tx_carrier_errors++;
 			atl1e_link_chg_event(adapter);
 			break;
 		}
