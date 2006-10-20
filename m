From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 00:15:30 -0700 (PDT)
Message-ID: <20061020.001530.35664340.davem@davemloft.net>
References: <20061019171541.062261760@osdl.org>
	<20061019171814.281988608@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58582
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992534AbWJTHP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:15:28 -0400
To: shemminger@osdl.org
In-Reply-To: <20061019171814.281988608@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 19 Oct 2006 10:15:43 -0700

> The original skb management for netpoll was a mess, it had two queue paths
> and a callback. This changes it to have a per-instance transmit queue
> and use a tasklet rather than a work queue for the congested case.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

I think you mis-diffed this one:

- 	WARN_ON(skb->protocol == 0);

That line doesn't exist in my copy of net/core/netpoll.c
even with your first patch applied.

Also, you forgot to remove the ->drop callback pointer
from struct netpoll, which you should do if it really
isn't used any more.

I think you might run into problems there, as I believe the netdump
stuff does make non-trivial use of the ->drop callback.  Indeed, it
uses the ->dump callback for invoking a special
netpoll_start_netdump() function.  I'm pretty sure ->dump was created
specifically to accomodate netdump.

So this is something else which will need to be worked out before we
can apply this patch.
