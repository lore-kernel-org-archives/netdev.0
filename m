From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1211/1214]
 drivers/infiniband/hw/mlx5/main.c:118:69: sparse: incorrect type in argument
 2 (different base types)
Date: Fri, 5 Jun 2015 10:06:02 +0800
Message-ID: <201506051038.z3APMCg6%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Or Gerlitz <ogerlitz@mellanox.com>,
	netdev@vger.kernel.org
To: Majd Dibbiny <majd@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:60703 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbbFECGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 22:06:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   bb62f791f922254dc1847d3d0b77c9b066d5280b
commit: 1b5daf11b015123108686a9060ee6de705a03e76 [1211/1214] IB/mlx5: Avoid using the MAD_IFC command under ISSI > 0 mode
reproduce:
  # apt-get install sparse
  git checkout 1b5daf11b015123108686a9060ee6de705a03e76
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/infiniband/hw/mlx5/main.c:118:69: sparse: incorrect type in argument 2 (different base types)
   drivers/infiniband/hw/mlx5/main.c:118:69:    expected restricted __be64 [usertype] *sys_image_guid
   drivers/infiniband/hw/mlx5/main.c:118:69:    got unsigned long long *<noident>

vim +118 drivers/infiniband/hw/mlx5/main.c

   102	}
   103	
   104	static int mlx5_query_system_image_guid(struct ib_device *ibdev,
   105						__be64 *sys_image_guid)
   106	{
   107		struct mlx5_ib_dev *dev = to_mdev(ibdev);
   108		struct mlx5_core_dev *mdev = dev->mdev;
   109		u64 tmp;
   110		int err;
   111	
   112		switch (mlx5_get_vport_access_method(ibdev)) {
   113		case MLX5_VPORT_ACCESS_METHOD_MAD:
   114			return mlx5_query_mad_ifc_system_image_guid(ibdev,
   115								    sys_image_guid);
   116	
   117		case MLX5_VPORT_ACCESS_METHOD_HCA:
 > 118			err = mlx5_query_hca_vport_system_image_guid(mdev, &tmp);
   119			if (!err)
   120				*sys_image_guid = cpu_to_be64(tmp);
   121			return err;
   122	
   123		default:
   124			return -EINVAL;
   125		}
   126	}

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
