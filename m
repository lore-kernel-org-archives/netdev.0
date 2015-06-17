From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 01/12] fsl/fman: Add the FMan FLIB headers
Date: Wed, 17 Jun 2015 12:57:51 -0500
Message-ID: <1434563871.2353.90.camel@freescale.com>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
	 <1433962446.2477.121.camel@freescale.com>
	 <DM2PR03MB3830ADD2B503C6738BB27E7E6A60@DM2PR03MB383.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM2PR03MB3830ADD2B503C6738BB27E7E6A60@DM2PR03MB383.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-17 at 09:59 -0500, Liberman Igal-B31950 wrote:
> 
> Regards,
> Igal Liberman.
> 
> > -----Original Message-----
> > From: Wood Scott-B07421
> > Sent: Wednesday, June 10, 2015 9:54 PM
> > To: Bucur Madalin-Cristian-B32716
> > Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linuxppc-
> > dev@lists.ozlabs.org; Liberman Igal-B31950
> > Subject: Re: [PATCH 01/12] fsl/fman: Add the FMan FLIB headers
> > 
> > On Wed, 2015-06-10 at 18:21 +0300, Madalin Bucur wrote:
> > > From: Igal Liberman <Igal.Liberman@freescale.com>
> > > 
> > > This patch presents the FMan Foundation Libraries (FLIB) headers.
> > > The FMan FLib provides the basic API used by the FMan drivers to
> > > configure and control the FMan hardware.
> > > 
> > > Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> > > ---
> > >  .../ethernet/freescale/fman/flib/common/general.h  |  41 ++
> > >  .../net/ethernet/freescale/fman/flib/fsl_fman.h    | 609
> > > +++++++++++++++++++++
> > >  2 files changed, 650 insertions(+)
> > >  create mode 100644
> > > drivers/net/ethernet/freescale/fman/flib/common/general.h
> > >  create mode 100644
> > > drivers/net/ethernet/freescale/fman/flib/fsl_fman.h
> > 
> > Why do we need separate patches just for headers?
> > 
> 
> We wanted to make the patches smaller, it's the main reason for this 
> separation.

Patches should be divided by function, not arbitrarily in order to 
decrease size.  Splitting like this makes it harder to see the whole 
picture, to search for identifiers, etc.

The right way to make these patches smaller is to remove unnecessary 
features.


> > What does the flib directory mean, in the context of Linux?  If 
> > someone were
> > to add code to this driver, how do they know if the code should go 
> > into the
> > flib directory or not?
> > 
> > > 
> > > +#define iowrite32be(val, addr)               out_be32(&(*addr), 
> > > val)
> > > +#define ioread32be(addr)             in_be32(&(*addr))
> > 
> > iowrite32be()/ioread32be() are already defined for all relevant 
> > architectures.
> > Why are you redefining them into something PPC- specific?
> > 
> 
> Removed those. 

Please don't stop at the specific things I'm pointing out.

> > > +/* do not change! if changed, must be disabled for rev1 ! */ 
> > > #define
> > > +DEFAULT_HALT_ON_EXTERNAL_ACTIVATION  false
> > > +/* do not change! if changed, must be disabled for rev1 ! */ 
> > > #define
> > > +DEFAULT_HALT_ON_UNRECOVERABLE_ECC_ERROR false
> > 
> > rev1 of what chip?
> > 
> 
> P4080. I'll update the comments. 

No.  p4080rev1 is not supported, and in any case this is not the right 
way to select different errata for different chips.

-Scott
