From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Mon, 01 Dec 2008 17:45:24 +0100
Message-ID: <493414A4.8010804@hartkopp.net>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>	 <200811271602.16128.opurdila@ixiacom.com>	 <1227799867.16263.517.camel@ecld0pohly>	 <200811272053.10009.opurdila@ixiacom.com> <1228127861.16263.590.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:8699 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710AbYLAQp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 11:45:27 -0500
In-Reply-To: <1228127861.16263.590.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly wrote:
>
> Oliver asked:
>   
>> One additional question for Patrick:
>> As you wrote that your hw timestamp contained in the new skbuff-field is 
>> already cocked ... is there any identifier that tells the userspace 
>> application about the type of hw timestamp he gets (e.g. cocked, raw 
>> registers, offset to whatever, etc.) ?
>>     
>
> In the proposed API the userspace application gets three time stamps:
> software, "cooked" hardware time stamp (converted to nanoseconds by the
> driver, but not tampered with in any other way), hardware time stamp
> converted to system time. Each of these may be missing (not available,
> couldn't be calculated). So yes, the userspace application knows what it
> got and can pick the value that it needs.
>   

That's really fine. Sorry that i did not go that deep into your code 
myself :-]

> Oliver suggested:
>   
>> What about just creating a new pointer in the struct skbuff that points 
>> to a struct hwstamp when it is available OR the pointer is NULL when no 
>> hwstamps are available.
>>     
>
> I like this better than tampering with the data buffer pointers
> implicitly because it enables usages of the additional information
> inside the kernel itself. It's similar to skb_shared_info, except that
> it is not allocated for all skbs.
>
> The skb_shared_info is always at the end of the data buffer. Assume that
> we have a new __netdev_alloc_hw_skb() which increases the allocated data
> buffer to make room for the additional struct hwtstamp (either before
> skb_shared_info or after). I cannot think of a way how the rest of the
> kernel can tell that this additional data is available by just looking
> at the existing head/data/end fields in a skb - if I missed something,
> please let me know.
>
>   

I'm not very familiar with skb fields but hiding this with a new 
__netdev_alloc_hw_skb() looks very good to me and creates a proper way 
to add hw-specific netdevice information in a generic way and - that's 
probably the best news - only when it's really needed.

> So it seems to me that we need the additional 32 bit offset (or pointer,
> on 32 bit architectures) in skb which points towards the struct
> hwtstamp. But that's actually less than the additional 64 bit which hold
> the time stamp value, as in the current patch. I'll give it a few more
> days for further debate, then try out this approach.
>   

I'll be on a business trip until Thursday, so from my side you would get 
a 'go ahead' right now ;-)

Best regards,
Oliver

