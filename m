From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPsec] fix process of error from crypto module
Date: Thu, 27 Jan 2005 07:33:38 +1100
Message-ID: <E1Cttr8-0005S6-00@gondolin.me.apana.org.au>
References: <200501261910.20867.kazunori@miyazawa.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org (MIYAZAWA Kazunori)
In-Reply-To: <200501261910.20867.kazunori@miyazawa.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

MIYAZAWA Kazunori <kazunori@miyazawa.org> wrote:
> 
> This patch fixes the process under the case that the crypto module
> returns error because of its weak keys or etc.

Good catch.

> diff -ur a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> --- a/net/ipv6/esp6.c 2004-12-25 06:35:01.000000000 +0900
> +++ b/net/ipv6/esp6.c 2005-01-26 18:57:04.000000000 +0900
> @@ -364,7 +364,8 @@
>    goto error;
>   get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
>  }
> - crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
> + if (crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len))
> +  goto error;
>  x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
>  if (x->props.mode)
>   x->props.header_len += sizeof(struct ipv6hdr);

You need to free esp->conf.ivec here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
