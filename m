From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 3/8] bfin_mac: Support the get_ts_info ethtool method.
Date: Sat, 17 Mar 2012 13:12:29 +0100
Message-ID: <c390ad4cf2f5dcd8cedaf0074f21f772f7db9e95.1331983687.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43430 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030803Ab2CQMMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 08:12:49 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so4653078wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 05:12:49 -0700 (PDT)
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331983685.git.richardcochran@gmail.com>
References: <cover.1331983685.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index ab4daec..db22278 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -548,6 +548,25 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 	return 0;
 }
 
+static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
+	struct ethtool_ts_info *info);
+{
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_SYS_HARDWARE;
+	info->phc_index = -1;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
+	return 0;
+}
+
 static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_settings = bfin_mac_ethtool_getsettings,
 	.set_settings = bfin_mac_ethtool_setsettings,
@@ -555,6 +574,7 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_drvinfo = bfin_mac_ethtool_getdrvinfo,
 	.get_wol = bfin_mac_ethtool_getwol,
 	.set_wol = bfin_mac_ethtool_setwol,
+	.get_ts_info = bfin_mac_ethtool_get_ts_info,
 };
 
 /**************************************************************************/
-- 
1.7.2.5
