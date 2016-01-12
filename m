From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the nettree
Date: Tue, 12 Jan 2016 13:15:07 +1100
Message-ID: <20160112131507.4509e7bf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlxsw/spectrum.h

between commit:

  366ce6031529 ("mlxsw: spectrum: Add FDB lock to prevent session interleaving")

from the net tree and commit:

  0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 69281ca534b1,199f91a62962..000000000000
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@@ -63,13 -120,16 +120,17 @@@ struct mlxsw_sp 
  	} fdb_notify;
  #define MLXSW_SP_DEFAULT_AGEING_TIME 300
  	u32 ageing_time;
 +	struct mutex fdb_lock;	/* Make sure FDB sessions are atomic. */
- 	struct {
- 		struct net_device *dev;
- 		unsigned int ref_count;
- 	} master_bridge;
+ 	struct mlxsw_sp_upper master_bridge;
+ 	struct mlxsw_sp_upper lags[MLXSW_SP_LAG_MAX];
  };
  
+ static inline struct mlxsw_sp_upper *
+ mlxsw_sp_lag_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id)
+ {
+ 	return &mlxsw_sp->lags[lag_id];
+ }
+ 
  struct mlxsw_sp_port_pcpu_stats {
  	u64			rx_packets;
  	u64			rx_bytes;
