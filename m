From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 18:06:47 -0700 (PDT)
Message-ID: <20090728.180647.241258705.davem@davemloft.net>
References: <20090728071247.GA25611@gondor.apana.org.au>
	<20090728.125919.146001472.davem@davemloft.net>
	<20090729004428.GA765@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbZG2BGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 21:06:41 -0400
In-Reply-To: <20090729004428.GA765@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Jul 2009 08:44:28 +0800

> Suppose that we have a single large flow going through that has
> filled up the hardware queue and is now backlogged in the qdisc
> with qdisc_run on CPU A.   Now some other flow comes along and
> sends a packet on CPU B.
> 
> So now CPU A and B will both be processing packets for the first
> flow causing loads of lock contention.
> 
> But worse yet, we have introduced packet reordering.  So are you
> convinced now :)

More interesting to me is the case where the queue is not
filled up, or is very nearly so. :-)

But yes I do see your point.
