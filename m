From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Wed, 13 Nov 2013 14:53:09 +0100
Message-ID: <20131113135309.GA27006@gmail.com>
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
Cc: Neil Horman <nhorman@tuxdriver.com>, Joe Perches <joe@perches.com>,
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


* David Laight <David.Laight@ACULAB.COM> wrote:

> > > I'm not sure, whats the typical capacity for the branch predictors 
> > > ability to remember code paths?
> ...
> > 
> > For such simple single-target branches it goes near or over a thousand 
> > for recent Intel and AMD microarchitectures. Thousands for really 
> > recent CPUs.
> 
> IIRC the x86 can also correctly predict simple sequences - like a branch 
> in a loop that is taken every other iteration, or only after a previous 
> branch is taken.

They tend to be rather capable but not very well documented :) With a 
large out of order execution design and 20+ pipeline stages x86 branch 
prediction accuracy is perhaps the most important design aspect to good 
CPU performance.

> Much simpler cpus may use a much simpler strategy.

Yeah. The patches in this thread are about the x86 assembly implementation 
of the csum routines, and for 'typical' x86 CPUs the branch prediction 
units and caches are certainly sophisticated enough.

Also note that here, for real usecases, the csum routines are (or should 
be) memory bandwidth limited, missing the data cache most of the time, 
with a partially idling pipeline, while branch prediction accuracy matters 
most when the pipeline is well fed and there are a lot of instructions in 
flight.

Thanks,

	Ingo
