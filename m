From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Tue, 13 Jun 2017 23:01:44 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A26E1@FRAEML521-MBX.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2554@FRAEML521-MBX.china.huawei.com>
 <20170613224042.GF15847@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:7415 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbdFMXCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 19:02:00 -0400
In-Reply-To: <20170613224042.GF15847@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, June 13, 2017 11:41 PM
> To: Salil Mehta
> Cc: Florian Fainelli; davem@davemloft.net; Zhuangyuzeng (Yisen);
> huangdaode; lipeng (Y); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
> Ethernet driver for hip08 SoC
> 
> > > Hum why do you do this? mdiobus_register() will scan through your
> bus
> > > provided that you set an appropriate phy_mask value (here you tell
> it
> > > not to) and you already provide the PHY address to scan for
> > >
> > I know this looks weird but the reason why it appears as it is in
> code is:
> >
> > mdiobus_register() calls mdiobus_scan(). If you see below code leg
> function
> > get_phy_device() assumes to be having supporting Clause 22 so its
> input
> > parameter 'is_c45' is always 'false'.
> >
> > struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
> > {
> > 	struct phy_device *phydev;
> > 	int err;
> >
> > 	phydev = get_phy_device(bus, addr, false);
> > 	if (IS_ERR(phydev))                ^^^^^
> > 		return phydev;
> > 	[...]
> > }
> >
> > Therefore, to support C45 device we did below:
> >
> > * disabled the autoscan/mdiobus_scan() Of the PHY devices using the
> >   phy_mask(= ~0)
> > * Now, did almost the same thing what mdiobus_scan does i.e.
> >     * get_phy_device but with is_c45 (=true/false)
> >     * register the above phy device with phy_device_register()
> >
> > There could be some gap in my understanding, please help to correct
> this?
> 
> So this is the question i was asking Florian
> 
> Rather than hack around limitations of the core, you should fix the
> core. I think we should make the core first try probing using c45. If
> that comes back with an error, or does not find a device, try the
> probe using c22.
I can take this activity but please allow me to do this as a separate activity
and not part of this driver Up-streaming activity.

Since I would be touching the core, lots of drivers will get impacted and will
have to wait till everyone gives clean signal. This will impact our internal
deadlines. But as I said I am eager to cooperate & contribute :)

Thanks
Salil
> 
>       Andrew
