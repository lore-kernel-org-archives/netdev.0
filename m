From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V5 2/2] net: hns: Use phy_driver to setup Phy loopback
Date: Fri, 30 Jun 2017 15:39:15 +0200
Message-ID: <20170630133915.GD17212@lunn.ch>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-3-git-send-email-linyunsheng@huawei.com>
 <20170626134235.GC2623@lunn.ch>
 <17132762-9b94-bc32-fee8-e90a6db5762a@huawei.com>
 <20170627132958.GA9921@lunn.ch>
 <3d382bc6-f7b6-9df3-8bb0-fee55b72ac74@huawei.com>
 <20170628202819.GA22815@lunn.ch>
 <1bff07ed-d423-dfa2-61e3-3f35c4536632@huawei.com>
 <20170629135648.GD9244@lunn.ch>
 <e53994a8-25df-a7dc-cbf0-cbc4063e734c@huawei.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e53994a8-25df-a7dc-cbf0-cbc4063e734c@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Any idea?

Maybe consider what the self test is good for.

My guess is, self test was added when a network interface card was a
full size VME card, and had a couple of hundred components or more.
They did break during there life, due to heat, mechanism stresses,
causing parts to pop off the PCB, or out of their sockets.

Nowadays, the Ethernet interface is part of the SoC, and just has
maybe 10 external parts for the PHY.  What does a failed "MAC loopback
test" tell you? Probably that the driver has a bug, or there is a
silicon bug. What does "SERDES loopback test" tell you? Probably that
the driver has a bug, or there is a silicon bug. And since this is all
inside the silicon, if it fails for you, it is going to fail for
everybody, making the test pretty pointless.

What does a "PHY loopback test" tell you? There is a slim chance it
tells you the device has been hit by lightning, and the PHY is
fried. But more likely, that the driver has a bug, or there is a
silicon bug.

I really expect your own Q&A testing is much better at finding driver
and silicon bugs. You don't use the ethtool --selftest for this.

So i personally would just delete the whole selftest code, it is
pretty pointless.

       Andrew
