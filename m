From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB
Date: Wed, 13 Jan 2016 15:28:23 +0300
Message-ID: <20160113122823.GD19993@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a missing break statement so we always return -EOPNOTSUPP.

Fixes: 3a49b4fde2a1 ('mlxsw: Adding layer 2 multicast support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index ffe894e..45479ef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1015,6 +1015,7 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = mlxsw_sp_port_mdb_del(mlxsw_sp_port,
 					    SWITCHDEV_OBJ_PORT_MDB(obj));
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
