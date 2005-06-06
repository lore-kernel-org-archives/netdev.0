From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 6 Jun 2005 22:40:43 +1000
Message-ID: <20050606124043.GA625@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604112314.GA19819@infradead.org> <20050604112606.GA1799@gondor.apana.org.au> <20050604115853.GA20335@infradead.org> <20050606115939.GA399@gondor.apana.org.au> <20050606120914.GA8317@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20050606120914.GA8317@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 01:09:14PM +0100, Christoph Hellwig wrote:
>
> > #if (PAGE_SHIFT > 16) || (BITS_PER_LONG > 32)
> 
> what is the BITS_PER_LONG check for?

These structures are normally used in arrays.  On a 64-bit machine
the alignment requirement means that the 16-bit version will be
padded to have the same length as the 32-bit version.  Since 32-bit
access is usually faster we might as well get it for free.

> > typedef unsigned int page_offset_t
> 
> the name is a) a little long and b) easy to confuse with pgoff_t as used in
> the pagecache.  I'm not sure what a better name would be.

Alternatively we can put the ifdef around (or inside) the struct definition.

> We probably shouldn't care about this as the networking code didn't handle
> larger offsets either.

I'm not sure what you mean here.

However, for skb_frag_t at least going to the 32-bit version on i386
means at least 72 bytes extra for every skb->data allocation.

Dave, what are your views on making skb_frag_t bigger?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
