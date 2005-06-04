From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 19:58:54 +1000
Message-ID: <20050604095854.GA1003@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 01:55:35PM +0400, Evgeniy Polyakov wrote:
> 
> processing code. And you can not easily move away of SA lock due to
> synchronous problems with the same tfm.

This is not true.  The tfm context contains no shared state apart
from the IV.  As the IV can be specified through the *_iv functions,
this allows crypto API users to process the same cipher tfm on two
CPUs in parallel.

If you don't believe me just wait for my upcoming patches to IPsec.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
