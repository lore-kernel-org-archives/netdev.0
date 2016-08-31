From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ethernet: Use ether_addr_copy rather than memcpy
Date: Wed, 31 Aug 2016 11:32:48 -0700
Message-ID: <1472668368.14381.358.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Rose <grose@lightfleet.com>
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34512 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933845AbcHaScx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 14:32:53 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so22080758pfb.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 11:32:50 -0700 (PDT)
In-Reply-To: <1472661168-22396-1-git-send-email-grose@lightfleet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-31 at 09:32 -0700, Greg Rose wrote:
> I'm not sure why this hasn't been done before because it seems obvious,
> so maybe there is some reason that memcpy is used instead of
> ether_addr_copy in this code.  But let's try this anyway.
> 
> Change memcpy to ether_addr_copy.

...

>  
> @@ -211,7 +211,7 @@ EXPORT_SYMBOL(eth_type_trans);
>  int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
>  {
>  	const struct ethhdr *eth = eth_hdr(skb);
> -	memcpy(haddr, eth->h_source, ETH_ALEN);
> +	ether_addr_copy(haddr, eth->h_source);


Please carefully read ether_addr_copy() comments.

Not all arches are like x86
