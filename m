From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: RCU stall in af_unix.c, should use spin_lock_irqsave?
Date: Tue, 21 Oct 2014 12:10:11 +0200
Message-ID: <20141021121011.53686d5f@free-electrons.com>
References: <20141021100313.397f4962@free-electrons.com>
	<1413885874.23173.11.camel@edumazet-glaptop2.roam.corp.google.com>
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
In-Reply-To: <1413885874.23173.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric Dumazet,

On Tue, 21 Oct 2014 03:04:34 -0700, Eric Dumazet wrote:

> > So, the question is: is this patch the correct solution (but then other
> > usage of spin_lock in af_unix.c might also need fixing) ? Or is the
> > network driver at fault?
> > 
> > Thanks for your input,
> > 
> > Thomas
> 
> Locks in af_unix do not need to mask irqs. Ever.
> 
> skb_queue_tail() uses an irqsave variant because its a generic function,
> and _some_ skb list might be manipulated from hard irq handlers in pre
> NAPI drivers. But af_unix does not have an interrupt handler that could
> potentially try to lock sk_receive_queue.lock

Ok. So it's actually safe to mix spin_lock() and spin_lock_irqsave() on
the same lock, if you know that this lock will never ever be taken in
an interrupt context?

> mvpp2 is seriously brain damaged : on_each_cpu() cannot be used from
> a bottom half handler.

That's what I thought. Back to the drawing board then, to fix mvpp2.

Do you think there is a place where we can write down those
assumptions? It isn't easy to spot whether on_each_cpu() is safe to use
in a bottom half or not.

Anyway, thanks a lot for your quick feedback!

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
