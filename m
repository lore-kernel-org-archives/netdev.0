From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] WAN: converting generic HDLC to use netif_dormant*()
Date: Sun, 16 Jul 2006 14:07:57 +0200
Message-ID: <m3ac79n46a.fsf@defiant.localdomain>
References: <m3veq3suve.fsf@defiant.localdomain>
	<20060712.134632.06531928.davem@davemloft.net>
	<20060713194504.f6c97d47.akpm@osdl.org>
	<20060713.211858.15263760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	paulkf@microgate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:27860 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751030AbWGPMIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 08:08:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060713.211858.15263760.davem@davemloft.net> (David Miller's message of "Thu, 13 Jul 2006 21:18:58 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> WARNING: "hdlc_set_carrier" [drivers/char/synclinkmp.ko] undefined!
>> WARNING: "hdlc_set_carrier" [drivers/char/synclink_gt.ko] undefined!
>> WARNING: "hdlc_set_carrier" [drivers/char/synclink.ko] undefined!
>> WARNING: "hdlc_set_carrier" [drivers/char/pcmcia/synclink_cs.ko] undefined!
>
> Krzysztof please provide a fix for this,

Sure

> this function you added
> calls to does not exist anywhere,

The function doesn't exist anymore, I've removed the calls (but
unfortunately not all of them). Now, instead of hdlc_set_carrier(),
normal netif_carrier_on|off() should be used (it looks like only
synclink drivers and drivers written by me used hdlc_set_carrier()
- other drivers always used netif_carrier_*() only).

> which suggests you either produced
> a patch against a different tree than the current one or you didn't
> even compile test this patch.

Actually I wasn't at the moment aware that there are WAN drivers in
drivers/char (only checked drivers/net).

I'm just posting a patch.
-- 
Krzysztof Halasa
