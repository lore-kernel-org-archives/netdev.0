From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] af_packet: when sending ethernet frames, parse
 header for skb->protocol
Date: Wed, 31 Jul 2013 17:30:17 -0700 (PDT)
Message-ID: <20130731.173017.624144247713296239.davem@davemloft.net>
References: <20130729165357.GA23134@orbit.nwl.cc>
	<1375291667-9572-1-git-send-email-phil@nwl.cc>
	<1375291667-9572-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab3HAAaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:30:17 -0400
In-Reply-To: <1375291667-9572-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 31 Jul 2013 19:27:45 +0200

> @@ -2324,6 +2328,13 @@ static int packet_snd(struct socket *sock,
>  
>  	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
>  
> +	if (dev->type == ARPHRD_ETHER) {
> +		skb->protocol = eth_type_trans(skb, dev);
> +	} else {
> +		skb->protocol = proto;
> +		skb->dev = dev;
> +	}
> +
>  	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
>  		/* Earlier code assumed this would be a VLAN pkt,
>  		 * double-check this now that we have the actual
> @@ -2338,8 +2349,6 @@ static int packet_snd(struct socket *sock,
>  		}
>  	}
>  
> -	skb->protocol = proto;
> -	skb->dev = dev;
>  	skb->priority = sk->sk_priority;
>  	skb->mark = sk->sk_mark;

I don't see anything explaining why you are avoiding setting skb->dev when
you use eth_type_trans() to set the skb->protocol field.

Also, why isn't the user setting the protocol field correctly?  Isn't
that the _real_ source of these problems?

This patch series cannot be applied as is, it's either wrong, or
explanations are missing from the commit messages.
