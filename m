From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v5 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Tue, 19 Sep 2017 21:49:52 -0500
Message-ID: <CAL_JsqJ2eVA9Zg60Hagqm732ZoOzHWTwVBqOabOhjE5aQ26L+g@mail.gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-6-clabbe.montjoie@gmail.com> <20170908072538.rqsp6dobwsqmzrsr@flea.lan>
 <20170908074325.GB29999@Red> <20170913182004.uniyo5opeilcfk7r@rob-hp-laptop>
 <20170914185301.GB4021@Red> <20170914191949.GA3796@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170914191949.GA3796-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 2:19 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> > Is the MDIO controller "allwinner,sun8i-h3-emac" or "snps,dwmac-mdio"?
>> > If the latter, then I think the node is fine, but then the mux should be
>> > a child node of it. IOW, the child of an MDIO controller should either
>> > be a mux node or slave devices.
>
> Hi Rob
>
> Up until now, children of an MDIO bus have been MDIO devices. Those
> MDIO devices are either Ethernet PHYs, Ethernet Switches, or the
> oddball devices that Broadcom iProc has, like generic PHYs.
>
> We have never had MDIO-muxes as MDIO children. A Mux is not an MDIO
> device, and does not have the properties of an MDIO device. It is not
> addressable on the MDIO bus. The current MUXes are addressed via GPIOs
> or MMIO.

The DT parent/child relationship defines the bus topology. We describe
MDIO buses in that way and if a mux is sitting between the controller
and the devices, then the DT hierarchy should reflect that. Now
sometimes we have 2 options for what interface has the parent/child
relationship (e.g. an I2C controlled USB hub chip), but in this case
we don't.

> There other similar cases. i2c-mux-gpio is not a child of an i2c bus,
> nor i2c-mux-reg or gpio-mux. nxp,pca9548 is however a child of the i2c
> bus, because it is an i2c device itself...

Some are i2c controlled mux devices, but some can be GPIO controlled.

>
> If the MDIO mux was an MDIO device, i would agree with you. Bit it is
> not, so lets not make it a child.
>
>             Andrew
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
