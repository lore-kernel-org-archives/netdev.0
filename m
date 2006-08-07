From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 07 Aug 2006 12:31:59 -0400
Message-ID: <1154968319.5446.30.camel@jzny2>
References: <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2>
	 <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com>
	 <1154955036.5246.32.camel@jzny2>
	 <20060807152126.GL24653@edgar.underground.se.axis.com>
	 <1154965249.5446.15.camel@jzny2>
	 <20060807155929.GM24653@edgar.underground.se.axis.com>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, mchan@broadcom.com,
	shemminger@osdl.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:29706 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S932211AbWHGQcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 12:32:04 -0400
To: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
In-Reply-To: <20060807155929.GM24653@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-08 at 17:59 +0200, Edgar E. Iglesias wrote:

> Ok, I thought you wanted the code inside the ifdefs to be considered. If not,
> I guess there is no problem. Yes, the forwarding case does not suffer from
> any deadlocks issues that I am aware of.
> 

>From my tests:
It does _not_ provide any performance improvements and at some point i decided
i didnt want to add more variables to analyze, so i got rid of it; I would have 
had to hand edit the patch to totally remove it; so that why you still see the 
ifdefed out variant.

> No, the deadlock happens only if you don't prune the descriptors. If the host
> sends some data and then goes quite, fdesc < tx_ring->prunet might not be
> true for a long time and skbs will end up sitting in the tx ring indefinitely,
> charging the socket's sndbuf.
> 

Note: I didnt get rid of the rx path pruning. i.e that is still on. It
just prunes lesser descriptors with that change on the tx. So not very
different from before.

I think i may be getting a gist now of the discussion after a re-read; 
while packets are still charged to TCP may have been transmitted they may sit
on the tx ring forever. They will only be pruned if we had netif_stopped
(and even that is not good enough with Jesse's threshold check) or if a
new packet comes in destined for us. 
Did i understand correctly? If yes, i didnt introduce this challenge it
has always been there. I think i understand the suggestion now from
Dave/Herbert to orphan those skbs... 

cheers,
jamal


