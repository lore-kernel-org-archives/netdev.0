From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 26 Aug 2008 08:50:29 -0400
Message-ID: <20080826085029.44a26f56@speedy>
References: <20080822120918.GB14981@ff.dom.local>
	<20080822121144.GA32397@gondor.apana.org.au>
	<20080822.051841.259820995.davem@davemloft.net>
	<20080822124556.GA15788@gondor.apana.org.au>
	<20080824192639.587f9391@speedy>
	<20080824234947.GA19018@gondor.apana.org.au>
	<20080824202922.2cc9b9f6@speedy>
	<20080826073508.GA1039@gondor.apana.org.au>
	<20080826074702.GA1102@gondor.apana.org.au>
	<20080826082455.729662ae@speedy>
	<20080826124153.GA2732@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40808 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664AbYHZMud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 08:50:33 -0400
In-Reply-To: <20080826124153.GA2732@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2008 22:41:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> (Adding Jamal to the cc)
> 
> On Tue, Aug 26, 2008 at 08:24:55AM -0400, Stephen Hemminger wrote:
> > 
> > The problem with netem as child of TBF is that TBF counts the number
> > of packets in the queue to determine the rate. Therefore TBF gets confused
> > about the rate because of the large number of packets that are held in
> > netem when delaying. 
> 
> OK I'm probably missing something.  I can't find any code in TBF
> that looks at the number of packets held in the queue.  All it
> does is look at the dequeued packet and whether we have enough
> tokens to send it right now.
> 
> In any case, looking at the number of packets in the queue sounds
> broken for TBF as the packets could be held in upper-level queues
> which are invisible.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Last time I tried TBF(100kbit) { netem(+100ms) } it gave different answers
than netem(+100ms) { TBF(100kbit) }.  

I would prefer a peek() to the current dequeue/requeue.
An alternative would be to have netem keep a parallel data structure with
the time to send for all packets, but that would be assuming the underlying
qdisc's were work conserving.
