From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx4_en: Fix port counters statistics bitmask
Date: Mon, 30 Mar 2015 17:45:20 +0300
Message-ID: <1427726726-27516-2-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50762 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752960AbbC3Opl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:45:41 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Two counters (rx_chksum_complete and tx_chksum_offload) are not displayed
under SRIOV for the PF via ethtool because their bit mask is off, fix that.

Fixes: f8c6455bb ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
Fixes: 9fab426de ('mlx4: add a new xmit_more counter')

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 9f268f0..553c98c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -47,7 +47,7 @@
 #define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
 #define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
 #define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
-#define MLX4_STATS_PORT_COUNTERS_MASK		0x1fe00000ULL
+#define MLX4_STATS_PORT_COUNTERS_MASK		0x7fe00000ULL
 
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
-- 
1.7.1
