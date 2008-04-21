From: David Miller <davem@davemloft.net>
Subject: Re: poor network loopback performance and scalability
Date: Mon, 21 Apr 2008 01:16:23 -0700 (PDT)
Message-ID: <20080421.011623.67335122.davem@davemloft.net>
References: <E1JnmdQ-0001qO-00@gondolin.me.apana.org.au>
	<20080420.203810.183610437.davem@davemloft.net>
	<20080421081103.GA31328@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	a.p.zijlstra@chello.nl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751587AbYDUIQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 04:16:21 -0400
In-Reply-To: <20080421081103.GA31328@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Apr 2008 10:11:03 +0200

> 
> * David Miller <davem@davemloft.net> wrote:
> 
> > To move things forward, we should look into doing something similar to 
> > what Al Viro suggested, which would be to return an SKB pointer from 
> > the transmit path and call back into netif_receive_skb() using that.
> 
> yep, basically the sk_peer trick that AF_UNIX is already using.

Please read again, that isn't the suggestion being discussed.

What's being discussed is having the top of the transmit call path
getting a socket "buffer" pointer, that it can feed back into the
packet input path directly.  Loopback would return buffer pointers
from ->hard_start_xmit() instead of passing them netif_rx().  The top
of the transmit call path, upon getting a non-NULL buffer returned,
would pass it to netif_receive_skb().

We're not talking about sockets, although that is another idea (which
I'm working on a patch for, and I have a mechanism for what you refer
to as "path validation").
