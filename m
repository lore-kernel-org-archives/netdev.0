From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH V5 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Fri, 28 Jul 2017 23:50:38 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B82AA4A@FRAEML521-MBX.china.huawei.com>
References: <20170728222652.118448-1-salil.mehta@huawei.com>
 <20170728222652.118448-7-salil.mehta@huawei.com>
 <20170728232428.GA16080@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170728232428.GA16080-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> Sent: Saturday, July 29, 2017 12:24 AM
> To: Salil Mehta
> Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH V5 net-next 6/8] net: hns3: Add MDIO support to
> HNS3 Ethernet driver for hip08 SoC
> 
> > +static void hclge_mac_adjust_link(struct net_device *netdev)
> > +{
> > +	struct hnae3_handle *h = *((void **)netdev_priv(netdev));
> > +	struct hclge_vport *vport = hclge_get_vport(h);
> > +	struct hclge_dev *hdev = vport->back;
> > +	int duplex, speed;
> > +	int ret;
> > +
> > +	speed = netdev->phydev->speed;
> > +	duplex = netdev->phydev->duplex;
> > +
> > +	ret = hclge_cfg_mac_speed_dup(hdev, speed, duplex);
> > +	if (ret)
> > +		dev_err(&hdev->pdev->dev, "adjust link fail.\n");
> 
> Here and hclge_mac_start_phy() you have a netdev, so you should be
> using netdev_err()
Ok sure. Will replace in next patch.

> 
> > +}
> > +
> > +int hclge_mac_start_phy(struct hclge_dev *hdev)
> > +{
> > +	struct net_device *netdev = hdev->vport[0].nic.netdev;
> > +	struct phy_device *phydev = hdev->hw.mac.phydev;
> > +	int ret;
> > +
> > +	if (!phydev)
> > +		return 0;
> > +
> > +	ret = phy_connect_direct(netdev, phydev,
> > +				 hclge_mac_adjust_link,
> > +				 PHY_INTERFACE_MODE_SGMII);
> > +	if (ret) {
> > +		pr_info("phy_connect_direct err");
> > +		return ret;
> 
> netdev_err(). checkpatch probably gave you a warning about this?
No, it did not.

> 
> > +	}
> > +
> > +	phy_start(phydev);
> > +
> > +	return 0;
> > +}
> > +
> > +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> > +{
> > +	struct net_device *netdev = hdev->vport[0].nic.netdev;
> > +	struct phy_device *phydev = netdev->phydev;
> > +
> > +	phy_stop(phydev);
> > +	phy_disconnect(phydev);
> > +}
> 
> In hclge_mac_start_phy() you check for !phydev. Here you
> unconditionally use phydev. Seems inconsistent.
Yes, I think NULL check for phy should be present here as well.

> 
> 	Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
