From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 1/3] mlx4_core: fix memory leak at multi_func_cleanup
Date: Mon, 6 Feb 2012 18:26:17 +0200
Message-ID: <4F2FFF29.2030701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:46869 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754513Ab2BFQeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:34:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Perform cleanup also in non-master flow.
The VFs use communication channel as well.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 405e6ac..eaf09d4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1616,12 +1616,12 @@ void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 				kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
 		}
 		kfree(priv->mfunc.master.slave_state);
-		iounmap(priv->mfunc.comm);
-		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
-						     priv->mfunc.vhcr,
-						     priv->mfunc.vhcr_dma);
-		priv->mfunc.vhcr = NULL;
 	}
+
+	iounmap(priv->mfunc.comm);
+	dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
+		     priv->mfunc.vhcr, priv->mfunc.vhcr_dma);
+	priv->mfunc.vhcr = NULL;
 }
 
 void mlx4_cmd_cleanup(struct mlx4_dev *dev)
-- 
1.5.4.3
