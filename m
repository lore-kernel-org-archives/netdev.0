From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Mon, 28 Oct 2013 13:49:27 -0400
Message-ID: <20131028174927.GC31048@hmsreliant.think-freely.org>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <20131012172124.GA18241@gmail.com>
 <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
 <20131028160131.GA31048@hmsreliant.think-freely.org>
 <20131028162044.GA14350@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131028162044.GA14350@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 05:20:45PM +0100, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Base:
> >        0.093269042 seconds time elapsed                                          ( +-  2.24% )
> > Prefetch (5x64):
> >        0.079440009 seconds time elapsed                                          ( +-  2.29% )
> > Parallel ALU:
> >        0.087666677 seconds time elapsed                                          ( +-  4.01% )
> > Prefetch + Parallel ALU:
> >        0.080758702 seconds time elapsed                                          ( +-  2.34% )
> > 
> > So we can see here that we get about a 1% speedup between the base 
> > and the both (Prefetch + Parallel ALU) case, with prefetch 
> > accounting for most of that speedup.
> 
> Hm, there's still something strange about these results. So the 
> range of the results is 790-930 nsecs. The noise of the measurements 
> is 2%-4%, i.e. 20-40 nsecs.
> 
> The prefetch-only result itself is the fastest of all - 
> statistically equivalent to the prefetch+parallel-ALU result, within 
> the noise range.
> 
> So if prefetch is enabled, turning on parallel-ALU has no measurable 
> effect - which is counter-intuitive. Do you have an 
> theory/explanation for that?
> 
> Thanks,
 I mentioned it farther down, loosely theorizing that running with parallel
alu's in conjunction with a prefetch, puts more pressure on the load/store unit
causing stalls while both alu's wait for the L1 cache to fill.  Not sure if that
makes sense, but I did note that in the both (prefetch+alu case) our data cache
hit rate was somewhat degraded, so I was going to play with the prefetch stride
to see if that fixed the situation.  Regardless I agree, the lack of improvement
in the both case is definately counter-intuitive.

Neil

> 
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
