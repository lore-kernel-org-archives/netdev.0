From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 09 Sep 2004 09:24:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909.092428.125540781.yoshfuji@linux-ipv6.org>
References: <20040909000330.GA5581@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20040909000330.GA5581@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040909000330.GA5581@gondor.apana.org.au> (at Thu, 9 Sep 2004 10:03:31 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> +       u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
:
> +	/*
> +	 * The following gives us:
> +	 * INET_ECN_ECT_1 => check += __constant_htons(0xFFFD)
> +	 * INET_ECN_ECT_0 => check += __constant_htons(0xFFFE)
> +	 */
> +	if (__constant_htons(1) != 1)
> +		ecn <<= 8;
> +	check += __constant_htons(0xFFFB) + ecn;
> +
>  	iph->check = check + (check>=0xFFFF);
>  	iph->tos |= INET_ECN_CE;
>  }

s/__constant_htons/htons/g here, please.

And, I think 
  u16 ecn = (iph->tos + 1) & INET_ECN_MASK;
:
  check += (u32)htons(0xfffb) + (u32)htons(ecn);

or something like that?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
