From: David Miller <davem@davemloft.net>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 04:10:37 -0800 (PST)
Message-ID: <20090226.041037.134928084.davem@davemloft.net>
References: <20090226093902.GA12753@gondor.apana.org.au>
	<20090226105616.GA5754@ff.dom.local>
	<20090226115604.GA13592@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754804AbZBZMKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 07:10:55 -0500
In-Reply-To: <20090226115604.GA13592@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Feb 2009 19:56:04 +0800

> On Thu, Feb 26, 2009 at 10:56:16AM +0000, Jarek Poplawski wrote:
> > 
> > netconsole. It's a known issue, btw.
> 
> I see.  So the problem in this case appears to be that we're
> processing incoming packets in netpoll_poll.  So the obvious
> question can we just not do that since all we need to do is
> transmit packets?

netpoll supports receiving packets and has a trap handler to eat them
to avoid packets it is interested in going into the real stack.
(netpoll_receive_skb, netpoll_rx_skb, etc.)

I'm pretty sure this has been discussed before. :-)

If I'm not mistaken, we only see this with certain drivers, and the
issue therefore likely has to do with how such drivers implement their
poll handler.

If you do your ->poll_controller() handler without taking IRQ locks,
you're fine.  Or something like that...
