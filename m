From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Fri, 07 Oct 2011 21:07:03 +0100
Message-ID: <1318018023.2771.44.camel@bwh-desktop>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
	 <1317966007.3457.47.camel@edumazet-laptop>
	 <6.2.5.6.2.20111007020308.039be248@binnacle.cx>
	 <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw@mail.gmail.com>
	 <6.2.5.6.2.20111007143050.039bd578@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chetan loke <loke.chetan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>, Willy Tarreau <w@1wt.eu>,
	Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Joe Perches <joe@perches.com>, lokechetan@gmail.com,
	Con Kolivas <conman@kolivas.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>
To: starlight@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111007143050.039bd578@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-10-07 at 14:37 -0400, starlight@binnacle.cx wrote:
> At 02:09 PM 10/7/2011 -0400, chetan loke wrote:
[...]
> b) Use non-commodity(?) NICs(from vendors
> >you mentioned): where it might have some on-board
> >memory(cushion) and so it can absorb the spikes
> >and can also smoothen out too many
> >PCI-transactions for bursty (and small payload -
> >as in 64 byte traffic). But wait, when you use the
> >libs provided by these vendors, then their
> >driver(especially the Rx path) is not so much
> >working in inline mode as NIC drivers in case a)
> >above. This driver with a special Rx-path purely
> >exists for managing your mmap'd queues.So
> >of-course it's going to be faster that the
> >traditional inline drivers. In this partial-inline
> >mode, the adapter might i) batch the packets and
> >ii) send a single notification to the
> >host-side. With that single event you are now
> >processing 1+ packets.

Solarflare's user-mode queues have their own wakeup moderation timers,
similar to interrupt moderation timers.

Note also that NICs designed for user-mode networking may allow DMA
descriptor/event rings and doorbell registers to be mapped into user
processes.  This allows packets to be passed continuously without any
need to call into the kernel.

> Kernel bypass is probably the best answer for
> what we do.  Problem has been lack of maturity
> in their driver software.  Looks like it's reaching
> a point where they cover our use case.  As mentioned
> earlier, Solarflare could not match the Intel
> 82599 + ixgbe for this app last year.  Was a
> disaster.

Ouch.  What's the application?

> Myricom is focused on UDP (better
> for us), but only just added multi-core IRQ
> doorbell wakeups in recent months.  Previously
> one had to accept all IRQs on a single core or
> poll, neither of which works for us.
[...]

Our hardware does support spreading wakeups for user-mode queues across
multiple kernel-mode event queues (hence multiple CPUs), although not in
a very flexible way.  I believe most Onload users prefer to keep their
threads polling for events rather than waiting for wakeups, though, so
it doesn't yet use this feature.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
