From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Wed, 13 Nov 2013 11:01:03 -0500
Message-ID: <20131113160103.GA25711@neilslaptop.think-freely.org>
References: <1384220542.4771.23.camel@joe-AO722>
 <20131112171239.GC19780@hmsreliant.think-freely.org>
 <1384277615.3665.10.camel@joe-AO722>
 <20131112195005.GD19780@hmsreliant.think-freely.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B740E@saturn3.aculab.com>
 <20131113123010.GB2993@hmsreliant.think-freely.org>
 <20131113130832.GB22140@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7412@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>, Joe Perches <joe@perches.com>,
	netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7412@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2013 at 01:32:50PM -0000, David Laight wrote:
> > > I'm not sure, whats the typical capacity for the branch predictors
> > > ability to remember code paths?
> ...
> > 
> > For such simple single-target branches it goes near or over a thousand for
> > recent Intel and AMD microarchitectures. Thousands for really recent CPUs.
> 
> IIRC the x86 can also correctly predict simple sequences - like a branch
> in a loop that is taken every other iteration, or only after a previous
> branch is taken.
> 
> Much simpler cpus may use a much simpler strategy.
> I think one I've used (a fpga soft-core cpu) just uses the low
> bits of the instruction address to index a single bit table.
> This means that branches alias each other.
> In order to get the consistent cycle counts in order to minimise
> the worst case code path we had to disable the dynamic prediction.
> 
> For the checksum code the loop branch isn't a problem.
> Tests on entry to the function might get mispredicted.
> 
> So if you have conditional prefetch when the buffer is long
> then time a short buffer after a 100 long ones you'll almost
> certainly see the mispredition penalty.
> 
> FWIW I remember speeding up a copy (I think) loop on a strongarm by
> adding an extra instruction to fetch a word from later in the buffer
> into a register I never otherwise used.
> (That was an unpaged system so I knew it couldn't fault.)
> 
Fair enough, but the code we're looking at here is arch specific.  If strongarms
benefit from different coding patterns, we can handle that in that arch.  This
x86 implementation can still avoid worrying about branch predicition since its
hardware handles it well
Neil

> 	David
> 
> 
> 
> 
> 
