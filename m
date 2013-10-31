From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Thu, 31 Oct 2013 11:22:00 +0100
Message-ID: <20131031102200.GA10098@gmail.com>
References: <20131029082542.GA24625@gmail.com>
 <20131029112022.GA24477@neilslaptop.think-freely.org>
 <20131029113031.GA16897@gmail.com>
 <20131029114907.GE24477@neilslaptop.think-freely.org>
 <20131029125233.GA17449@gmail.com>
 <20131029130712.GA25078@neilslaptop.think-freely.org>
 <20131029131149.GB20408@gmail.com>
 <20131029141706.GC25078@neilslaptop.think-freely.org>
 <20131029142716.GA28113@gmail.com>
 <20131029202644.GB32389@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029202644.GB32389@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> > etc. For such short runtimes make sure the last column displays 
> > close to 100%, so that the PMU results become trustable.
> > 
> > A nehalem+ PMU will allow 2-4 events to be measured in parallel, 
> > plus generics like 'cycles', 'instructions' can be added 'for free' 
> > because they get counted in a separate (fixed purpose) PMU register.
> > 
> > The last colum tells you what percentage of the runtime that 
> > particular event was actually active. 100% (or empty last column) 
> > means it was active all the time.
> > 
> > Thanks,
> > 
> > 	Ingo
> > 
> 
> Hmm, 
> 
> I ran this test:
> 
> for i in `seq 0 1 3`
> do
> echo $i > /sys/module/csum_test/parameters/module_test_mode
> taskset -c 0 perf stat --repeat 20 -C 0 -e L1-dcache-load-misses -e L1-dcache-prefetches -e cycles -e instructions -ddd ./test.sh
> done

You need to remove '-ddd' which is a shortcut for a ton of useful 
events, but here you want to use fewer events, to increase the 
precision of the measurement.

Thanks,

	Ingo
