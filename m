From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
Date: Thu, 04 Jun 2015 19:37:57 -0700
Message-ID: <1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150604103159.4744.75870.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150604103159.4744.75870.stgit@ivy>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-04 at 12:31 +0200, Jesper Dangaard Brouer wrote:
> This patch improves performance of SLUB allocator fastpath with 38% by
> avoiding the call to this_cpu_cmpxchg_double() for NO-PREEMPT kernels.
> 
> Reviewers please point out why this change is wrong, as such a large
> improvement should not be possible ;-)

I am not sure if anyone already answered, but the cmpxchg_double()
is needed to avoid the ABA problem.

This is the whole point using tid _and_ freelist

Preemption is not the only thing that could happen here, think of
interrupts.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
