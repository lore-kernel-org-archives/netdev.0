From: greg chesson <greg@atheros.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Wed, 08 Sep 2004 13:52:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413F70F0.6020709@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <1094628909.1097.145.camel@jzny.localdomain> <413F2D33.1000508@atheros.com> <200409082251.45771.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca, jgarzik@pobox.com,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409082251.45771.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Vladimir Kondratiev wrote:
> Greg,
> you missed one important point. Besides data packets, that every driver now 
> convert .11<->.3 using almost the same code, there is whole story of 
> management. Many modern cards are "softmac" and do all management on host. I 
> see no point for every driver to implement its own scanning and association. 

Yes, Quite right.  No disagreement.
It is standard practice on NDIS and Apple Darwin that a common GUI-based
application controls scanning, association, and manages 
keys+authentication+crypto.

Linux does the same thing (driver is configured by application code)
  although there does not yet exist a single app
that can serve as a common point of control for multiple vendor drivers.
I believe that achieving that goal is the real payoff for wireless Linux 
users.

> It is simply waste of resources.
> 
> To make step forward, I suggest the following:
> 
> 1. Dave's code is at least year old. someone need to start maintain it, 
> starting with update for current kernel infrastructure. Get it compile and 
> load for 2.6.9, for example.
> 
> 2. To debug stack, you don't need real driver. I can write dummy .11 driver 
> that will silently discard all Tx, and will provide some way for user level 
> tool to simulate Rx (ioctl, netlink, does not really matter). For logic, it 
> is sufficient. Later, when it will come to timing, performance etc, it will 
> be easy to strip some real driver.
> 
> This may be king of "proof of concept".

Yes, for logic it is sufficient.
My personal approach would be to test the theory by examining
what fits or doesn't fit into David's API if I were to port one of the
MLME implementations that I work with.   Discover if it fits or not.


> 
> Vladimir
> 
> On Wednesday 08 September 2004 19:02, greg chesson wrote:
> gc> You guys are too serious and, I believe, missed the real points.
> gc>
> gc> 1.  There is a need in the OS for a "service" to convert between
> gc>        .11 and .3 packet formats.   It should be designed for
> gc> hw-independence.
> gc>       Everyone sees the same potential for unification
> gc>        of wireless drivers.
> gc>
> gc> 2.  It's harder to do than it first appears because the complete
> gc>       transformation from .3 to .11 cannot be done in isolation
> gc>       from the driver(s) and there are monkey wrenches that get
> gc>       tossed in from crypto, interaction between crypto and
>  fragementation, gc>       power-save, observing txoplimits, and other things
>  that tend gc>       to cross architecture lines that would otherwise be nice
>  and clean. gc>
> gc> 3.  I personally don't have religion about whether a service
> gc>       that transforms headers is implemented as a stack or implemented
> gc>       as a side call.   I think that a variety of factors are worth
> gc> considering.
> gc>       In this particular case (header transformation), I believe a side
>  call gc>       "helper function" is appropriate and has less overhead than
>  the full gc>       protocol stack mechanism.   But it's pointless to argue
>  about it gc> without
> gc>       measurements.
> gc>
> gc> 4.  David's skeleton code is quite interesting and a good start.
> gc>        You won't know its usefulness until someone tries to implement
> gc>       a real driver.
> gc>
> gc> g
> gc>
> gc>
> gc>
> gc> jamal wrote:
> gc> > On Tue, 2004-09-07 at 13:10, David S. Miller wrote:
> gc> >
> gc> >>On Tue, 07 Sep 2004 10:03:41 -0700
> gc> >>greg chesson <greg@atheros.com> wrote:
> gc> >>
> gc> >>
> gc> >>>What about eth_type_trans()?
> gc> >>
> gc> >>It determines the protocol type from the ethernet header
> gc> >>fields.  It is a simple shorthand header field fetcher,
> gc> >>not a protocol stack.
> gc> >>
> gc> >>You would need a eth80211_type_trans() for wireless
> gc> >>drivers too, and surprise surprise my skeleton 802.11
> gc> >>stack code in fact does exactly this.
> gc> >
> gc> >
> gc> > Or as Andi has been suggesting for sometime, not invoke it all ;->
> gc> > This is possible if the DMA descriptor already has all the info
> gc> > needed (quiet a few modern hardware can be programmed to do this).
> gc> > .. er, at the driver level. So this is not "a gross input packet
> gc> > hooked eater thing that's an ugly wart bolted onto the
> gc> > side of the driver API.";->
> gc> >
> gc> > cheers,
> gc> > jamal
> gc> >
> gc> >
> gc> >
> gc>
> gc>
> gc>
> gc
> 
