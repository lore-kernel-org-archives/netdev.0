From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/31] mm: expose gfp_to_alloc_flags()
Date: Thu, 1 Oct 2009 14:03:16 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.0910011355230.32006@chino.kir.corp.google.com>
References: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
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
In-Reply-To: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Oct 2009, Suresh Jayaraman wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> 
> Expose the gfp to alloc_flags mapping, so we can use it in other parts
> of the vm.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>

Nack, these flags are internal to the page allocator and exporting them to 
generic VM code is unnecessary.

The only bit you actually use in your patchset is ALLOC_NO_WATERMARKS to 
determine whether a particular allocation can use memory reserves.  I'd 
suggest adding a bool function that returns whether the current context is 
given access to reserves including your new __GFP_MEMALLOC flag and 
exporting that instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
