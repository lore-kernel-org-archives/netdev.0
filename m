From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4_core: Fixing array indexes when setting port types
Date: Thu, 23 Feb 2012 19:04:35 +0200
Message-ID: <4F4671A3.60600@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:37537 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752891Ab2BWREl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:04:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 32f8799..d498f04 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -538,7 +538,7 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 		mlx4_unregister_device(dev);
 		for (port = 1; port <= dev->caps.num_ports; port++) {
 			mlx4_CLOSE_PORT(dev, port);
-			dev->caps.port_type[port + 1] = port_types[port];
+			dev->caps.port_type[port] = port_types[port - 1];
 			err = mlx4_SET_PORT(dev, port);
 			if (err) {
 				mlx4_err(dev, "Failed to set port %d, "
-- 
1.7.7
