From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 08:26:27 -0700 (PDT)
Message-ID: <20080721.082627.128593651.davem@davemloft.net>
References: <20080721135846.GA11543@gondor.apana.org.au>
	<20080721.080901.214889979.davem@davemloft.net>
	<20080721152220.GA12341@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbYGUP01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:26:27 -0400
In-Reply-To: <20080721152220.GA12341@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 21 Jul 2008 23:22:20 +0800

> On Mon, Jul 21, 2008 at 08:09:01AM -0700, David Miller wrote:
> >
> > > Actually you've hit it on the head, as an alternative to TX hashing
> > > on the packet content, we need to allow TX queue selection based on
> > > the current CPU ID.
> > 
> > This we should avoid, it would allow reordering within a flow.
> 
> Not if the RX hashing is flow-based...

Can you control the process scheduler and where it decides
to run the processing running sendmsg() too?

That's the problem.

It is totally unwise to do CPU based TX hashing.
