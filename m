From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 18:18:22 -0500 (EST)
Message-ID: <20130221.181822.1234155083700257175.davem@davemloft.net>
References: <1361485132.17413.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab3BUXS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 18:18:27 -0500
In-Reply-To: <1361485132.17413.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Feb 2013 14:18:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> It looks like its possible to open thousands of TCP IPv6
> sessions on a server, all landing in a single slot of TCP hash
> table. Incoming packets have to lookup sockets in a very
> long list.
> 
> We should hash all bits from foreign IPv6 addresses, using
> a salt and hash mix, not a simple XOR.
> 
> inet6_ehashfn() can also separately use the ports, instead
> of xoring them.
> 
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, and queued up for -stable, thanks Eric.

I bet we can consolidate this slightly, to make it less
expensive yet not give up much in terms of protection.  Two
jhash3word()'s is quite a lot.
