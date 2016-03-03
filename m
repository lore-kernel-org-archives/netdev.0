From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 3 Mar 2016 11:24:56 +1100
Message-ID: <20160303112456.15afe12b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Gal Pressman <galp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got conflicts in:

  drivers/net/ethernet/mellanox/mlx5/core/en.h

between commit:

  b081da5ee186 ("net/mlx5e: Add rx/tx bytes software counters")

from the net tree and commits:

  89db09eb5979 ("net/mlx5e: Add TX inner packet counters")
  3c1b5532191d ("net/mlx5e: Move common case counters within sq_stats struct")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5b1753233c5d,9c0e80e64b43..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@@ -244,9 -256,12 +258,13 @@@ struct mlx5e_rq_stats 
  
  static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
  	"packets",
 +	"bytes",
  	"tso_packets",
  	"tso_bytes",
+ 	"tso_inner_packets",
+ 	"tso_inner_bytes",
+ 	"csum_offload_inner",
+ 	"nop",
  	"csum_offload_none",
  	"stopped",
  	"wake",
@@@ -254,11 -269,15 +272,16 @@@
  };
  
  struct mlx5e_sq_stats {
+ 	/* commonly accessed in data path */
  	u64 packets;
 +	u64 bytes;
  	u64 tso_packets;
  	u64 tso_bytes;
+ 	u64 tso_inner_packets;
+ 	u64 tso_inner_bytes;
+ 	u64 csum_offload_inner;
+ 	u64 nop;
+ 	/* less likely accessed in data path */
  	u64 csum_offload_none;
  	u64 stopped;
  	u64 wake;
