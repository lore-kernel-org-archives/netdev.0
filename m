From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Tue, 17 Aug 2004 09:38:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408170933240.9207-100000@dhcp83-76.boston.redhat.com>
References: <20040817100755.A20489@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040817100755.A20489@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004, Christoph Hellwig wrote:

> On Tue, Aug 17, 2004 at 02:43:38AM -0400, James Morris wrote:
> >  net/bridge/br_fdb.c: br_fdb_cache = kmem_cache_create("bridge_fdb_cache"
> >  net/decnet/dn_table.c:  dn_hash_kmem = kmem_cache_create("dn_fib_info_cache"
> 
> Can't these two be modular?

Yes, although I'm not clear on what should be done.  Returning an error
via an initcall does not do anything, so if these were built statically,
then the kernel would go on running after they failed.  This is a general
problem.  e.g. IPv6, which is commonly built as a module, will panic if
kmem_cache_create() fails during module load in several places.


- James
-- 
James Morris
<jmorris@redhat.com>
