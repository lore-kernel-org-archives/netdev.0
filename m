From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Tue, 13 Jun 2017 23:15:54 +0200
Message-ID: <20170613211554.GD15847@lunn.ch>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
 <20170611024314.GD26740@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2303@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2303@FRAEML521-MBX.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You are correct is_c45 should not be derived from the type of PHY like
> it is being done here. I have changed this code and now we are getting this
> information from the IMP(Integrated Management Processor) which handles
> the NIC commands and also maintains Ethernet specific configuration.

Florian

With c22, registering the MDIO bus is enough to cause all c22
addresses to be probed and the PHYs found. If you are not using device
tree, you can then use phy_find_first() to get the first phy on the
bus.

As far as i remember, this does not work for c45. mdiobus_scan() is
only looking for c22 PHYs. Maybe we should be making mdiobus_scan()
look first for a c45 and then try c22?

     Andrew
