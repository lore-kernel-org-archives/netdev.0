From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Mon, 3 Jul 2017 17:57:05 +0800
Message-ID: <a678e5ae-4ce8-4d96-2c37-f9af02250733@huawei.com>
References: <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
 <20170628202819.GA22815@lunn.ch>
 <1bff07ed-d423-dfa2-61e3-3f35c4536632@huawei.com>
 <20170629135648.GD9244@lunn.ch>
 <e53994a8-25df-a7dc-cbf0-cbc4063e734c@huawei.com>
 <20170630133915.GD17212@lunn.ch> <20170701151707.GA5859@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, "f.fainelli" <f.fainelli@gmail.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "xuwei (O)" <xuwei5@hisilicon.com>,
        "Liguozhu (Kenneth)" <liguozhu@hisilicon.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        John Garry <john.garry@huawei.com>,
        Linuxarm <linuxarm@huawei.com>,
        "Salil Mehta" <salil.mehta@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>, tremyfr <tremyfr@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170701151707.GA5859@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/7/1 23:17, Andrew Lunn wrote:
> On Sat, Jul 01, 2017 at 11:57:32AM +0000, linyunsheng wrote:
>> Hi, Andrew
>>
>> I am agreed wih you on this.
>> But self test is also a feature of our product, and our
>> customer way choose to diagnose a problem using
>> self test, even if self test does not give a clear
>> reason to the problem.
>> we don't want to remove a feature that we don't
>> know when our customer will be using.
> 
> Far enough. So please take a close look at the code and try to fix
> it. The corner cases are your problem, a down'ed interface, WOL, etc.
> It is issues like this which can result in phy_resume() being called
> without there first being a phy_suspend.
> 
I looked into how the phy core deal with down'ed interface, WOL problem,
here is what I found:
1.phydev->state is used to track the state of the phy.
2.phy_start/stop and phy_state_machine work together to make sure the
  phydev->state is consistent with phydev->suspended.

And using phy_start/stop instead of phy_resume/suspend should take care
of down'ed interface problem.
Will using phy_start/stop cause other problems?

As for WOL,
phy_state_machine:
	if (needs_aneg)
		err = phy_start_aneg_priv(phydev, false);
	else if (do_suspend)
		phy_suspend(phydev);

I think the phy core also have the same problem, because above code does
not put the phy into suspending when it is WOL'ed, and it do not check the
return value of phy_suspend.

I hope I am not missing something obvious.
Please let me know if you have any idea about WOL problem, thanks.

Best Regards
Yunsheng Lin
