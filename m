From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 13:55:35 +0400
Message-ID: <20050604135535.3cfb631f@zanzibar.2ka.mipt.ru>
References: <20050603234623.GA20088@gondor.apana.org.au>
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
In-Reply-To: <20050603234623.GA20088@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 4 Jun 2005 09:46:23 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi:
> 
> I was looking at how we can move the IPsec input/output processing out
> of the critical section protected by the spin locks on the xfrm_state.
> This is useful because it would allow concurrent processing of IPsec
> packets for the same SA.  It is also necessary if we're ever going to
> add support for asynchronous crypto to IPsec.

Asynchronous schemas already works without any changes to scaterlist 
processing code. And you can not easily move away of SA lock due to
synchronous problems with the same tfm.
Existing asynchronous schemas do not use any shared object in SA,
only skb.

> The first requirement for this is that we need to stop using data that
> is shared across a single SA in the IPsec input/output routines.  The
> biggest hurdle there as it stands is sgbuf in esp_data.  This was
> introduced to reduce stack usage in esp_input/esp_output as sgbuf
> would consume up to 64 bytes of space.

No need to have it at all, I think.

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe linux-crypto" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
