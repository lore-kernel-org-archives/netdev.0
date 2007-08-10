From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70 check_irq_resend()
Date: Fri, 10 Aug 2007 11:12:31 +0200
Message-ID: <20070810091231.GH1764@ff.dom.local>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local> <20070810083050.GA4545@elte.hu> <20070810084924.GF1764@ff.dom.local> <20070810085611.GA11639@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070810085611.GA11639@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 10:56:11AM +0200, Ingo Molnar wrote:
...
> this changes the picture completely and makes the IO-APIC/local-APIC hw 
> retrigger code/logic the main suspect. I think you right that it's quite 
> bogus to hw-retrigger level irqs, and that could be confusing the 
> IO-APIC (or the local APIC, or both).
> 
> and i think i see why my first sw-resend patch didnt do the trick:
> 
> > > -               if (!desc->chip || !desc->chip->retrigger ||
> > > -                                       !desc->chip->retrigger(irq)) {
> > > +               if (desc->handle_irq == handle_edge_irq) {
> > > +                       if (desc->chip->retrigger)
> > > +                               desc->chip->retrigger(irq);
> > > +                       return;
> > > +               }
> > >  #ifdef CONFIG_HARDIRQS_SW_RESEND
> 
> we used the hw-resend method unconditionally, right?

Right: unconditionally on a condition they are not edges...

But, since not resending at all seems to work so good in testing,
I thought, _SW_RESEND could be considered as an unnecessarily
complicated alternative.

Now, I'm a bit confused...

Jarek P.
