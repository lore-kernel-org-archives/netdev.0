From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Thu, 22 Sep 2016 10:07:48 -0700
Message-ID: <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
	 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton
 <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko
 <mhocko@kernel.org>,  netdev@vger.kernel.org
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-22 at 18:56 +0200, Vlastimil Babka wrote:
> On 09/22/2016 06:49 PM, Eric Dumazet wrote:
> > On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
> >> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
> >> with the number of fds passed. We had a customer report page allocation
> >> failures of order-4 for this allocation. This is a costly order, so it might
> >> easily fail, as the VM expects such allocation to have a lower-order fallback.
> >>
> >> Such trivial fallback is vmalloc(), as the memory doesn't have to be
> >> physically contiguous. Also the allocation is temporary for the duration of the
> >> syscall, so it's unlikely to stress vmalloc too much.
> >
> > vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.
> >
> > So I guess allowing vmalloc() being called from an innocent application
> > doing a select() might be dangerous, especially if this select() happens
> > thousands of time per second.
> 
> Isn't seq_buf_alloc() similarly exposed? And ipc_alloc()?

Possibly.

We don't have a library function (attempting kmalloc(), fallback to
vmalloc() presumably to avoid abuses, but I guess some patches were
accepted without thinking about this.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
