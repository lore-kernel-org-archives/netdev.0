From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform
	busses
Date: Thu, 5 Aug 2010 11:32:16 +0900
Message-ID: <AANLkTimkMy6_201XNGb41e7LivkvVHMkFZWVoA-7UmBo@mail.gmail.com>
References: <4C59E654.1090403@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C59E654.1090403@codeaurora.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 5, 2010 at 7:14 AM, Patrick Pannuto <ppannuto@codeaurora.or=
g> wrote:
> Inspiration for this comes from:
> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
>
> RFC: http://lkml.org/lkml/2010/8/3/496
> Patch is unchanged from the RFC. Reviews seemed generally positive
> and it seemed this was desired functionality.

Thanks for your patch, it's really nice to see work done in this area!
I'd like to see something like this merged in the not so distant
future. At this point I'm not so concerned about the details, so I'll
restrict myself to this:

> /drivers/my_driver.c
> =A0 =A0 =A0 =A0static struct platform_driver my_driver =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.driver =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =3D "my-driv=
er",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.owner =A0=3D THIS_MOD=
ULE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.bus =A0 =A0=3D &my_bu=
s_type,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0};

I would really prefer not to have the bus type in the here. I
understand it's needed at this point, but I wonder if it's possible to
adjust the device<->driver matching for platform devices to allow any
type of pseudo-platform bus_type.

The reason why I'd like to avoid having the bus type in the driver is
that I'd like to reuse the platform driver across multiple
architectures and buses. For instance, on the SH architecture and
SH-Mobile ARM we have SoCs with SCIF hardware blocks driven by the
sh-sci.c serial driver. The sh-sci.c platform driver supports a wide
range of different SCI(F)(A)(B) hardware blocks, and on any given SoC
there is a mix of SCIF blocks spread out on different buses.

At this point our SH platform drivers are unaware where their driver
instanced are located on the SoC. The I/O address and IRQs are
assigned via struct resource and clocks are managed through clkdev. I
believe that adding the bus type in the driver will violate this
abstraction and make it more difficult to just instantiate a driver
somewhere on the SoC.

> /somewhere/my_device.c
> =A0 =A0 =A0 =A0static struct platform_device my_device =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "my-devi=
ce",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.id =A0 =A0 =A0 =A0 =A0 =A0 =3D -1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.dev.bus =A0 =A0 =A0 =A0=3D &my_bus_ty=
pe,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.dev.parent =A0 =A0 =3D &sub_bus_1.dev=
,
> =A0 =A0 =A0 =A0};

This I don't mind at all. Actually, this is the place where the
topology should be defined IMO.

Cheers,

/ magnus
--
To unsubscribe from this list: send the line "unsubscribe linux-omap" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
