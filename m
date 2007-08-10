From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.23-rc2: WARNING: at kernel/irq/resend.c:70
	check_irq_resend()
Date: Fri, 10 Aug 2007 10:30:50 +0200
Message-ID: <20070810083050.GA4545@elte.hu>
References: <18107.11431.838905.331157@stoffel.org> <20070809155445.GA5161@ff.dom.local> <1186733140.12828.45.camel@chaos> <20070810082346.GD1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, vignaud@xandmail.fr,
	marcin.slusarz@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070810082346.GD1764@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> > Hmm. This solution is still just pampering over the real problem. 
> > The delayed disable just re-sends level interrupts unnecessarily. I 
> > have a fix (needs some testing) for this, which I send out tomorrow, 
> > when I'm really back from vacation.
> > 
> > But suppressing the resend is not fixing the driver problem. The 
> > problem can show up with spurious interrupts and with interrupts on 
> > a shared PCI interrupt line at any time. It just might take weeks 
> > instead of minutes.
> 
> Doesn't it look like a little change of mind? [...]

what change of mind do you mean exactly?

> [...] Well, there are probably (but need more testing) two other 
> solutions: _SW_RESEND and disabling without delay for levels only...

IIRC Marcin tested software-resend and it didnt fix the hang. That 
strongly points in the direction of a driver bug (or a genirq bug) being 
made more prominent by the genirq change - not any hardware detail such 
as the APIC vector-retrigger sequence.

While we'd like to see the suspected driver bug (or any higher level 
genirq bug) fixed, we'll undo the effect of the genirq change (because 
it is causing a regression). We'll also add a separate, optional 
irq-debugging feature that generates high-rate interrupts on any shared 
irq line. (and thus artificially stresses the robustness of the driver 
and the genirq layer against spurious interrupts.)

	Ingo
