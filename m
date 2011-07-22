From: David Miller <davem@davemloft.net>
Subject: Re: icmp_route_lookup returns wrong source address information
Date: Fri, 22 Jul 2011 00:59:04 -0700 (PDT)
Message-ID: <20110722.005904.2234780049605106051.davem@davemloft.net>
References: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1GVH7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 03:59:12 -0400
In-Reply-To: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 20 Jul 2011 21:22:58 +0200

> With linux-2.6 and net-next trees, whenever an icmp error message is
> sent in response to a to-be-forwarded packet, the destination address
> of the original packet is used as the IP header source address.
> 
> Example:
> $ traceroute breakpoint.cc
> traceroute to breakpoint.cc (85.10.199.196), 30 hops max, 40 byte packets
>  1  chamillionaire.breakpoint.cc (85.10.199.196)  0.476 ms  0.468 ms  0.793 ms
> 
> But the expected 1st hop is 192.168.20.7 in my setup.
> 
> I bisected this down to 77968b78242ee25e2a4d759f0fca8dd52df6d479
> ("ipv4: Pass flow keys down into datagram packet building engine.")
> 
> Specifically, it is caused by this hunk:
 ...
> Problem is that xfrm_decode_session_reverse() may rebuild fl4 from scratch.
> 
> In my setup, "goto relookup_failed" will be hit a bit later on, and fl4->saddr will
> be set to iph->daddr...

Thanks for the detailed report Florian, I'll look into this.
