From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1206/1214]
 drivers/net/ethernet/mellanox/mlx5/core/vport.c:321:33: sparse: incorrect
 type in assignment (different base types)
Date: Fri, 5 Jun 2015 09:08:05 +0800
Message-ID: <201506050903.YTbzD1YY%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Or Gerlitz <ogerlitz@mellanox.com>,
	netdev@vger.kernel.org
To: Majd Dibbiny <majd@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60537 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbbFEBIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 21:08:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   bb62f791f922254dc1847d3d0b77c9b066d5280b
commit: 707c4602cda6624940761b66a4119f1909492385 [1206/1214] net/mlx5_core: Add new query HCA vport commands
reproduce:
  # apt-get install sparse
  git checkout 707c4602cda6624940761b66a4119f1909492385
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlx5/core/vport.c:321:33: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/mellanox/mlx5/core/vport.c:321:33:    expected restricted __be64 [usertype] <noident>
   drivers/net/ethernet/mellanox/mlx5/core/vport.c:321:33:    got unsigned long long [unsigned] [usertype] sys_image_guid

vim +321 drivers/net/ethernet/mellanox/mlx5/core/vport.c

   305		return err;
   306	}
   307	EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_context);
   308	
   309	int mlx5_query_hca_vport_system_image_guid(struct mlx5_core_dev *dev,
   310						   __be64 *sys_image_guid)
   311	{
   312		struct mlx5_hca_vport_context *rep;
   313		int err;
   314	
   315		rep = kzalloc(sizeof(*rep), GFP_KERNEL);
   316		if (!rep)
   317			return -ENOMEM;
   318	
   319		err = mlx5_query_hca_vport_context(dev, 0, 1, 0, rep);
   320		if (!err)
 > 321			*sys_image_guid = rep->sys_image_guid;
   322	
   323		kfree(rep);
   324		return err;
   325	}
   326	EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_system_image_guid);
   327	
   328	int mlx5_query_hca_vport_node_guid(struct mlx5_core_dev *dev,
   329					   u64 *node_guid)

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
