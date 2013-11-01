From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Fri, 1 Nov 2013 10:21:48 +0100
Message-ID: <20131101092148.GB27063@gmail.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
 <20131030110214.GA10220@localhost.localdomain>
 <52710B09.6090302@redhat.com>
 <20131031183003.GC25894@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131031183003.GC25894@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> Prefetch and simluated adcx/adox from above:
>  Performance counter stats for './test.sh' (20 runs):
> 
>         35,704,331 L1-dcache-load-misses                                         ( +-  0.07% ) [75.00%]
>                  0 L1-dcache-prefetches                                         [75.00%]
>     19,751,409,264 cycles                    #    0.000 GHz                      ( +-  0.59% ) [75.00%]
>         34,850,056 branch-misses                                                 ( +-  1.29% ) [75.00%]
> 
>        7.768602160 seconds time elapsed                                          ( +-  1.38% )

btw., you might also want to try measuring only the basics:

   -e cycles -e instructions -e branches -e branch-misses

that should give you 100% in the last column and should also allow 
you to double check whether all the PMU counts are correct: is it 
the expected number of instructions, expected number of branches, 
expected number of branch-misses, etc.

Then you can remove branch stats and add just L1-dcache stats - and 
still be 100% covered:

   -e cycles -e instructions -e L1-dcache-loads -e L1-dcache-load-misses

etc.

Just so that you can trust what the PMU tells you. Prefetch counts 
are sometimes off, they might include speculative activities, etc.

Thanks,

	Ingo
