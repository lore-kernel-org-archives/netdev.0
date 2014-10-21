From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: RCU stall in af_unix.c, should use spin_lock_irqsave?
Date: Tue, 21 Oct 2014 13:58:20 +0200
Message-ID: <20141021135820.3664bdeb@free-electrons.com>
References: <20141021100313.397f4962@free-electrons.com>
	<1413885874.23173.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141021121011.53686d5f@free-electrons.com>
	<1413887300.23173.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre FOURNIER <alexandre.fournier@wisp-e.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413887300.23173.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric Dumazet,

On Tue, 21 Oct 2014 03:28:20 -0700, Eric Dumazet wrote:

> > Ok. So it's actually safe to mix spin_lock() and spin_lock_irqsave() on
> > the same lock, if you know that this lock will never ever be taken in
> > an interrupt context?
> 
> Sure.

Ok, thanks.

> > > mvpp2 is seriously brain damaged : on_each_cpu() cannot be used from
> > > a bottom half handler.
> > 
> > That's what I thought. Back to the drawing board then, to fix mvpp2.
> > 
> > Do you think there is a place where we can write down those
> > assumptions? It isn't easy to spot whether on_each_cpu() is safe to use
> > in a bottom half or not.
> > 
> 
> Really ? kernel/smp.c is full of comments.
> 
> Too many comments and people seem to not read them ;)
> 
> Take a look at smp_call_function(), which is called from on_each_cpu()

Indeed, it's written black on white on smp_call_function(). I guess
we'll have to dig into the details of the mvpp2 hardware and its
per-CPU registers and see how to handle things properly.

Thanks a lot for your input!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
