From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] UDP memory accounting and limitation(take 5): memory limitation
Date: Mon, 15 Oct 2007 18:43:06 +0800
Message-ID: <20071015104306.GA30828@gondor.apana.org.au>
References: <470F61D4.6040808@hitachi.com> <470F646F.2030003@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?utf-8?B?IumdkuacqEBSZWRIYXQi?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?utf-8?B?5ZCJ6JekIOiLseaYjg==?= <yoshfuji@linux-ipv6.org>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3412 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757198AbXJOKoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:44:17 -0400
Content-Disposition: inline
In-Reply-To: <470F646F.2030003@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 12, 2007 at 09:11:27PM +0900, Satoshi OSHIMA wrote:
>
> +static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
> +{
> +	switch(sk->sk_protocol) {
> +	case IPPROTO_UDP:
> +		if (sk->sk_prot->sysctl_mem[0] > UDP_MIN_SKB_PAGES)
> +			if (atomic_read(sk->sk_prot->memory_allocated)+size
> +			    >= sk->sk_prot->sysctl_mem[0])
> +				return -ENOBUFS;
> +		/* Fall through */	
> +	default:
> +		break;
> +	}
> +	return 0;
> +}

Since you're not doing a per-user limit, you must give each
socket a minimum even when the total exceeds your threshold.

Otherwise any local user can trivially DoS the whole system.

> +UDP variables:
> +
> +udp_mem - INTERGER
> +	Number of pages allowed for queueing by all UDP sockets.
> +	Minimal value is 4096. If 4096 is set, UDP memory will not
> +	be limited.
> +	Default: 4096

This seems to be a rather confusing setup.  We don't set a
minimum for TCP so is this really necessary?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
