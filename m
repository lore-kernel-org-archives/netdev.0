From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: properly increase rcv_ssthresh for ofo packets
Date: Fri, 06 Sep 2013 14:48:04 -0400 (EDT)
Message-ID: <20130906.144804.670121103659369611.davem@davemloft.net>
References: <1378488958.31445.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab3IFSsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:48:06 -0400
In-Reply-To: <1378488958.31445.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Sep 2013 10:35:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP receive window handling is multi staged.
> 
> A socket has a memory budget, static or dynamic, in sk_rcvbuf.
> 
> Because we do not really know how this memory budget translates to
> a TCP window (payload), TCP announces a small initial window
> (about 20 MSS).
> 
> When a packet is received, we increase TCP rcv_win depending
> on the payload/truesize ratio of this packet. Good citizen
> packets give a hint that it's reasonable to have rcv_win = sk_rcvbuf/2
> 
> This heuristic takes place in tcp_grow_window()
> 
> Problem is : We currently call tcp_grow_window() only for in-order
> packets.
> 
> This means that reorders or packet losses stop proper grow of
> rcv_win, and senders are unable to benefit from fast recovery,
> or proper reordering level detection.
> 
> Really, a packet being stored in OFO queue is not a bad citizen.
> It should be part of the game as in-order packets.
> 
> In our traces, we very often see sender is limited by linux small
> receive windows, even if linux hosts use autotuning (DRS) and should
> allow rcv_win to grow to ~3MB.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied.
