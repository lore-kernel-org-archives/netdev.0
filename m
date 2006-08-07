From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 14:00:24 -0400
Message-ID: <1154973625.5446.56.camel@jzny2>
References: <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
	 <1154968319.5446.30.camel@jzny2>
	 <20060807170403.GA10818@edgar.underground.se.axis.com>
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
Received: from mx03.cybersurf.com ([209.197.145.106]:23959 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932256AbWHGSA2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 14:00:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GA9Oy-00067R-ML
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 14:00:32 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807170403.GA10818@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 19:04 +0200, Edgar E. Iglesias wrote:

> 
> I'll give you an example.

Thanks - that matches my understanding.

> A TCP flow sends X data and later waits for a response, host is now quietly
> waiting. Assume fdesc >= tx_ring->prunet, so we dont free any skbs, right?
> 

I am hoping they will be freed by a tx interrupt that will force poll to
happen. Or a new packet arrival etc. Just like before. Why do you see
the two as different? (the tx path pruning is still going on as i noted
before). If all you are looking for is a scheme to quickly free the skbs
so that TCP doesnt get charged, I am not sure if this is the right one.

> Now assume that some part of X data gets lost, our retransmit timer hits and
> we want to retransmit but our socket is charged with too much data sitting on
> the nics tx-ring, so we don't send anything. By orphaning, those skbs won't
> charge the socket and the flow can retransmit.

I understand that as well as the dilemma that TCP not being charged for
skbs (if you decide to orphan) it holds in its retransmit queue ;->
Which is not a problem unless that queueu grows to be a huge one ;->

cheers,
jamal

