From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 24 Aug 2008 19:26:39 -0400
Message-ID: <20080824192639.587f9391@speedy>
References: <20080822.044248.175133807.davem@davemloft.net>
	<20080822120918.GB14981@ff.dom.local>
	<20080822121144.GA32397@gondor.apana.org.au>
	<20080822.051841.259820995.davem@davemloft.net>
	<20080822124556.GA15788@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52222 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752412AbYHXX0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2008 19:26:45 -0400
In-Reply-To: <20080822124556.GA15788@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2008 22:45:57 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Aug 22, 2008 at 05:18:41AM -0700, David Miller wrote:
> > 
> > Netem is trying to create packet reordering by requeueing (which is
> > logically like a head insert) instead of enqueueing (which is
> > logically like a tail insert).
> 
> Why does it use requeue when tfifo's enqueue will insert this
> at the front of the queue anyway based on time_to_send anyway?
> 
> Perhaps it's trying to force reordering when the user replaces
> tfifo with some other qidsc? But that doesn't make sense since
> netem relies on tfifo to implement all the other features such
> as delay and jitter.
> 
> So how about
> 
> 1) Change netem_graft to disallow the replacement of tfifo;
> 2) Simply use enqueue instead of requeue in netem_enqueue?
> 
> Cheers,


Tfifo is there only to add the jitter based reordering. Netem has other
better kinds of reordering as well.

Netem has to be able to put TBF in as a child qdisc. This is how loss
plus rate control is done.

Requeue was the natural way to do this based on the API's available
at the time.
