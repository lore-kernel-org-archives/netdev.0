From: Roy Pledge <roy.pledge@freescale.com>
Subject: RE: [v2 04/11] soc/fsl: Introduce drivers for the DPAA QMan
Date: Tue, 15 Sep 2015 15:32:10 +0000
Message-ID: <BN3PR0301MB1267B1FE0917FB456281983F8C5C0@BN3PR0301MB1267.namprd03.prod.outlook.com>
References: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
 <1439410497-19039-5-git-send-email-Roy.Pledge@freescale.com>
 <20150912011005.GA8796@home.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Scott Wood <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150912011005.GA8796@home.buserror.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Wood Scott-B07421
> Sent: Friday, September 11, 2015 9:10 PM
> To: Pledge Roy-R01356 <roy.pledge@freescale.com>
> Cc: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [v2 04/11] soc/fsl: Introduce drivers for the DPAA QMan
> 
> On Wed, Aug 12, 2015 at 04:14:50PM -0400, Roy Pledge wrote:
> > +/* Lock/unlock frame queues, subject to the "LOCKED" flag. This is
> > +about
> > + * inter-processor locking only. Note, FQLOCK() is always called
> > +either under a
> > + * local_irq_save() or from interrupt context - hence there's no need
> > +for irq
> > + * protection (and indeed, attempting to nest irq-protection doesn't
> > +work, as
> > + * the "irq en/disable" machinery isn't recursive...). */ #define
> > +FQLOCK(fq) \
> > +	do { \
> > +		struct qman_fq *__fq478 = (fq); \
> > +		if (fq_isset(__fq478, QMAN_FQ_FLAG_LOCKED)) \
> > +			spin_lock(&__fq478->fqlock); \
> > +	} while (0)
> > +#define FQUNLOCK(fq) \
> > +	do { \
> > +		struct qman_fq *__fq478 = (fq); \
> > +		if (fq_isset(__fq478, QMAN_FQ_FLAG_LOCKED)) \
> > +			spin_unlock(&__fq478->fqlock); \
> > +	} while (0)
> > +
> 
> I don't see QMAN_FQ_FLAG_LOCKED set anywhere.  What is the use case?

The idea was to allow multiple threads to manipulate the state of a frame queue at the same time without clobbering each others changes since the operation is a read/modify/write.  I see two users of this flag in code that hasn't been submitted upstream yet, but I'm not sure if the use is required in those two instances either. At a glance it doesn't seem like it is needed but I would need to follow up with the users to make sure they aren't performing FQ management commands in multiple threads.

> 
> -Scott
