From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Thu, 13 Apr 2017 12:49:17 -0400 (EDT)
Message-ID: <20170413.124917.1229157998659042404.davem@davemloft.net>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170410214258.9409-1-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 10 Apr 2017 14:42:58 -0700

> A MDIO bus driver can set phy_mask to indicate which PHYs should be
> probed and which should not. Right now, of_mdiobus_register() always
> sets mdio->phy_mask to ~0 which means: don't probe anything yourself,
> and let the Device Tree scanning do it based on the availability of
> child nodes.
> 
> When MDIO buses are stacked together (on purpose, as is done by DSA), we
> run into possible double probing which is, at best unnecessary, and at
> worse, can cause problems if that's not expected (e.g: during probe
> deferral).
> 
> Fix this by remember the original mdio->phy_mask, and make sure that if
> it was set to all 0xF, we set it to zero internally in order not to
> influence how the child PHY/MDIO device registration is going to behave.
> When the original mdio->phy_mask is set to something non-zero, we honor
> this value and utilize it as a hint to register only the child nodes
> that we have both found, and indicated to be necessary.
> 
> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I don't think it's valid to have a unique OF node appear twice in the
device tree hiearchy.

Even if you can somehow hack this situation into working, you are
asking for all kinds of problems in the long run by doing things that
way.

If you have to, instantiate a new dummy device (perhaps a
platform_device, which thus can have private attributes you can store
in a structure whose layout you control) to act as the placeholder for
operation interception and property duplication.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
