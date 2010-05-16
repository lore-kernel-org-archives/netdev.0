From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Sun, 16 May 2010 00:37:19 -0700 (PDT)
Message-ID: <20100516.003719.62329711.davem@davemloft.net>
References: <1273245486.2261.76.camel@edumazet-laptop>
	<1273247090.2261.81.camel@edumazet-laptop>
	<1273267137.2325.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhaskie@gmail.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238Ab0EPHhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 03:37:10 -0400
In-Reply-To: <1273267137.2325.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 May 2010 23:18:57 +0200

> [PATCH] net: Introduce sk_route_nocaps
> 
> TCP-MD5 sessions have intermittent failures, when route cache is
> invalidated. ip_queue_xmit() has to find a new route, calls
> sk_setup_caps(sk, &rt->u.dst), destroying the 
> 
> sk->sk_route_caps &= ~NETIF_F_GSO_MASK
> 
> that MD5 desperately try to make all over its way (from
> tcp_transmit_skb() for example)
> 
> So we send few bad packets, and everything is fine when
> tcp_transmit_skb() is called again for this socket.
> 
> Since ip_queue_xmit() is at a lower level than TCP-MD5, I chose to use a
> socket field, sk_route_nocaps, containing bits to mask on sk_route_caps.
> 
> Reported-by: Bhaskar Dutta <bhaskie@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Since the connection does recover eventually, I'm stuffing this into
net-next-2.6 into net-2.6

After some time in net-next-2.6, we can submit it to -stable.
