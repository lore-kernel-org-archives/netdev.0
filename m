From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] genirq: Add IRQ affinity notifiers
Date: Fri, 14 Jan 2011 21:40:16 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101142138090.2678@localhost6.localdomain6>
References: <1294169842.3636.31.camel@bwh-desktop>  <1294169919.3636.33.camel@bwh-desktop>  <alpine.LFD.2.00.1101141928210.2678@localhost6.localdomain6> <1295035597.5386.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295035597.5386.8.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2011, Ben Hutchings wrote:
> On Fri, 2011-01-14 at 20:47 +0100, Thomas Gleixner wrote:
> > > +#if defined(CONFIG_SMP) && defined(CONFIG_GENERIC_HARDIRQS)
> > 
> > The whole affinity thing is SMP and GENERIC_HARDIRQS only anyway, so
> > what's the point of this ifdeffery ?
> 
> The intent is that code using this can be compiled even if those config
> options are not set.  The work_struct is not needed in that case.  I
> think this is probably pointless though.

Yup, work_struct is defined for the !SMP and !GENERIC_HARDIRQS case as
well :)
 
> > > +        struct work_struct work;
> > > +#endif
> > > +        void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
> > > +        void (*release)(struct kref *ref);
> > > +};
> > > +
> > 
> > > +/**
> > > + *	irq_set_affinity_notifier - control notification of IRQ affinity changes
> > > + *	@irq:		Interrupt for which to enable/disable notification
> > > + *	@notify:	Context for notification, or %NULL to disable
> > > + *			notification.  Function pointers must be initialised;
> > > + *			the other fields will be initialised by this function.
> > > + *
> > > + *	Must be called in process context.  Notification may only be enabled
> > > + *	after the IRQ is allocated but before it is bound with request_irq()
> > 
> > Why? And if there is that restriction, then it needs to be
> > checked. But I don't see why this is necessary.
> 
> Which restriction?

  Notification may only be enabled after the IRQ is allocated but
  before it is bound with request_irq()

After IRQ is allocated is obvious, but why needs it to be done
_before_ request_irq() ?

Thanks,

	tglx
