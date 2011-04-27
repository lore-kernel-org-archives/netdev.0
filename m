From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Respect 'saddr' and 'daddr' args to
 ip_build_and_send_pkt().
Date: Wed, 27 Apr 2011 14:03:19 -0700 (PDT)
Message-ID: <20110427.140319.39177501.davem@davemloft.net>
References: <20110426.151200.179925027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40076
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752919Ab1D0VDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 17:03:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 880E424C087
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:03:19 -0700 (PDT)
In-Reply-To: <20110426.151200.179925027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 26 Apr 2011 15:12:00 -0700 (PDT)

> 
> This function ignores the passed in addresses and forces their
> settings using rt->rt_dst and rt->rt_src.
> 
> There is never a reason to do this, because the socket of the
> callers of this function must know what addresses it is using.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

I did not end up applying this one to net-next-2.6, it's not correct.
It would break things when the source routing is enabled on the
socket.

When that happens, we look up the route to the SRR options's first
entry, not the actual final destination.  And that initial SRR option
address is the destination IP address we need to use in the IP header
this we need to use rt->rt_{src,dst}.

This could be implemented properly by doing something like:

	if (opt && opt->srr)
		iph->daddr = x;
	else
		iph->daddr = daddr;

I'll think about it.
