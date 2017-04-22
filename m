From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 4/5] mlx5: hide unused functions
Date: Sat, 22 Apr 2017 21:45:06 +0300
Message-ID: <20170422184507.26569-5-saeedm@mellanox.com>
References: <20170422184507.26569-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48071 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1426142AbdDVSpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 14:45:44 -0400
In-Reply-To: <20170422184507.26569-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Fix sparse warnings in recent ipoib support.
The RDMA functions are not used yet, hide behind #ifdef.
Based on comment, they will eventually be local so make static.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index ec78e637840f..3c84e36af018 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -178,7 +178,7 @@ static int mlx5i_init_tx(struct mlx5e_priv *priv)
 	return 0;
 }
 
-void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
+static void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
 {
 	struct mlx5i_priv *ipriv = priv->ppriv;
 
@@ -359,9 +359,10 @@ static int mlx5i_close(struct net_device *netdev)
 	return 0;
 }
 
+#ifdef notusedyet
 /* IPoIB RDMA netdev callbacks */
-int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
-		       union ib_gid *gid, u16 lid, int set_qkey)
+static int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
+			      union ib_gid *gid, u16 lid, int set_qkey)
 {
 	struct mlx5e_priv    *epriv = mlx5i_epriv(netdev);
 	struct mlx5_core_dev *mdev  = epriv->mdev;
@@ -377,8 +378,8 @@ int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
 	return err;
 }
 
-int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
-		       union ib_gid *gid, u16 lid)
+static int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
+			      union ib_gid *gid, u16 lid)
 {
 	struct mlx5e_priv    *epriv = mlx5i_epriv(netdev);
 	struct mlx5_core_dev *mdev  = epriv->mdev;
@@ -395,7 +396,7 @@ int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
 	return err;
 }
 
-int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
+static int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
 	       struct ib_ah *address, u32 dqpn, u32 dqkey)
 {
 	struct mlx5e_priv *epriv = mlx5i_epriv(dev);
@@ -404,6 +405,7 @@ int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
 
 	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, dqkey);
 }
+#endif
 
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
@@ -418,10 +420,10 @@ static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	return 0;
 }
 
-struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
-					  struct ib_device *ibdev,
-					  const char *name,
-					  void (*setup)(struct net_device *))
+static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+						 struct ib_device *ibdev,
+						 const char *name,
+						 void (*setup)(struct net_device *))
 {
 	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
 	int nch = profile->max_nch(mdev);
@@ -480,7 +482,7 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);
 
-void mlx5_rdma_netdev_free(struct net_device *netdev)
+static void mlx5_rdma_netdev_free(struct net_device *netdev)
 {
 	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
 	const struct mlx5e_profile *profile = priv->profile;
-- 
2.11.0
