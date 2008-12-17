From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 18:53:10 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0812161331270.28806@t2.domain.actdsltmp>
References: <200812161939.30033.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61613 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYLQCyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 21:54:09 -0500
In-Reply-To: <200812161939.30033.tvrtko@ursulin.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Dec 2008, Tvrtko A. Ursulin wrote:
> Does it make any sense from bandwith point of view to bond gigabit and fast
> ethernet?
>
> I wanted to use adaptive-alb mode to load balance both transmit and receive
> direction of traffic but it seems 8139too does not support it so I use
> balance-rr.

My experience from channel bonding in Beowulf clusters, which is now
somewhat dated wrt the current kernel, is that channel bonding with gigabit
didn't work well.

The problem is that at gigabit speeds, one IRQ per packet is very costly. 
So gigabit drivers have to use interrupt mitigation to transfer multiple
packets per interrupt (and/or use jumbo frames to move more data per
packet).

If the transmitter is sending out packets round-robin on two links, it's
sending the packets like this:

Link A:  1   3   5   7
Link B:    2   4   6   8

If the cards return two packets per interrupt, the receiver gets them like
this:

Link A:  1 3     5 7
Link B:      2 4     6 8

Well, the Linux kernel does not like getting the packets in the order (1 3
2 4 5 7 6 8).  It likes to get the packets in the correct order.  And so
performance suffers.  At the time, it suffered greatly.  Maybe it's better
or worse now?
