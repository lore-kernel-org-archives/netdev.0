From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Fri, 04 Dec 2015 09:45:20 -0800
Message-ID: <1449251120.25029.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
	 <20151130093755.GA8159@gondor.apana.org.au>
	 <20151130101401.GA17712@orbit.nwl.cc>
	 <20151130101859.GA8378@gondor.apana.org.au>
	 <20151203125117.GB5505@gondor.apana.org.au>
	 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151204143956.GA17471@gondor.apana.org.au>
	 <20151204170101.GB29598@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204170101.GB29598@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-12-04 at 18:01 +0100, Phil Sutter wrote:
> On Fri, Dec 04, 2015 at 10:39:56PM +0800, Herbert Xu wrote:
> > On Thu, Dec 03, 2015 at 08:08:39AM -0800, Eric Dumazet wrote:
> > >
> > > Anyway, __vmalloc() can be used with GFP_ATOMIC, have you tried this ?
> > 
> > OK I've tried it and I no longer get any ENOMEM errors!
> 
> I can't confirm this, sadly. Using 50 threads, results seem to be stable
> and good. But increasing the number of threads I can provoke ENOMEM
> condition again. See attached log which shows a failing test run with
> 100 threads.
> 
> I tried to extract logs of a test run with as few as possible failing
> threads, but wasn't successful. It seems like the error amplifies
> itself: While having stable success with less than 70 threads, going
> beyond a margin I could not identify exactly, much more threads failed
> than expected. For instance, the attached log shows 70 out of 100
> threads failing, while for me every single test with 50 threads was
> successful.
> 
> HTH, Phil

But this patch is about GFP_ATOMIC allocations, I doubt your test is
using GFP_ATOMIC.

Threads (process context) should use GFP_KERNEL allocations.

BTW, if 100 threads are simultaneously trying to vmalloc(32 MB), this
might not be very wise :(

Only one should really do this, while others are waiting.

If we really want parallelism (multiple cpus coordinating their effort),
it should be done very differently.
