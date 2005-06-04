From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 14:40:59 +0400
Message-ID: <20050604144059.2be84671@zanzibar.2ka.mipt.ru>
References: <20050603234623.GA20088@gondor.apana.org.au>
	<20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
	<20050604095854.GA1003@gondor.apana.org.au>
	<20050604141731.37479347@zanzibar.2ka.mipt.ru>
	<20050604102204.GA1214@gondor.apana.org.au>
	<20050604142939.4e2efc55@zanzibar.2ka.mipt.ru>
	<20050604103249.GA1378@gondor.apana.org.au>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        James Morris
 <jmorris@redhat.com>,
        Linux Crypto Mailing List
 <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050604103249.GA1378@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005 20:32:49 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Jun 04, 2005 at 02:29:39PM +0400, Evgeniy Polyakov wrote:
> > 
> > But without sg we sill save 4*sizeof(dma addr) - is it really a price?
> 
> We're also reducing the offset/length to 16 bits from 32 bits so we're
> shaving off half the size.
> 
> > For hardware we will need to remap it later...
> 
> Well we can't modify the supplied scatterlist structure in the
> crypto API anyway since we don't have exclusive ownership of it.
> Since we can't expect the user of the crypto API to do the mapping
> this space is basically wasted.

So why not remove it completely?

Sycnhronous hardware (like VIA/freescale processors) do not use at all
any scaterlists, so it is not needed there.
CryptoAPI does not use half of the scaterlist structure.
CryptoAPI design can not be used with "interruptible" hardware like
HIFN, so for asynchronous hardware we need some kind of remapping
anyway, so why just not to move to the new fragments Herbert introduced
all over the place in CryptoAPI?
But pleaso do not remove skb_to_sgvec() :)

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
