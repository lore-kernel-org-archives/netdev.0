From: Moritz Fischer <moritz.fischer-+aYTwkv1SeIAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Thu, 13 Jul 2017 20:36:29 -0700
Message-ID: <CAAtXAHc-Rzj41PA8tW6RWROrKDBc_YZWSo1+vvihB5njF_Og-Q@mail.gmail.com>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org>
 <1499980909-11702-2-git-send-email-mdf@kernel.org> <20170713223636.GF3120@lunn.ch>
 <20170714003111.GA13512@tyrael.ni.corp.natinst.com> <20170714013435.GA9065@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Devicetree List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170714013435.GA9065-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Thu, Jul 13, 2017 at 6:34 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> > > + /* not sure if this is the correct way of dealing with this ... */
>> > > + ndev->phydev->supported &= ~(SUPPORTED_Autoneg);
>> > > + ndev->phydev->advertising = ndev->phydev->supported;
>> > > + ndev->phydev->autoneg = AUTONEG_DISABLE;
>> >
>> > What are you trying to achieve?
>>
>> Basically can't do Autoneg, I'll need to take a closer look.
>
> Hi Moritz
>
> What i actually think you mean, is it can only do 1Gbps. So you could
> autoneg, but only advertise 1Gbps. Look at masking out
> PHY_10BT_FEATURES and PHY_100BT_FEATURES.

It does either 1Gbps or 10Gbps (over SFP+), depending which bitstream is loaded
into the  FPGA. In the current setup I could also just have two
different compatible
strings, since neither setup supports the other rate, but that might change.

It seems getting rid of that part (the default values) now works, too.

I'll need to take a closer look tomorrow (and I need to retest with 1Gbps)

>
> Take a look at:
>
> http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/renesas/ravb_main.c#L1045

Will do.

Thanks for feedback,

Moritz
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
