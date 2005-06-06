From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 6 Jun 2005 13:09:14 +0100
Message-ID: <20050606120914.GA8317@infradead.org>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604112314.GA19819@infradead.org> <20050604112606.GA1799@gondor.apana.org.au> <20050604115853.GA20335@infradead.org> <20050606115939.GA399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050606115939.GA399@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 09:59:39PM +1000, Herbert Xu wrote:
> On Sat, Jun 04, 2005 at 12:58:53PM +0100, Christoph Hellwig wrote:
> > 
> > the usage of 16bit counters in bio_vec doesn't make sense, and if did
> > all others would have to move to 32bit aswell (in case we started
> > supporting page sizes that aren't addressable by 16bits)
> 
> You know what? The more I think about this the more I think that your
> idea is brilliant.  The reason is that the two main users of crypto API
> happen to be in possession of bio_vec and skb_frag_t respectively.
> 
> Had we merged the three structures, they would not have to copy the
> structures as they do now or even worse, process the buffers one-by-one
> as dmcrypt is doing.
> 
> Back to the topic of 16-bit vs. 32-bit counters.  Could we do something
> like this?
> 
> #if (PAGE_SHIFT > 16) || (BITS_PER_LONG > 32)

what is the BITS_PER_LONG check for?

> typedef unsigned int page_offset_t
> #else
> typedef unsigned short page_offset_t
> #endif

the name is a) a little long and b) easy to confuse with pgoff_t as used in
the pagecache.  I'm not sure what a better name would be.

We probably shouldn't care about this as the networking code didn't handle
larger offsets either.
