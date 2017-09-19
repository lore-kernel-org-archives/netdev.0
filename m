From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 13/14] gtp: Support for GRO
Date: Tue, 19 Sep 2017 19:57:46 +0800
Message-ID: <201709191913.n0asYsgt%fengguang.wu@intel.com>
References: <20170919003904.5124-14-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        pablo@netfilter.org, laforge@gnumonks.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10522 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751543AbdISL7J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 07:59:09 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-14-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Tom-Herbert/gtp-Additional-feature-support/20170919-143920
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +3958 include/linux/netdevice.h

5b33bc6e Tom Herbert 2017-09-18  3944  
5b33bc6e Tom Herbert 2017-09-18  3945  /* rcu_read_lock() must be held */
5b33bc6e Tom Herbert 2017-09-18  3946  static inline struct skb_gso_app *skb_gso_app_lookup(struct sk_buff *skb,
5b33bc6e Tom Herbert 2017-09-18  3947  						     netdev_features_t features,
5b33bc6e Tom Herbert 2017-09-18  3948  						     unsigned int check_flags)
5b33bc6e Tom Herbert 2017-09-18  3949  {
5b33bc6e Tom Herbert 2017-09-18  3950  	struct skb_gso_app *app;
5b33bc6e Tom Herbert 2017-09-18  3951  	int type;
5b33bc6e Tom Herbert 2017-09-18  3952  
5b33bc6e Tom Herbert 2017-09-18  3953  	if (!(skb_shinfo(skb)->gso_type & SKB_GSO_APP_MASK))
5b33bc6e Tom Herbert 2017-09-18  3954  		return false;
5b33bc6e Tom Herbert 2017-09-18  3955  
5b33bc6e Tom Herbert 2017-09-18  3956  	type = skb_gso_app_to_index(skb_shinfo(skb)->gso_type);
5b33bc6e Tom Herbert 2017-09-18  3957  
5b33bc6e Tom Herbert 2017-09-18 @3958  	app = rcu_dereference(skb_gso_apps[type]);
5b33bc6e Tom Herbert 2017-09-18  3959  	if (app && app->gso_segment &&
5b33bc6e Tom Herbert 2017-09-18  3960  	    (check_flags & app->check_flags))
5b33bc6e Tom Herbert 2017-09-18  3961  		return app;
5b33bc6e Tom Herbert 2017-09-18  3962  
5b33bc6e Tom Herbert 2017-09-18  3963  	return NULL;
5b33bc6e Tom Herbert 2017-09-18  3964  }
5b33bc6e Tom Herbert 2017-09-18  3965  

:::::: The code at line 3958 was first introduced by commit
:::::: 5b33bc6e4fcae1113167c651a3d3a218c7e277c6 net: Add a facility to support application defined GSO

:::::: TO: Tom Herbert <tom@quantonium.net>
:::::: CC: 0day robot <fengguang.wu@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
