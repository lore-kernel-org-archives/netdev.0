From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] udp: memory limitation by using udp_mem
Date: Thu, 15 Nov 2007 15:23:53 -0800 (PST)
Message-ID: <20071115.152353.100893781.davem@davemloft.net>
References: <473CBDAD.1010708@redhat.com>
	<473CBF16.8040001@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satoshi.oshima.fk@hitachi.com,
	herbert@gondor.apana.org.au, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752232AbXKOXXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:23:54 -0500
In-Reply-To: <473CBF16.8040001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hideo AOKI <haoki@redhat.com>
Date: Thu, 15 Nov 2007 16:50:14 -0500

> +static inline int __ip_check_max_skb_pages(struct sock *sk, int size)
> +{
> +	switch(sk->sk_protocol) {
> +	case IPPROTO_UDP:
> +		if (atomic_read(sk->sk_prot->memory_allocated) + size
> +		    > sk->sk_prot->sysctl_mem[0])
> +			return -ENOBUFS;
> +		/* Fall through */	
> +	default:
> +		break;
> +	}
> +	return 0;
> +}
> +

This check misses UDPLITE, and this whole patch set is a designed in a
way that makes errors like this easy.

These special case checks are all over the place.

We don't have tests all over the place to see if a socket is TCP or
DCCP or SCTP in order to implement memory accounting there, because we
did it for connection oriented protocols cleanly, seperating things
via callbacks etc.

I would like to see the datagram memory accounting work similarly.
