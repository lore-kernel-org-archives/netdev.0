From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_core: Load the IB driver when the device supports IBoE
Date: Wed, 12 Mar 2014 17:16:32 +0200
Message-ID: <1394637392-31104-4-git-send-email-ogerlitz@mellanox.com>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40502 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754327AbaCLPQl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 11:16:41 -0400
In-Reply-To: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When checking what protocol drivers to load, the IB driver should be
requested also over Ethernet ports, if the device supports IBoE (RoCE).

Fixes: b046ffe 'net/mlx4_core: Load higher level modules according to ports type'
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 30a08a6..936c153 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -751,7 +751,7 @@ static void mlx4_request_modules(struct mlx4_dev *dev)
 			has_eth_port = true;
 	}
 
-	if (has_ib_port)
+	if (has_ib_port || (dev->caps.flags & MLX4_DEV_CAP_FLAG_IBOE))
 		request_module_nowait(IB_DRV_NAME);
 	if (has_eth_port)
 		request_module_nowait(EN_DRV_NAME);
-- 
1.7.1
