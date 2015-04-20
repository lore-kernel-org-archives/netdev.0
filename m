From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC,1/8] soc/fman: Add FMan MURAM support
Date: Mon, 20 Apr 2015 18:56:46 -0500
Message-ID: <1429574206.4352.53.camel@freescale.com>
References: <1426050469-12507-1-git-send-email-igal.liberman@freescale.com>
	 <32CF85E2-A8AA-454D-A46F-0E778DAF97ED@kernel.crashing.org>
	 <DM2PR03MB3835BC56CD47613CB1AD4EBE6E00@DM2PR03MB383.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>
To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:13920
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751650AbbDTX47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 19:56:59 -0400
In-Reply-To: <DM2PR03MB3835BC56CD47613CB1AD4EBE6E00@DM2PR03MB383.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-20 at 03:58 -0500, Liberman Igal-B31950 wrote:
> 
> Regards,
> Igal Liberman.
> 
> > -----Original Message-----
> > From: Kumar Gala [mailto:galak@kernel.crashing.org]
> > Sent: Thursday, March 12, 2015 5:57 PM
> > To: Liberman Igal-B31950
> > Cc: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; Wood Scott-B07421
> > Subject: Re: [RFC,1/8] soc/fman: Add FMan MURAM support
> > 
> > 
> > On Mar 11, 2015, at 12:07 AM, Igal.Liberman <igal.liberman@freescale.com>
> > wrote:
> > 
> > > From: Igal Liberman <Igal.Liberman@freescale.com>
> > >
> > > Add Frame Manager Multi-User RAM support.
> > >
> > > Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> > > ---
> > > drivers/soc/fsl/fman/Kconfig            |    1 +
> > > drivers/soc/fsl/fman/Makefile           |    5 +-
> > > drivers/soc/fsl/fman/fm_muram.c         |  174
> > +++++++++++++++++++++++++++++++
> > > drivers/soc/fsl/fman/inc/fm_muram_ext.h |   98 +++++++++++++++++
> > > 4 files changed, 276 insertions(+), 2 deletions(-) create mode 100644
> > > drivers/soc/fsl/fman/fm_muram.c create mode 100644
> > > drivers/soc/fsl/fman/inc/fm_muram_ext.h
> > >
> > 
> > use lib/genalloc instead of rheap
> > 
> 
> Hi Kumar,
> I looked into lib/genalloc allocator.
> As far as I see, the genalloc allocator doesn't allow to control the memory alignment when you allocate a chunk of memory.
> Two important notes regarding MURAM memory:
> - The allocated memory chunks should have specific alignment (might be different in each chunk).
> - The allocations must be efficient, we don't want to "waste" MURAM due to alignment issues.

If the requirement is that allocations must be size-aligned, use
gen_pool_first_fit_order_align.  Otherwise, improve genalloc to do what
you need.

-Scott
