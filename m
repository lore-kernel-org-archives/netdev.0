From: "Tero Kauppinen (JO/LMF)" <tero.kauppinen@ericsson.com>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Fri, 03 Nov 2006 12:26:45 +0200
Message-ID: <454B1965.5080005@ericsson.com>
References: <4549D8E7.1040409@tcs.hut.fi>	<20061102.215900.15793371.yoshfuji@linux-ipv6.org>	<4549EFA7.50004@tcs.hut.fi> <20061102.231810.119656005.yoshfuji@linux-ipv6.org> <454B0724.1070609@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:57003 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1752877AbWKCK0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 05:26:48 -0500
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <454B0724.1070609@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ville Nuorvala wrote:
> YOSHIFUJI Hideaki wrote:
>> In article <4549EFA7.50004@tcs.hut.fi> (at Thu, 02 Nov 2006 15:16:23 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>>
>>> On 11/02/06 14:59, YOSHIFUJI Hideaki wrote:
>>>> In article <4549D8E7.1040409@tcs.hut.fi> (at Thu, 02 Nov 2006 13:39:19 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>>>>
>>>>>  	read_unlock(&ip6ip6_lock);
>>>>> -	return 1;
>>>>> -
>>>>> +	icmpv6_send(skb, ICMPV6_DEST_UNREACH,
>>>>> +		    ICMPV6_ADDR_UNREACH, 0, skb->dev);
>>>>>  discard:
>>>> I'd argue this.  We probably should not send back any ICMPv6 packets 
>>>> to the original sender in this case to avoid DoS.
>>> Sorry, I don't follow you. I don't see the DoS scenario here (after we
>>> apply the patch, that is ;-).
>> Well, leaving aside whether sending icmpv6 is good thing (*),
>> the code for sending icmpv6 was moved from ip6_tunnel.c
>> to tunnel6.c by commit-id 50fba2aa7cefa6b0e1768cb350c9e69042320c03
>> by Herbert.
>>
>> The ip6_tunnel.c change that Herbert made does not seem consistent
>> with ipip.c change.  To fix your issue the appropriate change is just
>> fall through to discard section, as we're doing for ipip.c.
> 
> Ah, I hadn't noticed Herbert's patch. It actually appears to fix the
> problem I was trying to fix here. AFAIK Tero experienced the infinite
> loop on a 2.6.16 kernel.

Correct, it was a 2.6.16.29 kernel patched with MIPL 2.0.2. The problem 
was obviously not whether an ICMP error was sent or not but that a wrong 
return value was used. However, if that's then already fixed in newer 
kernels where MIPL is included in the source tree, we all can be happy 
again. :)

-- 
Tero
