From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Tue, 13 Jun 2017 20:47:50 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A2303@FRAEML521-MBX.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
 <20170611024314.GD26740@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170611024314.GD26740@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Sunday, June 11, 2017 3:43 AM
> To: Florian Fainelli
> Cc: Salil Mehta; davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode;
> lipeng (Y); mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
> Ethernet driver for hip08 SoC
> 
> > > +int hclge_mac_mdio_config(struct hclge_dev *hdev)
> > > +{
> > > +	struct hclge_mac *mac = &hdev->hw.mac;
> > > +	struct mii_bus *mdio_bus;
> > > +	struct net_device *ndev = &mac->ndev;
> > > +	struct phy_device *phy;
> > > +	bool is_c45;
> > > +	int ret;
> > > +
> > > +	if (hdev->hw.mac.phy_addr >= PHY_MAX_ADDR)
> > > +		return 0;
> > > +
> > > +	if (hdev->hw.mac.phy_if == PHY_INTERFACE_MODE_NA)
> > > +		return 0;
> > > +	else if (mac->phy_if == PHY_INTERFACE_MODE_SGMII)
> > > +		is_c45 = 0;
> > > +	else if (mac->phy_if == PHY_INTERFACE_MODE_XGMII)
> > > +		is_c45 = 1;
> > > +	else
> > > +		return -ENODATA;
> >
> > Can you consider using a switch () case statement here?
> 
> Does this concept even make sense? The Marvell 10G phy will use SGMII
> for 10/100/1000Mbs and swap to XGMII for 10Gbps. It however stays a
> c45 device all the time.
> 
> In general, i don't think PHY mode is related to C22/C45.
You are correct is_c45 should not be derived from the type of PHY like
it is being done here. I have changed this code and now we are getting this
information from the IMP(Integrated Management Processor) which handles
the NIC commands and also maintains Ethernet specific configuration.

Thanks
Salil
> 
>    Andrew
