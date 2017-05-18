From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 11:21:45 -0400 (EDT)
Message-ID: <20170518.112145.1364316716714361952.davem@davemloft.net>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1495112345-24795-1-git-send-email-geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>
Date: Thu, 18 May 2017 14:59:05 +0200

> If an Ethernet PHY is initialized before the interrupt controller it is
> connected to, a message like the following is printed:
> 
>     irq: no irq domain found for /interrupt-controller@e61c0000 !
> 
> However, the actual error is ignored, leading to a non-functional (-1)
> PHY interrupt later:
> 
>     Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=-1)
> 
> Depending on whether the PHY driver will fall back to polling, Ethernet
> may or may not work.
> 
> To fix this:
>   1. Switch of_mdiobus_register_phy() from irq_of_parse_and_map() to
>      of_irq_get().
>      Unlike the former, the latter returns -EPROBE_DEFER if the
>      interrupt controller is not yet available, so this condition can be
>      detected.
>      Other errors are handled the same as before, i.e. use the passed
>      mdio->irq[addr] as interrupt.
>   2. Propagate and handle errors from of_mdiobus_register_phy() and
>      of_mdiobus_register_device().
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>

Florian or someone similarly knowledgable, please review.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
