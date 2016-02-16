From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/6] net/mlx4_en: Do not count dropped packets twice
Date: Tue, 16 Feb 2016 17:01:46 +0200
Message-ID: <1455634911-31206-2-git-send-email-ogerlitz@mellanox.com>
References: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59321 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932229AbcBPPCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:02:35 -0500
In-Reply-To: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

RdropOvflw counter was mistakenly copied into rx_missed_errors. Because
of that it was counted twice for the device dropped packets accounting.

Fixes: c27a02cd94d6 ('mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC')
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index ee99e67..7b511a5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -242,7 +242,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
 	stats->rx_frame_errors = 0;
 	stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
-	stats->rx_missed_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
+	stats->rx_missed_errors = 0;
 	stats->tx_aborted_errors = 0;
 	stats->tx_carrier_errors = 0;
 	stats->tx_fifo_errors = 0;
-- 
2.3.7
