From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sun, 11 Jun 2017 04:43:14 +0200
Message-ID: <20170611024314.GD26740@lunn.ch>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-7-salil.mehta@huawei.com>
 <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net,
        yisen.zhuang@huawei.com, huangdaode@hisilicon.com,
        lipeng321@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ba416774-9ccc-e6b6-3518-fb492b8b2858@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +int hclge_mac_mdio_config(struct hclge_dev *hdev)
> > +{
> > +	struct hclge_mac *mac = &hdev->hw.mac;
> > +	struct mii_bus *mdio_bus;
> > +	struct net_device *ndev = &mac->ndev;
> > +	struct phy_device *phy;
> > +	bool is_c45;
> > +	int ret;
> > +
> > +	if (hdev->hw.mac.phy_addr >= PHY_MAX_ADDR)
> > +		return 0;
> > +
> > +	if (hdev->hw.mac.phy_if == PHY_INTERFACE_MODE_NA)
> > +		return 0;
> > +	else if (mac->phy_if == PHY_INTERFACE_MODE_SGMII)
> > +		is_c45 = 0;
> > +	else if (mac->phy_if == PHY_INTERFACE_MODE_XGMII)
> > +		is_c45 = 1;
> > +	else
> > +		return -ENODATA;
> 
> Can you consider using a switch () case statement here?

Does this concept even make sense? The Marvell 10G phy will use SGMII
for 10/100/1000Mbs and swap to XGMII for 10Gbps. It however stays a
c45 device all the time.

In general, i don't think PHY mode is related to C22/C45.

   Andrew
