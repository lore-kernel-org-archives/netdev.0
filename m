From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 26 Aug 2008 22:56:26 +1000
Message-ID: <20080826125626.GA2933@gondor.apana.org.au>
References: <20080822.051841.259820995.davem@davemloft.net> <20080822124556.GA15788@gondor.apana.org.au> <20080824192639.587f9391@speedy> <20080824234947.GA19018@gondor.apana.org.au> <20080824202922.2cc9b9f6@speedy> <20080826073508.GA1039@gondor.apana.org.au> <20080826074702.GA1102@gondor.apana.org.au> <20080826082455.729662ae@speedy> <20080826124153.GA2732@gondor.apana.org.au> <20080826085029.44a26f56@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48825 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753915AbYHZM4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 08:56:35 -0400
Content-Disposition: inline
In-Reply-To: <20080826085029.44a26f56@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 08:50:29AM -0400, Stephen Hemminger wrote:
>
> Last time I tried TBF(100kbit) { netem(+100ms) } it gave different answers
> than netem(+100ms) { TBF(100kbit) }.  

In what ways were the answers different?

> I would prefer a peek() to the current dequeue/requeue.
> An alternative would be to have netem keep a parallel data structure with
> the time to send for all packets, but that would be assuming the underlying
> qdisc's were work conserving.

The peek() interface isn't really appliacable for netem since the
packet that it's requeueing wasn't dequeued in the first place.

In any case, what I'm trying to say is that netem should really
have its own queue (e.g., just fold tfifo in) to implement the
reordering and delays.

This does not prevent the user from creating children of netem
such as TBF to simulate a network environment where you have
loss/delay/jitter after traffic goes through a shaper.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
