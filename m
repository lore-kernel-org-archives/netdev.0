From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 8390.c workaround for interrupt storm
Date: Fri, 13 Aug 2004 16:17:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411D21DE.2050804@pobox.com>
References: <20040813153047.GC28640@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
In-Reply-To: <20040813153047.GC28640@logos.cnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marcelo Tosatti wrote:
> Hi netdev, 
> 
> We've been seeing an interrupt storm on our 
> embedded PowerPC systems with Linksys PCMLM56 (network+modem) 
> PCMCIA cards (network part of it driven by pcnet_cs.c) as soon as the network 
> cable is  pluged/unpluged and after some activity on the serial
> line. 
> 
> The card goes nuts, and doesnt stop sending interrupts. 
> 
> So I hacked up this patch which resets the 8390 chip
> as soon as 256 empty interrupts are triggered. Works fine,
> the card comes back to sanity after resetting.
> 
> Not sure if its specific to our boards, but I believe
> it might happen on other archs also, so I'm posting it 
> here in the hope it might be useful for someone with the
> same problem.
> 
> Not likely to be included in mainline driver, but hey, why not,
> its protection against hardware insanity.


You have stumbled on a common class of problems, I think.

IMO interrupt storms are almost always caused by the platform or bus.  I 
see tons of bug reports for ethernet drivers which turn out to be 
interrupt routing, interrupt handling, or interrupt storms unrelated to 
the ethernet driver itself.

Yes, you can sometimes work around this in the driver, but that tends to 
wind up hiding the problem.

PCMCIA debugging isn't fun, to be sure, maybe RMK has some ideas?

	Jeff
