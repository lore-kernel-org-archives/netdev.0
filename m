From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 21:14:13 +0200
Message-ID: <20060807191413.GB10909@edgar.underground.se.axis.com>
References: <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com> <1154955036.5246.32.camel@jzny2> <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com> <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com> <1154973625.5446.56.camel@jzny2> <20060807184748.GA10909@edgar.underground.se.axis.com> <1154977413.5446.83.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:57994 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932314AbWHGTOP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 15:14:15 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k77JEDP0029938
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 21:14:13 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154977413.5446.83.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 03:03:33PM -0400, jamal wrote:
> On Mon, 2006-07-08 at 20:47 +0200, Edgar E. Iglesias wrote:
> 
> > I think we are out of sync :) 
> 
> Imagine that, eh? ;->
> 
> > My, fault I haven't been clear enough.
> > 
> 
> Not just your transmit but also my receive is at fault ;-> (aka, I may
> not be listening as well as i should). Now two machines or CPUs you
> would think wont have this problem since they dont possess minds;->
> 
> > First of all, I don't think the patch with jamal undefined has any problems. I 
> > assumed wrongly from the start that you somehow wanted that part to go in 
> > aswell, sorry about that. As you say, the flow goes just as before.
> > 
> > Now, with jamal defined, I only see e1000_prune_tx_ring beeing called if
> > fdesc < tx_ring->prunet or fdesc < tx_ring->waket. 
> 
> Ok, thats the code that has been commented out, no? i.e there is no
> fdesc otherwise.

Exactly.

> 
> > In other words, the freing
> > of skbs is dependant on external events that might not become true if the
> > host is quiet. Skb's could end up sitting on the ring indefinitely.
> > 
> 
> Yes, this has _always_ been true. In the patch i posted it merely
> converted things, example:
> 
> -#define E1000_TX_WEIGHT 64
> -               /* weight of a sort for tx, to avoid endless transmit
> cleanup */
> -               if (count++ == E1000_TX_WEIGHT) break;
> +               /* avoid endless transmit cleanup */
> +               if (count++ == tx_ring->prunet) break;
> 
> As you can see E1000_TX_WEIGHT threshold exists today and you are right
> if no TX interupts, packet arrivals or scheduled wakes happen the that
> descriptor that was not pruned will sit there forever (which is a bad
> thing for TCP). Are we in sync?

Yep :)

> If yes, what is the likelihood they will sit there forever? I think
> perhaps some TX interupts will happen, no?

with jamal undefined, absolutely. With jamal defined, TX interrupts will come
but I couldnt find a way into e1000_prune_tx_ring unless fdesc met the 
conditions. Correct? 

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
