From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 20:32:49 +1000
Message-ID: <20050604103249.GA1378@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604135535.3cfb631f@zanzibar.2ka.mipt.ru> <20050604095854.GA1003@gondor.apana.org.au> <20050604141731.37479347@zanzibar.2ka.mipt.ru> <20050604102204.GA1214@gondor.apana.org.au> <20050604142939.4e2efc55@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050604142939.4e2efc55@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 02:29:39PM +0400, Evgeniy Polyakov wrote:
> 
> But without sg we sill save 4*sizeof(dma addr) - is it really a price?

We're also reducing the offset/length to 16 bits from 32 bits so we're
shaving off half the size.

> For hardware we will need to remap it later...

Well we can't modify the supplied scatterlist structure in the
crypto API anyway since we don't have exclusive ownership of it.
Since we can't expect the user of the crypto API to do the mapping
this space is basically wasted.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
