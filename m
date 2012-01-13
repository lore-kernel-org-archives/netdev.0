From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 17:46:04 +1100
Message-ID: <20120113064604.GA18600@gondor.apana.org.au>
References: <20120111000040.GA3801@p183.telecom.by> <20120111003611.GA12257@gondor.apana.org.au> <20120113062256.GC12501@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120113062256.GC12501@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 07:22:56AM +0100, Steffen Klassert wrote:
>
> I did not try to reproduce, but this looks like a race of the 'local out'
> and the receive packet path. On 'lokal out' bottom halves are enabled,
> so could be interrupted by the NET_RX_SOFTIRQ while doing a sha512_update.
> The NET_RX_SOFTIRQ could invoke sha512_update too, that would corrupt the
> hash value. My guess could be checked easily by disabling the bottom halves
> before the percpu value is fetched.

Good point.  I'll send out a patch for Alexey to test.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
