From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_core: Load the Eth driver first
Date: Thu,  1 May 2014 15:51:55 +0300
Message-ID: <1398948716-6765-4-git-send-email-ogerlitz@mellanox.com>
References: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60832 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752099AbaEAMwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 08:52:15 -0400
In-Reply-To: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in SRIOV mode, VM that is assigned with a non-provisioned
Ethernet VFs get themselves a random mac when the Eth driver starts. In
this case, if the IB driver startup code that deals with RoCE runs first,
it will use a zero mac as the source mac for the Para-Virtual CM MADs
which is buggy. To handle that, we change the order of loading.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index cef267e..e98c15a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -754,10 +754,10 @@ static void mlx4_request_modules(struct mlx4_dev *dev)
 			has_eth_port = true;
 	}
 
-	if (has_ib_port || (dev->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
-		request_module_nowait(IB_DRV_NAME);
 	if (has_eth_port)
 		request_module_nowait(EN_DRV_NAME);
+	if (has_ib_port || (dev->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
+		request_module_nowait(IB_DRV_NAME);
 }
 
 /*
-- 
1.7.1
