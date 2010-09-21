From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: do not print backtraces on GFP_ATOMIC failures
Date: Tue, 21 Sep 2010 09:46:38 -0700
Message-ID: <20100921094638.9910add0.akpm@linux-foundation.org>
References: <20100921121818.4745f038@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        KOSAKI Motohiro
 <kosaki.motohiro@jp.fujitsu.com>,
        netdev@vger.kernel.org
To: Rik van Riel <riel@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100921121818.4745f038@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2010 12:18:18 -0400 Rik van Riel <riel@redhat.com> wrote:

> Atomic allocations cannot fall back to the page eviction code
> and are expected to fail.  In fact, in some network intensive
> workloads, it is common to experience hundreds of GFP_ATOMIC
> allocation failures.
> 
> Printing out a backtrace for every one of those expected
> allocation failures accomplishes nothing good. At multi-gigabit
> network speeds with jumbo frames, a burst of allocation failure
> backtraces could even slow down the system.
> 
> We're better off not printing out backtraces on GFP_ATOMIC
> allocation failures.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 975609c..5a0bddb 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -72,7 +72,7 @@ struct vm_area_struct;
>  /* This equals 0, but use constants in case they ever change */
>  #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
>  /* GFP_ATOMIC means both !wait (__GFP_WAIT not set) and use emergency pool */
> -#define GFP_ATOMIC	(__GFP_HIGH)
> +#define GFP_ATOMIC	(__GFP_HIGH | __GFP_NOWARN)
>  #define GFP_NOIO	(__GFP_WAIT)
>  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
>  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)

A much finer-tuned implementation would be to add __GFP_NOWARN just to
the networking call sites.  I asked about this in June and it got
nixed:

http://www.spinics.net/lists/netdev/msg131965.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
