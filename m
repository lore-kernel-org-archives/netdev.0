From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] FRV: do_gettimeofday() should no longer use tickadj
Date: Wed, 6 Sep 2006 14:56:26 +0200
Message-ID: <20060906125626.GA3718@elte.hu>
References: <20060906094301.GA8694@elte.hu> <1157507203.2222.11.camel@localhost> <20060905132530.GD9173@stusta.de> <20060901015818.42767813.akpm@osdl.org> <6260.1157470557@warthog.cambridge.redhat.com> <8430.1157534853@warthog.cambridge.redhat.com> <13982.1157545856@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john stultz <johnstul@us.ibm.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:23945 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1750817AbWIFNEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 09:04:40 -0400
To: David Howells <dhowells@redhat.com>
Content-Disposition: inline
In-Reply-To: <13982.1157545856@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Howells <dhowells@redhat.com> wrote:

> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > btw., would be nice to convert it to genirq (and irqchips) too =B-) That 
> > would solve the kind of disable_irq_lockdep() breakage that was reported 
> > recently.
> 
> I can think of reasons for not using that stuff also.
> 
>  (1) Passing "struct pt_regs *regs" around is a complete waste of 
>      resources on FRV.  It's in GR28 at all times and can thus be 
>      accessed directly.

we'll get rid of that pt_regs thing centrally, from all drivers at once 
- there's upstream buy-in for that already, and Thomas already generated 
a test-patch for that a few months ago. But it's not a big issue right 
now.

>  (2) All the little operations functions cause unnecessary jumping, 
>      jumps that icache lookahead can't predict because they're 
>      register-indirect.

this shouldnt be a big issue either - we use indirect jumps all around 
the kernel. CPUs are either smart enough to predict it, or they simply 
dont have that high penalties. (and if they have high penalties but dont 
optimize for it then genirq will be the last of their worries. The VFS 
and the MM is full of function pointers.)

>  (3) ACK'ing and controlling interrupts has to be done by groups.

please be more specific, how is this not possible via genirq?

>  (4) No account is taken of interrupt priority.

hm, i'm not sure what you mean - could you be more specific?

>  (5) The FRV CPU doesn't tell me which IRQ source fired.  Much of the 
>      code I've got is stuff to try and work it out.  I could just 
>      blindly poll all the sources attached to a particular interrupt 
>      level, but that seemssomehow less efficient.

but ... somehow the current FRV code does figure out which IRQ source 
fired, right? How is that a hindrance for a genirq/irqchips based 
design?

> BTW, have you looked at my patch to fix lockdep yet?

oops, i missed it - just acked it. (This problem too was a side-effect 
of FRV having its own IRQ layer.)

	Ingo
