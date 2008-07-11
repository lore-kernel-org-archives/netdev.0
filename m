From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [FIX] ARM: IXP4xx Ethernet NAPI fix
Date: Fri, 11 Jul 2008 21:41:23 +0200
Message-ID: <m3k5fs1a58.fsf@maximus.localdomain>
References: <m31w23ia8n.fsf@maximus.localdomain>
	<20080711121822.2d7bccc0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:34752 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbYGKTl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 15:41:26 -0400
In-Reply-To: <20080711121822.2d7bccc0.akpm@linux-foundation.org> (Andrew Morton's message of "Fri\, 11 Jul 2008 12\:18\:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

>> +++ b/drivers/net/arm/ixp4xx_eth.c
>> @@ -522,7 +522,6 @@ static int eth_poll(struct napi_struct *napi, int budget)
>>  #endif
>>  
>>  		if ((n = queue_get_desc(rxq, port, 0)) < 0) {
>> -			received = 0; /* No packet received */
>>  #if DEBUG_RX
>>  			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
>>  			       dev->name);
>> @@ -543,7 +542,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
>>  			printk(KERN_DEBUG "%s: eth_poll all done\n",
>>  			       dev->name);
>>  #endif
>> -			return 0; /* all work done */
>> +			return received; /* all work done */
>>  		}
>>  
>>  		desc = rx_desc_ptr(port, n);
>
> This is a functional change, and I do not believe that "fixes some
> weirdness" is an adequate description of it.

Well, tried my best :-)

> Please: what was wrong with the old code?

It shouldn't do anything like that, the function has to return the
number of received packets. I.e., it was not up to the NAPI specs. Now
it does what NAPI wants, hopefully. I have no idea why did I put that
in :-(

>  Were the effects user-visible?

I don't know. Actually, for me it works the same before and after the
change.
-- 
Krzysztof Halasa
