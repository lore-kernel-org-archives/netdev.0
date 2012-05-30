From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 5/6] net/mlx4_core: Check port out-of-range before using in mlx4_slave_cap
Date: Wed, 30 May 2012 22:36:30 +0300
Message-ID: <1338406590-17916-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:46257 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751471Ab2E3Tgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The range check was performed after using the port number.

Reverse this to prevent a potential array overflow.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7f71be0..ee6f4fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -485,15 +485,15 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	dev->caps.num_mgms              = 0;
 	dev->caps.num_amgms             = 0;
 
-	for (i = 1; i <= dev->caps.num_ports; ++i)
-		dev->caps.port_mask[i] = dev->caps.port_type[i];
-
 	if (dev->caps.num_ports > MLX4_MAX_PORTS) {
 		mlx4_err(dev, "HCA has %d ports, but we only support %d, "
 			 "aborting.\n", dev->caps.num_ports, MLX4_MAX_PORTS);
 		return -ENODEV;
 	}
 
+	for (i = 1; i <= dev->caps.num_ports; ++i)
+		dev->caps.port_mask[i] = dev->caps.port_type[i];
+
 	if (dev->caps.uar_page_size * (dev->caps.num_uars -
 				       dev->caps.reserved_uars) >
 				       pci_resource_len(dev->pdev, 2)) {
-- 
1.7.1
