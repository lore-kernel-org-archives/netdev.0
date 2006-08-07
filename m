From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 15:03:33 -0400
Message-ID: <1154977413.5446.83.camel@jzny2>
References: <1154867083.6269.35.camel@jzny2>
	 <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
	 <1154968319.5446.30.camel@jzny2>
	 <20060807170403.GA10818@edgar.underground.se.axis.com>
	 <1154973625.5446.56.camel@jzny2>
	 <20060807184748.GA10909@edgar.underground.se.axis.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:17897 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932312AbWHGTDg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 15:03:36 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GAAO4-00039B-Ug
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 15:03:40 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807184748.GA10909@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 20:47 +0200, Edgar E. Iglesias wrote:

> I think we are out of sync :) 

Imagine that, eh? ;->

> My, fault I haven't been clear enough.
> 

Not just your transmit but also my receive is at fault ;-> (aka, I may
not be listening as well as i should). Now two machines or CPUs you
would think wont have this problem since they dont possess minds;->

> First of all, I don't think the patch with jamal undefined has any problems. I 
> assumed wrongly from the start that you somehow wanted that part to go in 
> aswell, sorry about that. As you say, the flow goes just as before.
> 
> Now, with jamal defined, I only see e1000_prune_tx_ring beeing called if
> fdesc < tx_ring->prunet or fdesc < tx_ring->waket. 

Ok, thats the code that has been commented out, no? i.e there is no
fdesc otherwise.

> In other words, the freing
> of skbs is dependant on external events that might not become true if the
> host is quiet. Skb's could end up sitting on the ring indefinitely.
> 

Yes, this has _always_ been true. In the patch i posted it merely
converted things, example:

-#define E1000_TX_WEIGHT 64
-               /* weight of a sort for tx, to avoid endless transmit
cleanup */
-               if (count++ == E1000_TX_WEIGHT) break;
+               /* avoid endless transmit cleanup */
+               if (count++ == tx_ring->prunet) break;

As you can see E1000_TX_WEIGHT threshold exists today and you are right
if no TX interupts, packet arrivals or scheduled wakes happen the that
descriptor that was not pruned will sit there forever (which is a bad
thing for TCP). Are we in sync?
If yes, what is the likelihood they will sit there forever? I think
perhaps some TX interupts will happen, no?

cheers,
jamal


