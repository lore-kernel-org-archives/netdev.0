From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] net: cadence: Add architecture dependencies
Date: Mon, 14 Apr 2014 15:25:10 +0200
Message-ID: <1397481910.7186.84.camel@chaos.site>
References: <20140414141151.5ee5434d@endymion.delvare>
	 <534BDBC9.8000509@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33140 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbaDNNZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 09:25:13 -0400
In-Reply-To: <534BDBC9.8000509@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

Thanks for the quick reply.

Le Monday 14 April 2014 =C3=A0 14:59 +0200, Nicolas Ferre a =C3=A9crit =
:
> On 14/04/2014 14:11, Jean Delvare :
> > The Cadence ethernet chipsets are only used on specific ARM
> > architectures. Add Kconfig dependencies so that drivers for these
> > chipsets are only buildable on the relevant architectures.
> >=20
> > Signed-off-by: Jean Delvare <jdelvare@suse.de>
> > Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> > ---
> > I'm not 100% certain I got the dependencies for MACB right, please =
let
> > me know if I forgot something (or it can always be added later.)
> >=20
> >  drivers/net/ethernet/cadence/Kconfig |    6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >=20
> > --- linux-3.15-rc1.orig/drivers/net/ethernet/cadence/Kconfig	2014-0=
3-31 05:40:15.000000000 +0200
> > +++ linux-3.15-rc1/drivers/net/ethernet/cadence/Kconfig	2014-04-14 =
13:38:09.308168512 +0200
> > @@ -4,7 +4,7 @@
> > =20
> >  config NET_CADENCE
> >  	bool "Cadence devices"
> > -	depends on HAS_IOMEM
> > +	depends on HAS_IOMEM && (ARM || COMPILE_TEST)
>=20
> This one is wrong: PLATFORM_AT32AP is not an ARM platform but an AVR3=
2 one.

Doh, I thought AVR32 was a subset of ARM. See how little I know about
embedded stuff :( I'll fix and resubmit.

> >  	default y
> >  	---help---
> >  	  If you have a network (Ethernet) card belonging to this class, =
say Y.
> > @@ -22,7 +22,7 @@ if NET_CADENCE
> > =20
> >  config ARM_AT91_ETHER
> >  	tristate "AT91RM9200 Ethernet support"
> > -	depends on HAS_DMA
> > +	depends on HAS_DMA && (ARCH_AT91RM9200 || COMPILE_TEST)
> >  	select MACB
> >  	---help---
> >  	  If you wish to compile a kernel for the AT91RM9200 and enable
> > @@ -30,7 +30,7 @@ config ARM_AT91_ETHER
> > =20
> >  config MACB
> >  	tristate "Cadence MACB/GEM support"
> > -	depends on HAS_DMA
> > +	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOX=
CELL || ARCH_ZYNQ || COMPILE_TEST)
> >  	select PHYLIB
> >  	---help---
> >  	  The Cadence MACB ethernet interface is found on many Atmel AT32=
 and
> >=20
> >=20
>=20
> Well, do we really need the adding of these dependencies? I though th=
at
> we were moving toward the decreasing of dependency checks in Kconfig.=
=2E.

I realize we may not all be on the same track regarding this, and just
started a discussion thread on LKML. Sorry for not including you. Here'=
s
a pointer if you want to read and/or participate:
  https://lkml.org/lkml/2014/4/14/280

My understanding is that there was resistance to non-strictly-necessary
hardware-based dependencies because it lowered the build test coverage.
Now that COMPILE_TEST was introduced, this is no longer an issue. So I
personally would like to see more dependencies, not fewer, so as to eas=
e
kernel configuration. Well, see the thread for the details, there's
little point in repeating myself here.

Thanks,
--=20
Jean Delvare
SUSE L3 Support
