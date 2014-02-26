From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory accounting for dgram sockets
Date: Wed, 26 Feb 2014 21:21:54 +0100
Message-ID: <20140226202154.GA9626@order.stressinduktion.org>
References: <20140217130353.GA22833@order.stressinduktion.org> <20140219.144927.1558282069067885839.davem@davemloft.net> <20140219200811.GE1179@order.stressinduktion.org> <20140226.145559.1040609936875578841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55161 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaBZUVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:21:55 -0500
Content-Disposition: inline
In-Reply-To: <20140226.145559.1040609936875578841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 02:55:59PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 19 Feb 2014 21:08:11 +0100
> 
> > On Wed, Feb 19, 2014 at 02:49:27PM -0500, David Miller wrote:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Mon, 17 Feb 2014 14:03:53 +0100
> >> 
> >> > We still allocate dgram packets with sock_alloc_send_pskb, which now
> >> > does normally not block if the socket has too many packets in flight.
> >> 
> >> It seems like it does to me, it does sock_wait_for_wmem(), right?
> > 
> > We still do the sock_wait_for_wmem in sock_alloc_send_pskb, correct,
> > but we rarly block there, maybe in highly concurrent cases with big
> > payloads where one process got interrupted to account the memory to the
> > receiving socket.
> > 
> >> Or are you trying to say that usually this is not the point at which
> >> we block, but rather it's when we check the peer's receive queue?
> > 
> > Exactly.
> 
> So my only major objection is that we're now going to incur two atomics
> on every single datagram UNIX packet sent between two peers.

Ok, I see. Daniel Borkmann pointed me to hackbench off-list and I will
do some before/after benchmarks.

> I think you can safely put the 'other' sock pointer into the control
> block.  Because when we disassociate from a peer any pending packets
> in flight to him will be consumed/dropped, so there can't be any
> lingering references, right?

I am afraid lingering socket references will happen if the sockets are
used in unconnected mode.

Greetings,

  Hannes
