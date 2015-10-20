From: kbuild test robot <lkp@intel.com>
Subject: Re: [net PATCH] ixgbe: Reset interface after enabling SR-IOV
Date: Wed, 21 Oct 2015 06:25:09 +0800
Message-ID: <201510210632.SQvcZPbZ%fengguang.wu@intel.com>
References: <20151020195738.1495.80824.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19857 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754073AbbJTWYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 18:24:33 -0400
Content-Disposition: inline
In-Reply-To: <20151020195738.1495.80824.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

[auto build test WARNING on net/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Alexander-Duyck/ixgbe-Reset-interface-after-enabling-SR-IOV/20151021-040132
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:675:33: sparse: cast to restricted __le64
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:675:33: sparse: cast to restricted __le64
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:787:33: sparse: cast to restricted __le64
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:787:33: sparse: cast to restricted __le64
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:793:33: sparse: cast to restricted __le64
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:793:33: sparse: cast to restricted __le64
>> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7879:29: sparse: incorrect type in argument 1 (different base types)
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7879:29:    expected struct ixgbe_adapter *adapter
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7879:29:    got struct net_device *dev
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_setup_tc':
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7879:15: warning: passing argument 1 of 'ixgbe_reset' from incompatible pointer type [-Wincompatible-pointer-types]
      ixgbe_reset(dev);
                  ^
   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:4994:6: note: expected 'struct ixgbe_adapter *' but argument is of type 'struct net_device *'
    void ixgbe_reset(struct ixgbe_adapter *adapter)
         ^

vim +7879 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c

  7863			return -EINVAL;
  7864	
  7865		if (hw->mac.type == ixgbe_mac_82598EB && tc && tc < MAX_TRAFFIC_CLASS)
  7866			return -EINVAL;
  7867	
  7868		pools = (find_first_zero_bit(&adapter->fwd_bitmask, 32) > 1);
  7869		if (tc && pools && adapter->num_rx_pools > IXGBE_MAX_DCBMACVLANS)
  7870			return -EBUSY;
  7871	
  7872		/* Hardware has to reinitialize queues and interrupts to
  7873		 * match packet buffer alignment. Unfortunately, the
  7874		 * hardware is not flexible enough to do this dynamically.
  7875		 */
  7876		if (netif_running(dev))
  7877			ixgbe_close(dev);
  7878		else
> 7879			ixgbe_reset(dev);
  7880	
  7881		ixgbe_clear_interrupt_scheme(adapter);
  7882	
  7883	#ifdef CONFIG_IXGBE_DCB
  7884		if (tc) {
  7885			netdev_set_num_tc(dev, tc);
  7886			ixgbe_set_prio_tc_map(adapter);
  7887	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
