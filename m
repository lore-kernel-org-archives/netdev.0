From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH linux-next v2 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 21:04:42 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004302038140.2951@localhost.localdomain>
References: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com> <alpine.LFD.2.00.1004301249540.2951@localhost.localdomain> <Pine.WNT.4.64.1004301059230.6264@PPWASKIE-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.WNT.4.64.1004301059230.6264@PPWASKIE-MOBL2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
> On Fri, 30 Apr 2010, Thomas Gleixner wrote:
> > > +extern int irq_register_affinity_hint(unsigned int irq,
> > > +                                      const struct cpumask *m);
> > 
> > I think we can do with a single funtion irq_set_affinity_hint() and
> > let the caller set the pointer to NULL.
> 
> Ok, I've been running into some issues.  If CONFIG_CPUMASK_OFFSTACK is not
> set, then cpumask_var_t structs are single-element arrays that cannot be
> NULL'd out.  I'm pretty sure I need to keep the unregister part of the API.
> Thoughts?

extern int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m);

So why should calling irq_set_affinity_hint(irqnr, NULL) not work ?
 
> I just looked at the original show_affinity function, and it does not grab
> desc->lock before copying mask out of desc.  Should I follow that model, or
> should I fix that function to honor desc->lock?

desc->affinity can only race against something changing the affinity
bits, so that just might return some random data.

In the hint case the irq could be shut down and the affinity hint
could be freed while you are accessing it. Not a good idea :)

Thanks,

	tglx
