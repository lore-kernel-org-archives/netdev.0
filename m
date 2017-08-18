From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next] net: hns3: Add support to change MTU in
 hardware & netdev
Date: Fri, 18 Aug 2017 18:01:57 +0200
Message-ID: <20170818160157.GB3258@lunn.ch>
References: <20170818113558.71928-1-salil.mehta@huawei.com>
 <20170818133128.GA523@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B86F75F@FRAEML521-MBX.china.huawei.com>
 <20170818150358.GA3258@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B86F9E7@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B86F9E7-WFPaWmAhWqtUuCJht5byYAK1hpo4iccwjNknBlVQO8k@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> for example,
> file: drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  		netdev->priv_flags |= IFF_UNICAST_FLT;
>  
> +		/* MTU range: 81 - 9600 */
> +		netdev->min_mtu = 81; 
> +		netdev->max_mtu = MAX_MTU;

In this cause, the driver is not using the default values. So it sets
them.

Anyway, try it. After your alloc_etherdev_mqs(), print the value of
min_mtu. It should already be set to MIN_ETH_MTU.

> I see. IMHO HNS3 is currently limited by maximum buffer per descriptor
> which is 64k. I am sure such frames would get dropped in the hardware
> itself and which I guess should be more preferable than dropping in
> driver since it saves you some precious cpu cycles?

If you hardware handles this, then you don't need to do anything.

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
