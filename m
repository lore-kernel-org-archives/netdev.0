From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: gro: fix CHECKSUM_COMPLETE support
Date: Mon, 19 May 2014 21:41:53 -0700
Message-ID: <1400560913.5367.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400548164.5367.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:39688 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaETElz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 00:41:55 -0400
Received: by mail-pd0-f178.google.com with SMTP id v10so197963pde.23
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 21:41:55 -0700 (PDT)
In-Reply-To: <1400548164.5367.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-19 at 18:09 -0700, Eric Dumazet wrote:

> @@ -264,13 +263,10 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
>  
>  	NAPI_GRO_CB(skb)->flush |= flush;
>  
> -	csum = skb->csum;
> -	skb_postpull_rcsum(skb, iph, skb_network_header_len(skb));
> +	skb_gro_postpull_rcsum(skb, iph, sizeof(*iph));
>  

sizeof(*iph) doesn't support extension headers. nlen is more appropriate

I'll send a V2
