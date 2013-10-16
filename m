From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Wed, 16 Oct 2013 17:48:41 +0200
Message-ID: <20131016154841.GC18135@order.stressinduktion.org>
References: <525E6B03.1040409@blub.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Valentijn Sessink <valentyn@blub.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38773 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206Ab3JPPsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:48:42 -0400
Content-Disposition: inline
In-Reply-To: <525E6B03.1040409@blub.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 12:31:31PM +0200, Valentijn Sessink wrote:
> Hello list,
> 
> I'm experiencing difficulties with IPv6 path discovery. The setup is 
> quite simple, a machine with native IPv6, no special routing - let's 
> call it the "server" for now. Unfortunately, I seem to loose 
> connectivity multiple times a day - and after digging in, I found this 
> to be "too big" messages that weren't honored at the server. The network 
> consists of something like:
> 
> server --- hosting --- others ---- SIXXS tunnel with 1280 MTU --- me.
> 
> A "ip -6 route list cache" would show a cached route to my "client", but 
> one without MTU. Then after "ip -6 route flush cache", and after trying 
> to send a large packet (for example issuing "ps uaxww" on an ssh 
> prompt), "ip -6 route list cache" will show a correct MTU.

Oh, thats another very good hint.

> But after a while, things start to go wrong again, and another "ip -6 
> route flush cache" is needed.
> 
> The server is running 3.8.0-something (ubuntu 12.04 with a newer kernel).
> 
> tcpdump shows that on reception of icmpv6 "too big", nothing happens 
> (i.e. the "too big" packet will be sent time and again), and after the 
> "ip -6 route flush cache", suddenly the "too big" message is honored.
> 
> I saw a couple of path discovery issues on this list, more specifically 
> one with the subject "IPv6 path MTU discovery broken" earlier this month 
> - but I'm not sure it's the same issue (because the original submitter 
> specifically mentions kernels 3.10 and 3.11 and has a much more 
> complicated routing table).

I do think these two issues are connected. Could you send me a the
corresponding ip route output and /proc/net/ipv6_route output for when it
works and mtus are correctly handled and when it does not work?

Thanks,

  Hannes
