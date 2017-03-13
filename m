From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 12/25] net/mlx5e: Use underlay_qpn in tis creation
Date: Mon, 13 Mar 2017 20:31:23 +0200
Message-ID: <1489429896-10781-13-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Enable IB link to use the same code, by default the underlay_qp is zero
for ETH link.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e5c8badc38c7..84db4761f09c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -222,6 +222,7 @@ struct mlx5e_params {
 	bool rx_am_enabled;
 	u32 lro_timeout;
 	u32 pflags;
+	u32 underlay_qpn;
 };
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
@@ -718,6 +719,7 @@ struct mlx5e_priv {
 
 	const struct mlx5e_profile *profile;
 	void                      *ppriv;
+	u32                       underlay_qpn;
 };
 
 void mlx5e_build_ptys2ethtool_map(void);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0eb16ada0ae6..87881f9ddf35 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2453,6 +2453,7 @@ static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
 
 	MLX5_SET(tisc, tisc, prio, tc << 1);
 	MLX5_SET(tisc, tisc, transport_domain, mdev->mlx5e_res.td.tdn);
+	MLX5_SET(tisc, tisc, underlay_qpn, priv->underlay_qpn);
 
 	if (mlx5_lag_is_lacp_owner(mdev))
 		MLX5_SET(tisc, tisc, strict_lag_tx_port_affinity, 1);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
