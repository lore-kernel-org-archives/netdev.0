From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 May 2016 11:29:14 +1000
Message-ID: <20160510112914.08f1a497@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

In file included from drivers/net/ethernet/mellanox/mlx5/core/en_main.c:37:0:
drivers/net/ethernet/mellanox/mlx5/core/en.h:525:29: error: field 'fts' has incomplete type
  struct mlx5e_flow_tables   fts;   
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:526:29: error: field 'eth_addr' has incomplete type
  struct mlx5e_eth_addr_db   eth_addr;
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:527:29: error: field 'vlan' has incomplete type
  struct mlx5e_vlan_db       vlan;  
                             ^
In file included from drivers/net/ethernet/mellanox/mlx5/core/en_fs.c:38:0:
drivers/net/ethernet/mellanox/mlx5/core/en.h:525:29: error: field 'fts' has incomplete type
  struct mlx5e_flow_tables   fts;   
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:526:29: error: field 'eth_addr' has incomplete type
  struct mlx5e_eth_addr_db   eth_addr;
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:527:29: error: field 'vlan' has incomplete type
  struct mlx5e_vlan_db       vlan;  
                             ^
In file included from drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:33:0:
drivers/net/ethernet/mellanox/mlx5/core/en.h:525:29: error: field 'fts' has incomplete type
  struct mlx5e_flow_tables   fts;   
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:526:29: error: field 'eth_addr' has incomplete type
  struct mlx5e_eth_addr_db   eth_addr;
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en.h:527:29: error: field 'vlan' has incomplete type
  struct mlx5e_vlan_db       vlan;  
                             ^
drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2619:0: error: unterminated #ifdef
 #ifdef CONFIG_MLX5_CORE_EN_VXLAN   
 ^

Caused by commit

  e800072c18f0 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")

which seems to have reversed some of the merge fixes in commit

  cba653210056 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")

But I am not reaaly sure what has happened here :-(

I tried to use the net-next tree from next-20160509 but that now has
conflicts agains other changes, so I applied the following fix patch
for today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 May 2016 11:20:23 +1000
Subject: [PATCH] net-next: fix bad merge

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 3 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 +
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7aea32e085b3..19b1b021af2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -522,9 +522,6 @@ struct mlx5e_priv {
 	struct mlx5e_direct_tir    direct_tir[MLX5E_MAX_NUM_CHANNELS];
 
 	struct mlx5e_flow_steering fs;
-	struct mlx5e_flow_tables   fts;
-	struct mlx5e_eth_addr_db   eth_addr;
-	struct mlx5e_vlan_db       vlan;
 #ifdef CONFIG_MLX5_CORE_EN_VXLAN
 	struct mlx5e_vxlan_db      vxlan;
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b60a1bc6f457..98be1ce3afd8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2620,6 +2620,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_add_vxlan_port      = mlx5e_add_vxlan_port,
 	.ndo_del_vxlan_port      = mlx5e_del_vxlan_port,
 	.ndo_features_check      = mlx5e_features_check,
+#endif
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
-- 
2.7.0

-- 
Cheers,
Stephen Rothwell
