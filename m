From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Sun, 25 Sep 2016 11:50:05 -0700
Message-ID: <87r387oluq.fsf@tassilo.jf.intel.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
	<1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org,linux-kernel@vger.kernel.org,netdev@vger.kernel.org
To: linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>> with the number of fds passed. We had a customer report page allocation
>> failures of order-4 for this allocation. This is a costly order, so it might
>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>> 
>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>> physically contiguous. Also the allocation is temporary for the duration of the
>> syscall, so it's unlikely to stress vmalloc too much.
>
> vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.
>
> So I guess allowing vmalloc() being called from an innocent application
> doing a select() might be dangerous, especially if this select() happens
> thousands of time per second.

Yes it seems like a bad idea because of all the scaling problems here.

The right solution would be to fix select to use multiple
non virtually contiguous pages.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
