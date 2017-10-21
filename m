From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH v3 1/4] phylib: Add device reset GPIO support
Date: Sat, 21 Oct 2017 12:08:41 +0200
Message-ID: <CAMuHMdVsbc_+YEuZGXR6UTuwPuBLZRwcKRCmkABpQiJ6vgPkRQ@mail.gmail.com>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
 <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
 <2dacbfaf-ce5e-f113-9ae8-641441d99bbc@gmail.com> <44bc181e-6fd2-4868-3c8d-64e66d9c8d6b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
        Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Ferre <nicolas.ferre-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux-Renesas <linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <44bc181e-6fd2-4868-3c8d-64e66d9c8d6b-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 21, 2017 at 12:03 PM, Sergei Shtylyov
<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> wrote:
> On 10/20/2017 9:11 PM, Florian Fainelli wrote:
>>> From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>>> --- a/drivers/of/of_mdio.c
>>> +++ b/drivers/of/of_mdio.c
>
> [...]
>>>
>>> @@ -55,10 +56,22 @@ static int of_mdiobus_register_phy(struct mii_bus
>>> *mdio,
>>>         is_c45 = of_device_is_compatible(child,
>>>                                          "ethernet-phy-ieee802.3-c45");
>>>   +     /* Deassert the optional reset signal */
>>> +       gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
>>> +                                      GPIOD_OUT_LOW, "PHY reset");
>>> +       if (PTR_ERR(gpiod) == -ENOENT)
>>> +               gpiod = NULL;
>>> +       else if (IS_ERR(gpiod))
>>> +               return PTR_ERR(gpiod);
>>> +
>>>         if (!is_c45 && !of_get_phy_id(child, &phy_id))
>>>                 phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>>>         else
>>>                 phy = get_phy_device(mdio, addr, is_c45);
>>> +
>>> +       /* Assert the reset signal again */
>>> +       gpiod_set_value(gpiod, 1);
>>
>> You have a phy_device reference now, so why not call phy_device_reset()
>> directly here?
>
>    Symmetry, perhaps? (There was a gpiod_set_value(gpiod, 0) call above
> it...

Not only because of symmetry: the validity of the phy object hasn't been
checked yet (that's done immediately below), and phy->mdio.reset hasn't been
filled in yet.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
