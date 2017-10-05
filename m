From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v6 11/11] of: mdio: Prevent of_mdiobus_register from
 scanning mdio-mux nodes
Date: Thu, 5 Oct 2017 17:09:27 -0500
Message-ID: <20171005220927.7rabn3ftvow253xj@rob-hp-laptop>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
 <20170927073414.17361-12-clabbe.montjoie@gmail.com>
 <20170927141213.GF13516@lunn.ch>
 <c8697b60-294f-7cc1-8425-aa5b837fcca0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
        wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c8697b60-294f-7cc1-8425-aa5b837fcca0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 09:50:46PM -0700, Florian Fainelli wrote:
> 
> 
> On 09/27/2017 07:12 AM, Andrew Lunn wrote:
> > On Wed, Sep 27, 2017 at 09:34:14AM +0200, Corentin Labbe wrote:
> >> Each child node of an MDIO node is scanned as a PHY when calling
> >> of_mdiobus_register() givint the following result:
> >> [   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
> >> [   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
> >> [   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
> >> [...]
> >> [   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
> >> [   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31
> >>
> >> Since mdio-mux nodes are not PHY, this patch a way to to not scan
> >> them.
> > 
> > Hi Corentin
> > 
> > I still don't like this, but ...
> 
> Me neither, even more so as I don't understand the reasoning behind
> putting the mux as a child node of the MDIO bus controller in the first
> place.

If no one agrees with me, then you shouldn't just accept my answers. I'm 
not always right.

Looking at this some more, why can't mdio-mux-mmio be used? Then there 
is nothing to review or discuss. If you want to extend that then make it 
clear this is just extending/inheriting already defined bindings.

That being said, if we were starting over I would probably do mux 
designs differently with DT hierarchy reflecting the mux hierarchy, but 
that ship has sailed.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
