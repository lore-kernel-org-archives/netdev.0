From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 1/6] net/mlx4_en: Count HW buffer overrun only once
Date: Wed, 17 Feb 2016 17:24:22 +0200
Message-ID: <1455722667-23179-2-git-send-email-ogerlitz@mellanox.com>
References: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44321 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965184AbcBQPY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 10:24:56 -0500
In-Reply-To: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

RdropOvflw counts overrun of HW buffer, therefore should
be used for rx_fifo_errors only.

Currently RdropOvflw counter is mistakenly also set into
rx_missed_errors and rx_over_errors too, which makes the
device total dropped packets accounting to show wrong results.

Fix that. Use it for rx_fifo_errors only.

Fixes: c27a02cd94d6 ('mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC')
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index ee99e67..3904b5f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -238,11 +238,11 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	stats->collisions = 0;
 	stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP);
 	stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
-	stats->rx_over_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
+	stats->rx_over_errors = 0;
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
