From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 23:13:08 +0100
Message-ID: <492F1B74.8000701@hartkopp.net>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <200811271602.16128.opurdila@ixiacom.com> <1227799867.16263.517.camel@ecld0pohly> <200811272053.10009.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>,
	Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:55211 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbYK0WNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 17:13:17 -0500
In-Reply-To: <200811272053.10009.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Thu, 27 Nov 2008 16:31:07 +0100
>
>   
>> On Thu, 2008-11-27 at 14:02 +0000, Octavian Purdila wrote:
>>     
>>> From: Patrick Ohly <patrick.ohly@intel.com>
>>> Date: Thu, 27 Nov 2008 11:07:07 +0100
>>>
>>>       
>>>> To summarize, I see the following options at this time:
>>>>         
>>> [snip]
>>>
>>>       
>>>> My personal preference is, in this order: 3, 4, 2b (current patch,
>>>> but needs clean way to find network device), 1a.
>>>>         
>>> I also vote for 3 (storing hw timestamps in the skb).
>>>
>>>       

4 would be mine.

I assume, we would get kicked somewhere when we are trying to push 
*another* 8 bytes into the skb by default ;-]


> How about this twist: we add a new option at the socket level, to get the 
> whole skb->head - skb->end data into a user buffer. Then, we call an device 
> ioctl and pass this buffer. The device will extract the hw timestamp and give 
> it to the user. 
>
> We might not need to get the whole skb->head - skb->end buffer, maybe just skb-
>   
>> head - skb->mac if we know that skb->mac is sane at the socket level and we 
>>     
> use the convention that the device driver must put the timestamp below the mac 
> header.
>
> One potential problem I see with this approach is leaking sensitive 
> information into userspace, which means we will have to restrict this to 
> privileged processes only.
>
>   

Ugh.

Not every protocol that uses skbuffs, has a mac header (e.g. the CAN 
protocol doesn't have mac addresses). This twist does not look very 
maintainable to me ...

One additional question for Patrick:
As you wrote that your hw timestamp contained in the new skbuff-field is 
already cocked ... is there any identifier that tells the userspace 
application about the type of hw timestamp he gets (e.g. cocked, raw 
registers, offset to whatever, etc.) ?

Regards,
Oliver

