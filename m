From: Andreas =?iso-8859-1?q?Irest=E5l?= <andreas.irestal-VrBV9hrLPhE@public.gmane.org>
Subject: Re: [RFC PATCH] net:Add basic DWC Ethernet QoS Driver
Date: Thu, 8 May 2014 16:18:04 +0200
Message-ID: <201405081618.04475.Andreas.Irestal@axis.com>
References: <201405081349.03139.Andreas.Irestal@axis.com> <20248221.mJ8pFfyc5U@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org" <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org" <abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
	"jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"sr-ynQEQJNshbs@public.gmane.org" <sr-ynQEQJNshbs@public.gmane.org>,
	"jonas.jensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <jonas.jensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jesper Nilsson <jespern-VrBV9hrLPhE@public.gmane.org>, <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20248221.mJ8pFfyc5U@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > Signed-off-by: Andreas Irestaal <Andreas.Irestal-VrBV9hrLPhE@public.gmane.org>
> > ---
> >  drivers/net/ethernet/Kconfig                |    1 +
> >  drivers/net/ethernet/Makefile               |    1 +
> >  drivers/net/ethernet/synopsys/Kconfig       |   24 +
> >  drivers/net/ethernet/synopsys/Makefile      |    5 +
> >  drivers/net/ethernet/synopsys/dwc_eth_qos.c |  710 +++++++++++++++++++++++++++
> >  drivers/net/ethernet/synopsys/dwc_eth_qos.h |  308 ++++++++++++
> 
> Should we maybe move the dw_mac driver out of the stmicro directory into
> synopsys as a preparation, to keep them in the same place?
> 

That sounds like a good idea since that driver uses the same IP. I'm not the
person to take that decision though.

> > +
> > +	/* Set poll wait timeout to 2 seconds */
> > +	dwc_wait = 200;
> > +
> > +	while (lp->tx_descs[i].tdes3.wr.own) {
> > +		mdelay(10);
> > +		if (!dwc_wait--)
> > +			break;
> > +	}
> 
> This is really evil: you are blocking the CPU for up to two seconds!
> You already mentioned that this is work-in-progress, but I guess it has
> to be a little better than this and do something that doesn't block
> out the CPU during TX.
> 

It really is, but a 2s lockout is only happening upon TX failure. Anyway, this
won't be an issue in the final version, since it won't use polling for TX.

> 
> > +/* Fields/constants */
> > +#define DWCEQOS_DMA_MODE_SWR			1
> > +#define DWCEQOS_DMA_MODE_TXPR			(1 << 11)
> > +#define DWCEQOS_DMA_MODE_DA			(1 << 1)
> > +#define DWCEQOS_DMA_SYSBUS_MB			(1 << 14)
> 
> I find it more readable to use hexadecimal notation here
> 
> #define DWCEQOS_DMA_MODE_SWR		0x0001
> #define DWCEQOS_DMA_MODE_DA		0x0002
> #define DWCEQOS_DMA_MODE_TXPR		0x0800
> #define DWCEQOS_DMA_SYSBUS_MB		0x4000
> 

I agree, but it's not 100% clear which one is preferred as there exist drivers
using the first notation style. Anyway, I'll use the hex notation in future
patches since you prefer it.

Thanks for all valuable input. This was exactly the kind of feedback i was looking for

/Andreas


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
