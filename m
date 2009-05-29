From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Fri, 29 May 2009 13:49:56 -0700
Message-ID: <20090529134956.44104655@nehalam>
References: <20090517201528.GA8552@ami.dom.local>
	<20090518065629.GA6006@ff.dom.local>
	<298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	<298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	<20090521085116.GC2892@ami.dom.local>
	<298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
	<20090523073201.GA2766@ami.dom.local>
	<298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
	<20090528211258.GA3658@ami.dom.local>
	<298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
	<20090529194643.GA2753@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39263 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbZE2UuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 16:50:00 -0400
In-Reply-To: <20090529194643.GA2753@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 May 2009 21:46:43 +0200
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Fri, May 29, 2009 at 06:02:39PM +0100, Antonio Almeida wrote:
> > On Thu, May 28, 2009 at 10:12 PM, Jarek Poplawski wrote:
> > > Yes, but according to my assessment there should be "only" 50Mbit
> > > difference for this rate/packet size. Anyway, could you try a testing
> > > patch below, which should add some granularity to this rate table?
> > >
> > > Thanks,
> > > Jarek P.
> > > ---
> > >
> > >  include/net/pkt_sched.h |    4 ++--
> > >  1 files changed, 2 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> > > index e37fe31..f0faf03 100644
> > > --- a/include/net/pkt_sched.h
> > > +++ b/include/net/pkt_sched.h
> > > @@ -42,8 +42,8 @@ typedef u64   psched_time_t;
> > >  typedef long   psched_tdiff_t;
> > >
> > >  /* Avoid doing 64 bit divide by 1000 */
> > > -#define PSCHED_US2NS(x)                        ((s64)(x) << 10)
> > > -#define PSCHED_NS2US(x)                        ((x) >> 10)
> > > +#define PSCHED_US2NS(x)                        ((s64)(x) << 6)
> > > +#define PSCHED_NS2US(x)                        ((x) >> 6)
> > >
> > >  #define PSCHED_TICKS_PER_SEC           PSCHED_NS2US(NSEC_PER_SEC)
> > >  #define PSCHED_PASTPERFECT             0
> > 
> > It's better! This patch gives more accuracy to HTB. Here some values:
> > Note that these are boundary values, so, e.g., any HTB configuration
> > between 377000Kbit and 400000Kbit would fall in the same step - close
> > to 397977Kbit.
> 
> Good news! So it seems there are no other reasons of this inaccuracy
> than too coarse granularity, but I have to check this yet. Alas there
> is needed something more than this patch, because it probably breaks
> other things like hfsc.
> 
> Thanks,
> Jarek P.
> 

Why would it break hfsc, if it isn't already broken.
