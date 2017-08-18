From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next] net: hns3: Add support to change MTU in
 hardware & netdev
Date: Fri, 18 Aug 2017 17:03:58 +0200
Message-ID: <20170818150358.GA3258@lunn.ch>
References: <20170818113558.71928-1-salil.mehta@huawei.com>
 <20170818133128.GA523@lunn.ch>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B86F75F@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org" <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B86F75F-WFPaWmAhWqtUuCJht5byYAK1hpo4iccwjNknBlVQO8k@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > +	/* MTU range: 68 - 9706 */
> > > +	netdev->min_mtu = ETH_MIN_MTU;
> > 
> > http://elixir.free-
> > electrons.com/linux/latest/source/net/ethernet/eth.c#L361
> Supported range of Min and Max MTU should be at the discretion
> of the driver. Therefore, initialization looks fine to me.
> 
> I could not clearly understand the problem being highlighted
> over here. Could you further clarify?

This is already setting min_mtu to ETH_MIN_MTU. There is no need for
you to set it.

> > >  #define HNS3_RING_MAX_PENDING			32768
> > > +#define HNS3_MAX_MTU				9728
> > 
> > It seems odd that it does not already exists somewhere. The core does
> > not enforce the MTU.  You could be passed a frame which is bigger. So
> > you should check before trying to pass something to the hardware which
> > the hardware cannot handle.
> There is a check already in place for this as well since 4.10-rc1.

Yes, the core will check when changing the MTU.

But when passing frames to be transmitted, it does not check the frame
fits the MTU.  DSA actually makes use of this, when passing frames to
an Ethernet switch attached to the interface. We need to add an extra
header to the frame, which makes the frame bigger than the MTU. Most
Ethernet drivers are happy with this, they send the frame. Other
reject it, and we have had to make driver changes. And some just
explode :-(

If 9728 is a hard limit for your device, you should check when passed
a frame to make sure it is actually <= 9728 bytes in length.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
