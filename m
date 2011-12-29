From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 2/2] mlx4_core: limiting VF port options
Date: Thu, 29 Dec 2011 19:42:39 +0200
Message-ID: <4EFCA68F.9060904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:53839 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752748Ab1L2RtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 12:49:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At the moment VFs can only operate in Eth mode.
In addition we don't want the VF to attempt link sensing,
so we block this option as well.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index e0639eb..8bcc66f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -657,6 +657,8 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 	u8 port_type;
 	int err;
 
+#define MLX4_VF_PORT_ETH_ONLY_MASK	0xE6
+
 	err = mlx4_cmd_box(dev, 0, outbox->dma, vhcr->in_modifier, 0,
 			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
 			   MLX4_CMD_NATIVE);
@@ -671,8 +673,8 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_GET(port_type, outbox->buf,
 			 QUERY_PORT_SUPPORTED_TYPE_OFFSET);
 
-		/* disable ib */
-		port_type &= 0xFE;
+		/* Allow only Eth port, no link sensing allowed */
+		port_type &= MLX4_VF_PORT_ETH_ONLY_MASK;
 
 		/* check eth is enabled for this port */
 		if (!(port_type & 2))
-- 
1.7.7
