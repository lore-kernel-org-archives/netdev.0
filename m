From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: immediate send IPI in
 process_backlog()
Date: Thu, 22 Apr 2010 00:21:18 -0700 (PDT)
Message-ID: <20100422.002118.107274505.davem@davemloft.net>
References: <1271883898.7895.3379.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034Ab0DVHVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:21:13 -0400
In-Reply-To: <1271883898.7895.3379.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Apr 2010 23:04:58 +0200

> If some skb are queued to our backlog, we are delaying IPI sending at
> the end of net_rx_action(), increasing latencies. This defeats the
> queueing, since we want to quickly dispatch packets to the pool of
> worker cpus, then eventually deeply process our packets.
> 
> It's better to send IPI before processing our packets in upper layers,
> from process_backlog().
> 
> Change the _and_disable_irq suffix to _and_enable_irq(), since we enable
> local irq in net_rps_action(), sorry for the confusion.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric, irqs are enabled in process_backlog(), so I don't know how legal
it is to invoke net_rps_action_and_irq_enable() from there.

At least, if you are depending upon a later action to pick up the
pieces if the rps_ipi_list test races, you need to update the comment
above net_rps_action_and_irq_enable() since it states that it is
always invoked with IRQs disabled :-)
