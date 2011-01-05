From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Wed, 5 Jan 2011 17:40:18 +0800
Message-ID: <20110105094011.GA5814@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
 <1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
 <20110104095916.GE2987@jasper.tkos.co.il>
 <20110104141259.GA21274@freescale.com>
 <20110105084513.GA26617@pengutronix.de>
 <20110105090312.GO25121@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Baruch Siach <baruch@tkos.co.il>, <B32542@freescale.com>,
	<netdev@vger.kernel.org>, <bryan.wu@canonical.com>,
	<gerg@snapgear.com>, <w.sang@pengutronix.de>,
	<r64343@freescale.com>, <eric@eukrea.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <lw@karo-electronics.de>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:9749 "EHLO
	TX2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab1AEJiO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 04:38:14 -0500
Received: from mail102-tx2 (localhost.localdomain [127.0.0.1])	by
 mail102-tx2-R.bigfish.com (Postfix) with ESMTP id B17481400383	for
 <netdev@vger.kernel.org>; Wed,  5 Jan 2011 09:38:13 +0000 (UTC)
Received: from TX2EHSMHS034.bigfish.com (unknown [10.9.14.244])	by
 mail102-tx2.bigfish.com (Postfix) with ESMTP id 2BEBE15F8053	for
 <netdev@vger.kernel.org>; Wed,  5 Jan 2011 09:38:13 +0000 (UTC)
Received: from az33smr02.freescale.net (az33smr02.freescale.net
 [10.64.34.200])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p059cABj007061	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 02:38:11 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id
 p059c8qk006994	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 03:38:08 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110105090312.GO25121@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 05, 2011 at 10:03:12AM +0100, Uwe Kleine-K=F6nig wrote:
> Hello Shawn,
>=20
> On Wed, Jan 05, 2011 at 09:45:13AM +0100, Sascha Hauer wrote:
> > On Tue, Jan 04, 2011 at 10:13:09PM +0800, Shawn Guo wrote:
> > > Hi Baruch,
> > >=20
> > > On Tue, Jan 04, 2011 at 11:59:16AM +0200, Baruch Siach wrote:
> > > > Hi Shawn,
> > > >=20
> > > > On Tue, Jan 04, 2011 at 05:24:11PM +0800, Shawn Guo wrote:
> > > > > This patch is to add mx28 dual fec support. Here are some key=
 notes
