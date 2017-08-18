From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next] net: hns3: Add support to change MTU in
 hardware & netdev
Date: Fri, 18 Aug 2017 16:10:07 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B86FB7E@FRAEML521-MBX.china.huawei.com>
References: <20170818113558.71928-1-salil.mehta@huawei.com>
 <20170818133128.GA523@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B86F75F@FRAEML521-MBX.china.huawei.com>
 <20170818150358.GA3258@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B86F9E7@FRAEML521-MBX.china.huawei.com>
 <20170818160157.GB3258@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818160157.GB3258@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, August 18, 2017 5:02 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next] net: hns3: Add support to change MTU in
> hardware & netdev
> 
> > for example,
> > file: drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > static int init_one(struct pci_dev *pdev, const struct pci_device_id
> *ent)
> >
> >  		netdev->priv_flags |= IFF_UNICAST_FLT;
> >
> > +		/* MTU range: 81 - 9600 */
> > +		netdev->min_mtu = 81;
> > +		netdev->max_mtu = MAX_MTU;
> 
> In this cause, the driver is not using the default values. So it sets
> them.
> 
> Anyway, try it. After your alloc_etherdev_mqs(), print the value of
> min_mtu. It should already be set to MIN_ETH_MTU.
I understand your point. In this case, I would like to keep the
range being set by the driver just to be more explicit. 
So for now keep this initialization in the driver?

Thanks
Salil
> 
> > I see. IMHO HNS3 is currently limited by maximum buffer per
> descriptor
> > which is 64k. I am sure such frames would get dropped in the hardware
> > itself and which I guess should be more preferable than dropping in
> > driver since it saves you some precious cpu cycles?
> 
> If you hardware handles this, then you don't need to do anything.
Fine. Thanks!

Salil
> 
>    Andrew
