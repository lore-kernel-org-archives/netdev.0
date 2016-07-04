From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 4 Jul 2016 13:02:17 +1000
Message-ID: <20160704130217.79de2ba1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Jurgens <danielj@mellanox.com>,
	Gil Rockah <gilr@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en.h

between commit:

  6cd392a082de ("net/mlx5e: Handle RQ flush in error cases")

from the net tree and commit:

  cb3c7fd4f839 ("net/mlx5e: Support adaptive RX coalescing")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en.h
index 943b1bd434bf,00643a116492..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@@ -143,10 -146,32 +146,31 @@@ struct mlx5e_umr_wqe 
  	struct mlx5_wqe_data_seg       data;
  };
  
+ static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
+ 	"rx_cqe_moder",
+ };
+ 
+ enum mlx5e_priv_flag {
+ 	MLX5E_PFLAG_RX_CQE_BASED_MODER = (1 << 0),
+ };
+ 
+ #define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
+ 	do {                                        \
+ 		if (enable)                         \
+ 			priv->pflags |= pflag;      \
+ 		else                                \
+ 			priv->pflags &= ~pflag;     \
+ 	} while (0)
+ 
  #ifdef CONFIG_MLX5_CORE_EN_DCB
  #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
 -#define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
  #endif
  
+ struct mlx5e_cq_moder {
+ 	u16 usec;
+ 	u16 pkts;
+ };
+ 
  struct mlx5e_params {
  	u8  log_sq_size;
  	u8  rq_wq_type;
@@@ -190,7 -215,7 +214,8 @@@ struct mlx5e_tstamp 
  enum {
  	MLX5E_RQ_STATE_POST_WQES_ENABLE,
  	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
 +	MLX5E_RQ_STATE_FLUSH_TIMEOUT,
+ 	MLX5E_RQ_STATE_AM,
  };
  
  struct mlx5e_cq {
@@@ -542,9 -610,9 +614,10 @@@ struct mlx5e_priv 
  	struct workqueue_struct    *wq;
  	struct work_struct         update_carrier_work;
  	struct work_struct         set_rx_mode_work;
 +	struct work_struct         tx_timeout_work;
  	struct delayed_work        update_stats_work;
  
+ 	u32                        pflags;
  	struct mlx5_core_dev      *mdev;
  	struct net_device         *netdev;
  	struct mlx5e_stats         stats;