> > > > > for mx28 fec controller.
> > > > >=20
> > > > >  - mx28 fec design made an assumption that it runs on a
> > > > >    big-endian system, which is incorrect. As the result, the
> > > > >    driver has to swap every frame going to and coming from
> > > > >    the controller.
> > > > >  - external phys can only be configured by fec0, which means
> > > > >    fec1 can not work independently and both phys need to be
> > > > >    configured by mii_bus attached on fec0.
> > > > >  - mx28 fec reset will get mac address registers reset too.
> > > > >  - MII/RMII mode and 10M/100M speed are configured differentl=
y
> > > > >    from i.mx/mxs fec controller.
> > > > >  - ETHER_EN bit must be set to get interrupt work.
> > > > >=20
> > > > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > > > ---
> > > > > Changes for v2:
> > > > >  - Use module parameter fec.macaddr over new kernel command l=
ine
> > > > >    fec_mac to pass mac address
> > > >=20
> > > > Since you introduce this new kernel command line parameter in p=
atch #3 of this=20
> > > > series, why not just make it right in the first place? This sho=
uld make both=20
> > > > patches smaller and easier for review.
> > > >=20
> > > > >  - Update comment in fec_get_mac() to stop using confusing wo=
rd
> > > > >    "default"
> > > > >  - Fix copyright breakage in fec.h
> > > >=20
> > > > Ditto.
> > > >=20
> > > Sorry for rushing to send the patch set out. All these updates
> > > should happen on patch #3 than #5.  This is a serious problem,
> > > and I will fix it soon and resend as v3.
> > >=20
> > > > >  drivers/net/Kconfig |    7 ++-
> > > > >  drivers/net/fec.c   |  139 +++++++++++++++++++++++++++++++++=
+++++++----------
> > > > >  drivers/net/fec.h   |    5 +-
> > > > >  include/linux/fec.h |    3 +-
> > > > >  4 files changed, 120 insertions(+), 34 deletions(-)
> > > >=20
> > > > [snip]
> > > >=20
> > > > > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > > > > index f147508..b2b3e37 100644
> > > > > --- a/drivers/net/fec.c
> > > > > +++ b/drivers/net/fec.c
> > > > > @@ -17,6 +17,8 @@
> > > > >   *
> > > > >   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.=
be)
> > > > >   * Copyright (c) 2004-2006 Macq Electronique SA.
> > > > > + *
> > > > > + * Copyright (C) 2010 Freescale Semiconductor, Inc.
> > > > >   */
> > > > > =20
> > > > >  #include <linux/module.h>
> > > > > @@ -45,21 +47,34 @@
> > > > > =20
> > > > >  #include <asm/cacheflush.h>
> > > > > =20
> > > > > -#ifndef CONFIG_ARCH_MXC
> > > > > +#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
> > > > >  #include <asm/coldfire.h>
> > > > >  #include <asm/mcfsim.h>
> > > > >  #endif
> > > > > =20
> > > > >  #include "fec.h"
> > > > > =20
> > > > > -#ifdef CONFIG_ARCH_MXC
> > > > > -#include <mach/hardware.h>
> > > >=20
> > > > Since you now remove mach/hardware.h for ARCH_MXC, does this bu=
ild for all=20
> > > > i.MX variants?
> > > >=20
> > > Did the test build for mx25, mx27, mx3 and mx51.
> > >=20
> > > > > +#ifdef CONFIG_SOC_IMX28
> > > > > +/*
> > > > > + * mx28 does not have MIIGSK registers
> > > > > + */
> > > > > +#undef FEC_MIIGSK_ENR
> > > > > +#include <mach/mxs.h>
> > > > > +#else
> > > > > +#define cpu_is_mx28()	(0)
> > > > > +#endif
> > > >=20
> > > > This breaks kernels for multiple archs (e.g. i.MX28 and i.MX25)=
=2E Please use=20
> > > > run-time detection of CPU type, and do the MII/RMII etc. config=
uration=20
> > > > accordingly.
> > > >=20
> > > I do not find a good way to detect cpu type.  Neither adding a ne=
w
> > > platform data field nor using __machine_arch_type to enumerate al=
l
> > > mx28 based machine (though there is only one currently) seems to =
be
> > > good for me.
> > >=20
> > > I will try to manipulate some mx28 unique register to identify mx=
28
> > > from other i.mx variants.  Hopefully, it will work.
> >=20
> > There won't be a register which you can safely read on all i.MX
> > variants.FEC_TRUNC_FL

Register FEC_TRUNC_FL (offset 0x1b0) is one I found I can use to
distinguish ENET-MAC from FEC.  This address is being reserved on
=46EC, and I knew from designer that access the address on FEC
will not generate exception as it's valid in FEC address range.
I proved it on mx51.

        /*
         * Detect ENET-MAC by writing and reading back on TRUNC_FL regi=
ster,
         * which is accessible on ENET-MAC while always return 0 on FEC=
=2E
         */
        writel(0x7ff, fep->hwp + 0x1b0);
        if (readl(fep->hwp + 0x1b0) =3D=3D 0x7ff)
                fec_is_enetmac =3D 1;

But it does not matter.  I more like the solution that offered by Uwe
below.

Thanks, Sascha.

> > Why don't you implement it the same way the other i.MX do? They do =
not
> > need SoC detection and the macro expands to 0 at compile time when =
the
> > cpu is not enabled.
> Alternatively you can use the approach I used for spi-imx and identif=
y
> the device by name.
>=20
Thanks, Uwe.

> Best regards
> Uwe
>=20
> --=20
> Pengutronix e.K.                           | Uwe Kleine-K=F6nig      =
      |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
>=20

--=20
Regards,
Shawn

