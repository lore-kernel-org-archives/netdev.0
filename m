From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 3/4] be2net: Fix to show tx priority pause counter in
 ethtool -S
Date: Wed, 1 May 2013 14:38:00 -0500
Message-ID: <20130501193800.GA3824@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6210 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756939Ab3EATiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:38:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx priority pause count is available with the driver.
But we were not showing it.
This change should fix it and display it in ethtool stats.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c    |    1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 1b7233c..9a1aab9 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -85,6 +85,7 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(tx_pauseframes)},
 	{DRVSTAT_INFO(tx_controlframes)},
 	{DRVSTAT_INFO(rx_priority_pause_frames)},
+	{DRVSTAT_INFO(tx_priority_pauseframes)},
 	/* Received packets dropped when an internal fifo going into
 	 * main packet buffer tank (PMEM) overflows.
 	 */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e0eaad1..03c43d8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -397,6 +397,7 @@ static void populate_be_v1_stats(struct be_adapter *adapter)
 	drvs->rxpp_fifo_overflow_drop = port_stats->rxpp_fifo_overflow_drop;
 	drvs->tx_pauseframes = port_stats->tx_pauseframes;
 	drvs->tx_controlframes = port_stats->tx_controlframes;
+	drvs->tx_priority_pauseframes = port_stats->tx_priority_pauseframes;
 	drvs->jabber_events = port_stats->jabber_events;
 	drvs->rx_drops_no_pbuf = rxf_stats->rx_drops_no_pbuf;
 	drvs->rx_drops_no_erx_descr = rxf_stats->rx_drops_no_erx_descr;
-- 
1.7.10.4
