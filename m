From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Mon, 26 Sep 2016 18:38:44 -0700
Message-ID: <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlastimil Babka <vbabka@suse.cz>, Alexander Viro
 <viro@zeniv.linux.org.uk>,  linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,  Michal Hocko
 <mhocko@kernel.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-26 at 17:01 -0700, Andrew Morton wrote:

> I don't share Eric's concerns about performance here.  If the vmalloc()
> is called, we're about to write to that quite large amount of memory
> which we just allocated, and the vmalloc() overhead will be relatively
> low.

I did not care of the performance of this particular select() system
call really, but other cpus because of more TLB invalidations.

At least CONFIG_DEBUG_PAGEALLOC=y builds should be impacted, but maybe
we do not care.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
