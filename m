From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v4 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Mon, 3 Oct 2016 14:53:35 +0530
Message-ID: <20161003092333.GA24705@microsemi.com>
References: <1475062449-22168-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928161653.GA25553@lunn.ch>
 <20161003072043.GA24259@microsemi.com>
 <20161003075656.GC18219@lunn.ch>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161003075656.GC18219-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,


On Mon, Oct 03, 2016 at 09:56:56AM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > > > +        vsc8531_0: ethernet-phy@0 {
> > > > +                compatible = "ethernet-phy-id0007.0570";
> > > > +                vsc8531,vddmac               = /bits/ 16 <MSCC_VDDMAC_3300>;
> > > > +                vsc8531,edge-slowdown        = /bits/ 8  <17>;
> > >
> > > No, real values please:
> > >
> > >                 vsc8531,vddmac          = <2000>;
> > >                 vsc8531,edge-slowdown   = <21>;
> > >
> > > The driver should then do the maths to figure out the nearest magic
> > > value to write to the register, or complain the settings are out of
> > > range with an -EINVAL.
> 
> I think you missed my point. Notice my example does not use values
> from the table. Is there a reason not to use the PHY with 2000mv? Or
> does it break when you don't use one of the 4 listed voltages?
> 
As per PHY data sheet, It should use one of the voltage in list.
i.e. 3.3V (3300 mV) or 2.5V (2500 mV) or 1.8V (1800 mV) or 1.5V (1500).
Other voltages are not accepted. Drivr considers default as 3.3V (3300 mV).

> I was wanting you to implement some formula, which given the voltage
> and percentage slowdown, returns the magic number. Hence the comment:
> 

Based on Voltage selection and percentage slowdown, Driver pick the
magic number from Edge rate table.

> > > FYI: No floating point maths are allowed in the kernel.
> 
> You need to do integer arithmetic, which is why i suggested mV, not V.
> 
I understood your suggestion and used voltage in milli Volts.

>   Andrew

Thanks,
Raju.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
