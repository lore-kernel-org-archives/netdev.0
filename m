From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add POLLPRI to sock_def_readable()
Date: Thu, 06 Jan 2011 10:55:00 -0800 (PST)
Message-ID: <20110106.105500.71107144.davem@davemloft.net>
References: <20110106155040.GA27769@libre.l.ngdn.org>
	<1294335897.3074.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leonardo.lists@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915Ab1AFSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:54:29 -0500
In-Reply-To: <1294335897.3074.83.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jan 2011 18:44:57 +0100

> Leonardo Chiquitto found poll() could block forever on tcp sockets and
> Urgent data was received, if the event flag only contains POLLPRI.
> 
> He did a bisection and found commit 4938d7e0233 (poll: avoid extra
> wakeups in select/poll) was the source of the problem.
> 
> Problem is TCP sockets use standard sock_def_readable() function for
> their sk_data_ready() handler, and sock_def_readable() doesnt signal
> POLLPRI.
> 
> Only TCP is affected by the problem. Adding POLLPRI to the list of flags
> might trigger unnecessary schedules, but URGENT handling is such a
> seldom used feature this seems a good compromise.
> 
> Thanks a lot to Leonardo for providing the bisection result and a test
> program as well.
> 
> Reference : http://www.spinics.net/lists/netdev/msg151793.html
> 
> Reported-and-bisected-by: Leonardo Chiquitto <leonardo.lists@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
