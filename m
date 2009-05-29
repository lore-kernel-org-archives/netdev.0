From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Fri, 29 May 2009 22:59:49 +0200
Message-ID: <20090529205949.GC2753@ami.dom.local>
References: <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com> <20090521085116.GC2892@ami.dom.local> <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com> <20090523073201.GA2766@ami.dom.local> <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com> <20090529194643.GA2753@ami.dom.local> <20090529134956.44104655@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:40061 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbZE2VBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 17:01:46 -0400
Received: by bwz22 with SMTP id 22so6381166bwz.37
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 14:01:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090529134956.44104655@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 01:49:56PM -0700, Stephen Hemminger wrote:
> On Fri, 29 May 2009 21:46:43 +0200
> Jarek Poplawski <jarkao2@gmail.com> wrote:
...
> > > >  /* Avoid doing 64 bit divide by 1000 */
> > > > -#define PSCHED_US2NS(x)                        ((s64)(x) << 10)
> > > > -#define PSCHED_NS2US(x)                        ((x) >> 10)
> > > > +#define PSCHED_US2NS(x)                        ((s64)(x) << 6)
> > > > +#define PSCHED_NS2US(x)                        ((x) >> 6)
> > > >
> > > >  #define PSCHED_TICKS_PER_SEC           PSCHED_NS2US(NSEC_PER_SEC)
> > > >  #define PSCHED_PASTPERFECT             0
> > > 
> > > It's better! This patch gives more accuracy to HTB. Here some values:
> > > Note that these are boundary values, so, e.g., any HTB configuration
> > > between 377000Kbit and 400000Kbit would fall in the same step - close
> > > to 397977Kbit.
> > 
> > Good news! So it seems there are no other reasons of this inaccuracy
> > than too coarse granularity, but I have to check this yet. Alas there
> > is needed something more than this patch, because it probably breaks
> > other things like hfsc.
> > 
> > Thanks,
> > Jarek P.
> > 
> 
> Why would it break hfsc, if it isn't already broken.

I might be wrong but e.g. these usecs could be one reason:

/* convert d (us) into dx (psched us) */
static u64
d2dx(u32 d)
{
        u64 dx;

        dx = ((u64)d * PSCHED_TICKS_PER_SEC);
        dx += USEC_PER_SEC - 1;
        do_div(dx, USEC_PER_SEC);
        return dx;
}

And maybe these shifts need some adjustment:
m = (sm * PSCHED_TICKS_PER_SEC) >> SM_SHIFT;

Jarek P.
