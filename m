From: Andi Kleen <ak@suse.de>
Subject: Re: purpose of the skb head pool
Date: Tue, 29 Apr 2003 15:03:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429130317.GA32212@Wotan.suse.de>
References: <20030429135506.A22411@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20030429135506.A22411@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 01:55:06PM +0200, Christoph Hellwig wrote:
> [sorry, wrong Cc: the first time]
> 
> net/core/skbuf.c has a small per-cpu pool to keep some hot skbufs around
> instead of returning them to the system allocator.  But if you loook
> at the slab allocator we'll have exactly that same code duplicated in
> there (see functions ac_data, __cache_alloc and kmem_cache_alloc in
> slab.c).  So is there some other reason why this pool is needed?

The code was added before slab grew an own per cpu allocator.

AFAIK it wasn't removed because the "extreme routing" people
like Jamal and Robert O. still saw small advantages, but it's 
probably worth rebenchmarking.

-Andi
