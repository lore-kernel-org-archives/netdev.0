From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3] net/mlx4_core: Use min3 to select number of MSI-X
 vectors
Date: Thu, 11 May 2017 21:36:30 +0800
Message-ID: <201705112123.XAIeddmG%fengguang.wu@intel.com>
References: <1494499258-17017-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all-JC7UmRfGjtg@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494499258-17017-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Yuval,

[auto build test WARNING on net-next/master]
[also build test WARNING on v4.11 next-20170511]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yuval-Shaia/net-mlx4_core-Use-min3-to-select-number-of-MSI-X-vectors/20170511-184906
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> drivers/net/ethernet/mellanox/mlx4/main.c:2865:28: sparse: incompatible types in comparison expression (different signedness)
>> drivers/net/ethernet/mellanox/mlx4/main.c:2865:28: sparse: incompatible types in comparison expression (different signedness)
>> drivers/net/ethernet/mellanox/mlx4/main.c:2865:28: sparse: incompatible types in comparison expression (different signedness)
   In file included from include/linux/list.h:8:0,
                    from include/linux/module.h:9,
                    from drivers/net/ethernet/mellanox/mlx4/main.c:36:
   drivers/net/ethernet/mellanox/mlx4/main.c: In function 'mlx4_enable_msi_x':
   include/linux/kernel.h:757:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&min1 == &min2);   \
                   ^
   include/linux/kernel.h:755:2: note: in definition of macro '__min'
     t1 min1 = (x);     \
     ^~
   include/linux/kernel.h:774:23: note: in expansion of macro 'min'
    #define min3(x, y, z) min((typeof(x))min(x, y), z)
                          ^~~
   include/linux/kernel.h:760:2: note: in expansion of macro '__min'
     __min(typeof(x), typeof(y),   \
     ^~~~~
   include/linux/kernel.h:774:38: note: in expansion of macro 'min'
    #define min3(x, y, z) min((typeof(x))min(x, y), z)
                                         ^~~
   drivers/net/ethernet/mellanox/mlx4/main.c:2865:14: note: in expansion of macro 'min3'
      int nreq = min3(dev->caps.num_ports * num_online_cpus() + 1,
                 ^~~~
   include/linux/kernel.h:757:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&min1 == &min2);   \
                   ^
   include/linux/kernel.h:755:13: note: in definition of macro '__min'
     t1 min1 = (x);     \
                ^
   include/linux/kernel.h:774:23: note: in expansion of macro 'min'
    #define min3(x, y, z) min((typeof(x))min(x, y), z)
                          ^~~
   include/linux/kernel.h:760:2: note: in expansion of macro '__min'
     __min(typeof(x), typeof(y),   \
     ^~~~~
   include/linux/kernel.h:774:38: note: in expansion of macro 'min'
    #define min3(x, y, z) min((typeof(x))min(x, y), z)
                                         ^~~
   drivers/net/ethernet/mellanox/mlx4/main.c:2865:14: note: in expansion of macro 'min3'
      int nreq = min3(dev->caps.num_ports * num_online_cpus() + 1,
                 ^~~~
   include/linux/kernel.h:757:16: warning: comparison of distinct pointer types lacks a cast
     (void) (&min1 == &min2);   \
                   ^
   include/linux/kernel.h:760:2: note: in expansion of macro '__min'
     __min(typeof(x), typeof(y),   \
     ^~~~~
   include/linux/kernel.h:774:23: note: in expansion of macro 'min'
    #define min3(x, y, z) min((typeof(x))min(x, y), z)
                          ^~~
   drivers/net/ethernet/mellanox/mlx4/main.c:2865:14: note: in expansion of macro 'min3'
      int nreq = min3(dev->caps.num_ports * num_online_cpus() + 1,
                 ^~~~

vim +2865 drivers/net/ethernet/mellanox/mlx4/main.c

  2849		if (!zalloc_cpumask_var(&eq->affinity_mask, GFP_KERNEL))
  2850			return -ENOMEM;
  2851	
  2852		cpumask_set_cpu(requested_cpu, eq->affinity_mask);
  2853	
  2854		return 0;
  2855	}
  2856	
  2857	static void mlx4_enable_msi_x(struct mlx4_dev *dev)
  2858	{
  2859		struct mlx4_priv *priv = mlx4_priv(dev);
  2860		struct msix_entry *entries;
  2861		int i;
  2862		int port = 0;
  2863	
  2864		if (msi_x) {
> 2865			int nreq = min3(dev->caps.num_ports * num_online_cpus() + 1,
  2866					dev->caps.num_eqs - dev->caps.reserved_eqs,
  2867					MAX_MSIX);
  2868	
  2869			entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
  2870			if (!entries)
  2871				goto no_msi;
  2872	
  2873			for (i = 0; i < nreq; ++i)

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
