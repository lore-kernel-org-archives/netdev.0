From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 7/8] dp83640: Support the get_ts_info ethtool method.
Date: Sat, 17 Mar 2012 13:12:33 +0100
Message-ID: <fc2142b009005ed46fa42103066f559b35a42d6c.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43430 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030819Ab2CQMNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:13:00 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so4653078wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:59 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index dd7ae19..940b290 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1215,6 +1215,36 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 	}
 }
 
+static int dp83640_ts_info(struct phy_device *dev, struct ethtool_ts_info *info)
+{
+	struct dp83640_private *dp83640 = dev->priv;
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = ptp_clock_index(dp83640->clock->ptp_clock);
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON) |
+		(1 << HWTSTAMP_TX_ONESTEP_SYNC);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ);
+	return 0;
+}
+
 static struct phy_driver dp83640_driver = {
 	.phy_id		= DP83640_PHY_ID,
 	.phy_id_mask	= 0xfffffff0,
@@ -1225,6 +1255,7 @@ static struct phy_driver dp83640_driver = {
 	.remove		= dp83640_remove,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.ts_info	= dp83640_ts_info,
 	.hwtstamp	= dp83640_hwtstamp,
 	.rxtstamp	= dp83640_rxtstamp,
 	.txtstamp	= dp83640_txtstamp,
-- 
1.7.2.5
