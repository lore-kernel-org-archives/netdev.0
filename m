From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
Date: Tue, 26 Mar 2013 17:42:33 +0100
Message-ID: <20130326164233.GG29705@order.stressinduktion.org>
References: <20130204231414.GD6898@order.stressinduktion.org> <20130309214333.GI28531@order.stressinduktion.org> <1362889861.4051.15.camel@edumazet-glaptop> <20130310044043.GB2709@order.stressinduktion.org> <20130311193704.GA24481@order.stressinduktion.org> <20130326001740.GB29705@order.stressinduktion.org> <1364313218.1716.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59711 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564Ab3CZQmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:42:35 -0400
Content-Disposition: inline
In-Reply-To: <1364313218.1716.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 08:53:38AM -0700, Eric Dumazet wrote:
> > This patch also changes the reporting of unix dgram rqueue size, as it
> > now reports not only the size of the first fragment but the amount of
> > readable memory for the socket.
> > 
> > Based on the patches from Yannick Koehler and Cong Wang.
> 
> This opens the possibility of a sender to flood a receiver, instead of
> being blocked by its own sndbuf.

Hm, the sender should get blocked by the receiver's rcvbuf. This opens the
possiblity to flood many receivers at once. But somehow this is the purpose of
this patch. Or am I missing something?

> Do we want such regression ? How many applications might rely on
> existing behavior ?

I tried to not break existing applications. The only way I can think about how
problems could arise would be by applications redoing the buffer calculations
in userspace?

I think it is a bug that a unix dgram socket can trick another dgram
socket into a situation where it cannot accept frames anymore (in case of a
ping-pong protocol).
