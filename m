From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2 0/4] improve fault-tolerance of rhashtable runtime-test
Date: Mon, 30 Nov 2015 11:14:01 +0100
Message-ID: <20151130101401.GA17712@orbit.nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151130093755.GA8159@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 05:37:55PM +0800, Herbert Xu wrote:
> Phil Sutter <phil@nwl.cc> wrote:
> > The following series aims to improve lib/test_rhashtable in different
> > situations:
> > 
> > Patch 1 allows the kernel to reschedule so the test does not block too
> >        long on slow systems.
> > Patch 2 fixes behaviour under pressure, retrying inserts in non-permanent
> >        error case (-EBUSY).
> > Patch 3 auto-adjusts the upper table size limit according to the number
> >        of threads (in concurrency test). In fact, the current default is
> >        already too small.
> > Patch 4 makes it possible to retry inserts even in supposedly permanent
> >        error case (-ENOMEM) to expose rhashtable's remaining problem of
> >        -ENOMEM being not as permanent as it is expected to be.
> 
> I'm sorry but this patch series is simply bogus.

The whole series?!

> If rhashtable is indeed returning such errors under normal
> conditions then rhashtable is broken and we must fix it instead
> of working around it in the test code!

You're stating the obvious. Remember, the reason I prepared patch 4 was
because you wanted to fix just that bug in rhashtable in the first
place.

Just to make this clear: Patches 1-3 are reasonable on their own, the
only connection to the bug is that patch 2 makes it visible (at least on
my system it wasn't before).

> FWIW I still haven't been able to reproduce this problem, perhaps
> because my machines have too few CPUs?

Did you try with my bogus patch series applied? How many CPUs does your
test system actually have?

> So can someone please help me reproduce this? Because just loading
> test_rhashtable isn't doing it.

As said, maybe you need to increase the number of spawned threads
(tcount=50 or so).

Cheers, Phil
