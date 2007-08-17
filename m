From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 08:42:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708170840270.25474@anakin>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Mackerras <paulus@samba.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoboe1bl1.telenet-ops.be ([195.130.137.72]:55825 "EHLO
	hoboe1bl1.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbXHQGmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 02:42:31 -0400
In-Reply-To: <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Aug 2007, Linus Torvalds wrote:
> On Fri, 17 Aug 2007, Paul Mackerras wrote:
> > I'm really surprised it's as much as a few K.  I tried it on powerpc
> > and it only saved 40 bytes (10 instructions) for a G5 config.
> 
> One of the things that "volatile" generally screws up is a simple
> 
> 	volatile int i;
> 
> 	i++;
> 
> which a compiler will generally get horribly, horribly wrong.
> 
> In a reasonable world, gcc should just make that be (on x86)
> 
> 	addl $1,i(%rip)
> 
> on x86-64, which is indeed what it does without the volatile. But with the 
> volatile, the compiler gets really nervous, and doesn't dare do it in one 
> instruction, and thus generates crap like
> 
>         movl    i(%rip), %eax
>         addl    $1, %eax
>         movl    %eax, i(%rip)
> 
> instead. For no good reason, except that "volatile" just doesn't have any 
> good/clear semantics for the compiler, so most compilers will just make it 
> be "I will not touch this access in any way, shape, or form". Including 
> even trivially correct instruction optimization/combination.

Apart from having to fetch more bytes for the instructions (which does
matter), execution time is probably the same on modern processors, as they
convert the single instruction to RISC-style load, modify, store anyway.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
