From: Alex Aizman <alex@neterion.com>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Thu, 04 May 2006 15:49:11 -0700
Message-ID: <445A84E7.1060906@neterion.com>
References: <54AD0F12E08D1541B826BE97C98F99F149E8D5@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	Leonid.Grossman@neterion.com, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:40883 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751446AbWEDWtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 18:49:19 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F149E8D5@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So, what are the requirements? The hardware already parses L2, L3, L4 headers, 
and for the future generation we could add to the set of already supported 
steering/filtering criteria. Having some discussion on the essential vs. 
optional requirements seems like the right thing at this point.

On one hand, this describes what's available:

http://www.spinics.net/lists/netdev/msg04001.html

OTOH, and this is just my opinion - it'd be unrealistic to expect a general 
purpose NIC to offload the entire netfilter. On the third hand, one could 
think of IPsec and/or NAT, and what happens then with the hardware-supported 
filtering. And so on.

There's also a question of relative importance specifically for the Data 
Center environment.

Anyway, discussion would help.

Caitlin Bestler wrote:
> David S. Miller wrote:
>> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>> Date: Wed, 3 May 2006 22:07:40 +0400
>>
>>> On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler
>> (caitlinb@broadcom.com) wrote:
>>>>> I'd expect high end NIC ASICs to implement rx steering based upon
>>>>> some sort of hash (for load balancing), as well as explicit "1:1"
>>>>> steering between a sw channel and a hw channel. Both options for
>>>>> channel configuration are present in the driver interface.
>>>>> If netfilter assists can be done in hardware, I agree the driver
>>>>> interface will need to add support for these - otherwise,
>>>>> netfilter processing will stay above the driver.
>>>>>
>>>>>
>>>> Even if the hardware cannot fully implement netfilter rules there is
>>>> still value in having an interface that documents exactly how much
>>>> filtering a given piece of hardware can do.
>>>> There is no point in having the kernel repeat packet classifications
>>>> that have already been done by the NIC.
>>> Please do not suppose that vj channel must rely on underlaying
>>> hardware. 
>> I am not.  I am just saying that it is futile to build
>> hardware that cannot handle netfilter at least to some
>> extent, because this will result in HW net channels being
>> disabled for %99 of real users which makes the hardware just a waste.
> 
> Or netfilters being disabled, which would be just as bad or worse.
> The kernel and hardware need to co-operate so that users are not
> asked to make artificial choices between performance and security.
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

