From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] datagram: mem_scheudle functions
Date: Sat, 1 Dec 2007 23:09:46 +1100
Message-ID: <20071201120946.GA14368@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB90B.9090107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3024 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752406AbXLAMKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:10:02 -0500
Content-Disposition: inline
In-Reply-To: <474DB90B.9090107@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 28, 2007 at 01:52:59PM -0500, Hideo AOKI wrote:
>
> +static inline int sk_wmem_schedule(struct sock *sk, int size)
> +{
> +	if (sk->sk_type == SOCK_STREAM)
> +		return sk_stream_wmem_schedule(sk, size);
> +	else if (sk->sk_type == SOCK_DGRAM)
> +		return sk_datagram_wmem_schedule(sk, size);
> +	else
> +		return 1;
> +}

Why do we need this function? As far as I can see we always know
whether it's a stream or datagram socket at compile time so doing
a run-time test is pointless.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
