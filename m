From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: 8390.c workaround for interrupt storm
Date: Fri, 13 Aug 2004 17:07:37 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040813200737.GC29875@logos.cnet>
References: <20040813153047.GC28640@logos.cnet> <411D21DE.2050804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <411D21DE.2050804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 13, 2004 at 04:17:34PM -0400, Jeff Garzik wrote:
> Marcelo Tosatti wrote:
> >Hi netdev, 
> >
> >We've been seeing an interrupt storm on our 
> >embedded PowerPC systems with Linksys PCMLM56 (network+modem) 
> >PCMCIA cards (network part of it driven by pcnet_cs.c) as soon as the 
> >network cable is  pluged/unpluged and after some activity on the serial
> >line. 
> >
> >The card goes nuts, and doesnt stop sending interrupts. 
> >
> >So I hacked up this patch which resets the 8390 chip
> >as soon as 256 empty interrupts are triggered. Works fine,
> >the card comes back to sanity after resetting.
> >
> >Not sure if its specific to our boards, but I believe
> >it might happen on other archs also, so I'm posting it 
> >here in the hope it might be useful for someone with the
> >same problem.
> >
> >Not likely to be included in mainline driver, but hey, why not,
> >its protection against hardware insanity.

Hi Jeff!

> You have stumbled on a common class of problems, I think.
> 
> IMO interrupt storms are almost always caused by the platform or bus.  I 
> see tons of bug reports for ethernet drivers which turn out to be 
> interrupt routing, interrupt handling, or interrupt storms unrelated to 
> the ethernet driver itself.
> 
> Yes, you can sometimes work around this in the driver, but that tends to 
> wind up hiding the problem.

I see. So, following your thoughts, what is causing the interrupt storm 
here is not the card itself, but the bus/platform/irq controller? That is,
those interrupts are not coming from the card.

Or that something on the bus/platform/irq controller triggers the card
into insanity, and the card really is sending those interrupts? 

Since resetting the 8390 stops it from madness, its likely that 
the card itself is sending the interrupts, no?

Interesting...

> PCMCIA debugging isn't fun, to be sure, maybe RMK has some ideas?

This is a MontaVista v2.4.17 kernel patched up, so I doubt he will care much.

I'll ask him anyway.

Thanks for answering!!
