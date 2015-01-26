From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: tcp: fix race in IPV6_2292PKTOPTIONS
Date: Mon, 26 Jan 2015 00:44:28 -0800 (PST)
Message-ID: <20150126.004428.66350757054974030.davem@davemloft.net>
References: <1421840742.4832.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbbAZIod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 03:44:33 -0500
In-Reply-To: <1421840742.4832.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Jan 2015 03:45:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> IPv6 TCP sockets store in np->pktoptions skbs, and use skb_set_owner_r()
> to charge the skb to socket.
> 
> It means that destructor must be called while socket is locked.
> 
> Therefore, we cannot use skb_get() or atomic_inc(&skb->users)
> to protect ourselves : kfree_skb() might race with other users
> manipulating sk->sk_forward_alloc
> 
> Fix this race by holding socket lock for the duration of
> ip6_datagram_recv_ctl()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  Since this bug is very old, feel free to apply on net-next ;)

Applied to net-next, thanks Eric.
