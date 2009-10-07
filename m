From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] be2net: Get rid of net_device_stats from
	adapter.
Date: Wed, 7 Oct 2009 14:39:16 +0530
Message-ID: <20091007090903.GA18843@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:37813 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934072AbZJGJKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 05:10:00 -0400
Received: by pxi9 with SMTP id 9so4627173pxi.4
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 02:09:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adapter doesnot need to maintain a copy of net_device_stats.
Use the one already available in net_device. This patch takes care of the same.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    1 -
 drivers/net/benet/be_ethtool.c |    2 +-
 drivers/net/benet/be_main.c    |    6 ++----
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index a80da0e..4b61a91 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -181,7 +181,6 @@ struct be_drvr_stats {
 
 struct be_stats_obj {
 	struct be_drvr_stats drvr_stats;
-	struct net_device_stats net_stats;
 	struct be_dma_mem cmd;
 };
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 77c66da..333729b 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -234,7 +234,7 @@ be_get_ethtool_stats(struct net_device *netdev,
 	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
 	struct be_port_rxf_stats *port_stats =
 			&rxf_stats->port[adapter->port_num];
-	struct net_device_stats *net_stats = &adapter->stats.net_stats;
+	struct net_device_stats *net_stats = &netdev->stats;
 	struct be_erx_stats *erx_stats = &hw_stats->erx;
 	void *p = NULL;
 	int i;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6d5e81f..0e92a1f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -141,7 +141,7 @@ void netdev_stats_update(struct be_adapter *adapter)
 	struct be_rxf_stats *rxf_stats = &hw_stats->rxf;
 	struct be_port_rxf_stats *port_stats =
 			&rxf_stats->port[adapter->port_num];
-	struct net_device_stats *dev_stats = &adapter->stats.net_stats;
+	struct net_device_stats *dev_stats = &adapter->netdev->stats;
 	struct be_erx_stats *erx_stats = &hw_stats->erx;
 
 	dev_stats->rx_packets = port_stats->rx_total_frames;
@@ -269,9 +269,7 @@ static void be_rx_eqd_update(struct be_adapter *adapter)
 
 static struct net_device_stats *be_get_stats(struct net_device *dev)
 {
-	struct be_adapter *adapter = netdev_priv(dev);
-
-	return &adapter->stats.net_stats;
+	return &dev->stats;
 }
 
 static u32 be_calc_rate(u64 bytes, unsigned long ticks)
-- 
1.6.0.4

