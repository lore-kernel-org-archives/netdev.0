From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 20:47:48 +0200
Message-ID: <20060807184748.GA10909@edgar.underground.se.axis.com>
References: <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2> <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com> <1154955036.5246.32.camel@jzny2> <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com> <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com> <1154973625.5446.56.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:42221 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932303AbWHGSru
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 14:47:50 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k77IlmP0026379
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:47:48 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154973625.5446.56.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 02:00:24PM -0400, jamal wrote:
> On Mon, 2006-07-08 at 19:04 +0200, Edgar E. Iglesias wrote:
> 
> > 
> > I'll give you an example.
> 
> Thanks - that matches my understanding.
> 
> > A TCP flow sends X data and later waits for a response, host is now quietly
> > waiting. Assume fdesc >= tx_ring->prunet, so we dont free any skbs, right?
> > 
> 
> I am hoping they will be freed by a tx interrupt that will force poll to
> happen. Or a new packet arrival etc. Just like before. Why do you see
> the two as different? (the tx path pruning is still going on as i noted
> before). If all you are looking for is a scheme to quickly free the skbs
> so that TCP doesnt get charged, I am not sure if this is the right one.
> 

I think we are out of sync :) My, fault I haven't been clear enough.

First of all, I don't think the patch with jamal undefined has any problems. I 
assumed wrongly from the start that you somehow wanted that part to go in 
aswell, sorry about that. As you say, the flow goes just as before.

Now, with jamal defined, I only see e1000_prune_tx_ring beeing called if
fdesc < tx_ring->prunet or fdesc < tx_ring->waket. In other words, the freing
of skbs is dependant on external events that might not become true if the
host is quiet. Skb's could end up sitting on the ring indefinitely.

Sorry for the confusion.
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
