From: Christoph Hellwig <hch@lst.de>
Subject: purpose of the skb head pool
Date: Tue, 29 Apr 2003 13:55:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429135506.A22411@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[sorry, wrong Cc: the first time]

net/core/skbuf.c has a small per-cpu pool to keep some hot skbufs around
instead of returning them to the system allocator.  But if you loook
at the slab allocator we'll have exactly that same code duplicated in
there (see functions ac_data, __cache_alloc and kmem_cache_alloc in
slab.c).  So is there some other reason why this pool is needed?
