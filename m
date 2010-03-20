From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ip_gre: include route header_len in max_headroom calculation
Date: Sat, 20 Mar 2010 14:43:25 +0200
Message-ID: <4BA4C2ED.9090701@iki.fi>
References: <1269088078-7343-1-git-send-email-timo.teras@iki.fi> <20100320123736.GC1930@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:56295 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab0CTMn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:43:26 -0400
Received: by ewy8 with SMTP id 8so235605ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 05:43:24 -0700 (PDT)
In-Reply-To: <20100320123736.GC1930@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Mar 20, 2010 at 02:27:58PM +0200, Timo Teras wrote:
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index f47c9f7..f78402d 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -810,11 +810,13 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>>  			tunnel->err_count = 0;
>>  	}
>>  
>> -	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
>> +	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->u.dst.header_len;
>>  
>>  	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
>>  	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
>>  		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
>> +		if (max_headroom > dev->needed_headroom)
>> +			dev->needed_headroom = max_headroom;
> 
> Are you sure about this? LL_RESERVED_SPACE already includes
> dev->needed_headroom so won't this get bigger each time?

Whoops. Must've been after-midnight issue. And not noticed since the
max_headroom won't change many times.

dev->needed_headroom should be compared against gre_hlen+rt->u.dst.header_len.
I'll send a fixed patch in a jiffy.

- timo

