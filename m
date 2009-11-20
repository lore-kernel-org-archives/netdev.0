From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 21:51:02 +0100
Message-ID: <87aayg539l.fsf@basil.nowhere.org>
References: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35820 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbZKTUu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:50:57 -0500
In-Reply-To: <4B05D8DC.7020907@gmail.com> (Eric Dumazet's message of "Fri, 20 Nov 2009 00:46:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Here is first version of XPS.
>
> Goal of XPS is to free TX completed skbs by the cpu that submitted the transmit.
>
> Because I chose to union skb->iif with skb->sending_cpu, I chose
> to introduce a new xps_consume_skb(skb), and not generalize consume_skb() itself.
>
> This means that selected drivers must use new function to benefit from XPS
>
> Preliminary tests are quite good, especially on NUMA machines.
>
> Only NAPI drivers can use this new infrastructure (xps_consume_skb() cannot
> be called from hardirq context, only from softirq)
>
> I converted tg3 and pktgen for my tests

Do you have numbers on this? It seems like a lot of effort to avoid transfering
a few cache lines.

-Andi (who is a bit sceptical and would rather see generic work for this in slab)

-- 
ak@linux.intel.com -- Speaking for myself only.
