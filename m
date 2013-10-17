From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Thu, 17 Oct 2013 11:19:21 -0700
Message-ID: <52602A29.506@zytor.com>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com> <20131012172124.GA18241@gmail.com> <20131014202854.GH26880@hmsreliant.think-freely.org> <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com> <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com> <20131017003421.GA31470@hmsreliant.think-freely.org> <20131017084121.GC22705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>, Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131017084121.GC22705@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2013 01:41 AM, Ingo Molnar wrote:
> 
> To correctly simulate the workload you'd have to:
> 
>  - allocate a buffer larger than your L2 cache.
> 
>  - to measure the effects of the prefetches you'd also have to randomize
>    the individual buffer positions. See how 'perf bench numa' implements a
>    random walk via --data_rand_walk, in tools/perf/bench/numa.c.
>    Otherwise the CPU might learn your simplistic stream direction and the
>    L2 cache might hw-prefetch your data, interfering with any explicit 
>    prefetches the code does. In many real-life usecases packet buffers are
>    scattered.
> 
> Also, it would be nice to see standard deviation noise numbers when two 
> averages are close to each other, to be able to tell whether differences 
> are statistically significant or not.
> 

Seriously, though, how much does it matter?  All the above seems likely
to do is to drown the signal by adding noise.

If the parallel (threaded) checksumming is faster, which theory says it
should and microbenchmarking confirms, how important are the
macrobenchmarks?

	-hpa
