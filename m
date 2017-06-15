From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 2/6] net/mlx5e: Fix timestamping capabilities reporting
Date: Thu, 15 Jun 2017 23:55:26 +0300
Message-ID: <20170615205530.26674-3-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Maor Dickman <maord@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52487 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751590AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Dickman <maord@mellanox.com>

Misuse of (BIT) macro caused to report wrong flags for
"Hardware Transmit Timestamp Modes" and "Hardware Receive
Filter Modes"

Fixes: ef9814deafd0 ('net/mlx5e: Add HW timestamping (TS) support')
Signed-off-by: Maor Dickman <maord@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 8209affa75c3..16486dff1493 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1242,11 +1242,11 @@ static int mlx5e_get_ts_info(struct net_device *dev,
 				 SOF_TIMESTAMPING_RX_HARDWARE |
 				 SOF_TIMESTAMPING_RAW_HARDWARE;
 
-	info->tx_types = (BIT(1) << HWTSTAMP_TX_OFF) |
-			 (BIT(1) << HWTSTAMP_TX_ON);
+	info->tx_types = BIT(HWTSTAMP_TX_OFF) |
+			 BIT(HWTSTAMP_TX_ON);
 
-	info->rx_filters = (BIT(1) << HWTSTAMP_FILTER_NONE) |
-			   (BIT(1) << HWTSTAMP_FILTER_ALL);
+	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE) |
+			   BIT(HWTSTAMP_FILTER_ALL);
 
 	return 0;
 }
-- 
2.11.0
