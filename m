From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 10:06:55 -0400
Message-ID: <20131101140655.GA8467@hmsreliant.think-freely.org>
References: <20131029114907.GE24477@neilslaptop.think-freely.org>
 <20131029125233.GA17449@gmail.com>
 <20131029130712.GA25078@neilslaptop.think-freely.org>
 <20131029131149.GB20408@gmail.com>
 <20131029141706.GC25078@neilslaptop.think-freely.org>
 <20131029142716.GA28113@gmail.com>
 <20131029202644.GB32389@localhost.localdomain>
 <20131031102200.GA10098@gmail.com>
 <20131031143325.GB25894@hmsreliant.think-freely.org>
 <20131101091337.GA27063@gmail.com>
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
In-Reply-To: <20131101091337.GA27063@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 01, 2013 at 10:13:37AM +0100, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > On Thu, Oct 31, 2013 at 11:22:00AM +0100, Ingo Molnar wrote:
> > > 
> > > * Neil Horman <nhorman@tuxdriver.com> wrote:
> > > 
> > > > > etc. For such short runtimes make sure the last column displays 
> > > > > close to 100%, so that the PMU results become trustable.
> > > > > 
> > > > > A nehalem+ PMU will allow 2-4 events to be measured in parallel, 
> > > > > plus generics like 'cycles', 'instructions' can be added 'for free' 
> > > > > because they get counted in a separate (fixed purpose) PMU register.
> > > > > 
> > > > > The last colum tells you what percentage of the runtime that 
> > > > > particular event was actually active. 100% (or empty last column) 
> > > > > means it was active all the time.
> > > > > 
> > > > > Thanks,
> > > > > 
> > > > > 	Ingo
> > > > > 
> > > > 
> > > > Hmm, 
> > > > 
> > > > I ran this test:
> > > > 
> > > > for i in `seq 0 1 3`
> > > > do
> > > > echo $i > /sys/module/csum_test/parameters/module_test_mode
> > > > taskset -c 0 perf stat --repeat 20 -C 0 -e L1-dcache-load-misses -e L1-dcache-prefetches -e cycles -e instructions -ddd ./test.sh
> > > > done
> > > 
> > > You need to remove '-ddd' which is a shortcut for a ton of useful 
> > > events, but here you want to use fewer events, to increase the 
> > > precision of the measurement.
> > > 
> > > Thanks,
> > > 
> > > 	Ingo
> > > 
> > 
> > Thank you ingo, that fixed it.  I'm trying some other variants of 
> > the csum algorithm that Doug and I discussed last night, but FWIW, 
> > the relative performance of the 4 test cases 
> > (base/prefetch/parallel/both) remains unchanged. I'm starting to 
> > feel like at this point, theres very little point in doing 
> > parallel alu operations (unless we can find a way to break the 
> > dependency on the carry flag, which is what I'm tinkering with 
> > now).
> 
> I would still like to encourage you to pick up the improvements that 
> Doug measured (mostly via prefetch tweaking?) - that looked like 
> some significant speedups that we don't want to lose!
> 
Well, yes, I made a line item of that in my subsequent note below.  I'm going to
repost that shortly, and I suggested that we revisit this when the AVX
instruction extensions are available.

> Also, trying to stick the in-kernel implementation into 'perf bench' 
> would be a useful first step as well, for this and future efforts.
> 
> See what we do in tools/perf/bench/mem-memcpy-x86-64-asm.S to pick 
> up the in-kernel assembly memcpy implementations:
> 
Yes, I'll look into adding this as well
Regards
Neil
