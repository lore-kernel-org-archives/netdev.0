From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 10:13:16 +0200
Message-ID: <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
 <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34462 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752329AbcI0INT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 04:13:19 -0400
In-Reply-To: <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 03:38 AM, Eric Dumazet wrote:
> On Mon, 2016-09-26 at 17:01 -0700, Andrew Morton wrote:
>
>> I don't share Eric's concerns about performance here.  If the vmalloc()
>> is called, we're about to write to that quite large amount of memory
>> which we just allocated, and the vmalloc() overhead will be relatively
>> low.
>
> I did not care of the performance of this particular select() system
> call really, but other cpus because of more TLB invalidations.

There are many other ways to cause those, AFAIK. The reclaim/compaction
for order-3 allocation has its own impact on system, including TLB flushes.
Or a flood of mmap(MAP_POPULATE) and madvise(MADV_DONTNEED) calls...
This vmalloc() would however require raising RLIMIT_NOFILE above the defaults.

> At least CONFIG_DEBUG_PAGEALLOC=y builds should be impacted, but maybe
> we do not care.

I doubt anyone runs that in production, especially if performance is of concern.
