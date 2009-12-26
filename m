From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] net: sock_queue_err_skb() and sk_forward_alloc
 corruption
Date: Fri, 25 Dec 2009 17:29:05 -0800 (PST)
Message-ID: <20091225.172905.104081824.davem@davemloft.net>
References: <20091207090154.6bbfe8e2@nehalam>
	<4B1D8270.20308@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757429AbZLZB3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 20:29:03 -0500
In-Reply-To: <4B1D8270.20308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Dec 2009 23:32:16 +0100

> I wonder if we could use a special version of skb_set_owner_r()/sock_rfree()
> *without* sk_mem_charge()/sk_mem_uncharge() calls for this error queue.
> 
> (We dont call sk_rmem_schedule() anyway, so I guess current usage is not correct,
> even with sock locked ?)
> 
> Something like this (untested but compiled) patch ?
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I think this is legitimate in exactly this kind of case.

The paths where we do these non-charging add, we already just
made sure the receive queue is not over the limit.  Therefore
we won't have possible paths where we can queue error skbs
endlessly and without any controls.

So I'm ok with this approach to fix these bugs.
