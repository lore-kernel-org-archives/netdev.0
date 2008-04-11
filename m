From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Fri, 11 Apr 2008 19:35:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804111916590.3759@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
 <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk> <47FF5EB9.2010108@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40699 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760349AbYDKRfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 13:35:25 -0400
In-Reply-To: <47FF5EB9.2010108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2008, Patrick McHardy wrote:

> Jesper Dangaard Brouer wrote:
>> @@ -87,6 +111,16 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32
>>  *rtab, int cell_log, unsigned mt
>>           unsigned sz = ((i+1)<<cell_log);
>>           if (sz < mpu)
>>               sz = mpu;
>>  +        switch (linklayer) {
>>  +        case LINKLAYER_ATM:
>>  +            sz = tc_align_to_atm(sz);
>>  +            break;
>>  +        case LINKLAYER_ETHERNET:
>>  +            // No size adjustments on Ethernet
>>  +            break;
>
> Couldn't this use the ARPHRD values?

It would make it more difficult to expand to new linklayer types.  For 
example I cannot find a define suitable for DOCSIS (cabel modems) (Thats 
next om my list to make DaveM happy ;-))

If we need to use the ARPHRD values (ARPHRD_ATM + ARPHDR_ETHER), I'm 
wondering which "if_arp.h" is the correct to include.

#include <linux/if_arp.h>
  or
#include <net/if_arp.h>

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
