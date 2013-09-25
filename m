From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] random: introduce get_random_bytes_busy_wait_initialized
Date: Wed, 25 Sep 2013 15:35:30 +0200
Message-ID: <20130925133530.GD4904@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924054532.GA24446@order.stressinduktion.org> <1380028797.3165.65.camel@edumazet-glaptop> <20130925090034.GC4904@order.stressinduktion.org> <1380110810.3165.140.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, tytso@mit.edu,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380110810.3165.140.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 25, 2013 at 05:06:50AM -0700, Eric Dumazet wrote:
> On Wed, 2013-09-25 at 11:00 +0200, Hannes Frederic Sowa wrote:
> 
> >  /*
> > + * Busy loop until the nonblocking_pool is intialized and return
> > + * random data in buf of size nbytes.
> > + *
> > + * This is used by the network stack to defer the extraction of
> > + * entropy from the nonblocking_pool until the pool is initialized.
> > + *
> > + * We need to busy loop here, because we could be called from an
> > + * atomic section.
> > + */
> > +void get_random_bytes_busy_wait_initialized(void *buf, int nbytes)
> > +{
> > +	while (!nonblocking_pool.initialized)
> > +		cpu_relax();
> > +	get_random_bytes(buf, nbytes);
> > +}
> 
> No idea if this can work if called from IRQ context.
> 
> How is nonblocking_poll initialized if host has a single cpu ?

We increase the entropy_count and can initialize the random pool from
handle_irq_event.

We can document that it should not get called from irq context and
maybe add a WARN_ON(irqs_disabled())?
