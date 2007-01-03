From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Wed, 03 Jan 2007 16:20:14 +1100
Message-ID: <1167801614.6165.117.camel@localhost.localdomain>
References: <1167800285.6165.105.camel@localhost.localdomain>
	 <20070102.211158.35016452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33982 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbXACFUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 00:20:20 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070102.211158.35016452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Thanks for finding these bugs, although that's really strange pause
> behavior you are seeing on your switches.
> 
> By default, we advertise PAUSE but not ASYM PAUSE in the tg3 driver,
> and I get flow control on every switch I have here.

Yeah, that's strange. I still have the debug values at hand:

 - I advertise 0x5e1
 - I read in LPA 0xc9e1 from the switch
(and my bcm PHY tells me Rx and Tx pause disabled in a separate
register)

Now, I cross-over with a TG3 and I get:

 - I advertise 0x5e1 (hopefully same value)
 - I read in LPA 0xc5e1 from the TG3
(and that other register tells me Rx and Tx pause can be enabled).

> You should try to use flow control, even slower than 1000Mbit links.

Sorry, not sure I parse ;-) You mean allowing pause on 10 and 100 as
well ? I sure can, it's easy to fix.

> That's the only problem I can see, would you mind fixing that and
> I'll put your change into my net-2.6 tree and perhaps play around
> with PAUSE on my switches here?

Sure will do.

Ben.


