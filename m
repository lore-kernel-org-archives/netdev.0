From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 27 Jul 2015 13:59:25 -0500
Message-ID: <1438023565.2993.299.camel@freescale.com>
References: <1437581806-17420-1-git-send-email-madalin.bucur@freescale.com>
	 <1437581806-17420-2-git-send-email-madalin.bucur@freescale.com>
	 <1437586665.20787.24.camel@perches.com>
	 <BL2PR03MB545D22D02CEEDA05878E833E6810@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Liberman Igal-B31950 <Igal.Liberman@freescale.com>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>
To: Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:48474
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751245AbbG0S7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 14:59:36 -0400
In-Reply-To: <BL2PR03MB545D22D02CEEDA05878E833E6810@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-24 at 10:45 -0500, Bucur Madalin-Cristian-B32716 wrote:
> > -----Original Message-----
> > From: Joe Perches [mailto:joe@perches.com]
> > On Wed, 2015-07-22 at 19:16 +0300, Madalin Bucur wrote:
> > > +static int __init dpa_load(void)
> > > +{
> > []
> > > + err = platform_driver_register(&dpa_driver);
> > > + if (unlikely(err < 0)) {
> > > +         pr_err(KBUILD_MODNAME
> > > +                 ": %s:%hu:%s(): platform_driver_register() = %d\n",
> > > +                 KBUILD_BASENAME ".c", __LINE__, __func__, err);
> > > + }
> > > +
> > > + pr_debug(KBUILD_MODNAME ": %s:%s() ->\n",
> > > +          KBUILD_BASENAME ".c", __func__);
> > 
> > Perhaps these should use pr_fmt
> 
> Agree.

How about dropping all that complexity, and just using pr_debug("%s\n", 
__func__), or dev_dbg where possible?

> 
> > > +static void __exit dpa_unload(void)
> > > +{
> > > + pr_debug(KBUILD_MODNAME ": -> %s:%s()\n",
> > > +          KBUILD_BASENAME ".c", __func__);
> > 
> > dynamic debug has __func__ available and perhaps
> > the function tracer might be used instead.
> > 
> > > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > []
> > > +#define __hot
> > 
> > curious.
> > 
> > Maybe it'd be good to add a real __hot to compiler.h
> 
> They're mostly there to make readers aware the code is critical, any
> changes could mess performance.

Mostly or entirely?  Why not just use a comment, which could also point out 
specific things that were done for performance?

-Scott
