From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: of_mdiobus_register_phy() and deferred probe
Date: Fri, 23 Oct 2015 09:38:33 +0200
Message-ID: <CAMuHMdUpeHXze=BMRsafWbzHT8WL9L+WO5xbO7niqk0wi_eRJQ@mail.gmail.com>
References: <CAMuHMdX+_0Cf0VwmKDtcfMNwaPEN5jvjZQUXg6MKMJa+cvYz3w@mail.gmail.com>
	<56294202.5020507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56294202.5020507-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Thu, Oct 22, 2015 at 10:07 PM, Sergei Shtylyov
<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> wrote:
> On 10/22/2015 04:31 PM, Geert Uytterhoeven wrote:
>
>> Due to a probe deferral of an interrupt controller[1], the Micrel
>> Ethernet PHY on
>> r8a7791/koelsch started failing to get its IRQ:
>>
>>      no irq domain found for /interrupt-controller@e61c0000 !
>>
>> However, of_mdiobus_register_phy() uses irq_of_parse_and_map(), which
>> plainly
>> ignores EPROBE_DEFER, and it just continues.
>>
>> Later I get:
>>
>>      sh-eth ee700000.ethernet eth0: attached PHY 1 (IRQ -1) to driver
>> Micrel KSZ8041RNLI
>>
>> instead of
>>
>>      sh-eth ee700000.ethernet eth0: attached PHY 1 (IRQ 408) to driver
>> Micrel KSZ8041RNLI
>>
>> Ethernet still works, as the interrupt seems to be unneeded(?).
>
>    Yes, the phylib uses PHY polling anyway, IRQ isn't strictly necessary.
>
>> Has anyone already looked into fixing of_mdio to handle deferred probing?
>
>    It's the first time I hear about that. Will have to look into this...

Thanks a lot!

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
