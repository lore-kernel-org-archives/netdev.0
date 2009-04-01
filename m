From: Sajith P V <sajithpv@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Wed, 1 Apr 2009 17:24:27 +0530
Message-ID: <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
	 <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Alan Carvalho de Assis <acassis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:44700 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763730AbZDALya convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 07:54:30 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2069wff.4
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 04:54:27 -0700 (PDT)
In-Reply-To: <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,

On Tue, Mar 31, 2009 at 7:06 PM, Alan Carvalho de Assis
<acassis@gmail.com> wrote:
> This is a fix to get cs89x0 network driver working on i.MX31ADS
> diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
> index ff64976..8ccc8f7 100644
> --- a/drivers/net/cs89x0.c
> +++ b/drivers/net/cs89x0.c
> @@ -190,6 +190,7 @@ static unsigned int cs8900_irq_map[] =3D
> {IRQ_IXDP2X01_CS8900, 0, 0, 0};
> =A0static unsigned int netcard_portlist[] __used __initdata =3D
> {CIRRUS_DEFAULT_BASE, 0};
> =A0static unsigned int cs8900_irq_map[] =3D {CIRRUS_DEFAULT_IRQ, 0, 0=
, 0};
> =A0#elif defined(CONFIG_MACH_MX31ADS)
> +#include <mach/hardware.h>
> =A0#include <mach/board-mx31ads.h>
> =A0static unsigned int netcard_portlist[] __used __initdata =3D {
> =A0 =A0 =A0 =A0PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
>

I tried this change on a different Freescale board but using the same
ethernet controller. The probe worked as shown in the console dump
below:

cs89x0:cs89x0_probe(0x0)
cs89x0.c: v2.4.3-pre1 Russell Nelson <nelson@crynwr.com>, Andrew
Morton <andrewm@uow.edu.au>
eth0: cs8900 rev K found at 0xf0000300
cs89x0: Extended EEPROM checksum bad and no Cirrus EEPROM, relying on
command line
cs89x0 media  IRQ 61, programmed I/O, MAC 00:00:00:00:00:00
cs89x0_probe1() successful
cs89x0:cs89x0_probe(0x0)
cs89x0: request_region(0xf0000300, 0x10) failed
cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETU=
P

But going further the network device configuration failed:
IP-Config: Failed to open eth0
IP-Config: No network devices available.

Should we not also enable interrupts for the ethernet controller to
make it work?

Regards,
Saijth
