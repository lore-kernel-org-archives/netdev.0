From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6
 packets
Date: Mon, 18 Sep 2017 21:19:08 -0700 (PDT)
Message-ID: <20170918.211908.2152170523885516973.davem@davemloft.net>
References: <20170919003904.5124-1-tom@quantonium.net>
        <20170919003904.5124-8-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdISETJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 00:19:09 -0400
In-Reply-To: <20170919003904.5124-8-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 18 Sep 2017 17:38:57 -0700

> @@ -98,6 +104,7 @@ static void pdp_context_delete(struct pdp_ctx *pctx);
>  static inline u32 gtp0_hashfn(u64 tid)
>  {
>  	u32 *tid32 = (u32 *) &tid;
> +
>  	return jhash_2words(tid32[0], tid32[1], gtp_h_initval);
>  }
>  
> @@ -111,6 +118,11 @@ static inline u32 ipv4_hashfn(__be32 ip)
>  	return jhash_1word((__force u32)ip, gtp_h_initval);
>  }
>  
> +static inline u32 ipv6_hashfn(const struct in6_addr *a)
> +{
> +	return __ipv6_addr_jhash(a, gtp_h_initval);
> +}

I know you are just following the pattern of the existing "ipv4_hashfn()" here
but this kind of stuff is not very global namespace friendly.  Even simply
adding a "gtp_" prefix to these hash functions would be a lot better.
