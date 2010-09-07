From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 12:59:47 -0700 (PDT)
Message-ID: <20100907.125947.39192078.davem@davemloft.net>
References: <4C865C21.5010803@ans.pl>
	<1283877391.2313.62.camel@edumazet-laptop>
	<1283887569.2634.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ole@ans.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932136Ab0IGT73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 15:59:29 -0400
In-Reply-To: <1283887569.2634.95.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Sep 2010 21:26:09 +0200

>  	}
> +/*
> + * Should connect() change inet_rcv_saddr ?
> + * It should not IMHO, because we want to specify the peer to which
> + * datagrams are to be sent, regardless of our source address that might
> + * change in the future, after a route change.
> + * To specify our source address, bind() is the right API.
> + */
> +#if 0
>  	if (!inet->inet_saddr)
>  		inet->inet_saddr = rt->rt_src;	/* Update source address */
>  	if (!inet->inet_rcv_saddr)
>  		inet->inet_rcv_saddr = rt->rt_src;
> +#endif
>  	inet->inet_daddr = rt->rt_dst;
>  	inet->inet_dport = usin->sin_port;
>  	sk->sk_state = TCP_ESTABLISHED;

Eric, please just delete the code block instead of leaving it
there inside of an #if 0 block.

If there is information conveyed by the unused code, add that
information to the nice comment you're adding :-)

Thanks.
