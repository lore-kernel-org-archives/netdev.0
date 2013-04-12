From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: GSO should be TSQ friendly
Date: Fri, 12 Apr 2013 18:17:49 -0400 (EDT)
Message-ID: <20130412.181749.137416591880112218.davem@davemloft.net>
References: <1365802312.4459.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ycheng@google.com,
	nanditad@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050Ab3DLWRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 18:17:52 -0400
In-Reply-To: <1365802312.4459.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 12 Apr 2013 14:31:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I noticed that TSQ (TCP Small queues) was less effective when TSO is
> turned off, and GSO is on. If BQL is not enabled, TSQ has then no
> effect.
> 
> It turns out the GSO engine frees the original gso_skb at the time the
> fragments are generated and queued to the NIC.
> 
> We should instead call the tcp_wfree() destructor for the last fragment,
> to keep the flow control as intended in TSQ. This effectively limits
> the number of queued packets on qdisc + NIC layers.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good to me, applied, thanks!
