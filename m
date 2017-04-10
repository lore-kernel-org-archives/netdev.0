From: Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 0/6] mvmdio updates
Date: Mon, 10 Apr 2017 21:57:36 +0200
Message-ID: <CAPv3WKfguGokT=Dm-5-rA+zQ3Tg+dL9bQvX5mPqA48bdT-EJ4A@mail.gmail.com>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170410152728.GT17774-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Russel,

2017-04-10 17:27 GMT+02:00 Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>:
> This series of patches update mvmdio for Armada 8k CP110.  A number of
> issues were found:
>
> 1. The driver fails to disable an interrupt when something goes wrong
>    in the probe function.
>
> 2. The interrupt is specified in DT to be optional, but the driver
>    unconditionally writes to the interrupt mask register, which may
>    not exist.
>
> 3. The DT binding specifies
>     "reg: address and length of the SMI register"
>    however, when supporting the interrupt, the size must cover the
>    interrupt register as well.  Update the binding documentation
>    with this information that was previously omitted.
>
> 4. If the register size is too small, have the driver print an error
>    and disable use of the interrupt.
>
> 5. Armada 8k needs three clocks for the MDIO interface, otherwise the
>    SoC hangs (since it is part of one of the ethernet interfaces.)
>    GOP clock, MG core clock and MG clock are needed on 8k. Augment the
>    binding and driver to allow three clocks to be specified.
>

Actually most of the interfaces on a7k/a8k require multiple clocks to
be enabled, however all those twisted dependencies are handled within:
drivers/clk/mvebu/cp110-system-controller.c
With the latest patch of Thomas Petazzoni, MG clock is already
specified as a child of MG_CORE, so I believe a just minor change will
resolve remaining GOP clock dependency. This way we will leave
orion-mdio driver untouched around clocks.

Thomas, what is your opinion?

Regards,
Marcin
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
