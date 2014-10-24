From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Fri, 24 Oct 2014 17:33:15 +0800
Message-ID: <20141024093315.GA18290@gondor.apana.org.au>
References: <5448383A.4090908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5448383A.4090908@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Crestez Dan Leonard <cdleonard@gmail.com> wrote:
>
>> Yep, but the sg stuff does not allow for stack variables. Because of
>> possible offloading and DMA, I dont know...
> A stack buffer is used in tcp_md5_hash_header to add a tcphdr to the 
> hash. A quick grep for sg_init_one find a couple of additional instances 
> of what looks like doing crypto on small stack buffers:

First of all crypto_hash_update is obsolete, don't use it in any
new code.  Thanks for reminding me to get rid of existing users.

You should either use crypto_shash_update for small data, e.g., headers
or crypto_ahash_update for large data such as whole packets.

If you use shash then you may allocate your buffer on the stack.  With
ahash stack memory is not allowed.

I hope this clears things up for you.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
