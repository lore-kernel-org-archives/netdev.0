From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/31] mm: tag reseve pages
Date: Thu, 1 Oct 2009 14:09:54 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.0910011407390.32006@chino.kir.corp.google.com>
References: <1254405917-15796-1-git-send-email-sjayaraman@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        netdev@vger.kernel.org, Neil Brown <neilb@suse.de>,
        Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1254405917-15796-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> Index: mmotm/mm/page_alloc.c
> ===================================================================
> --- mmotm.orig/mm/page_alloc.c
> +++ mmotm/mm/page_alloc.c
> @@ -1501,8 +1501,10 @@ zonelist_scan:
>  try_this_zone:
>  		page = buffered_rmqueue(preferred_zone, zone, order,
>  						gfp_mask, migratetype);
> -		if (page)
> +		if (page) {
> +			page->reserve = !!(alloc_flags & ALLOC_NO_WATERMARKS);
>  			break;
> +		}
>  this_zone_full:
>  		if (NUMA_BUILD)
>  			zlc_mark_zone_full(zonelist, z);

page->reserve won't necessary indicate that access to reserves was 
_necessary_ for the allocation to succeed, though.  This will mark any 
page being allocated under PF_MEMALLOC as reserve when all zones may be 
well above their min watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
