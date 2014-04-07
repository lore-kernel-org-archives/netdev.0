From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 5/6] net: Call skb_checksum_init in IPv6
Date: Mon, 07 Apr 2014 13:15:12 -0400 (EDT)
Message-ID: <20140407.131512.2218385912431719305.davem@davemloft.net>
References: <alpine.DEB.2.02.1404041721050.21509@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553AbaDGRPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:15:13 -0400
In-Reply-To: <alpine.DEB.2.02.1404041721050.21509@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 4 Apr 2014 17:28:09 -0700 (PDT)

> @@ -62,6 +62,14 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
>  EXPORT_SYMBOL(csum_ipv6_magic);
>  #endif
>  
> +__wsum ip6_pseudo_compute(struct sk_buff *skb, int proto)
> +{
> +	return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +					    &ipv6_hdr(skb)->daddr,
> +					    skb->len, proto, 0));
> +}
> +EXPORT_SYMBOL(ip6_pseudo_compute);

Similarly to the ipv4 case this should really be inline.

I see what the problem is, you've made this now a callback so now it
can't be really inlined any more.

That's really a terrible negative to this set of changes, please see
if you can avoid that and inline all of this exactly how it is done
now in the input paths.

Thanks.
