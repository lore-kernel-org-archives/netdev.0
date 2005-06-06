From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 6 Jun 2005 21:59:39 +1000
Message-ID: <20050606115939.GA399@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604112314.GA19819@infradead.org> <20050604112606.GA1799@gondor.apana.org.au> <20050604115853.GA20335@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20050604115853.GA20335@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 12:58:53PM +0100, Christoph Hellwig wrote:
> 
> the usage of 16bit counters in bio_vec doesn't make sense, and if did
> all others would have to move to 32bit aswell (in case we started
> supporting page sizes that aren't addressable by 16bits)

You know what? The more I think about this the more I think that your
idea is brilliant.  The reason is that the two main users of crypto API
happen to be in possession of bio_vec and skb_frag_t respectively.

Had we merged the three structures, they would not have to copy the
structures as they do now or even worse, process the buffers one-by-one
as dmcrypt is doing.

Back to the topic of 16-bit vs. 32-bit counters.  Could we do something
like this?

#if (PAGE_SHIFT > 16) || (BITS_PER_LONG > 32)
typedef unsigned int page_offset_t
#else
typedef unsigned short page_offset_t
#endif

And then define

struct foovec {
	struct page *page;
	page_offset_t offset;
	page_offset_t length;
};

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
