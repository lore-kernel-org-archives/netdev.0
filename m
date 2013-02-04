From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] State resolution packet queue for IPsec
Date: Mon, 4 Feb 2013 09:25:27 +0100
Message-ID: <20130204082526.GE23291@secunet.com>
References: <20130121094847.GC30530@secunet.com>
 <20130121.161716.752461350033731834.davem@davemloft.net>
 <20130122111029.GF9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33754 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711Ab3BDIZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 03:25:29 -0500
Content-Disposition: inline
In-Reply-To: <20130122111029.GF9147@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 12:10:29PM +0100, Steffen Klassert wrote:
> On Mon, Jan 21, 2013 at 04:17:16PM -0500, David Miller wrote:
> > 
> > This is probably the best way to solve this problem without adding
> > xfrm_state resolution notifications.
> > 
> > But really why would notifications be so bad even if they would not
> > be fine grained?
> > 
> > Any time a state is resolved, any state, you run what you have put
> > currently into this new timer function.
> > 
> 
> When we use state resolution notifiers, we have two problems.
> First, we would probably not dequeue the packets on the same
> cpu we enqueued them, this can introduce packet reorder. The
> timer will at least try to run on the local cpu.
> 
> Second, as you already mentioned, even with state resolution
> notifiers, we don't know if the inserted state is the one we
> need and if our state bundle is complete with this state.
> We would need to do a lookup whenever a state is inserted,
> so we hog the cpu that tries to insert the states we need.
> 
> With the timer, we don't have these two problems for the price
> that we have take a good choice on the relookup intervals.
> Not sure what's better here.
> 

I'd apply the timer version to ipsec-next if there are no objections.
We can still tune it if something does not perform well.
