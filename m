From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 18/21] net: phy: expose phy_aneg_done API for
 use by drivers
Date: Mon, 7 Nov 2016 09:01:56 -0600
Message-ID: <9aa07ca3-3056-58a3-ce40-30d76712fe54@amd.com>
References: <201611041055.uVHswmMu%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Andreas Larsson <andreas@gaisler.com>,
        Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0045.outbound.protection.outlook.com ([104.47.42.45]:47760
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752994AbcKGPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 10:02:50 -0500
In-Reply-To: <201611041055.uVHswmMu%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 09:13 PM, kbuild test robot wrote:
> Hi Tom,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Tom-Lendacky/amd-xgbe-AMD-XGBE-driver-updates-2016-11-01/20161103-222344
> config: sparc-allyesconfig (attached as .config)
> compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sparc 
> 
> All errors (new ones prefixed by >>):
> 
>>> drivers/net/ethernet/aeroflex/greth.c:1293:19: error: static declaration of 'phy_aneg_done' follows non-static declaration
>     static inline int phy_aneg_done(struct phy_device *phydev)
>                       ^~~~~~~~~~~~~
>    In file included from include/net/dsa.h:19:0,
>                     from include/linux/netdevice.h:44,
>                     from drivers/net/ethernet/aeroflex/greth.c:29:
>    include/linux/phy.h:789:5: note: previous declaration of 'phy_aneg_done' was here
>     int phy_aneg_done(struct phy_device *phydev);
>         ^~~~~~~~~~~~~
> 
> vim +/phy_aneg_done +1293 drivers/net/ethernet/aeroflex/greth.c
> 

Hi Andreas/Kristoffer,

Kbuild generated an error for this driver when I exposed the phylib
phy_aneg_done() function in the first version of my patches.  For this
driver, I have two choices:

  - Remove the phy_aneg_done() function from the aeroflex driver and
    have it use the phylib version which is now exported

  - Rename the current phy_aneg_done() function in the aeroflex driver
    and have the driver continue to use its version.

I think the first option is the way to go, but I don't have a sparc
machine on which to test it. Let me know which you would prefer and
I will include that in the second version of the patch submission.

Thanks,
Tom

> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1287  	greth->speed = 0;
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1288  	greth->duplex = -1;
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1289  
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1290  	return 0;
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1291  }
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1292  
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15 @1293  static inline int phy_aneg_done(struct phy_device *phydev)
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1294  {
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1295  	int retval;
> d4c41139 drivers/net/greth.c Kristoffer Glembo 2010-02-15  1296  
> 
> :::::: The code at line 1293 was first introduced by commit
> :::::: d4c41139df6e74c6fff0cbac43e51cab782133be net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
> 
> :::::: TO: Kristoffer Glembo <kristoffer@gaisler.com>
> :::::: CC: David S. Miller <davem@davemloft.net>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
