From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 11:40:49 -0400
Message-ID: <1154965249.5446.15.camel@jzny2>
References: <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
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
Received: from mx02.cybersurf.com ([209.197.145.105]:47535 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932182AbWHGPky
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 11:40:54 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GA7Dr-0006WA-QW
	for netdev@vger.kernel.org; Mon, 07 Aug 2006 11:40:55 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807152126.GL24653@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2006-07-08 at 17:21 +0200, Edgar E. Iglesias wrote:
[..]
> I have a question regarding your patch. In clean_tx_irq, it seems you dont
> clean the ring unless fdesc < tx_ring->prunet. Won't this cause deadlocks for
> local TCP connections if transmit goes quiet?
> 

I have not tested the TCP case; however, note that the specific part you
reference is commented out. There are no deadlock issues in the case of
forwarding (as in my testcases). 

I did not quiet follow the ensuing discussion after your post:
These descriptors being pruned in the tx path happen only after the
packets have been sent out on the wire. Why would this contribute to a
deadlock but not when it happens on the receive path? It is true that
tcp retransmit queue will still be referencing the skbs, but why is it
any different because in one case it happens in the tx and in the other
on the receive? Is there dependency on waking up the queue?

> It seems to me as if this patch depends on the skb orphaning previously 
> suggested on this thread. Please correct me if I'm wrong.
> 

I didnt quiet follow that discussion I will go back and read it; you
could also answer my questions above to make me understand better.

cheers,
jamal

