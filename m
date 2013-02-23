From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: [PATCH] mlx4_en: fix allocation of device tx_cq
Date: Fri, 22 Feb 2013 21:58:02 -0300
Message-ID: <1361581082-5583-1-git-send-email-klebers@linux.vnet.ibm.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bb40dc42.virtua.com.br ([187.64.220.66]:42162 "EHLO
	oc3234564620.ibm.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754922Ab3BWBFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:05:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory to hold the network device tx_cq is not being allocated with
the correct size in mlx4_en_init_netdev(). It should use MAX_TX_RINGS
instead of MAX_RX_RINGS. This can cause problems if the number of tx
rings being used is greater than MAX_RX_RINGS.

Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5088dc5..5944dd6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2067,7 +2067,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		err = -ENOMEM;
 		goto out;
 	}
-	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_RX_RINGS,
+	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_TX_RINGS,
 			      GFP_KERNEL);
 	if (!priv->tx_cq) {
 		err = -ENOMEM;
-- 
1.7.1
