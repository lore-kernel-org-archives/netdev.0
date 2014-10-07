From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] icmp6: Add new icmpv6 type for RPL control
 message
Date: Tue, 07 Oct 2014 22:26:30 +0200
Message-ID: <1412713590.11600.5.camel@localhost>
References: <1412591826-32037-1-git-send-email-simon.vincent@xsilon.com>
	 <20141006.181322.2253854250567400185.davem@davemloft.net>
	 <1412639626.712591.175897305.2FA01596@webmail.messagingengine.com>
	 <20141007.155545.116517484203308074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: simon.vincent@xsilon.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:50246 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754562AbaJGU0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:26:32 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 54D5B20994
	for <netdev@vger.kernel.org>; Tue,  7 Oct 2014 16:26:32 -0400 (EDT)
In-Reply-To: <20141007.155545.116517484203308074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-10-07 at 15:55 -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 07 Oct 2014 01:53:46 +0200
> 
> > Might be possible, but I would favor to get rid of the printk or move
> > the test for informational icmp notifications up.
> > Some of the type < 128 icmp (non-informal) packets we also report to
> > user space, so we cannot just add them to a blacklist.
> 
> So basically:
> 
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 141e1f3..97ae700 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -777,12 +777,12 @@ static int icmpv6_rcv(struct sk_buff *skb)
>  		break;
>  
>  	default:
> -		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6: msg of unknown type\n");
> -
>  		/* informational */
>  		if (type & ICMPV6_INFOMSG_MASK)
>  			break;
>  
> +		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6: msg of unknown type\n");
> +
>  		/*
>  		 * error of unknown type.
>  		 * must pass to upper level

Yep, can you take care of this?

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks! :)
