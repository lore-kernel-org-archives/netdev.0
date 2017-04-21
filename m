From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Date: Fri, 21 Apr 2017 10:52:29 -0700
Message-ID: <CA+55aFznH8Y9_okyQ=dU1AeJL8rtHx=n5DqT3sGJj7kr6QMYXA@mail.gmail.com>
References: <20170420110042.73d01e0f@redhat.com> <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>, Tariq Toukan <tariqt@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
To: Mel Gorman <mgorman@techsingularity.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 7:30 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>> The end result was a revert, and this is waiting in AKPMs quilt queue:
>>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
>>
>
> This was flagged to Andrew that it should go in for either 4.11 or if
> there were concerns about how close to the release we are then put it in
> for 4.11-stable. At worst, I can do a resubmit to -stable myself after
> it gets merged in the next window if it falls between the cracks.

This got merged (commit d34b0733b452: "Revert "mm, page_alloc: only
use per-cpu allocator for irq-safe requests"").

The other issue (caused by commit a499a5a14dbd: "sched/cputime:
Increment kcpustat directly on irqtime account") is still open.

Frederic? Revert? But I guess it's something we can delay for
backporting, it's presumably not possible to hit maliciously except on
some fast local network attacker just causing an effective DoS.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
