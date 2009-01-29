From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Wed, 28 Jan 2009 17:45:22 -0800 (PST)
Message-ID: <20090128.174522.208349319.davem@davemloft.net>
References: <20090128213141.GD22141@gondor.apana.org.au>
	<20090128.164058.248259991.davem@davemloft.net>
	<20090129013403.GA24043@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40137
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752621AbZA2BpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 20:45:24 -0500
In-Reply-To: <20090129013403.GA24043@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jan 2009 12:34:03 +1100

> So having more TX queues than you have cores (or rather caches)
> isn't all that useful since a single core can only do so much (and a
> single piece of wire can only carry so much data, no matter how many
> queues you place in front of it).

This is already proven to be false :-)

Having more TX queues helps a lot.  Robert's testing confirms
this even when the number of TX queues exceeds the number of
cores.

When Robert directly maps RX queues to a single TX queue on NIU, we
get drops at the qdisc level during his routing tests.  With the TX
queue iterator which causes all of the TX queues to be utilizied there
are no drops.

It would not be one bit surprising to me to see more hardware coming
out with more TX queues than RX queues, for similar reasons.  It's a
real situation and we have more proof that it's likely to continue
than not.

> > One way to deal with this is to grab the hash the chip computed.
> > I'm reluctant to advocate this because it's expensive with NIU
> > because I have to start using the larger RX descriptor layout
> > to get at that cookie.  (see "rx_pkt_hdr0" vs. "rx_pkt_hdr1" in
> > drivers/net/niu.h)
> 
> That's a separate discussion.  The hash would be useful for the
> software multiplexer discussed above, and further processing in
> our stack.  But it isn't all that important with regards to keeping
> the traffic on the core where it arrived.

I see your point.
