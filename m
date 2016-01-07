From: kbuild test robot <lkp@intel.com>
Subject: Re: [patch net-next 2/2] mlxsw: spectrum: remove FDB entry in case
 we get unknown object notification
Date: Thu, 7 Jan 2016 18:27:09 +0800
Message-ID: <201601071825.Hwvx9UNt%fengguang.wu@intel.com>
References: <1452158701-15747-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52241 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbcAGK2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 05:28:36 -0500
Content-Disposition: inline
In-Reply-To: <1452158701-15747-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Jiri-Pirko/mlxsw-spectrum-pass-local_port-to-mlxsw_sp_port_fdb_uc_op/20160107-172927


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:1122:32-40: ERROR: mlxsw_sp_port is NULL but dereferenced.
   drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:1062:35-43: ERROR: mlxsw_sp_port is NULL but dereferenced.

vim +1122 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c

aac78a44 Ido Schimmel 2015-12-15  1106  								  vfid);
aac78a44 Ido Schimmel 2015-12-15  1107  		if (!mlxsw_sp_vport) {
aac78a44 Ido Schimmel 2015-12-15  1108  			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
5c00f06c Jiri Pirko   2016-01-07  1109  			goto just_remove;
aac78a44 Ido Schimmel 2015-12-15  1110  		}
aac78a44 Ido Schimmel 2015-12-15  1111  
aac78a44 Ido Schimmel 2015-12-15  1112  		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
64771e31 Ido Schimmel 2015-12-15  1113  		lag_vid = vid;
aac78a44 Ido Schimmel 2015-12-15  1114  		/* Override the physical port with the vPort. */
aac78a44 Ido Schimmel 2015-12-15  1115  		mlxsw_sp_port = mlxsw_sp_vport;
aac78a44 Ido Schimmel 2015-12-15  1116  	} else {
aac78a44 Ido Schimmel 2015-12-15  1117  		vid = fid;
aac78a44 Ido Schimmel 2015-12-15  1118  	}
aac78a44 Ido Schimmel 2015-12-15  1119  
5c00f06c Jiri Pirko   2016-01-07  1120  do_fdb_op:
64771e31 Ido Schimmel 2015-12-15  1121  	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid, lag_vid,
8a1ab5d7 Jiri Pirko   2015-12-03 @1122  					  adding && mlxsw_sp_port->learning,
8a1ab5d7 Jiri Pirko   2015-12-03  1123  					  true);
8a1ab5d7 Jiri Pirko   2015-12-03  1124  	if (err) {
8a1ab5d7 Jiri Pirko   2015-12-03  1125  		if (net_ratelimit())
8a1ab5d7 Jiri Pirko   2015-12-03  1126  			netdev_err(mlxsw_sp_port->dev, "Failed to set FDB entry\n");
8a1ab5d7 Jiri Pirko   2015-12-03  1127  		return;
8a1ab5d7 Jiri Pirko   2015-12-03  1128  	}
8a1ab5d7 Jiri Pirko   2015-12-03  1129  
5c00f06c Jiri Pirko   2016-01-07  1130  	if (!do_notification)

:::::: The code at line 1122 was first introduced by commit
:::::: 8a1ab5d766396aad0e60cc8796646a1171b419c8 mlxsw: spectrum: Implement FDB add/remove/dump for LAG

:::::: TO: Jiri Pirko <jiri@mellanox.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
