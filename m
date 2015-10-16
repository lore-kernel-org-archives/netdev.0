From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] net: hisilicon: add OF dependency
Date: Sat, 17 Oct 2015 01:03:46 +0800
Message-ID: <201510170106.1m7jnT7h%fengguang.wu@intel.com>
References: <4665385.OoIztz6y5m@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, huangdaode <huangdaode@hisilicon.com>,
	davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13952 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932105AbbJPRF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 13:05:29 -0400
Content-Disposition: inline
In-Reply-To: <4665385.OoIztz6y5m@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

[auto build test ERROR on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Arnd-Bergmann/net-hisilicon-add-OF-dependency/20151016-173818
config: x86_64-allmodconfig
reproduce:
        make ARCH=x86_64  allmodconfig
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):


vim +/vzalloc +1123 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c

511e6bc0 huangdaode 2015-09-17  1117  
511e6bc0 huangdaode 2015-09-17  1118  	ret = hns_dsaf_init_hw(dsaf_dev);
511e6bc0 huangdaode 2015-09-17  1119  	if (ret)
511e6bc0 huangdaode 2015-09-17  1120  		return ret;
511e6bc0 huangdaode 2015-09-17  1121  
511e6bc0 huangdaode 2015-09-17  1122  	/* malloc mem for tcam mac key(vlan+mac) */
511e6bc0 huangdaode 2015-09-17 @1123  	priv->soft_mac_tbl = vzalloc(sizeof(*priv->soft_mac_tbl)
511e6bc0 huangdaode 2015-09-17  1124  		  * DSAF_TCAM_SUM);
511e6bc0 huangdaode 2015-09-17  1125  	if (!priv->soft_mac_tbl) {
511e6bc0 huangdaode 2015-09-17  1126  		ret = -ENOMEM;
511e6bc0 huangdaode 2015-09-17  1127  		goto remove_hw;
511e6bc0 huangdaode 2015-09-17  1128  	}
511e6bc0 huangdaode 2015-09-17  1129  
511e6bc0 huangdaode 2015-09-17  1130  	/*all entry invall */
511e6bc0 huangdaode 2015-09-17  1131  	for (i = 0; i < DSAF_TCAM_SUM; i++)
511e6bc0 huangdaode 2015-09-17  1132  		(priv->soft_mac_tbl + i)->index = DSAF_INVALID_ENTRY_IDX;
511e6bc0 huangdaode 2015-09-17  1133  
511e6bc0 huangdaode 2015-09-17  1134  	return 0;
511e6bc0 huangdaode 2015-09-17  1135  
511e6bc0 huangdaode 2015-09-17  1136  remove_hw:
511e6bc0 huangdaode 2015-09-17  1137  	hns_dsaf_remove_hw(dsaf_dev);
511e6bc0 huangdaode 2015-09-17  1138  	return ret;
511e6bc0 huangdaode 2015-09-17  1139  }
511e6bc0 huangdaode 2015-09-17  1140  
511e6bc0 huangdaode 2015-09-17  1141  /**
511e6bc0 huangdaode 2015-09-17  1142   * hns_dsaf_free - free dsa fabric
511e6bc0 huangdaode 2015-09-17  1143   * @dsaf_dev: dsa fabric device struct pointer
511e6bc0 huangdaode 2015-09-17  1144   */
511e6bc0 huangdaode 2015-09-17  1145  static void hns_dsaf_free(struct dsaf_device *dsaf_dev)
511e6bc0 huangdaode 2015-09-17  1146  {
511e6bc0 huangdaode 2015-09-17  1147  	struct dsaf_drv_priv *priv =
511e6bc0 huangdaode 2015-09-17  1148  	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
511e6bc0 huangdaode 2015-09-17  1149  
511e6bc0 huangdaode 2015-09-17  1150  	hns_dsaf_remove_hw(dsaf_dev);
511e6bc0 huangdaode 2015-09-17  1151  
511e6bc0 huangdaode 2015-09-17  1152  	/* free all mac mem */
511e6bc0 huangdaode 2015-09-17 @1153  	vfree(priv->soft_mac_tbl);
511e6bc0 huangdaode 2015-09-17  1154  	priv->soft_mac_tbl = NULL;
511e6bc0 huangdaode 2015-09-17  1155  }
511e6bc0 huangdaode 2015-09-17  1156  

:::::: The code at line 1123 was first introduced by commit
:::::: 511e6bc071db1484d1a3d1d0bd4c244cf33910ff net: add Hisilicon Network Subsystem DSAF support

:::::: TO: huangdaode <huangdaode@hisilicon.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
