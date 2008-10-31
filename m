From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 15/18] netdevice libertas: Fix directly reference of
	netdev->priv
Date: Fri, 31 Oct 2008 15:17:11 -0400
Message-ID: <20081031191711.GE4310@tuxdriver.com>
References: <48C0A219.2030004@cn.fujitsu.com> <48C0A76F.8090706@cn.fujitsu.com> <1220634465.6430.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1220634465.6430.16.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 05, 2008 at 01:07:45PM -0400, Dan Williams wrote:
> On Fri, 2008-09-05 at 11:28 +0800, Wang Chen wrote:
> > We have some reasons to kill netdev->priv:
> > 1. netdev->priv is equal to netdev_priv().
> > 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
> >    netdev_priv() is more flexible than netdev->priv.
> > But we cann't kill netdev->priv, because so many drivers reference to it
> > directly.
> > 
> > OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> > and I want to kill netdev->priv later, I decided to convert all the direct
> > reference of netdev->priv first.
> > 
> > Different to readonly reference of netdev->priv, in this driver, netdev->priv
> > was changed. I use netdev->ml_priv to replace netdev->priv.
> 
> Same comment as the other two; any reason we can't use netdev_priv()
> instead of ->ml_priv?  That would be preferable.

Actually, I think this one was OK -- the two ml_priv uses were for
the extra mesh and rtap devices, which point back to the already
allocated priv data for the main device.

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
