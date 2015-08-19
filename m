From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 269/271]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:970:38: sparse: incorrect
 type in assignment (different base types)
Date: Wed, 19 Aug 2015 11:41:06 +0800
Message-ID: <201508191103.5pFJR3w3%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	netdev@vger.kernel.org
To: Rajesh Borundia <Rajesh.Borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21037 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759AbbHSDpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 23:45:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   c938a003448063382e0575aee2d381d4cd7aec34
commit: f34fa14cc033239037622dbe84faf53923bb7e74 [269/271] bnx2x: Add vxlan RSS support
reproduce:
  # apt-get install sparse
  git checkout f34fa14cc033239037622dbe84faf53923bb7e74
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:970:38: sparse: incorrect type in assignment (different base types)
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:970:38:    expected unsigned short [unsigned] [usertype] vxlan_dst_port
   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:970:38:    got restricted __le16 [usertype] <noident>

vim +970 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h

   954			start_params->c2s_pri_valid = 1;
   955	
   956			DP(NETIF_MSG_IFUP,
   957			   "Inner-to-Outer priority: %02x %02x %02x %02x %02x %02x %02x %02x [Default %02x]\n",
   958			   start_params->c2s_pri[0], start_params->c2s_pri[1],
   959			   start_params->c2s_pri[2], start_params->c2s_pri[3],
   960			   start_params->c2s_pri[4], start_params->c2s_pri[5],
   961			   start_params->c2s_pri[6], start_params->c2s_pri[7],
   962			   start_params->c2s_pri_default);
   963		}
   964	
   965		if (CHIP_IS_E2(bp) || CHIP_IS_E3(bp))
   966			start_params->network_cos_mode = STATIC_COS;
   967		else /* CHIP_IS_E1X */
   968			start_params->network_cos_mode = FW_WRR;
   969	
 > 970		start_params->vxlan_dst_port = cpu_to_le16(bp->vxlan_dst_port);
   971	
   972		start_params->inner_rss = 1;
   973	
   974		if (IS_MF_UFP(bp) && BNX2X_IS_MF_SD_PROTOCOL_FCOE(bp)) {
   975			start_params->class_fail_ethtype = ETH_P_FIP;
   976			start_params->class_fail = 1;
   977			start_params->no_added_tags = 1;
   978		}

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
