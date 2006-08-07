From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 12:36:57 -0400
Message-ID: <1154968617.5446.42.camel@jzny2>
References: <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807162915.GN24653@edgar.underground.se.axis.com>
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
Received: from mx02.cybersurf.com ([209.197.145.105]:30680 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932247AbWHGRcc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 13:32:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GA8xw-0006LI-2J
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 13:32:36 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807162915.GN24653@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 18:29 +0200, Edgar E. Iglesias wrote:

> Assuming you would get the code inside the jamal ifdefs working without
> deadlocks, you now have a tx_irq function which if fdesc >= tx_ring->prunet
> essentially just checks for hw lockups. Let's speculate and further assume you
> could do the detect_tx_hung from some other context (timer or whatever) then
> you end up having a tx_irq function which most of the time does nothing.
> 
> The next step could be to move the fdesc >= tx_ring->prunet logic into the
> transmit path and completely disable the tx_irq when the condition is not met.
> 
> Now you end up not taking the irq at all as long as fdesc >= tx_ring->prunet.
> 
> This was the logic I tried on the cris driver but ended up with deadlocks :)
> 

Like i said in one of my earlier postings (first email i CCed you on),
this specific test i assumed was as close to what you did. But if i
understand what you describe as "deadlock" then we have a slightly
different problem that can only be solved by orphaning the skbs that are
determined to have been put on the DMA ring ....

cheers,
jamal

