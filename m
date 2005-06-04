From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 14:29:39 +0400
Message-ID: <20050604142939.4e2efc55@zanzibar.2ka.mipt.ru>
References: <20050603234623.GA20088@gondor.apana.org.au>
	<20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
	<20050604095854.GA1003@gondor.apana.org.au>
	<20050604141731.37479347@zanzibar.2ka.mipt.ru>
	<20050604102204.GA1214@gondor.apana.org.au>
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
In-Reply-To: <20050604102204.GA1214@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005 20:22:04 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Jun 04, 2005 at 02:17:31PM +0400, Evgeniy Polyakov wrote:
> >
> > Static scaterlists are not used and new are dinamically allocated.
> 
> That's precisely why we're having this discussion.  We can now
> encrypt/decrypt a 1500 byte packet in 2us so the last thing we
> want is to impose additional latencies on the common case unless
> it's absolutely required.
> 
> If we can shrink the structure used between IPsec and the crypto
> layer then we can allocate the sgbuf off the stack for 99% of
> the users.

I do see that 4 sg are enough for 99% of the users, I event think
2 is enough - it will be 8kb, almost the maximum seen 9kb jumbo frame.
But without sg we sill save 4*sizeof(dma addr) - is it really a price?
For hardware we will need to remap it later...

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
