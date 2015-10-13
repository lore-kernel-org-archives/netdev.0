From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/4] net/mlx5_core: Add pci error handlers to
 mlx5_core driver
Date: Wed, 14 Oct 2015 01:04:06 +0800
Message-ID: <201510140139.d9CDDacp%fengguang.wu@intel.com>
References: <1444751049-2511-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46167 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063AbbJMRFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 13:05:15 -0400
Content-Disposition: inline
In-Reply-To: <1444751049-2511-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Majd,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Or-Gerlitz/net-mlx5_core-Fix-internal-error-detection-conditions/20151013-234855
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlx5/core/cmd.c:1383:36: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/mellanox/mlx5/core/cmd.c:1383:36:    expected restricted __be32 [usertype] <noident>
   drivers/net/ethernet/mellanox/mlx5/core/cmd.c:1383:36:    got unsigned int [unsigned] [addressable] [usertype] drv_synd

vim +1383 drivers/net/ethernet/mellanox/mlx5/core/cmd.c

  1367	}
  1368	
  1369	static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
  1370			    int out_size, mlx5_cmd_cbk_t callback, void *context)
  1371	{
  1372		struct mlx5_cmd_msg *inb;
  1373		struct mlx5_cmd_msg *outb;
  1374		int pages_queue;
  1375		gfp_t gfp;
  1376		int err;
  1377		u8 status = 0;
  1378		u32 drv_synd;
  1379	
  1380		if (pci_channel_offline(dev->pdev) ||
  1381		    dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
  1382			err = mlx5_internal_err_ret_value(dev, opcode_from_in(in), &drv_synd, &status);
> 1383			*get_synd_ptr(out) = drv_synd;
  1384			*get_status_ptr(out) = status;
  1385			return err;
  1386		}
  1387	
  1388		pages_queue = is_manage_pages(in);
  1389		gfp = callback ? GFP_ATOMIC : GFP_KERNEL;
  1390	
  1391		inb = alloc_msg(dev, in_size, gfp);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
