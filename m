From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 Jan 2016 13:15:05 +1100
Message-ID: <20160112131505.2228f559@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Schimmel <idosch@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c

between commit:

  366ce6031529 ("mlxsw: spectrum: Add FDB lock to prevent session interleaving")

from the net tree and commit:

  54a732018d8e ("mlxsw: spectrum: Adjust switchdev ops for VLAN devices")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 80e266063aee,4cdc18e72222..000000000000
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@@ -650,7 -1057,14 +1057,15 @@@ static int mlxsw_sp_port_fdb_dump(struc
  	if (!sfd_pl)
  		return -ENOMEM;
  
 +	mutex_lock(&mlxsw_sp_port->mlxsw_sp->fdb_lock);
+ 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
+ 		u16 tmp;
+ 
+ 		tmp = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+ 		vport_fid = mlxsw_sp_vfid_to_fid(tmp);
+ 		vport_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
+ 	}
+ 
  	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
  	do {
  		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
