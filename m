From: David Miller <davem@davemloft.net>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Mon, 03 May 2010 15:23:51 -0700 (PDT)
Message-ID: <20100503.152351.181464355.davem@davemloft.net>
References: <20100503094735.077c2af5@nehalam>
	<1272906266.2226.77.camel@edumazet-laptop>
	<1272907269.2226.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758575Ab0ECWXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:23:45 -0400
In-Reply-To: <1272907269.2226.111.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 May 2010 19:21:09 +0200

>  
> -	/* skb is now orphaned, might be freed outside of locked section */
> -	consume_skb(skb);
> +	/* skb is now orphaned, can be freed outside of locked section */
> +	__kfree_skb(skb);
>  }
>  EXPORT_SYMBOL(skb_free_datagram_locked);

Eric, if you do this you undo the utility of the SKB packet drop tracing
that Neil wrote.

consome_skb() says that the application actually took in the packet and
we didn't drop it due to some error or similar.

Whereas __kfree_skb() is going to be tagged as a packet drop and the
data didn't reach the application.

So if you need to use __kfree_skb() to fix this you'll need to somehow
add some appropriate annotations for the tracer.  Perhaps add a
__consume_skb() that is marked for the tracing stuff and does what
you need.
