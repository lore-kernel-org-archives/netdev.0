From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 08:44:28 +0800
Message-ID: <20090729004428.GA765@gondor.apana.org.au>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53217 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750961AbZG2Aoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 20:44:38 -0400
Content-Disposition: inline
In-Reply-To: <20090728.125919.146001472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 12:59:19PM -0700, David Miller wrote:
>
> The premise is that there'd be only one.  The qdisc lock.
> 
> If the traffic is distributed, flow wise, the driver XMIT
> lock would spread due to multiqueue.

Suppose that we have a single large flow going through that has
filled up the hardware queue and is now backlogged in the qdisc
with qdisc_run on CPU A.   Now some other flow comes along and
sends a packet on CPU B.

So now CPU A and B will both be processing packets for the first
flow causing loads of lock contention.

But worse yet, we have introduced packet reordering.  So are you
convinced now :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
