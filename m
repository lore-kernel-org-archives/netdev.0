From: Joe Eykholt <jre@nuovasystems.com>
Subject: Re: [PATCH 5/5] net/core: Allow receive on active slaves.
Date: Sat, 19 Jul 2008 21:20:37 -0700
Message-ID: <4882BD15.70303@nuovasystems.com>
References: <486E1B80.7060900@pobox.com>	<20080705.211256.121382294.davem@davemloft.net>	<48704BDA.1000200@nuovasystems.com> <20080705.213818.71574869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:41660 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750706AbYGTEUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 00:20:40 -0400
In-Reply-To: <20080705.213818.71574869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Joe Eykholt <jre@nuovasystems.com>
> Date: Sat, 05 Jul 2008 21:36:42 -0700
> 
>> David Miller wrote:
>>> From: Jeff Garzik <jgarzik@pobox.com>
>>> Date: Fri, 04 Jul 2008 08:45:52 -0400
>>>
>>>> Jay Vosburgh wrote:
>>>>> @@ -2104,7 +2104,8 @@ int netif_receive_skb(struct sk_buff *skb)
>>>>>  #endif
>>>>>  
>>>>>  	list_for_each_entry_rcu(ptype, &ptype_all, list) {
>>>>> -		if (ptype->dev == null_or_orig || ptype->dev == skb->dev) {
>>>>> +		if (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
>>>>> +		    ptype->dev == orig_dev) {
>>>>>  			if (pt_prev)
>>>>>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>>>>>  			pt_prev = ptype;
>>>>> @@ -2129,7 +2130,8 @@ ncls:
>>>>>  	list_for_each_entry_rcu(ptype,
>>>>>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>>>>>  		if (ptype->type == type &&
>>>>> -		    (ptype->dev == null_or_orig || ptype->dev == skb->dev)) {
>>>>> +		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
>>>>> +		     ptype->dev == orig_dev)) {
>>>>>  			if (pt_prev)
>>>> This needs a review&ack from David, then OK...
>>> I fear this bit of the changes will break AF_PACKET device binding.
>>> So for example, if a tap registers it wants to hear eth0, it will now
>>> hear bond0 as well as eth0 if eth0 is a part of bond0.
>> Each ptype will get matched and delivered to at most once.  So if 
>> someone binds AF_PACKET to only eth0, they'll only see the packet once.
>> Whereas before patch 4, the frame wouldn't be delivered to them
>> at all, since skb->dev has already been changed to the bond.
> 
> Ok, that works.
> 
> Jeff, I ACK this patch and the others that go with it:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Is there something more that I need to do to get this integrated?
Do I need to refresh the patches or something?
Will it go in during the next merge window?

	Thanks,
	Joe


