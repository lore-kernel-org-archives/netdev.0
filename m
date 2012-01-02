From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 2/2] mlx4_core: Elaborating limitation on VF port
 options
Date: Mon, 2 Jan 2012 16:07:43 +0200
Message-ID: <4F01BA2F.8020305@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:45261 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753060Ab2ABQTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:19:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Showing which capabilities are not passed to VF
when executing QUERY_PORT

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8bcc66f..a424a19 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -657,7 +657,12 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	u8 port_type;
 	int err;
 
-#define MLX4_VF_PORT_ETH_ONLY_MASK	0xE6
+#define MLX4_PORT_SUPPORT_IB		(1 << 0)
+#define MLX4_PORT_SUGGEST_TYPE		(1 << 3)
+#define MLX4_PORT_DEFAULT_SENSE		(1 << 4)
+#define MLX4_VF_PORT_ETH_ONLY_MASK	(0xff & ~MLX4_PORT_SUPPORT_IB & \
+					 ~MLX4_PORT_SUGGEST_TYPE & \
+					 ~MLX4_PORT_DEFAULT_SENSE)
 
 	err = mlx4_cmd_box(dev, 0, outbox->dma, vhcr->in_modifier, 0,
 			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
-- 
1.7.7
