From: Andreas Larsson <andreas@gaisler.com>
Subject: Re: [PATCH net-next v1 18/21] net: phy: expose phy_aneg_done API
 for use by drivers
Date: Tue, 08 Nov 2016 11:17:33 +0100
Message-ID: <5821A63D.6010405@gaisler.com>
References: <201611041055.uVHswmMu%fengguang.wu@intel.com> <9aa07ca3-3056-58a3-ce40-30d76712fe54@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>,
        Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.bahnhof.se ([213.80.101.12]:45452 "EHLO mx2.bahnhof.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752961AbcKHKsP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 05:48:15 -0500
In-Reply-To: <9aa07ca3-3056-58a3-ce40-30d76712fe54@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-11-07 16:01, Tom Lendacky wrote:
> On 11/03/2016 09:13 PM, kbuild test robot wrote:
>> Hi Tom,
>>
>> [auto build test ERROR on net-next/master]
>>
>> url:    https://github.com/0day-ci/linux/commits/Tom-Lendacky/amd-xgbe-AMD-XGBE-driver-updates-2016-11-01/20161103-222344
>> config: sparc-allyesconfig (attached as .config)
>> compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>          chmod +x ~/bin/make.cross
>>          # save the attached .config to linux build tree
>>          make.cross ARCH=sparc
>>
>> All errors (new ones prefixed by >>):
>>
>>>> drivers/net/ethernet/aeroflex/greth.c:1293:19: error: static declaration of 'phy_aneg_done' follows non-static declaration
>>      static inline int phy_aneg_done(struct phy_device *phydev)
>>                        ^~~~~~~~~~~~~
>>     In file included from include/net/dsa.h:19:0,
>>                      from include/linux/netdevice.h:44,
>>                      from drivers/net/ethernet/aeroflex/greth.c:29:
>>     include/linux/phy.h:789:5: note: previous declaration of 'phy_aneg_done' was here
>>      int phy_aneg_done(struct phy_device *phydev);
>>          ^~~~~~~~~~~~~
>>
>> vim +/phy_aneg_done +1293 drivers/net/ethernet/aeroflex/greth.c
>>
>
> Hi Andreas/Kristoffer,
>
> Kbuild generated an error for this driver when I exposed the phylib
> phy_aneg_done() function in the first version of my patches.  For this
> driver, I have two choices:
>
>    - Remove the phy_aneg_done() function from the aeroflex driver and
>      have it use the phylib version which is now exported
>
>    - Rename the current phy_aneg_done() function in the aeroflex driver
>      and have the driver continue to use its version.
>
> I think the first option is the way to go, but I don't have a sparc
> machine on which to test it. Let me know which you would prefer and
> I will include that in the second version of the patch submission.

Hi Tom,

Yes, the first option is the way to go.

Best regards,
Andreas Larsson
