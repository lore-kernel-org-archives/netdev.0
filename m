From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867
 TI's PHY driver
Date: Thu, 2 Feb 2017 02:54:16 +0100
Message-ID: <20170202015416.GG4967@lunn.ch>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
 <20170201171610.GC7395@lunn.ch>
 <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
 <20170201220500.29d478aa@jawa>
 <20170201211440.GG7395@lunn.ch>
 <20170201231323.732dd327@jawa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Karicheri Muralidharan <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Engestrom <eric-op+oiCINJLTt9jDmeYuA0g@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>,
        Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170201231323.732dd327@jawa>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2017 at 11:13:23PM +0100, Lukasz Majewski wrote:
> Hi Andrew,
> 
> > > We would need a tri-state device tree properly:
> > > 
> > > 1. Not defined - do nothing
> > > 2. Defined as 0 -> explicitly disable port mirroring
> > > 3. Defined as 1 -> explicitly enable port mirriring
> > > 
> > > The "net-phy-lane-swap" only fulfills points 1 and 3 above.
> > > 
> > > In my use case I do need point 2.
> > 
> > Looking at the datasheet, PORT_MIRROR_EN defaults to 0. So it seems
> > reasonable to unconditionally set it to 0 when the PHY driver
> > loads. Any device which needs a value of 1 can set "net-phy-lane-swap"
> 
> Unconditionally setting this field to 0 (as we expect the reset default
> setting) seems to me like a good solution. 
> 
> However, I was not sure if such approach is acceptable by the community.

So the issue here is, are there boards with bootloaders which set this
"lane swap" bit, and rely on Linux not changing it, because the
hardware design has such a swap?

It seems the bootloader you are using does this. But in your case, it
does it wrongly. I'm guessing you have a vendor bootloader? And no
easy access to the sources? Otherwise you would of fixed the
bootloader. So can we assume there are vendor designed boards which
require the swap? Do they run a mainline kernel? Or only the vendor
kernel?

If we know of mainline boards which are going to break, we should not
do this.

If however we do decide to reset it to default value, i think it would
be good to implement net-phy-lane-swap as well, so giving people an
easier path towards mainline.

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
