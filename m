From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about tcp_sendmsg()
Date: Thu, 15 Jul 2010 19:15:58 -0700 (PDT)
Message-ID: <20100715.191558.15224017.davem@davemloft.net>
References: <1279199688.2496.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935203Ab0GPCPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:15:43 -0400
In-Reply-To: <1279199688.2496.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Jul 2010 15:14:48 +0200

> While investigating for various bug reports in tcp stack, I looked at
> commit def87cf42069a (tcp: Slightly optimize tcp_sendmsg)
> 
> One question I have is that the 
> 
> sg = sk->sk_route_caps & NETIF_F_SG;
> 
> is now done at the beginning of tcp_sendmsg(), and kept in sg variable
> for the whole tcp_sendmsg() duration, even if task has to wait for
> space.
> 
> Previously sk->sk_route_caps & NETIF_F_SG was done in select_size()
> itself.
> 
> I am wondering if this can have a side effect, if SG capability changes
> while a thread has to wait in sk_stream_wait_memory(), and socket route
> changes (sk_route_caps flips NETIF_F_SG bit)

The consequence of this happening would be that we would linearize the
SKB in the device layer transmit path.

Therefore, to me it seems harmless.  And since such SG capability
changes are so rare, caching the value in this function as we do now
seems reasonable.
