From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [PATCH v2 net-next 1/2] net: phy: Add Edge-rate driver for
 Microsemi PHYs.
Date: Thu, 15 Sep 2016 15:56:37 +0530
Message-ID: <20160915102633.GA24647@microsemi.com>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1473326242-4198-2-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160908131415.GG26445@lunn.ch>
 <20160909054009.GA26767@microsemi.com>
 <20160909131832.GB30871@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <Allan.Nielsen@microsemi.com>, <robh+dt@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0086.outbound.protection.outlook.com ([104.47.32.86]:2112
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755151AbcIOK0y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 06:26:54 -0400
Content-Disposition: inline
In-Reply-To: <20160909131832.GB30871@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review the code.

On Fri, Sep 09, 2016 at 03:18:32PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > > > +static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
> > > > +                                   u8     edge_rate)
> > >
> > > No spaces place.
> > >
> > I ran the checkpatch. I did not find any error. I created another workspace and
> > applied the same patch. It shows the correct alignement. I have used tabs (8 space width).
> > then some spaces to align braces.
> 
> Sorry, i worded that poorly. I was meaning between the u8 and edge. A
> single space is enough.
> 
I accepted your suggestion.

> > > > +#ifdef CONFIG_OF_MDIO
> > > > +static int vsc8531_of_init(struct phy_device *phydev)
> > > > +{
> > > > +     int rc;
> > > > +     struct vsc8531_private *vsc8531 = phydev->priv;
> > > > +     struct device *dev = &phydev->mdio.dev;
> > > > +     struct device_node *of_node = dev->of_node;
> > > > +
> > > > +     if (!of_node)
> > > > +             return -ENODEV;
> > > > +
> > > > +     rc = of_property_read_u8(of_node, "vsc8531,edge-rate",
> > > > +                              &vsc8531->edge_rate);
> > >
> > > Until you have written the Documentation, it is hard for me to tell,
> > > but device tree bindings should use real units, like seconds, Ohms,
> > > Farads, etc. Is the edge rate in nS? Or is it some magic value which
> > > just gets written into the register?
> > >
> >
> > This is some magic value which just gets written into the register.
> 
> Magic values are generally not accepted in device tree bindings. Both
> Micrel and Renesas define their clock skew in ps, for example. Since
> this is rise time, it should also be possible to define it in a unit
> of time.
> 

I accepted your comment. I had discussion with my hardware team and explained
the code review comments.
They asked me to define as picoseconds as units.

> > > >  static int vsc85xx_config_init(struct phy_device *phydev)
> > > >  {
> > > >       int rc;
> > > > +     struct vsc8531_private *vsc8531;
> > > > +
> > > > +     if (!phydev->priv) {
> > >
> > > How can this happen?
> > >
> >
> > VSC 8531 driver don't have any private structure assigned initially.
> > Allways priv points to NULL.
> 
> So if it cannot happen, don't check for it.
> 
> Also, by convention, you allocate memory in the .probe() function of a
> driver. Please do it there.
> 
I accepted your review comment. 
I will re-send the patch with updates.

>         Andrew

---
Thanks,
Raju.
