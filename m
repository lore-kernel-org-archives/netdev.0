From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Date: Fri, 21 Apr 2017 22:33:12 +0200
Message-ID: <20170421203311.GD2586@lerouge>
References: <20170420110042.73d01e0f@redhat.com>
 <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
 <CA+55aFznH8Y9_okyQ=dU1AeJL8rtHx=n5DqT3sGJj7kr6QMYXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tariq Toukan <tariqt@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFznH8Y9_okyQ=dU1AeJL8rtHx=n5DqT3sGJj7kr6QMYXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 21, 2017 at 10:52:29AM -0700, Linus Torvalds wrote:
> On Thu, Apr 20, 2017 at 7:30 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >> The end result was a revert, and this is waiting in AKPMs quilt queue:
> >>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> >>
> >
> > This was flagged to Andrew that it should go in for either 4.11 or if
> > there were concerns about how close to the release we are then put it in
> > for 4.11-stable. At worst, I can do a resubmit to -stable myself after
> > it gets merged in the next window if it falls between the cracks.
> 
> This got merged (commit d34b0733b452: "Revert "mm, page_alloc: only
> use per-cpu allocator for irq-safe requests"").
> 
> The other issue (caused by commit a499a5a14dbd: "sched/cputime:
> Increment kcpustat directly on irqtime account") is still open.
> 
> Frederic? Revert? But I guess it's something we can delay for
> backporting, it's presumably not possible to hit maliciously except on
> some fast local network attacker just causing an effective DoS.

I can't tell about the security impact. But indeed I think we should rather
delay for backporting if we can't manage to fix it in the upcoming days.
Especially as you can't revert this patch alone, it's part of a whole series
of ~ 30 commits that removed cputime_t and it's in the middle of the series,
so those that come after depend on it and those that come before just don't make
sense alone.

But I'll fix this ASAP.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
