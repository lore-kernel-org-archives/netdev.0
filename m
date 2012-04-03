From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 03/28] igb: Support the get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:27 +0200
Message-ID: <8152a4a64d585010ebf49d1d582308180be66ba8.1333474522.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33431 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab2DCRsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:48:18 -0400
Received: by wibhj6 with SMTP id hj6so3895589wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 10:48:17 -0700 (PDT)
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
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
