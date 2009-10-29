From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Thu, 29 Oct 2009 01:00:09 -0700 (PDT)
Message-ID: <20091029.010009.175904855.davem@davemloft.net>
References: <20091028151313.ba4a4d23.akpm@linux-foundation.org>
	<4AE9298C.1000204@gmail.com>
	<4AE92F4D.6070101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751195AbZJ2H7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 03:59:45 -0400
In-Reply-To: <4AE92F4D.6070101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Oct 2009 06:59:41 +0100

> [PATCH] tcp: clear retrans hints in tcp_send_synack()
> 
> There is a small possibility the skb we unlink from write queue 
> is still referenced by retrans hints.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

So, this would only be true if we were dealing with a data
packet here.  We're not, this is a SYN+ACK which happens to
be cloned in the write queue.

The hint SKBs pointers can only point to real data packets.

And we're only dealing with data packets once we enter established
state, and when we enter established by definition we have unlinked
and freed up any SYN and SYN+ACK SKBs in the write queue.
