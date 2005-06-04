From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 21:26:06 +1000
Message-ID: <20050604112606.GA1799@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604112314.GA19819@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20050604112314.GA19819@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 12:23:14PM +0100, Christoph Hellwig wrote:
> On Sat, Jun 04, 2005 at 09:46:23AM +1000, Herbert Xu wrote:
> > struct crypto_frag {
> > 	struct page *page;
> > 	u16 offset;
> > 	u16 length;
> > };
> 
> we have this structure as skb_frag_struct and bio_vec already, care
> to use the same structure with a generic name for all of them?

I certainly would have no problems merging with skb_frag_struct.
However, merging with bio_vec would mean that either bio_vec would
have to drop down to 16-bit counters, or crypto_frag would have to
move up to 32-bit counters.

The latter is problematic because I'm trying to shrink the size
enough so that we can squeeze four of these things onto the stack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
