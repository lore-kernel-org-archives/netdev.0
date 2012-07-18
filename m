From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: add ipv6_addr_hash() helper
Date: Wed, 18 Jul 2012 06:57:59 -0700
Message-ID: <1342619879.9551.14.camel@joe2Laptop>
References: <1342613334.2626.2504.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50065 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276Ab2GRN6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 09:58:00 -0400
In-Reply-To: <1342613334.2626.2504.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:08 +0200, Eric Dumazet wrote:
> Introduce ipv6_addr_hash() helper doing a XOR on all bits
> of an IPv6 address, with an optimized x86_64 version.
[]
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
[]
> @@ -419,6 +419,19 @@ static inline bool ipv6_addr_any(const struct in6_addr *a)
>  #endif
>  }
>  
> +static inline u32 ipv6_addr_hash(const struct in6_addr *a)
> +{
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
> +	const unsigned long *ul = (const unsigned long *)a;
> +	unsigned long x = ul[0] ^ ul[1];
> +
> +	return x ^ (x >> 32);

Thanks Eric.

Perhaps this would be better with an explicit rather
than implicit cast.
