From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared with h/w
Date: Wed, 4 Aug 2004 17:48:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804174856.B24545@infradead.org>
References: <20040729192519.A6235@infradead.org> <E1BqoRX-0004DH-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, ganesh.venkatesan@intel.com,
        jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BqoRX-0004DH-00@gondolin.me.apana.org.au>; from herbert@gondor.apana.org.au on Sat, Jul 31, 2004 at 05:38:11PM +1000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 05:38:11PM +1000, Herbert Xu wrote:
> > No, it's not.  vmalloc needs virtual space that's rather limited (e.g. 64MB
> > on PAE x86) in addition to physical memory.  Unless you do really big
> > allocations stay away from vmalloc.
> 
> How big is really big? 64K? 256K? 1M?

Well, the VM deals with big-order (aka bigger than page size) allocations
rather bad, so for allocation during any I/O I'd stick to allocation smaller
than that (and certainly no vmalloc!), for init-time allocations order 1 is
fine, maybe even order 2 or three.
