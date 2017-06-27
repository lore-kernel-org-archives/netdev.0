From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Tue, 27 Jun 2017 15:29:58 +0200
Message-ID: <20170627132958.GA9921@lunn.ch>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Yunsheng Lin <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36695 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751453AbdF0NaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 09:30:16 -0400
Content-Disposition: inline
In-Reply-To: <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> -		phy_write(phy_dev, COPPER_CONTROL_REG, val);
> >> +		err = phy_resume(phy_dev);
> > 
> > Maybe this was discussed with an earlier version of these patches. Why
> > are using phy_resume() and phy_suspend()?
> When self_test is invoked with ETH_TEST_FL_OFFLINE option, hns mac driver
> call dev_close to set net dev to offline state if net dev is online.
> Doing the actual phy loolback test require phy is power up, So phy_resume
> and phy_suspend are used.

O.K, so you at least need some comments, because this is not obvious.

>From your description, it sounds like you can call phy_resume() on a
device which is not suspended. In general, suspend is expected to
store away state which will be lost when powering down a
device. Resume writes that state back into the device after it is
powered up. So resuming a device which was never suspended could write
bad state into it.

Also, what about if WOL has been set before closing the device?

      Andrew
