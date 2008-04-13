From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Sun, 13 Apr 2008 06:44:57 +0200
Message-ID: <48018FC9.9030808@trash.net>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk> <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk> <47FF5EB9.2010108@trash.net> <Pine.LNX.4.64.0804111916590.3759@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65522 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbYDMEpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 00:45:03 -0400
In-Reply-To: <Pine.LNX.4.64.0804111916590.3759@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Fri, 11 Apr 2008, Patrick McHardy wrote:
> 
>> Jesper Dangaard Brouer wrote:
>>> @@ -87,6 +111,16 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32
>>>  *rtab, int cell_log, unsigned mt
>>>           unsigned sz = ((i+1)<<cell_log);
>>>           if (sz < mpu)
>>>               sz = mpu;
>>>  +        switch (linklayer) {
>>>  +        case LINKLAYER_ATM:
>>>  +            sz = tc_align_to_atm(sz);
>>>  +            break;
>>>  +        case LINKLAYER_ETHERNET:
>>>  +            // No size adjustments on Ethernet
>>>  +            break;
>>
>> Couldn't this use the ARPHRD values?
> 
> It would make it more difficult to expand to new linklayer types.  For 
> example I cannot find a define suitable for DOCSIS (cabel modems) (Thats 
> next om my list to make DaveM happy ;-))

Fair enough, I guess ARPHRD is not the perfect match for this.
