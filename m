From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next-2.6] net: speedup sk_wake_async()
Date: Tue, 06 Oct 2009 17:28:46 -0700 (PDT)
Message-ID: <20091006.172846.209818051.davem@davemloft.net>
References: <4ACBCDD8.5000306@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43373
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933528AbZJGA2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:28:51 -0400
In-Reply-To: <4ACBCDD8.5000306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Oct 2009 01:08:08 +0200

> An incoming datagram must bring into cpu cache *lot* of cache lines,
> in particular : (other parts omitted (hash chains, ip route cache...))
> 
> On 32bit arches :
 ...
> We can avoid sk->sk_socket and socket->fasync_list referencing on sockets
> with no fasync() structures. (socket->fasync_list ptr is probably already in cache
> because it shares a cache line with socket->wait, ie location pointed by sk->sk_sleep)
> 
> This avoids one cache line load per incoming packet for common cases (no fasync())
> 
> We can leave (or even move in a future patch) sk->sk_socket in a cold location
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I like it, applied to net-next-2.6, thanks!
