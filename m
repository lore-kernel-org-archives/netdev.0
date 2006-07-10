From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Mon, 10 Jul 2006 14:01:58 +0200
Message-ID: <m33bd9653d.fsf@defiant.localdomain>
References: <44AE2FCC.6020207@trash.net>
	<20060709.114827.63031023.davem@davemloft.net>
	<m3irm6v90o.fsf@defiant.localdomain>
	<200607100817.26635.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:26566 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S964786AbWGJMCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 08:02:00 -0400
To: Stefan Rompf <stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf <stefan@loplof.de> writes:

> You've been asking for two independant flags of which one does not stop the 
> queue.

Actually I asked for only one flag which can be set independently of
others, and which would be visible to userspace. I provided a patch
as well. It didn't break anything. I provided a sample of code
showing usage of the flag. I still have Message-Ids and the actual
messages so don't hesitate to ask if you want to see that again.

Then we had that long discussion with you and Jamal and, I admit,
I said "pass".

> You've got two independant flags of which one does not stop the queue.

Is it ok to set that flag without synchronization with other flags?
I.e, from within another module and without using cross-module locks,
as I've shown at the time? Just asking, I don't know what the final
conclusion was.

I.e., is it ok if the hardware module does netif_carrier_on/off()
(for example, from its IRQ handler) and if the protocol module does
netif_dormant_on/off() independently (for example, from its timer
or linkwatch)?

If it's ok then I'll be happy to implement the support in my drivers
ASAP (this uncertainty was, in fact, the main problem). That should
also mean others things I have on queue (blocked by this issue) would
go upstream.
-- 
Krzysztof Halasa
