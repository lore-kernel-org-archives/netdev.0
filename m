From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Tue, 4 Jan 2011 17:07:33 +0200
Message-ID: <20110104150733.GF2987@jasper.tkos.co.il>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
 <1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
 <20110104095916.GE2987@jasper.tkos.co.il>
 <20110104141259.GA21274@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gerg@snapgear.com, eric@eukrea.com,
	bryan.wu@canonical.com, r64343@freescale.com, B32542@freescale.com,
	u.kleine-koenig@pengutronix.de, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:38218 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab1ADPIp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 10:08:45 -0500
Content-Disposition: inline
In-Reply-To: <20110104141259.GA21274@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shawn,

On Tue, Jan 04, 2011 at 10:13:09PM +0800, Shawn Guo wrote:
> On Tue, Jan 04, 2011 at 11:59:16AM +0200, Baruch Siach wrote:
> > On Tue, Jan 04, 2011 at 05:24:11PM +0800, Shawn Guo wrote:

[snip]

> > > -#ifdef CONFIG_ARCH_MXC
> > > -#include <mach/hardware.h>
> > 
> > Since you now remove mach/hardware.h for ARCH_MXC, does this build for all 
> > i.MX variants?
> > 
> Did the test build for mx25, mx27, mx3 and mx51.

This is surprising. It means that this include was not needed in the first 
place. git blame says this was added in 196719ec (fec: Add support for 
Freescale MX27) by Sascha.

> > > +#ifdef CONFIG_SOC_IMX28
> > > +/*
> > > + * mx28 does not have MIIGSK registers
> > > + */
> > > +#undef FEC_MIIGSK_ENR
> > > +#include <mach/mxs.h>
> > > +#else
> > > +#define cpu_is_mx28()	(0)
> > > +#endif
> > 
> > This breaks kernels for multiple archs (e.g. i.MX28 and i.MX25). Please use 
> > run-time detection of CPU type, and do the MII/RMII etc. configuration 
> > accordingly.
> > 
> I do not find a good way to detect cpu type.  Neither adding a new
> platform data field nor using __machine_arch_type to enumerate all
> mx28 based machine (though there is only one currently) seems to be
> good for me.

How about:

#ifdef CONFIG_SOC_IMX28
#include <mach/mxs.h>
#else
#define cpu_is_mx28()    (0)
#endif

if (cpu_is_mx28() {
    /* Do i.MX28 stuff */
} else {
    /* Do other i.MX stuff */
}

Note that the '#ifdef FEC_MIIGSK_ENR' section in fec_restart() is there only 
to allow build for M5272 which does not have this define in fec.h. Physically, 
i.MX27 does not have this register either.

> I will try to manipulate some mx28 unique register to identify mx28
> from other i.mx variants.  Hopefully, it will work.
> 
> Thanks for the comments.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
