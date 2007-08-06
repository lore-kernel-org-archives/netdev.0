From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch (take 2)] genirq: fix simple and fasteoi irq handlers
Date: Mon, 6 Aug 2007 09:19:32 +0200
Message-ID: <20070806071932.GA1973@ff.dom.local>
References: <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731155843.GA7033@elte.hu> <46B20E47.6020403@googlemail.com> <20070802201126.GA27000@elte.hu> <20070806060723.GA981@ff.dom.local> <20070806061459.GA26046@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, marcin.slusarz@gmail.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070806061459.GA26046@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 06, 2007 at 08:14:59AM +0200, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > Subject: genirq: fix simple and fasteoi irq handlers
> > 
> > After the "genirq: do not mask interrupts by default" patch interrupts 
> > should be disabled not immediately upon request, but after they 
> > happen. But, handle_simple_irq() and handle_fasteoi_irq() can skip 
> > this once or more if an irq is just serviced (IRQ_INPROGRESS), 
> > possibly disrupting a driver's work.
> 
> nice fix. I think this is exactly the type of bug we were hoping to be 
> able to identify and fix, and it could explain the regression in its 
> entirety. The big question - does it fix Marcin's regression?

Alas, there still could be something more... To be more sure, even
with this, there should be some debug printk (which could mess too),
but I don't know how much patience (and similar boxes...) Marcin has.
Of course, this "temporary fix" in -rc2 should give us more time.
But, I think you should confirm this gain with levels (I mean there
could be some saving on flag setting/ checking too). E.g. I've thought
about adding another ioapic_chip struct for fasteoi without .retrigger
(and maybe with .disable = .mask) maybe with some #ifdef CONFIG_...,
but maybe there could be reconsidered IRQ_DELAYED_DISABLE too (but
with this, there probably was a possibility to run this hw ->retrigger
'by chance' too, so with some strange IO-APICS there would be still
an unnecessary risk here).

The big question for me is still why this isn't more common: it seems
some (most of?) IO-APICS have some safety against this?

BTW: Marcin, if you're still willing to test anything (and your box is
alive after my previous 'could not make any damage' patch - sorry!),
this should be done with something before -rc2, so 2.6.22 or .23-rc1.

Jarek P.

PS: I've just read Marcin's messages - so, happily, it seems
everybody's alive! Thanks.
