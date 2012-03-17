From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 4/8] igb: Support the get_ts_info ethtool method.
Date: Sat, 17 Mar 2012 13:12:30 +0100
Message-ID: <f39925305283b127d040b5ed38fad0d4de0b7bcb.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43430 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030807Ab2CQMMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:52 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so4653078wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:51 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   31 ++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e10821a..245fec0 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2182,6 +2182,36 @@ static void igb_ethtool_complete(struct net_device *netdev)
 	pm_runtime_put(&adapter->pdev->dev);
 }
 
+static int igb_ethtool_get_ts_info(struct net_device *dev,
+				   struct ethtool_ts_info *info)
+{
+	struct igb_adapter *adapter = netdev_priv(dev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (adapter->ptp_clock)
+		info->phc_index = ptp_clock_index(adapter->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_ALL) |
+		(1 << HWTSTAMP_FILTER_SOME) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+
+	return 0;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2210,6 +2240,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_coalesce           = igb_set_coalesce,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
+	.get_ts_info		= igb_ethtool_get_ts_info,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5
